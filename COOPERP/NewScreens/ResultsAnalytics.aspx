<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResultsAnalytics.aspx.cs" Inherits="COOPERP_NewScreens_ResultsAnalytics" Title="Results Analytics - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box;}
.ra-wrap{max-width:1320px;margin:0 auto;padding:8px 10px 14px;}
.ra-err{display:none;margin:0 0 8px;padding:8px 10px;background:#fef2f2;border:1px solid #fecaca;color:#b91c1c;border-radius:0;font-size:11px;}
.ra-err.show{display:block;}
.ra-loading{opacity:.55;pointer-events:none;}

/* header / scope */
.ra-head{background:#fff;border:1px solid #e0e5ed;margin-bottom:8px;}
.ra-head__top{padding:10px 12px;display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;border-bottom:1px solid #e0e5ed;}
.ra-title{font-size:13px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.ra-sub{font-size:10px;color:#94a3b8;margin-top:2px;}
.ra-chip{display:inline-flex;align-items:center;gap:6px;padding:4px 12px;border-radius:20px;font-size:11px;font-weight:700;background:#e6f4ea;border:1px solid #a7d9b2;color:#2e7d32;white-space:nowrap;}
.ra-filters{padding:8px 12px;display:flex;gap:8px;align-items:flex-end;flex-wrap:wrap;}
.ra-fg{display:flex;flex-direction:column;gap:2px;}
.ra-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:700;}
.ra-select{height:30px;border:1px solid #cdd8e6;padding:4px 8px;font-size:11px;background:#fff;border-radius:0;color:#1a1a2e;min-width:130px;}
.ra-select:focus{outline:none;border-color:#174DA4;}
.ra-btn{height:30px;display:inline-flex;align-items:center;gap:5px;padding:5px 12px;border:1px solid #05275C;background:#05275C;color:#fff;font-size:11px;font-weight:700;cursor:pointer;border-radius:0;}
.ra-btn:hover{background:#174DA4;border-color:#174DA4;}
.ra-btn--ghost{background:#fff;color:#05275C;}
.ra-btn--ghost:hover{background:#f0f4fa;color:#174DA4;}

/* KPIs */
.ra-kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:8px;margin-bottom:8px;}
.ra-kpi{background:#fff;border:1px solid #e0e5ed;border-left:3px solid #174DA4;padding:10px 12px;}
.ra-kpi__v{font-size:23px;font-weight:800;color:#05275C;line-height:1;letter-spacing:-.02em;}
.ra-kpi__l{font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:700;margin-top:5px;}
.ra-kpi__s{font-size:9px;color:#9ca3af;margin-top:2px;}
.ra-kpi--pass{border-left-color:#16a34a;}.ra-kpi--pass .ra-kpi__v{color:#15803d;}
.ra-kpi--dist{border-left-color:#7c3aed;}.ra-kpi--dist .ra-kpi__v{color:#6d28d9;}
.ra-kpi--avg{border-left-color:#f59e0b;}.ra-kpi--avg .ra-kpi__v{color:#b45309;}

/* cards */
.ra-grid2{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:8px;}
@media(max-width:900px){.ra-grid2{grid-template-columns:1fr;}}
.ra-card{background:#fff;border:1px solid #e0e5ed;margin-bottom:8px;}
.ra-card__h{padding:8px 12px;border-bottom:1px solid #e0e5ed;background:#f8fafc;display:flex;align-items:center;justify-content:space-between;gap:8px;flex-wrap:wrap;}
.ra-card__t{font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.ra-card__b{padding:10px 12px;}

/* grade distribution bars */
.ra-gd-row{display:flex;align-items:center;gap:8px;margin-bottom:6px;}
.ra-gd-lbl{width:28px;font-size:11px;font-weight:800;color:#05275C;text-align:center;}
.ra-gd-track{flex:1;background:#f1f5f9;height:16px;border-radius:0;overflow:hidden;}
.ra-gd-fill{height:100%;}
.ra-gd-meta{width:120px;font-size:10px;color:#64748b;text-align:right;white-space:nowrap;}

/* tabs */
.ra-tabs{display:inline-flex;border:1px solid #cdd8e6;border-radius:0;overflow:hidden;}
.ra-tab{padding:4px 12px;font-size:10px;font-weight:700;background:#fff;color:#64748b;border:none;cursor:pointer;border-right:1px solid #cdd8e6;}
.ra-tab:last-child{border-right:none;}
.ra-tab.active{background:#05275C;color:#fff;}

/* tables */
.ra-tw{overflow:auto;}
.ra-table{width:100%;border-collapse:collapse;font-size:11px;}
.ra-table th{background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:700;padding:6px 10px;text-align:left;white-space:nowrap;}
.ra-table td{border-bottom:1px solid #eef2f6;padding:6px 10px;color:#1f2937;vertical-align:middle;}
.ra-table tbody tr:last-child td{border-bottom:none;}
.ra-table tbody tr:hover td{background:#fafcff;}
.ra-bar{display:inline-block;height:6px;border-radius:0;vertical-align:middle;}
.ra-bar-bg{background:#f1f5f9;height:6px;border-radius:0;width:90px;display:inline-block;overflow:hidden;vertical-align:middle;}
.ra-rate{font-weight:800;}
.ra-code{font-family:Consolas,monospace;font-size:10px;color:#174DA4;background:#f5f7fa;border:1px solid #e0e5ed;padding:1px 6px;}
.ra-empty{text-align:center;color:#94a3b8;padding:18px;font-size:11px;}
.ra-rank{display:inline-flex;align-items:center;justify-content:center;width:18px;height:18px;border-radius:50%;background:#eef2f8;color:#05275C;font-size:9px;font-weight:800;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="ra-wrap">
<div id="raErr" class="ra-err"></div>

<!-- header + scope + filters -->
<div class="ra-head" id="raHead">
    <div class="ra-head__top">
        <div>
            <div class="ra-title">Results Analytics</div>
            <div class="ra-sub" id="raScope">Resolving your access scope&hellip;</div>
        </div>
        <span class="ra-chip" id="raChip">&#10003; Approved results</span>
    </div>
    <div class="ra-filters">
        <div class="ra-fg"><label>Academic Year</label><select id="raYear" class="ra-select"></select></div>
        <div class="ra-fg"><label>Semester</label>
            <select id="raSem" class="ra-select">
                <option value="">All Semesters</option>
                <option value="1">Semester 1</option>
                <option value="2">Semester 2</option>
                <option value="3">Semester 3</option>
            </select>
        </div>
        <div class="ra-fg"><label>&nbsp;</label><button type="button" class="ra-btn" id="raApply">Apply</button></div>
        <div class="ra-fg"><label>&nbsp;</label><button type="button" class="ra-btn ra-btn--ghost" id="raReset">Reset</button></div>
    </div>
</div>

<!-- KPIs -->
<div class="ra-kpis">
    <div class="ra-kpi"><div class="ra-kpi__v" id="kResults">—</div><div class="ra-kpi__l">Results</div><div class="ra-kpi__s">Approved entries in scope</div></div>
    <div class="ra-kpi"><div class="ra-kpi__v" id="kStudents">—</div><div class="ra-kpi__l">Students</div><div class="ra-kpi__s">Distinct students</div></div>
    <div class="ra-kpi ra-kpi--pass"><div class="ra-kpi__v" id="kPass">—</div><div class="ra-kpi__l">Pass Rate</div><div class="ra-kpi__s" id="kPassSub">mark &ge; 50</div></div>
    <div class="ra-kpi ra-kpi--dist"><div class="ra-kpi__v" id="kDist">—</div><div class="ra-kpi__l">Distinctions</div><div class="ra-kpi__s" id="kDistSub">grade A</div></div>
    <div class="ra-kpi ra-kpi--avg"><div class="ra-kpi__v" id="kAvg">—</div><div class="ra-kpi__l">Average Mark</div><div class="ra-kpi__s">across all results</div></div>
</div>

<div class="ra-grid2">
    <!-- grade distribution -->
    <div class="ra-card">
        <div class="ra-card__h"><span class="ra-card__t">Grade Distribution</span></div>
        <div class="ra-card__b" id="raGrades"><div class="ra-empty">Loading&hellip;</div></div>
    </div>
    <!-- pass-rate trend -->
    <div class="ra-card">
        <div class="ra-card__h"><span class="ra-card__t">Pass Rate Trend (by year)</span></div>
        <div class="ra-card__b" id="raTrend"><div class="ra-empty">Loading&hellip;</div></div>
    </div>
</div>

<!-- performance breakdown with role-aware tabs -->
<div class="ra-card">
    <div class="ra-card__h">
        <span class="ra-card__t">Performance Breakdown</span>
        <span class="ra-tabs">
            <button type="button" class="ra-tab" data-g="fac">By Faculty</button>
            <button type="button" class="ra-tab" data-g="dept">By Department</button>
            <button type="button" class="ra-tab" data-g="prog">By Programme</button>
        </span>
    </div>
    <div class="ra-tw">
        <table class="ra-table">
            <thead><tr>
                <th id="raGroupHdr">Group</th>
                <th style="width:80px;text-align:right;">Students</th>
                <th style="width:80px;text-align:right;">Results</th>
                <th style="width:70px;text-align:right;">Avg Mark</th>
                <th style="width:70px;text-align:right;">Pass %</th>
                <th style="width:160px;">Pass rate</th>
            </tr></thead>
            <tbody id="raGroupBody"><tr><td colspan="6" class="ra-empty">Loading&hellip;</td></tr></tbody>
        </table>
    </div>
</div>

<div class="ra-grid2">
    <!-- problematic courses -->
    <div class="ra-card">
        <div class="ra-card__h"><span class="ra-card__t">Courses Needing Attention</span><span class="ra-sub">fail rate &gt; 20%</span></div>
        <div class="ra-tw">
            <table class="ra-table">
                <thead><tr><th style="width:80px;">Code</th><th>Course</th><th style="width:60px;text-align:right;">Results</th><th style="width:80px;text-align:right;">Fail %</th></tr></thead>
                <tbody id="raProblem"><tr><td colspan="4" class="ra-empty">Loading&hellip;</td></tr></tbody>
            </table>
        </div>
    </div>
    <!-- top students -->
    <div class="ra-card">
        <div class="ra-card__h"><span class="ra-card__t">Top Performing Students</span><span class="ra-sub">&ge; 3 results</span></div>
        <div class="ra-tw">
            <table class="ra-table">
                <thead><tr><th style="width:32px;">#</th><th>Student</th><th>Programme</th><th style="width:70px;text-align:right;">Avg</th></tr></thead>
                <tbody id="raTop"><tr><td colspan="4" class="ra-empty">Loading&hellip;</td></tr></tbody>
            </table>
        </div>
    </div>
</div>

</div><!-- /.ra-wrap -->

<script type="text/javascript">
(function(){
'use strict';
var _data=null, _grp='fac';
function qs(id){return document.getElementById(id);}
function n(v){var x=parseFloat(v);return isNaN(x)?0:x;}
function fmt(v){return n(v).toLocaleString('en-US');}
function esc(s){return s?String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'):'';}
function rateColor(r){return r>=70?'#16a34a':(r>=50?'#f59e0b':'#ef4444');}
function showErr(m){var e=qs('raErr');if(e){e.textContent=m||'Unable to load.';e.className='ra-err show';}}
function hideErr(){var e=qs('raErr');if(e)e.className='ra-err';}
function loading(on){var h=qs('raHead');if(h)h.className='ra-head'+(on?' ra-loading':'');}

function callAJAX(method,params,cb){
    var xhr=new XMLHttpRequest();
    xhr.open('POST','ResultsAnalytics.aspx/'+method,true);
    xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
    xhr.onload=function(){try{var o=JSON.parse(xhr.responseText);cb(typeof o.d==='string'?JSON.parse(o.d):o.d);}catch(e){cb({success:false,message:'Parse error.'});}};
    xhr.onerror=function(){cb({success:false,message:'Network error.'});};
    xhr.send(JSON.stringify(params||{}));
}

function applyScope(sc){
    if(!sc)return;
    var b=qs('raScope'),c=qs('raChip');
    if(b)b.innerHTML='Muteesa I Royal University &middot; <strong>'+esc(sc.label||'')+'</strong>';
    if(c){
        if(sc.isAdmin){c.textContent='Administrator · all faculties';c.style.background='#e8f0fc';c.style.borderColor='#9bbdf0';c.style.color='#174DA4';}
        else if(sc.hasAccess){c.textContent=(sc.role||'Scoped');c.style.background='#e6f4ea';c.style.borderColor='#a7d9b2';c.style.color='#2e7d32';}
        else{c.textContent='No data access';c.style.background='#fde8e8';c.style.borderColor='#f5b5b5';c.style.color='#b42318';}
    }
    // Default breakdown tab by role: admin→faculty, dean→department, HOD→programme.
    if(sc.mode==='faculty')_grp='dept';
    else if(sc.mode==='department')_grp='prog';
    else _grp='fac';
}

function setKpis(k){
    qs('kResults').textContent=fmt(k.results);
    qs('kStudents').textContent=fmt(k.students);
    qs('kPass').textContent=n(k.passRate).toFixed(1)+'%';
    qs('kPass').style.color=rateColor(n(k.passRate));
    qs('kPassSub').textContent=fmt(k.passes)+' of '+fmt(k.results)+' passed';
    qs('kDist').textContent=fmt(k.distinctions);
    qs('kDistSub').textContent='grade A · '+n(k.distinctionPct).toFixed(1)+'%';
    qs('kAvg').textContent=n(k.avgMark).toFixed(1);
}

var GCOLOR={'A':'#15803d','B+':'#16a34a','B':'#22c55e','C+':'#84cc16','C':'#eab308','D+':'#f59e0b','D':'#f97316','F':'#ef4444'};
function setGrades(g){
    var box=qs('raGrades');
    if(!g||!g.length){box.innerHTML='<div class="ra-empty">No graded results.</div>';return;}
    var max=0;g.forEach(function(x){if(n(x.count)>max)max=n(x.count);});
    var h='';
    g.forEach(function(x){
        var w=max>0?Math.round(n(x.count)*100/max):0;
        h+='<div class="ra-gd-row"><div class="ra-gd-lbl">'+esc(x.grade)+'</div>'+
           '<div class="ra-gd-track"><div class="ra-gd-fill" style="width:'+w+'%;background:'+(GCOLOR[x.grade]||'#94a3b8')+';"></div></div>'+
           '<div class="ra-gd-meta">'+fmt(x.count)+' &middot; '+n(x.pct).toFixed(1)+'%</div></div>';
    });
    box.innerHTML=h;
}

function setTrend(t){
    var box=qs('raTrend');
    if(!t||!t.length){box.innerHTML='<div class="ra-empty">No trend data.</div>';return;}
    var h='';
    t.forEach(function(x){
        var r=n(x.passRate);
        h+='<div class="ra-gd-row"><div class="ra-gd-lbl" style="width:64px;font-size:9px;">'+esc(x.label)+'</div>'+
           '<div class="ra-gd-track"><div class="ra-gd-fill" style="width:'+r+'%;background:'+rateColor(r)+';"></div></div>'+
           '<div class="ra-gd-meta">'+r.toFixed(1)+'% &middot; '+fmt(x.results)+'</div></div>';
    });
    box.innerHTML=h;
}

function renderGroup(){
    var rows = _data ? (_grp==='fac'?_data.byFaculty:_grp==='dept'?_data.byDepartment:_data.byProgramme) : [];
    var hdr=qs('raGroupHdr'); if(hdr) hdr.textContent=_grp==='fac'?'Faculty':_grp==='dept'?'Department':'Programme';
    var tb=qs('raGroupBody');
    if(!rows||!rows.length){tb.innerHTML='<tr><td colspan="6" class="ra-empty">No data in scope for this view.</td></tr>';return;}
    var h='';
    rows.forEach(function(g){
        var r=n(g.passRate);
        h+='<tr>'+
            '<td title="'+esc(g.name)+'" style="max-width:280px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">'+esc(g.name)+'</td>'+
            '<td style="text-align:right;font-weight:700;color:#05275C;">'+fmt(g.students)+'</td>'+
            '<td style="text-align:right;color:#475569;">'+fmt(g.results)+'</td>'+
            '<td style="text-align:right;color:#475569;">'+n(g.avgMark).toFixed(1)+'</td>'+
            '<td style="text-align:right;" class="ra-rate"><span style="color:'+rateColor(r)+';">'+r.toFixed(1)+'%</span></td>'+
            '<td><div class="ra-bar-bg" style="width:140px;"><div class="ra-bar" style="width:'+r+'%;background:'+rateColor(r)+';"></div></div></td>'+
        '</tr>';
    });
    tb.innerHTML=h;
    // sync active tab button
    var tabs=document.querySelectorAll('.ra-tab');
    for(var i=0;i<tabs.length;i++) tabs[i].className='ra-tab'+(tabs[i].getAttribute('data-g')===_grp?' active':'');
}

function setProblem(p){
    var tb=qs('raProblem');
    if(!p||!p.length){tb.innerHTML='<tr><td colspan="4" class="ra-empty">No courses above the fail-rate threshold. &#127881;</td></tr>';return;}
    var h='';
    p.forEach(function(c){
        h+='<tr><td><span class="ra-code">'+esc(c.code)+'</span></td>'+
           '<td title="'+esc(c.name)+'" style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">'+esc(c.name)+'</td>'+
           '<td style="text-align:right;color:#475569;">'+fmt(c.results)+'</td>'+
           '<td style="text-align:right;font-weight:800;color:#b42318;">'+n(c.failRate).toFixed(1)+'%</td></tr>';
    });
    tb.innerHTML=h;
}

function setTop(s){
    var tb=qs('raTop');
    if(!s||!s.length){tb.innerHTML='<tr><td colspan="4" class="ra-empty">No students with enough results.</td></tr>';return;}
    var h='';
    s.forEach(function(st,i){
        h+='<tr><td><span class="ra-rank">'+(i+1)+'</span></td>'+
           '<td title="'+esc(st.name)+'" style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">'+esc(st.name||st.regno)+'<div style="font-size:9px;color:#94a3b8;">'+esc(st.regno)+'</div></td>'+
           '<td title="'+esc(st.prog)+'" style="max-width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:10px;color:#64748b;">'+esc(st.prog)+'</td>'+
           '<td style="text-align:right;font-weight:800;color:#15803d;">'+n(st.avgMark).toFixed(1)+'</td></tr>';
    });
    tb.innerHTML=h;
}

function render(d){
    _data=d;
    setKpis(d.kpis||{});
    setGrades(d.grades||[]);
    setTrend(d.trend||[]);
    renderGroup();
    setProblem(d.problematic||[]);
    setTop(d.topStudents||[]);
}

function load(){
    hideErr(); loading(true);
    callAJAX('GetAnalytics',{year:qs('raYear').value,semester:qs('raSem').value},function(d){
        loading(false);
        if(!d||!d.success){showErr((d&&d.message)||'Failed to load analytics.');return;}
        if(d.scope) applyScope(d.scope);
        render(d.data||{});
    });
}

function init(){
    var tabs=document.querySelectorAll('.ra-tab');
    for(var i=0;i<tabs.length;i++) tabs[i].onclick=function(){_grp=this.getAttribute('data-g');renderGroup();};
    qs('raApply').onclick=load;
    qs('raReset').onclick=function(){qs('raSem').value='';if(qs('raYear').options.length>1)qs('raYear').selectedIndex=1;load();};
    loading(true);
    callAJAX('GetInit',{},function(d){
        loading(false);
        if(!d||!d.success){showErr((d&&d.message)||'Failed to initialise.');return;}
        if(d.scope) applyScope(d.scope);
        var y=qs('raYear');var h='<option value="">All Years</option>';
        (d.years||[]).forEach(function(it){h+='<option value="'+esc(it.value)+'">'+esc(it.text)+'</option>';});
        y.innerHTML=h;
        if(y.options.length>1) y.selectedIndex=1; // default to latest year
        load();
    });
}
init();
})();
</script>
</asp:Content>
