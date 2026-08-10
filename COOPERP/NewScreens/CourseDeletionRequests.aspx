<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true"
    CodeFile="CourseDeletionRequests.aspx.cs" Inherits="COOPERP_NewScreens_CourseDeletionRequests"
    Title="Course Deletion Requests" %>

<asp:Content ID="ch" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.cd-wrap{max-width:1240px;margin:0 auto;padding:18px 20px 40px;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;color:#1a1a2e;}
.cd-title{font-size:21px;font-weight:800;color:#05275C;margin:0;}
.cd-sub{font-size:12px;color:#64748b;margin:2px 0 16px;}
.cd-bar{display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin-bottom:12px;}
.cd-in,.cd-sel{padding:9px 11px;border:1px solid #cbd5e1;font-size:13px;background:#fff;color:#1a1a2e;font-family:inherit;}
.cd-in{flex:1 1 240px;min-width:0;}
.cd-btn{padding:9px 13px;border:1px solid #cbd5e1;background:#fff;color:#334155;font-size:13px;font-weight:600;cursor:pointer;font-family:inherit;}
.cd-btn--p{background:#05275C;border-color:#05275C;color:#fff;}
.cd-btn--ok{background:#0b5c3a;border-color:#0b5c3a;color:#fff;}
.cd-btn--no{color:#b91c1c;border-color:#fbc4c4;}
.cd-btn--rev{background:#174DA4;border-color:#174DA4;color:#fff;}
.cd-btn:disabled{opacity:.5;cursor:default;}
.cd-meta{font-size:12px;color:#64748b;margin:4px 0 10px;}
.cd-card{border:1px solid #e0e5ed;background:#fff;padding:14px 16px;margin-bottom:10px;border-left:3px solid #cbd5e1;}
.cd-card--PENDING{border-left-color:#ea580c;}
.cd-card--APPROVED{border-left-color:#0b5c3a;}
.cd-card--REJECTED{border-left-color:#b91c1c;}
.cd-card--REVERSED{border-left-color:#174DA4;}
.cd-card--CANCELLED{border-left-color:#94a3b8;}
.cd-hd{display:flex;justify-content:space-between;align-items:flex-start;gap:14px;flex-wrap:wrap;}
.cd-who{font-size:14px;font-weight:800;color:#05275C;}
.cd-who small{display:block;font-size:11px;font-weight:400;color:#8b93a3;margin-top:2px;}
.cd-badge{font-size:10px;font-weight:800;padding:3px 9px;white-space:nowrap;border:1px solid transparent;}
.cd-b--PENDING{background:#fff7ed;color:#9a3412;border-color:#fed7aa;}
.cd-b--APPROVED{background:#e6f4ec;color:#0b5c3a;border-color:#b5dcc5;}
.cd-b--REJECTED{background:#fee2e2;color:#991b1b;border-color:#fca5a5;}
.cd-b--REVERSED{background:#e8f0fe;color:#1d4ed8;border-color:#c7d2fe;}
.cd-b--CANCELLED{background:#f1f5f9;color:#64748b;border-color:#cbd5e1;}
.cd-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:8px 16px;margin:12px 0;}
.cd-grid div{font-size:12px;padding:5px 0;border-bottom:1px dashed #eef2f7;}
.cd-grid span{display:block;font-size:9.5px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;color:#94a3b8;}
.cd-grid b{color:#05275C;}
/* Marks are the whole reason this needs approval, so they are called out rather than
   listed among the other fields. */
.cd-marks{background:#fff7ed;border:1px solid #fed7aa;padding:9px 12px;margin:10px 0;font-size:12px;color:#9a3412;}
.cd-marks b{color:#7c2d12;}
.cd-reason{background:#f8fafc;border:1px solid #eef2f7;padding:9px 12px;margin:10px 0;font-size:12.5px;line-height:1.55;color:#334155;}
.cd-reason span{display:block;font-size:9.5px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;color:#94a3b8;margin-bottom:3px;}
.cd-acts{display:flex;flex-wrap:wrap;gap:7px;margin-top:12px;padding-top:10px;border-top:1px solid #eef2f7;}
.cd-ft{font-size:11px;color:#94a3b8;margin-top:8px;}
.cd-empty{text-align:center;padding:44px;color:#94a3b8;font-size:13px;border:1px solid #e0e5ed;background:#fff;}
.cd-pager{display:flex;flex-wrap:wrap;gap:4px;justify-content:center;align-items:center;margin-top:14px;}
.cd-pager a,.cd-pager button{min-width:32px;padding:6px 9px;border:1px solid #cbd5e1;background:#fff;font-size:12px;cursor:pointer;text-decoration:none;color:#334155;text-align:center;font-family:inherit;}
.cd-pager a.active{background:#05275C;border-color:#05275C;color:#fff;font-weight:700;}
.cd-pager button:disabled{opacity:.45;cursor:default;}
.cd-snap{margin-top:10px;}
.cd-snap summary{cursor:pointer;font-size:11px;font-weight:700;color:#174DA4;}
.cd-snap pre{background:#0b1b33;color:#cfe0ff;padding:10px;overflow:auto;max-height:280px;font-size:11px;line-height:1.45;margin:8px 0 0;}
.cd-toast{position:fixed;top:18px;right:18px;z-index:11000;padding:10px 16px;font-size:13px;font-weight:600;color:#fff;box-shadow:0 4px 16px rgba(0,0,0,.2);}
</style>
</asp:Content>

<asp:Content ID="cm" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="cd-wrap">
    <h1 class="cd-title">Course Deletion Requests</h1>
    <div class="cd-sub">
        Students cannot remove a course once it carries marks. These are their requests to have one removed.
        Approving deletes the registration <strong>and any published result</strong>, after taking a full snapshot &mdash;
        so every approved deletion can be reversed from here.
    </div>

    <div class="cd-bar">
        <input type="text" id="fq" class="cd-in" placeholder="Search student, reg no or course &mdash; any order&hellip;" autocomplete="off" />
        <select id="fSt" class="cd-sel">
            <option value="PENDING">Pending</option>
            <option value="APPROVED">Approved</option>
            <option value="REVERSED">Reversed</option>
            <option value="REJECTED">Declined</option>
            <option value="CANCELLED">Withdrawn</option>
            <option value="ALL">All</option>
        </select>
        <select id="fPs" class="cd-sel" title="Rows per page">
            <option value="25">25 / page</option><option value="50">50 / page</option><option value="100">100 / page</option>
        </select>
        <button type="button" class="cd-btn cd-btn--p" onclick="cdSearch(1)">Search</button>
        <button type="button" class="cd-btn" onclick="cdReset()">Reset</button>
    </div>

    <div class="cd-meta" id="meta">Loading&hellip;</div>
    <div id="list"></div>
    <div class="cd-pager" id="pager"></div>
</div>

<script type="text/javascript">
(function () {
'use strict';
var st = { q:'', status:'PENDING', page:1, ps:25 };

function qs(id){return document.getElementById(id);}
function esc(s){return s?String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'):'';}
function num(v){return (v===null||v===undefined||v==='')?'—':v;}
function toast(m, err){
    var t=document.createElement('div'); t.className='cd-toast'; t.textContent=m;
    t.style.background = err ? '#dc3545' : '#16a34a';
    document.body.appendChild(t);
    setTimeout(function(){ t.style.transition='opacity .4s'; t.style.opacity='0'; setTimeout(function(){t.remove();},400); }, 3200);
}
function ajax(m,p,cb){
    var x=new XMLHttpRequest();
    x.open('POST', location.pathname+'/'+m, true);
    x.setRequestHeader('Content-Type','application/json; charset=utf-8');
    x.timeout = 120000;
    x.onload=function(){ try{ var o=JSON.parse(x.responseText); cb(typeof o.d==='string'?JSON.parse(o.d):o.d); }catch(e){ cb({success:false,message:'Parse error'}); } };
    x.onerror=function(){ cb({success:false,message:'Network error'}); };
    x.ontimeout=function(){ cb({success:false,message:'The request timed out.'}); };
    x.send(JSON.stringify(p||{}));
}

// State lives in the URL, so a filtered view can be shared and Back works.
function readUrl(){
    var u; try{ u=new URLSearchParams(location.search||''); }catch(e){ return; }
    st.q=u.get('q')||''; st.status=(u.get('status')||'PENDING').toUpperCase();
    st.page=Math.max(1,parseInt(u.get('page'),10)||1);
    var ps=parseInt(u.get('ps'),10)||25; st.ps=[25,50,100].indexOf(ps)>=0?ps:25;
}
function buildUrl(o){
    o=o||{}; function pick(k){return (k in o)?o[k]:st[k];}
    var u=new URLSearchParams();
    if(pick('q'))u.set('q',pick('q'));
    if(pick('status')&&pick('status')!=='PENDING')u.set('status',pick('status'));
    if(pick('page')>1)u.set('page',pick('page'));
    if(pick('ps')!==25)u.set('ps',pick('ps'));
    var s=u.toString(); return location.pathname+(s?('?'+s):'');
}
function syncUrl(push){
    var url=buildUrl({});
    if(url===location.pathname+location.search)return;
    try{ push?history.pushState(null,'',url):history.replaceState(null,'',url); }catch(e){}
}
window.addEventListener('popstate',function(){ readUrl(); applyControls(); run(false); });
function applyControls(){ qs('fq').value=st.q; qs('fSt').value=st.status; qs('fPs').value=String(st.ps); }

window.cdSearch=function(page){
    st.q=qs('fq').value.replace(/^\s+|\s+$/g,''); st.status=qs('fSt').value;
    st.ps=parseInt(qs('fPs').value,10)||25; st.page=page||1;
    run(true);
};
window.cdReset=function(){ st={q:'',status:'PENDING',page:1,ps:25}; applyControls(); run(true); };
window.cdGo=function(p){ st.page=Math.max(1,p||1); run(true); return false; };

var seq=0;
function run(push){
    syncUrl(push);
    var mine=++seq;
    qs('meta').textContent='Loading…';
    ajax('List',{status:st.status,q:st.q,page:st.page,pageSize:st.ps},function(r){
        if(mine!==seq) return;
        if(!r||!r.success){ qs('meta').textContent=(r&&r.message)||'Error'; return; }
        st.page=r.page;
        var from=r.total?((r.page-1)*r.pageSize+1):0, to=Math.min(r.page*r.pageSize,r.total);
        qs('meta').innerHTML = (r.total? ('Showing '+from+'–'+to+' of '+r.total+' request'+(r.total===1?'':'s')) : 'No requests match these filters.')
            + (r.pending? (' &middot; <strong style="color:#9a3412">'+r.pending+' awaiting review</strong>') : '');
        render(r.rows);
        pager(r.page,r.pages);
    });
}

function render(rows){
    var el=qs('list');
    if(!rows||!rows.length){ el.innerHTML='<div class="cd-empty">Nothing here.</div>'; return; }
    var h='';
    rows.forEach(function(x){
        var marks=[];
        if(x.cw!==null&&x.cw!==undefined) marks.push('Coursework <b>'+x.cw+'</b>');
        if(x.exam!==null&&x.exam!==undefined) marks.push('Exam <b>'+x.exam+'</b>');
        if(x.total!==null&&x.total!==undefined) marks.push('Total <b>'+x.total+'</b>');
        if(x.pubScore!==null&&x.pubScore!==undefined) marks.push('Published <b>'+x.pubScore+(x.pubGrade?(' / '+esc(x.pubGrade)):'')+'</b>');
        if(x.markStage) marks.push('Stage <b>'+esc(x.markStage)+'</b>');

        h+='<div class="cd-card cd-card--'+esc(x.status)+'">'
         + ' <div class="cd-hd">'
         + '   <div class="cd-who">'+esc(x.name||x.regno)+'<small>'+esc(x.regno)+(x.prog?(' · '+esc(x.prog)):'')+'</small></div>'
         + '   <span class="cd-badge cd-b--'+esc(x.status)+'">'+esc(x.status)+'</span>'
         + ' </div>'
         + ' <div class="cd-grid">'
         + '   <div><span>Course</span><b>'+esc(x.courseId)+'</b></div>'
         + '   <div><span>Title</span><b>'+esc(x.courseName||'—')+'</b></div>'
         + '   <div><span>Year</span><b>'+esc(x.acadYear)+'</b></div>'
         + '   <div><span>Semester</span><b>'+esc(x.semester)+(x.studyYear?(' · Y'+esc(x.studyYear)):'')+'</b></div>'
         + ' </div>'
         + (marks.length? ('<div class="cd-marks">Marks on record when this was requested: '+marks.join(' &nbsp;·&nbsp; ')+'</div>') : '')
         + ' <div class="cd-reason"><span>Student&rsquo;s reason</span>'+esc(x.reason)+'</div>'
         + (x.adminComment? ('<div class="cd-reason"><span>Administrator</span>'+esc(x.adminComment)+'</div>') : '')
         + ' <div class="cd-acts">'
         + (x.status==='PENDING'
              ? '<button type="button" class="cd-btn cd-btn--ok" onclick="cdApprove('+x.id+')">Approve &amp; delete</button>'
                +'<button type="button" class="cd-btn cd-btn--no" onclick="cdReject('+x.id+')">Decline</button>'
              : '')
         + (x.status==='APPROVED'&&x.executed
              ? '<button type="button" class="cd-btn cd-btn--rev" onclick="cdReverse('+x.id+')">Reverse this deletion</button>'
              : '')
         + '<button type="button" class="cd-btn" onclick="cdSnap('+x.id+')">View snapshot</button>'
         + ' </div>'
         + ' <div class="cd-ft">Requested '+esc(x.createdAt)
         +   (x.decidedAt? (' · decided '+esc(x.decidedAt)+(x.admin?(' by '+esc(x.admin)):'')) : '')
         +   (x.executedAt? (' · deleted '+esc(x.executedAt)) : '')
         +   (x.reversedAt? (' · reversed '+esc(x.reversedAt)+(x.reversedBy?(' by '+esc(x.reversedBy)):'')) : '')
         +   (x.snapshotRows? (' · snapshot holds '+x.snapshotRows+' row(s)') : '')
         + ' </div>'
         + ' <div class="cd-snap" id="snap'+x.id+'"></div>'
         + '</div>';
    });
    el.innerHTML=h;
}

function pager(page,pages){
    var el=qs('pager'); el.innerHTML='';
    if(pages<=1) return;
    function link(label,pg,dis,act){
        if(dis){ var b=document.createElement('button'); b.textContent=label; b.disabled=true; el.appendChild(b); return; }
        var a=document.createElement('a'); a.href=buildUrl({page:pg}); a.textContent=label; if(act)a.className='active';
        a.onclick=function(ev){ if(ev.metaKey||ev.ctrlKey||ev.shiftKey)return true; ev.preventDefault(); cdGo(pg); return false; };
        el.appendChild(a);
    }
    link('« First',1,page<=1); link('‹ Prev',page-1,page<=1);
    var f=Math.max(1,page-4), t=Math.min(pages,f+8); if(t-f+1<9) f=Math.max(1,t-8);
    for(var i=f;i<=t;i++) link(String(i),i,false,i===page);
    link('Next ›',page+1,page>=pages); link('Last »',pages,page>=pages);
}

/* Approving destroys academic data, so the confirmation spells out exactly what goes and
   makes clear it is undoable — an operator should never have to guess either. */
window.cdApprove=function(id){
    if(!confirm('Approve this request?\n\nThis deletes the course registration AND any published result for it, and recalculates the student\'s semester GPA.\n\nA full snapshot is taken first, so you can reverse this afterwards.')) return;
    var note=prompt('Note for the student (optional):','')||'';
    ajax('Approve',{id:id,comment:note},function(r){
        if(!r||!r.success){ toast((r&&r.message)||'Approve failed.',true); return; }
        toast(r.message); run(false);
    });
};
window.cdReject=function(id){
    var why=prompt('Why are you declining? The student is shown this:','');
    if(why===null) return;
    if(!why.replace(/^\s+|\s+$/g,'')){ toast('A reason is required.',true); return; }
    ajax('Reject',{id:id,comment:why},function(r){
        if(!r||!r.success){ toast((r&&r.message)||'Decline failed.',true); return; }
        toast(r.message); run(false);
    });
};
window.cdReverse=function(id){
    if(!confirm('Reverse this deletion?\n\nThe course registration and any published result will be put back exactly as they were, and the semester GPA recalculated.')) return;
    var note=prompt('Reason for reversing (optional):','')||'';
    ajax('Reverse',{id:id,comment:note},function(r){
        if(!r||!r.success){ toast((r&&r.message)||'Reverse failed.',true); return; }
        toast(r.message); run(false);
    });
};
window.cdSnap=function(id){
    var box=qs('snap'+id);
    if(box.innerHTML){ box.innerHTML=''; return; }
    box.innerHTML='<div style="font-size:11px;color:#94a3b8">Loading snapshot…</div>';
    ajax('Detail',{id:id},function(r){
        if(!r||!r.success){ box.innerHTML='<div style="font-size:11px;color:#b91c1c">'+esc((r&&r.message)||'Error')+'</div>'; return; }
        var s=r.snapshot;
        box.innerHTML = s
            ? '<details open><summary>Exactly what was captured before deletion</summary><pre>'+esc(JSON.stringify(s,null,2))+'</pre></details>'
            : '<div style="font-size:11px;color:#94a3b8">No snapshot — this request has not been executed.</div>';
    });
};

(function(){
    readUrl(); applyControls();
    qs('fq').addEventListener('keydown',function(e){ if(e.key==='Enter'){ e.preventDefault(); cdSearch(1); } });
    qs('fSt').addEventListener('change',function(){ cdSearch(1); });
    qs('fPs').addEventListener('change',function(){ cdSearch(1); });
    run(false);
})();
})();
</script>
</asp:Content>
