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
/* Pager entries are real <a href> links (see renderPager) so they can be opened in a new
   tab or copied; only the disabled ends are inert <button>s. */
.se-pager{display:flex;flex-wrap:wrap;gap:4px;justify-content:center;align-items:center;margin-top:14px;}
.se-pager a,.se-pager button{min-width:32px;padding:6px 9px;border:1px solid #cbd5e1;background:#fff;font-size:12px;cursor:pointer;text-align:center;color:#334155;text-decoration:none;line-height:1.3;font-family:inherit;}
.se-pager a:hover{border-color:#174DA4;color:#174DA4;}
.se-pager a.active{background:#05275C;border-color:#05275C;color:#fff;font-weight:700;}
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
/* Per-campus cards. Clickable: they set the campus filter and re-run the search. */
.se-camps{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:10px;margin-bottom:16px;}
.se-camp{background:#fff;border:1px solid #e0e5ed;border-top:3px solid #05275C;padding:12px 14px;cursor:pointer;transition:border-color .15s,box-shadow .15s;}
.se-camp:hover{border-color:#174DA4;box-shadow:0 2px 10px rgba(5,39,92,.09);}
.se-camp.active{border-color:#174DA4;background:#f7faff;box-shadow:inset 0 0 0 1px #174DA4;}
.se-camp__h{display:flex;align-items:baseline;justify-content:space-between;gap:8px;margin-bottom:9px;}
.se-camp__n{font-size:13.5px;font-weight:800;color:#05275C;}
.se-camp__t{font-size:19px;font-weight:800;color:#05275C;line-height:1;font-variant-numeric:tabular-nums;}
.se-camp__g{display:grid;grid-template-columns:repeat(4,1fr);gap:6px;}
.se-camp__s{text-align:center;padding:5px 2px;background:#f9fafc;border:1px solid #eef2f7;}
.se-camp__sv{font-size:14px;font-weight:800;color:#334155;font-variant-numeric:tabular-nums;}
.se-camp__sl{font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;color:#94a3b8;margin-top:2px;}
.se-camp__bar{height:4px;background:#eef2f7;margin-top:9px;overflow:hidden;}
.se-camp__fill{height:100%;background:#16a34a;width:0;transition:width .4s ease;}
.se-camp__pct{font-size:10px;color:#64748b;margin-top:4px;font-weight:600;}
/* Email suggestions in the create modal */
.se-sug{background:#f7faff;border:1px solid #dbe6f5;padding:10px 12px;margin-bottom:12px;}
.se-sug__h{font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:#64748b;margin-bottom:7px;}
.se-sug__r{display:flex;align-items:center;gap:7px;margin-bottom:6px;}
.se-sug__r:last-child{margin-bottom:0;}
.se-sug__v{flex:1 1 auto;min-width:0;font-size:13px;font-weight:700;color:#05275C;font-family:Consolas,"Courier New",monospace;word-break:break-all;cursor:pointer;}
.se-sug__v:hover{text-decoration:underline;}
.se-cp{flex:0 0 auto;display:inline-flex;align-items:center;justify-content:center;width:26px;height:26px;border:1px solid #cbd5e1;background:#fff;color:#475569;cursor:pointer;padding:0;}
.se-cp:hover{border-color:#174DA4;color:#174DA4;}
.se-cp.ok{border-color:#16a34a;color:#16a34a;}
.se-use{flex:0 0 auto;border:1px solid #cbd5e1;background:#fff;color:#174DA4;font-size:10.5px;font-weight:700;padding:5px 8px;cursor:pointer;}
.se-use:hover{border-color:#174DA4;background:#174DA4;color:#fff;}
.se-fi--row{display:flex;gap:7px;align-items:center;}
.se-fi--row .se-fi{flex:1 1 auto;min-width:0;}
@media(max-width:640px){.se-wrap{padding:12px;}.se-camps{grid-template-columns:1fr;}}
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

    <!-- Per-campus breakdown. Clicking a card filters the pipeline to that campus, so the
         numbers are a way in rather than just a readout. -->
    <div class="se-camps" id="camps"></div>

    <div class="se-msg" id="topMsg"></div>

    <div class="se-tabs">
        <div class="se-tab active" id="tabPipe" onclick="setTab('pipe')">Pipeline</div>
        <div class="se-tab" id="tabCand" onclick="setTab('cand')">Candidates</div>
        <div class="se-tab" id="tabComp" onclick="setTab('comp')">Complaints</div>
    </div>

    <!-- Pipeline -->
    <div id="paneP">
        <div class="se-toolbar">
            <input type="text" id="fq" class="se-in" placeholder="Search name, student number, reg no or email &mdash; any order&hellip;" />
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
            <select id="fCampus" class="se-sel"><option value="">All campuses</option></select>
            <select id="fProg" class="se-sel"><option value="">All programmes</option></select>
            <select id="fPs" class="se-sel" title="Rows per page">
                <option value="25">25 / page</option>
                <option value="50">50 / page</option>
                <option value="100">100 / page</option>
                <option value="200">200 / page</option>
            </select>
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

        <!-- Suggested addresses, built from the student's own name + intake year.
             Click the address (or "Use") to drop it into the field; the icon copies it. -->
        <div class="se-sug" id="mSug">
            <div class="se-sug__h">Suggested addresses</div>
            <div class="se-sug__r">
                <span class="se-sug__v" id="sug1" title="Click to use this address" onclick="useSug(1)">&mdash;</span>
                <button type="button" class="se-use" onclick="useSug(1)">Use</button>
                <button type="button" class="se-cp" id="cp1" title="Copy" onclick="copyVal('sug1','cp1')"></button>
            </div>
            <div class="se-sug__r">
                <span class="se-sug__v" id="sug2" title="Click to use this address" onclick="useSug(2)">&mdash;</span>
                <button type="button" class="se-use" onclick="useSug(2)">Use</button>
                <button type="button" class="se-cp" id="cp2" title="Copy" onclick="copyVal('sug2','cp2')"></button>
            </div>
        </div>

        <label class="se-fl">University email address</label>
        <input type="text" id="mEmail" class="se-fi" placeholder="e.g. jdoe26@mru.ac.ug" autocomplete="off" />
        <label class="se-fl">Temporary password</label>
        <div class="se-fi--row">
            <input type="text" id="mPw" class="se-fi" autocomplete="off" />
            <button type="button" class="se-cp" id="cpPw" title="Copy password" onclick="copyVal('mPw','cpPw')"></button>
        </div>
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
var st={q:'',stage:'',verif:'',prog:'',campus:'',page:1,ps:25};
function qs(id){return document.getElementById(id);}
function esc(s){return s?String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'):'';}
function fmt(n){return (parseInt(n,10)||0).toLocaleString('en-US');}
function ajax(m,p,cb){var x=new XMLHttpRequest();x.open('POST','StudentEmailController.aspx/'+m,true);x.setRequestHeader('Content-Type','application/json; charset=utf-8');x.onload=function(){try{var o=JSON.parse(x.responseText);cb(typeof o.d==='string'?JSON.parse(o.d):o.d);}catch(e){cb({success:false,message:'Parse error'});}};x.onerror=function(){cb({success:false,message:'Network error'});};x.send(JSON.stringify(p||{}));}
function topMsg(m,ok){var e=qs('topMsg');e.textContent=m;e.className='se-msg '+(ok?'se-msg--ok':'se-msg--err');e.style.display='block';setTimeout(function(){e.style.display='none';},5000);}

// URL state
var PAGE_SIZES=[25,50,100,200];   // 200 is the server-side ceiling in SemsAdmin.Search

function readUrl(){
    var u=new URLSearchParams(location.search||'');
    st.q=u.get('q')||'';st.stage=u.get('stage')||'';st.verif=u.get('verif')||'';
    st.prog=u.get('prog')||'';st.campus=u.get('campus')||'';
    st.page=Math.max(1,parseInt(u.get('page'),10)||1);
    var ps=parseInt(u.get('ps'),10)||25;
    st.ps=(PAGE_SIZES.indexOf(ps)>=0)?ps:25;
}

// Build a real, complete URL for any state — this is what the pager anchors point at, so
// every page is a genuine GET address: bookmarkable, shareable, and openable in a new tab.
function buildUrl(o){
    o=o||{};
    function pick(k){return (k in o)?o[k]:st[k];}
    var u=new URLSearchParams();
    var q=pick('q'),stage=pick('stage'),verif=pick('verif'),prog=pick('prog'),campus=pick('campus'),
        page=pick('page'),ps=pick('ps');
    if(q)u.set('q',q); if(stage)u.set('stage',stage); if(verif)u.set('verif',verif);
    if(prog)u.set('prog',prog); if(campus)u.set('campus',campus);
    if(page>1)u.set('page',page);
    if(ps&&ps!==25)u.set('ps',ps);
    var s=u.toString();
    return location.pathname+(s?('?'+s):'');
}

// pushState (not replaceState) so Back genuinely walks the pages the user visited.
function syncUrl(push){
    var url=buildUrl({});
    if(url===location.pathname+location.search) return;      // nothing changed; don't stack duplicates
    try{ push?history.pushState(null,'',url):history.replaceState(null,'',url); }catch(e){}
}

// Back / Forward re-render from the URL alone, which is the real test of GET-driven state.
window.addEventListener('popstate',function(){
    readUrl();
    qs('fq').value=st.q;qs('fStage').value=st.stage;qs('fVerif').value=st.verif;
    qs('fProg').value=st.prog;qs('fCampus').value=st.campus;
    var sel=qs('fPs'); if(sel) sel.value=String(st.ps);
    runSearch(false);
});

function loadKpis(){ajax('Stats',{},function(r){if(!r||!r.success)return;var k=[['eligible','Eligible (100k+)','info'],['partial','Paid < 100k','warn'],['total','In Pipeline',''],['pending','Pending','warn'],['ready','Ready','ready'],['quiz','Quiz Passed','info'],['activated','Activated','ok'],['completed','Completed','ok'],['complaints','Open Complaints','warn'],['successRate','Success %','ok']];var h='';k.forEach(function(x){var raw=r[x[0]];var disp=(x[0]==='successRate')?((raw||0)+'%'):fmt(raw);h+='<div class="se-kpi'+(x[2]?' se-kpi--'+x[2]:'')+'"><div class="se-kpi__v">'+disp+'</div><div class="se-kpi__l">'+x[1]+'</div></div>';});qs('kpis').innerHTML=h;renderCampuses(r.campuses);});}

// Per-campus cards: headline total, the four stages that matter, and completion progress.
function renderCampuses(list){
    var el=qs('camps'); if(!el) return;
    if(!list||!list.length){el.innerHTML='';return;}
    var h='';
    list.forEach(function(c){
        var pct=parseFloat(c.successRate)||0;
        h+='<div class="se-camp" data-code="'+esc(c.code)+'" onclick="pickCampus(\''+esc(c.code)+'\')" title="Filter the pipeline to '+esc(c.name)+'">'
          +  '<div class="se-camp__h"><span class="se-camp__n">'+esc(c.name)+'</span><span class="se-camp__t">'+fmt(c.total)+'</span></div>'
          +  '<div class="se-camp__g">'
          +    '<div class="se-camp__s"><div class="se-camp__sv">'+fmt(c.pending)+'</div><div class="se-camp__sl">Pending</div></div>'
          +    '<div class="se-camp__s"><div class="se-camp__sv">'+fmt(c.ready)+'</div><div class="se-camp__sl">Ready</div></div>'
          +    '<div class="se-camp__s"><div class="se-camp__sv">'+fmt(c.verified)+'</div><div class="se-camp__sl">Verified</div></div>'
          +    '<div class="se-camp__s"><div class="se-camp__sv">'+fmt(c.completed)+'</div><div class="se-camp__sl">Done</div></div>'
          +  '</div>'
          +  '<div class="se-camp__bar"><div class="se-camp__fill" style="width:'+pct+'%"></div></div>'
          +  '<div class="se-camp__pct">'+pct+'% completed</div>'
          +'</div>';
    });
    el.innerHTML=h;
    markActiveCampus();
}
function payBadge(p){p=parseInt(p,10)||0;var c=p>=100000?'full':(p>0?'part':'none');return '<span class="se-pay se-pay--'+c+'">'+(p>0?('UGX '+fmt(p)):'—')+'</span>';}

function stageBadge(s){var m={PENDING_CREATION:['pending','Pending creation'],READY_FOR_COLLECTION:['ready','Ready for collection'],EMAIL_CREATED:['ready','Email created'],COMPLETED:['done','Completed']};var x=m[s]||['muted',s||'-'];return '<span class="se-badge se-b--'+x[0]+'">'+esc(x[1])+'</span>';}

// Reads the filter controls, then searches. Called by the Search button and the filters.
window.doSearch=function(page){
    st.q=qs('fq').value.trim();st.stage=qs('fStage').value;st.verif=qs('fVerif').value;
    st.prog=qs('fProg').value;st.campus=qs('fCampus').value;
    var sel=qs('fPs'); if(sel) st.ps=parseInt(sel.value,10)||25;
    st.page=page||1;
    runSearch(true);
};

// Jump to a page without re-reading the controls (used by the pager anchors).
window.goPage=function(p){ st.page=Math.max(1,p||1); runSearch(true); return false; };

// Only the newest in-flight search may paint. Without this, typing quickly could let a
// slower earlier response land last and overwrite the results for what you actually typed.
var _seq=0;

function runSearch(push){
    syncUrl(push);
    markActiveCampus();
    var mine=++_seq;
    qs('pMeta').textContent='Loading…';
    ajax('Search',{q:st.q,stage:st.stage,campus:st.campus,programme:st.prog,year:'',verification:st.verif,page:st.page,pageSize:st.ps},function(r){
        if(mine!==_seq) return;                       // a newer search has already been issued
        if(!r||!r.success){qs('pMeta').textContent=(r&&r.message)||'Error';return;}
        st.page=r.page;                               // server clamps out-of-range pages
        var from=r.total?((r.page-1)*r.pageSize+1):0, to=Math.min(r.page*r.pageSize,r.total);
        qs('pMeta').textContent=r.total
            ? ('Showing '+fmt(from)+'–'+fmt(to)+' of '+fmt(r.total)+' student'+(r.total===1?'':'s')+(r.pageCount>1?(' · page '+r.page+' of '+r.pageCount):''))
            : 'No students match these filters.';
        var b=qs('pBody');b.innerHTML='';qs('pEmpty').style.display=r.rows.length?'none':'block';
        r.rows.forEach(function(x){var canCreate=(x.stage==='PENDING_CREATION');var rg=x.regno.replace(/'/g,"");var tr=document.createElement('tr');
         tr.innerHTML='<td><strong>'+esc(x.name||'-')+'</strong></td><td>'+esc(x.regno)+'</td><td>'+esc(x.programme||'-')+'</td><td>'+esc(x.campus)+'</td><td>'+esc(x.year)+'</td><td>'+payBadge(x.paid)+'</td><td>'+(x.email?esc(x.email):'<span style="color:#cbd5e1">—</span>')+'</td><td>'+stageBadge(x.stage)+'</td><td>'+(x.verification==='VERIFIED'?'<span class="se-badge se-b--verified">Verified</span>':'<span class="se-badge se-b--muted">—</span>')+'</td><td style="color:#94a3b8">'+esc(x.updated||x.created)+'</td><td style="white-space:nowrap">'+(canCreate?'<span class="se-act" onclick="openCreate(\''+rg+'\',\''+esc(x.name).replace(/'/g,"")+'\',\''+esc(x.year)+'\')">Create</span> · ':'')+'<span class="se-act" onclick="openManage(\''+rg+'\')">Manage</span></td>';
         b.appendChild(tr);});
        renderPager(r.page,r.pageCount);
    });
}

// Pager built from real anchors, so every page number is a working link (middle-click,
// open-in-new-tab, copy-address all behave) while a left-click stays on the AJAX path.
// Window is 9 wide with First/Last, rather than the previous 5 with no jump to the ends.
function renderPager(page,pc){
    var el=qs('pPager');el.innerHTML='';
    if(pc<=1)return;
    function link(label,pg,disabled,active,title){
        if(disabled){var s=document.createElement('button');s.textContent=label;s.disabled=true;el.appendChild(s);return;}
        var a=document.createElement('a');
        a.href=buildUrl({page:pg});
        a.textContent=label;
        if(title)a.title=title;
        if(active)a.className='active';
        a.onclick=function(ev){
            if(ev.metaKey||ev.ctrlKey||ev.shiftKey||ev.button===1) return true;  // let the browser open it
            ev.preventDefault();goPage(pg);return false;
        };
        el.appendChild(a);
    }
    link('« First',1,page<=1,false,'First page');
    link('‹ Prev',page-1,page<=1,false,'Previous page');
    var span=9, half=Math.floor(span/2);
    var f=Math.max(1,page-half), t=Math.min(pc,f+span-1);
    if(t-f+1<span) f=Math.max(1,t-span+1);
    if(f>1) el.appendChild(document.createTextNode('…'));
    for(var i=f;i<=t;i++) link(String(i),i,false,i===page);
    if(t<pc) el.appendChild(document.createTextNode('…'));
    link('Next ›',page+1,page>=pc,false,'Next page');
    link('Last »',pc,page>=pc,false,'Last page');
}
window.resetF=function(){qs('fq').value='';qs('fStage').value='';qs('fVerif').value='';qs('fProg').value='';qs('fCampus').value='';var sel=qs('fPs');if(sel)sel.value='25';st={q:'',stage:'',verif:'',prog:'',campus:'',page:1,ps:25};runSearch(true);};

// Clicking a campus card is just another way to set the filter — it drives the same
// dropdown and the same search, so the two can never disagree.
window.pickCampus=function(code){
    qs('fCampus').value=(st.campus===code)?'':code;   // click the active card again to clear
    doSearch(1);
    var t=qs('paneP'); if(t&&t.scrollIntoView) t.scrollIntoView({behavior:'smooth',block:'nearest'});
};
function markActiveCampus(){
    var cards=document.querySelectorAll('.se-camp');
    for(var i=0;i<cards.length;i++)
        cards[i].className='se-camp'+(cards[i].getAttribute('data-code')===st.campus&&st.campus?' active':'');
}

window.genEligible=function(){var btn=qs('btnGen');btn.disabled=true;btn.textContent='Generating…';ajax('GenerateEligible',{},function(r){btn.disabled=false;btn.innerHTML='<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg> Generate Eligible Students';if(r&&r.success){topMsg(r.message,true);loadKpis();doSearch(1);}else topMsg((r&&r.message)||'Failed',false);});};

// ── Create modal ────────────────────────────────────────────────────────────
var _cReg='';
var DEFAULT_PW='mru123456';   // house default; the field is pre-filled with it and editable

// Strip anything that can't live in the local part of an address, and lowercase it.
function slug(s){return String(s||'').toLowerCase().replace(/[^a-z]/g,'');}

// Two house formats, both suffixed with the last two digits of the intake year:
//   1. firstname + first letter of surname      e.g. wilberforces26@mru.ac.ug
//   2. surname   + first letter of first name   e.g. ssentongow26@mru.ac.ug
// Names are stored as "FIRSTNAME SURNAME", so the first token is the given name and the
// last token is the family name. Middle names are ignored.
function buildSug(name,year){
    var parts=String(name||'').trim().split(/\s+/).filter(Boolean);
    var first=slug(parts[0]), last=slug(parts.length>1?parts[parts.length-1]:'');
    var yy=String(year||'').replace(/\D/g,'');
    yy=yy.length>=2?yy.slice(-2):yy;
    if(!first&&!last) return ['',''];
    // With only one usable name token, fall back to that token + year rather than
    // inventing an initial from nothing.
    if(!last)  return [first+yy+'@mru.ac.ug', first+yy+'@mru.ac.ug'];
    if(!first) return [last+yy+'@mru.ac.ug',  last+yy+'@mru.ac.ug'];
    return [first+last.charAt(0)+yy+'@mru.ac.ug', last+first.charAt(0)+yy+'@mru.ac.ug'];
}

var ICON_COPY='<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>';
var ICON_OK  ='<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg>';

// Copy helper. execCommand is the fallback because navigator.clipboard is unavailable
// on plain-HTTP origins, and this console is reached over http internally.
function copyText(t){
    if(!t) return false;
    if(navigator.clipboard&&window.isSecureContext){navigator.clipboard.writeText(t);return true;}
    var ta=document.createElement('textarea');
    ta.value=t;ta.setAttribute('readonly','');ta.style.position='fixed';ta.style.top='-1000px';
    document.body.appendChild(ta);ta.select();
    var ok=false;try{ok=document.execCommand('copy');}catch(e){ok=false;}
    document.body.removeChild(ta);return ok;
}
window.copyVal=function(srcId,btnId){
    var el=qs(srcId);if(!el)return;
    var val=(el.tagName==='INPUT')?el.value:el.textContent;
    val=String(val||'').trim();
    if(!val||val==='—')return;
    var b=qs(btnId);
    if(copyText(val)){
        b.innerHTML=ICON_OK;b.classList.add('ok');b.title='Copied';
        setTimeout(function(){b.innerHTML=ICON_COPY;b.classList.remove('ok');b.title='Copy';},1400);
    }
};
window.useSug=function(n){
    var v=qs('sug'+n).textContent.trim();
    if(v&&v!=='—'){qs('mEmail').value=v;qs('mEmail').focus();}
};

window.openCreate=function(reg,name,year){
    _cReg=reg;
    qs('mWho').textContent=name+' · '+reg;
    qs('mEmail').value='';
    qs('mPw').value=DEFAULT_PW;                  // pre-filled, still editable
    qs('mNotes').value='';
    qs('mMsg').style.display='none';
    qs('cp1').innerHTML=ICON_COPY;qs('cp2').innerHTML=ICON_COPY;qs('cpPw').innerHTML=ICON_COPY;
    qs('cp1').classList.remove('ok');qs('cp2').classList.remove('ok');qs('cpPw').classList.remove('ok');
    var s=buildSug(name,year);
    qs('sug1').textContent=s[0]||'—';
    qs('sug2').textContent=s[1]||'—';
    qs('mSug').style.display=(s[0]||s[1])?'block':'none';
    qs('ov').style.display='block';qs('mCreate').style.display='block';
};
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
  +(d.stage==='PENDING_CREATION'?'<button type="button" class="g-abtn g-abtn--p" onclick="closeM();openCreate(\''+_gReg+'\',\''+esc(d.name).replace(/\x27/g,"")+'\',\''+esc(d.year)+'\')">Create email</button>':'')
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
window.gPw=function(){var p=prompt('New temporary password for this student:',DEFAULT_PW);if(!p||!p.trim())return;ajax('SetPassword',{regno:_gReg,tempPw:p.trim()},function(r){if(r&&r.success){topMsg(r.message,true);openManage(_gReg);}else topMsg((r&&r.message)||'Failed',false);});};
window.gDel=function(){if(!confirm('Remove '+_gReg+' from the email pipeline? This deletes the record.'))return;var note=prompt('Reason (optional):','')||'';ajax('DeleteRecord',{regno:_gReg,note:note},function(r){if(r&&r.success){closeM();topMsg(r.message,true);loadKpis();doSearch(st.page);}else topMsg((r&&r.message)||'Failed',false);});};

// Complaints
var _rId=0;
window.loadComplaints=function(){ajax('Complaints',{status:qs('cStatus').value},function(r){var b=qs('cBody');b.innerHTML='';if(!r||!r.success){return;}qs('cEmpty').style.display=r.complaints.length?'none':'block';r.complaints.forEach(function(c){var tr=document.createElement('tr');tr.innerHTML='<td><strong>'+esc(c.regno)+'</strong></td><td>'+esc(c.category)+'</td><td style="max-width:280px">'+esc(c.description||'')+'</td><td><span class="se-badge se-b--'+(c.status==='RESOLVED'||c.status==='CLOSED'?'done':'ready')+'">'+esc(c.status)+'</span></td><td style="color:#94a3b8">'+esc(c.created)+'</td><td><span class="se-act" onclick="openResp('+c.id+',\''+esc(c.regno)+'\',\''+esc(c.category)+'\')">Respond</span></td>';b.appendChild(tr);});});};
window.openResp=function(id,reg,cat){_rId=id;qs('rWho').textContent=reg+' · '+cat;qs('rText').value='';qs('rMsg').style.display='none';qs('ov').style.display='block';qs('mResp').style.display='block';};
window.saveResp=function(){ajax('RespondComplaint',{id:_rId,status:qs('rStatus').value,response:qs('rText').value.trim()},function(r){if(r&&r.success){closeM();loadComplaints();loadKpis();}else modMsg('rMsg',(r&&r.message)||'Failed',false);});};

// init
(function(){readUrl();qs('fq').value=st.q;qs('fStage').value=st.stage;qs('fVerif').value=st.verif;
 qs('fPs').value=String(st.ps);
 qs('fq').addEventListener('keydown',function(e){if(e.key==='Enter'){e.preventDefault();doSearch(1);}});
 // Type-to-search, debounced. The stale-response guard in runSearch means a slow earlier
 // reply can never overwrite the results for what is currently in the box.
 var _t=null;
 qs('fq').addEventListener('input',function(){clearTimeout(_t);_t=setTimeout(function(){doSearch(1);},350);});
 // Changing any filter starts again at page 1 — staying on page 7 of a different result
 // set is never what someone means.
 qs('fCampus').addEventListener('change',function(){doSearch(1);});
 qs('fStage').addEventListener('change',function(){doSearch(1);});
 qs('fVerif').addEventListener('change',function(){doSearch(1);});
 qs('fProg').addEventListener('change',function(){doSearch(1);});
 qs('fPs').addEventListener('change',function(){doSearch(1);});
 loadKpis();

 // The results and the filter option-lists are independent, so they are fetched in
 // PARALLEL. Previously the first search waited for Filters to come back, which put two
 // sequential round trips in front of the very first row the user sees.
 //
 // runSearch (not doSearch) is used here deliberately: doSearch reads the dropdowns, and
 // at this instant fProg/fCampus are still empty — reading them would wipe the programme
 // and campus that came in on the URL. runSearch works from the parsed state instead.
 runSearch(false);

 ajax('Filters',{},function(r){
  if(!r||!r.success) return;
  var s=qs('fProg');(r.programmes||[]).forEach(function(p){var o=document.createElement('option');o.value=p.code;o.textContent=p.name;s.appendChild(o);});
  s.value=st.prog;
  // Campuses come from the pipeline itself, with counts, so the list can never offer an
  // option that returns nothing — and picks up a third campus automatically if one appears.
  var cs=qs('fCampus');(r.campuses||[]).forEach(function(cp){var o=document.createElement('option');o.value=cp.code;o.textContent=cp.name+' ('+fmt(cp.count)+')';cs.appendChild(o);});
  cs.value=st.campus;
 });
})();
})();
</script>
</asp:Content>
