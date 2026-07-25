<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResultsExporter.aspx.cs" Inherits="COOPERP_NewScreens_ResultsExporter" Title="Results Export Centre - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
<style type="text/css">
    .re-wrap { padding:12px; color:#1a1a2e; min-width:0; max-width:100%; box-sizing:border-box; }

    /* ── Horizontal-overflow fix ──────────────────────────────────────────────
       The master's content column is `.cd-content{flex:1}` with the default
       min-width:auto, so it refuses to shrink below its content's intrinsic
       width — Chart.js canvases (which carry a pixel width) and grid children
       then push the whole column past the viewport (content cut off on the right
       until zoomed out). Allowing every flex/grid child to shrink to zero fixes
       it. Scoped to this page (inline <style> loads only here). */
    .cd-content { min-width:0 !important; }
    .re-wrap *, .re-wrap { box-sizing:border-box; }
    .re-stats, .re-charts, .re-perf { min-width:0; }
    .re-stats > *, .re-charts > *, .re-perf > *, .re-card { min-width:0; }
    .re-wrap canvas { max-width:100% !important; }
    .re-chartbox { width:100%; }
    .re-hd__l { min-width:0; }
    .re-chip { max-width:100%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .re-hd { display:flex; align-items:center; justify-content:space-between; background:#05275C; color:#fff; padding:12px 18px; }
    .re-hd__l { display:flex; align-items:center; gap:12px; }
    .re-hd__ic { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; }
    .re-hd__t { font-size:16px; font-weight:700; }
    .re-hd__s { font-size:11px; opacity:.8; margin-top:2px; }
    .re-chip { background:rgba(255,255,255,.15); font-size:10px; padding:3px 9px; border-radius:10px; }

    .re-filter { background:#fff; border:1px solid #e0e5ed; padding:10px 12px; margin-top:12px; }
    .re-row { display:flex; flex-wrap:wrap; gap:8px; align-items:flex-end; }
    .re-fld { display:flex; flex-direction:column; gap:2px; flex:1 1 128px; min-width:0; }
    .re-fld label { font-size:9px; font-weight:600; text-transform:uppercase; letter-spacing:.3px; color:#555; }
    .re-fld select, .re-fld input { padding:5px 7px; border:1px solid #cdd3de; font-size:11px; border-radius:0; background:#fff; width:100%; min-width:0; font-family:inherit; box-sizing:border-box; }
    .re-srcnote { margin-top:8px; font-size:10px; color:#8a5a00; background:#fff8e1; border:1px solid #fde3a7; padding:5px 9px; }

    .re-cfg { display:flex; flex-wrap:wrap; gap:14px; align-items:center; margin-top:10px; padding-top:10px; border-top:1px solid #eef0f4; }
    .re-seg { display:inline-flex; border:1px solid #cdd3de; }
    .re-seg button { background:#fff; border:0; border-right:1px solid #cdd3de; padding:6px 12px; font-size:11px; cursor:pointer; color:#333; font-family:inherit; }
    .re-seg button:last-child { border-right:0; }
    .re-seg button.on { background:#05275C; color:#fff; }
    .re-seglbl { font-size:9px; font-weight:600; text-transform:uppercase; letter-spacing:.3px; color:#888; margin-right:6px; }

    .re-stats { display:grid; grid-template-columns:repeat(6,1fr); gap:8px; margin-top:12px; }
    .re-kpi { background:#fff; border:1px solid #e0e5ed; border-left:3px solid #174DA4; padding:10px 12px; }
    .re-kpi b { display:block; font-size:19px; font-weight:700; color:#05275C; line-height:1; }
    .re-kpi span { font-size:9px; text-transform:uppercase; letter-spacing:.3px; color:#888; margin-top:4px; display:block; }

    .re-charts { display:grid; grid-template-columns:1fr 1fr 1.1fr; gap:12px; margin-top:12px; }

    /* Staged marks-submission pipeline */
    .re-pipe { display:flex; flex-direction:column; gap:7px; }
    .re-pipe__hd { display:flex; justify-content:space-between; align-items:baseline; margin-bottom:2px; }
    .re-pipe__pct { font-size:20px; font-weight:700; color:#16a34a; }
    .re-pipe__pctl { font-size:9px; color:#888; text-transform:uppercase; }
    .re-stage { display:grid; grid-template-columns:78px 1fr 44px; align-items:center; gap:7px; }
    .re-stage__l { font-size:9px; font-weight:600; text-transform:uppercase; letter-spacing:.2px; color:#555; }
    .re-stage__bar { height:9px; background:#eef2f7; overflow:hidden; }
    .re-stage__bar>span { display:block; height:100%; }
    .re-stage__n { font-size:10px; font-weight:700; color:#1a1a2e; text-align:right; }

    /* Top / lowest performers */
    .re-perf { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-top:12px; }
    .re-plist { list-style:none; margin:0; padding:0; }
    .re-plist li { display:grid; grid-template-columns:20px 1fr auto; gap:8px; align-items:center; padding:4px 2px; border-bottom:1px solid #f0f2f6; font-size:10px; }
    .re-plist li:last-child { border-bottom:0; }
    .re-plist .rk { color:#9098a5; font-weight:700; font-size:9px; text-align:center; }
    .re-plist .nm { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .re-plist .nm small { color:#9098a5; }
    .re-plist .gp { font-weight:700; }
    .re-plist .gp--hi { color:#16a34a; } .re-plist .gp--lo { color:#dc3545; }

    /* Columns popover */
    .re-colwrap { position:relative; }
    .re-colbtn { font-size:10px; padding:3px 9px; border:1px solid #cdd3de; background:#fff; cursor:pointer; color:#333; }
    .re-colpop { display:none; position:absolute; right:0; top:26px; z-index:50; background:#fff; border:1px solid #cdd3de; box-shadow:0 8px 24px rgba(0,0,0,.15); padding:8px; min-width:190px; max-height:300px; overflow:auto; }
    .re-colpop.show { display:block; }
    .re-colpop label { display:flex; align-items:center; gap:6px; font-size:10px; padding:3px 4px; cursor:pointer; color:#333; }
    .re-colpop label:hover { background:#f5f7fa; }
    .re-card { background:#fff; border:1px solid #e0e5ed; }
    .re-card__h { font-size:11px; font-weight:600; color:#1a1a2e; padding:9px 12px; border-bottom:1px solid #e0e5ed; background:#f5f7fa; display:flex; justify-content:space-between; align-items:center; }
    .re-card__h small { color:#888; font-weight:400; }
    .re-card__b { padding:10px; }
    .re-chartbox { position:relative; height:230px; }

    .re-tblwrap { overflow:auto; max-height:460px; }
    .re-tbl { width:100%; border-collapse:collapse; font-size:10px; }
    .re-tbl th { position:sticky; top:0; background:#05275C; color:#fff; padding:6px 9px; text-align:left; font-size:9px; text-transform:uppercase; letter-spacing:.3px; white-space:nowrap; }
    .re-tbl td { padding:5px 9px; border-bottom:1px solid #eef0f4; white-space:nowrap; }
    .re-tbl tbody tr:nth-child(even) td { background:#f9fafc; }

    .re-actions { display:flex; gap:8px; align-items:center; margin-top:12px; }
    .re-btn { padding:8px 16px; font-size:12px; font-weight:600; border:1px solid transparent; cursor:pointer; border-radius:0; font-family:inherit; }
    .re-btn--primary { background:#05275C; color:#fff; }
    .re-btn--primary:hover { background:#041d45; }
    .re-btn--accent { background:#174DA4; color:#fff; }
    .re-btn--ghost { background:#fff; color:#333; border-color:#cdd3de; }
    .re-btn:disabled { opacity:.5; cursor:not-allowed; }
    .re-btn--sm { padding:6px 12px; font-size:11px; }
    .re-total { font-size:11px; color:#555; margin-left:auto; }
    .re-exp { display:inline-flex; align-items:center; gap:6px; margin-left:auto; flex-wrap:wrap; }
    .re-exp .re-seglbl { margin-right:2px; }

    .re-note { font-size:9px; color:#9098a5; font-style:italic; margin-top:6px; }
    .re-err { display:none; background:#fef5f5; border:1px solid #f5c6cb; color:#dc3545; font-size:11px; padding:8px 12px; margin-top:10px; }
    .re-err.show { display:block; }
    .re-noaccess { display:none; background:#fff8e1; border:1px solid #fcd34d; color:#b45309; font-size:12px; padding:14px 18px; margin-top:12px; }

    .md-loader { position:fixed; inset:0; background:rgba(245,247,250,.8); z-index:9998; display:none; align-items:center; justify-content:center; }
    .md-loader.show { display:flex; }
    .md-spinner { width:42px; height:42px; border:4px solid #e6ebf2; border-top-color:#05275C; border-radius:50%; animation:respin .75s linear infinite; margin:0 auto; }
    .md-loader__t { font-size:12px; color:#05275C; font-weight:600; margin-top:12px; text-align:center; }
    @keyframes respin { to { transform:rotate(360deg); } }
    @media (max-width:1100px){ .re-stats{grid-template-columns:repeat(3,1fr);} .re-charts{grid-template-columns:1fr;} .re-perf{grid-template-columns:1fr;} }
    @media (max-width:640px){
        .re-wrap{padding:8px;}
        .re-stats{grid-template-columns:repeat(2,1fr);gap:6px;}
        .re-kpi{padding:8px 9px;} .re-kpi b{font-size:16px;}
        .re-hd{padding:10px 12px;} .re-hd__s{display:none;}
        .re-fld{flex:1 1 46%;}
        .re-cfg{gap:8px;} .re-seg{flex-wrap:wrap;}
        .re-actions{flex-wrap:wrap;} .re-total{margin-left:0;width:100%;}
    }
    @media (max-width:400px){ .re-stats{grid-template-columns:1fr 1fr;} .re-fld{flex:1 1 100%;} }
</style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="re-wrap">

    <div class="re-hd">
        <div class="re-hd__l">
            <div class="re-hd__ic">
                <svg width="22" height="22" fill="none" stroke="#fff" stroke-width="1.8" viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
            </div>
            <div>
                <div class="re-hd__t">Results Export Centre</div>
                <div class="re-hd__s">Export marks &amp; results statistics for external representation</div>
            </div>
        </div>
        <div class="re-chip" id="reScope">&nbsp;</div>
    </div>

    <div class="re-noaccess" id="reNoAccess"></div>
    <div class="re-err" id="reErr"></div>

    <div id="reMain">
    <!-- FILTERS -->
    <div class="re-filter">
        <div class="re-row">
            <div class="re-fld"><label>Source</label><select id="fSource">
                <option value="published">Published results</option>
                <option value="approved">Approved (Dean)</option>
                <option value="captured">Captured (HOD)</option>
                <option value="entered">Entered (Lecturer)</option>
            </select></div>
            <div class="re-fld"><label>Academic Year</label><select id="fYear"></select></div>
            <div class="re-fld"><label>Semester</label><select id="fSem"><option value="">All</option><option value="1">Sem 1</option><option value="2">Sem 2</option><option value="3">Sem 3</option></select></div>
            <div class="re-fld"><label>Study Year</label><select id="fStudyYear"><option value="">All</option><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select></div>
            <div class="re-fld"><label>Faculty</label><select id="fFaculty"></select></div>
            <div class="re-fld"><label>Department</label><select id="fDept"></select></div>
            <div class="re-fld"><label>Programme</label><select id="fProg"></select></div>
            <div class="re-fld"><label>Course code</label><input type="text" id="fCourse" placeholder="optional" style="min-width:100px" /></div>
            <div class="re-fld"><label>Retakes</label><select id="fRetakes"><option value="all">Include</option><option value="exclude">Exclude</option><option value="only">Only retakes</option></select></div>
            <div class="re-fld"><label>Grade</label><select id="fGrade"><option value="">All</option><option>A</option><option>B+</option><option>B</option><option>C+</option><option>C</option><option>D+</option><option>D</option><option>F</option></select></div>
            <div class="re-fld"><label>Pass/Fail</label><select id="fPassFail"><option value="all">All</option><option value="pass">Pass only</option><option value="fail">Fail only</option></select></div>
        </div>
        <div class="re-cfg">
            <div><span class="re-seglbl">Report</span>
                <span class="re-seg" id="segMode">
                    <button type="button" data-mode="marks" class="on">Marks Sheet</button>
                    <button type="button" data-mode="summary">Student Summary</button>
                    <button type="button" data-mode="course_stats">Course Stats</button>
                    <button type="button" data-mode="prog_stats">Programme/Faculty Stats</button>
                </span>
            </div>
            <button type="button" class="re-btn re-btn--accent" id="btnApply">Generate Preview</button>
            <button type="button" class="re-btn re-btn--ghost" id="btnReset">Reset</button>
            <span class="re-exp">
                <span class="re-seglbl">Export</span>
                <button type="button" class="re-btn re-btn--primary re-btn--sm" id="btnXlsxTop" disabled="disabled">Excel</button>
                <button type="button" class="re-btn re-btn--primary re-btn--sm" id="btnCsvTop" disabled="disabled">CSV</button>
                <button type="button" class="re-btn re-btn--ghost re-btn--sm" id="btnPrintTop" disabled="disabled">Print</button>
            </span>
        </div>
        <div class="re-srcnote" id="reSrcNote" style="display:none;"></div>
    </div>

    <!-- STATS -->
    <div class="re-stats">
        <div class="re-kpi"><b id="kRec">&ndash;</b><span>Records</span></div>
        <div class="re-kpi"><b id="kStu">&ndash;</b><span>Students</span></div>
        <div class="re-kpi"><b id="kCrs">&ndash;</b><span>Courses</span></div>
        <div class="re-kpi"><b id="kMean">&ndash;</b><span>Mean Score</span></div>
        <div class="re-kpi"><b id="kPass">&ndash;</b><span>Pass Rate</span></div>
        <div class="re-kpi"><b id="kGp">&ndash;</b><span>Mean Grade Pt</span></div>
    </div>

    <div class="re-charts">
        <div class="re-card"><div class="re-card__h">Grade Distribution <small>NCHE bands (score-derived)</small></div><div class="re-card__b"><div class="re-chartbox"><canvas id="chGrade"></canvas></div></div></div>
        <div class="re-card"><div class="re-card__h">Class of Degree <small>indicative · selected scope</small></div><div class="re-card__b"><div class="re-chartbox"><canvas id="chClass"></canvas></div></div></div>
        <div class="re-card"><div class="re-card__h">Marks Submission <small>staged pipeline</small></div><div class="re-card__b"><div class="re-pipe" id="rePipe"><div style="font-size:10px;color:#9098a5;">Generate a preview to see submission progress.</div></div></div></div>
    </div>

    <div class="re-perf">
        <div class="re-card"><div class="re-card__h">Top Performers <small>by GPA · selected scope</small></div><div class="re-card__b"><ul class="re-plist" id="rePerfTop"></ul></div></div>
        <div class="re-card"><div class="re-card__h">Needs Attention <small>lowest GPA · selected scope</small></div><div class="re-card__b"><ul class="re-plist" id="rePerfBot"></ul></div></div>
    </div>

    <div class="re-card" id="reBreakCard" style="margin-top:12px;display:none;">
        <div class="re-card__h">
            <span id="reBreakTitle">Performance breakdown</span>
            <small id="reBreakMeta">&nbsp;</small>
        </div>
        <div class="re-card__b" style="padding:0;">
            <div class="re-tblwrap" style="max-height:320px;"><table class="re-tbl" id="reBreakTable"><thead></thead><tbody></tbody></table></div>
        </div>
    </div>

    <div class="re-card" style="margin-top:12px;">
        <div class="re-card__h">
            <span id="reTblTitle">Preview</span>
            <span style="display:flex;align-items:center;gap:10px;">
                <small id="reTblMeta">&nbsp;</small>
                <span class="re-colwrap">
                    <button type="button" class="re-colbtn" id="btnCols">Columns &#9662;</button>
                    <div class="re-colpop" id="colPop"></div>
                </span>
            </span>
        </div>
        <div class="re-card__b" style="padding:0;">
            <div class="re-tblwrap"><table class="re-tbl" id="reTable"><thead></thead><tbody></tbody></table></div>
        </div>
    </div>

    <div class="re-actions">
        <span class="re-seglbl">Format</span>
        <button type="button" class="re-btn re-btn--primary" id="btnXlsx">Export Excel</button>
        <button type="button" class="re-btn re-btn--primary" id="btnCsv">Export CSV</button>
        <button type="button" class="re-btn re-btn--ghost" id="btnPrint">Open Print View</button>
        <span class="re-total" id="reTotal">&nbsp;</span>
    </div>
    <div class="re-note">Statistics use derived NCHE grade bands (score-based). Student Summary CGPA &amp; class use the university's authoritative computation. Exports respect your access scope. Excel &amp; CSV return all rows in scope; the on-screen preview shows the first 100.</div>
    </div><!-- /reMain -->

    <input type="hidden" id="hdnConfig" name="hdnConfig" />
    <input type="hidden" id="hdnExportAction" name="hdnExportAction" />
</div>

<div class="md-loader" id="reLoader"><div><div class="md-spinner"></div><div class="md-loader__t">Working&hellip;</div></div></div>

<script type="text/javascript">
(function(){
'use strict';
var opts=null, gradeChart=null, classChart=null, mode='marks';
var hiddenSet={}, lastData=null, lastMode='';
function qs(id){ return document.getElementById(id); }
function setExportDisabled(dis){ ['btnXlsx','btnCsv','btnPrint','btnXlsxTop','btnCsvTop','btnPrintTop'].forEach(function(id){ var b=qs(id); if(b) b.disabled=dis; }); }
function esc(s){ return s==null?'':String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function nfmt(v){ return (Number(v)||0).toLocaleString('en-US'); }
function setL(on){ var l=qs('reLoader'); if(l) l.className='md-loader'+(on?' show':''); }
function showErr(m){ var e=qs('reErr'); if(e){ e.textContent=m; e.className='re-err show'; } }
function hideErr(){ var e=qs('reErr'); if(e) e.className='re-err'; }

function ajax(method,params,cb){
    var xhr=new XMLHttpRequest();
    xhr.open('POST','ResultsExporter.aspx/'+method,true);
    xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
    xhr.timeout=120000;
    xhr.onload=function(){ try{ var o=JSON.parse(xhr.responseText); cb(typeof o.d==='string'?JSON.parse(o.d):o.d); }catch(e){ cb({success:false,message:'Server did not return valid data (it may be warming up — retry).'}); } };
    xhr.onerror=function(){ cb({success:false,message:'Network error.'}); };
    xhr.ontimeout=function(){ cb({success:false,message:'The request took too long — narrow the filters and retry.'}); };
    xhr.send(JSON.stringify(params||{}));
}

function fill(id,items,allLabel){
    var el=qs(id); if(!el)return;
    var h = allLabel!=null ? '<option value="">'+esc(allLabel)+'</option>' : '';
    (items||[]).forEach(function(it){ h+='<option value="'+esc(it.value)+'" data-fac="'+esc(it.faculty||'')+'" data-dep="'+esc(it.department||'')+'">'+esc(it.text)+'</option>'; });
    el.innerHTML=h;
}
function hiddenArr(){ var a=[]; for(var k in hiddenSet){ if(hiddenSet[k]) a.push(Number(k)); } return a; }
function config(){
    var c={ mode:mode, source:qs('fSource').value, acadYear:qs('fYear').value, semester:qs('fSem').value, studyYear:qs('fStudyYear').value,
        faculty:qs('fFaculty').value, department:qs('fDept').value, programme:qs('fProg').value, course:qs('fCourse').value.trim(),
        retakes:qs('fRetakes').value, grade:qs('fGrade').value, passfail:qs('fPassFail').value, hidden:hiddenArr() };
    qs('hdnConfig').value=JSON.stringify(c);
    return c;
}
function cascadeDept(){
    var fac=qs('fFaculty').value, sel=qs('fDept');
    for(var i=0;i<sel.options.length;i++){
        var o=sel.options[i]; if(!o.value){ o.style.display=''; continue; }
        o.style.display=(!fac || o.getAttribute('data-fac')===fac)?'':'none';
    }
    if(sel.selectedOptions && sel.selectedOptions[0] && sel.selectedOptions[0].style.display==='none') sel.value='';
}
function cascadeProg(){
    var fac=qs('fFaculty').value, dep=qs('fDept').value, sel=qs('fProg');
    for(var i=0;i<sel.options.length;i++){
        var o=sel.options[i]; if(!o.value){ o.style.display=''; continue; }
        var okFac=(!fac || o.getAttribute('data-fac')===fac);
        var okDep=(!dep || o.getAttribute('data-dep')===dep);
        o.style.display=(okFac && okDep)?'':'none';
    }
    if(sel.selectedOptions && sel.selectedOptions[0] && sel.selectedOptions[0].style.display==='none') sel.value='';
}

function renderStats(s){
    if(!s) return;
    qs('kRec').textContent=nfmt(s.records);
    qs('kStu').textContent=nfmt(s.students);
    qs('kCrs').textContent=nfmt(s.courses);
    qs('kMean').textContent=(Number(s.meanScore)||0).toFixed(1);
    qs('kPass').textContent=(Number(s.passRate)||0).toFixed(1)+'%';
    qs('kGp').textContent=(Number(s.meanGp)||0).toFixed(2);
    var labels=(s.grades||[]).map(function(x){return x.name;});
    var data=(s.grades||[]).map(function(x){return Number(x.count)||0;});
    var colors=['#16a34a','#22a06b','#174DA4','#2f6fbf','#5b8def','#d97706','#e08e0b','#dc3545'];
    if(gradeChart) gradeChart.destroy();
    gradeChart=new Chart(qs('chGrade').getContext('2d'),{ type:'bar',
        data:{ labels:labels, datasets:[{ data:data, backgroundColor:colors }] },
        options:{ responsive:true, maintainAspectRatio:false, plugins:{legend:{display:false}},
            scales:{ y:{beginAtZero:true,ticks:{font:{size:9}},grid:{color:'#f0f2f6'}}, x:{ticks:{font:{size:10}},grid:{display:false}} } } });

    var clabels=(s.classes||[]).map(function(x){return x.name;});
    var cdata=(s.classes||[]).map(function(x){return Number(x.count)||0;});
    var ccolors=['#16a34a','#174DA4','#2f6fbf','#d97706','#dc3545'];
    if(classChart) classChart.destroy();
    classChart=new Chart(qs('chClass').getContext('2d'),{ type:'doughnut',
        data:{ labels:clabels, datasets:[{ data:cdata, backgroundColor:ccolors }] },
        options:{ responsive:true, maintainAspectRatio:false, plugins:{legend:{position:'right',labels:{font:{size:10},boxWidth:12}}} } });
}
function visible(i){ return !hiddenSet[i]; }
function renderTable(){
    if(!lastData) return;
    var cols=lastData.columns||[], rows=lastData.rows||[];
    var th=qs('reTable').getElementsByTagName('thead')[0];
    var tb=qs('reTable').getElementsByTagName('tbody')[0];
    th.innerHTML='<tr>'+cols.map(function(c,i){return visible(i)?('<th>'+esc(c)+'</th>'):'';}).join('')+'</tr>';
    var vis=cols.filter(function(c,i){return visible(i);}).length;
    if(!rows.length){ tb.innerHTML='<tr><td colspan="'+Math.max(1,vis)+'" style="text-align:center;color:#9098a5;padding:24px;">No results match the selected filters.</td></tr>'; }
    else tb.innerHTML=rows.map(function(r){ return '<tr>'+r.map(function(v,i){return visible(i)?('<td>'+esc(v)+'</td>'):'';}).join('')+'</tr>'; }).join('');
    qs('reTblMeta').textContent = nfmt(lastData.total)+' total · showing '+nfmt(lastData.previewCount);
    qs('reTotal').textContent = nfmt(lastData.total)+' rows in scope';
    var none = !lastData.total || lastData.total===0;
    setExportDisabled(none);
}
function buildCols(cols){
    var pop=qs('colPop'); pop.innerHTML='';
    (cols||[]).forEach(function(c,i){
        var lbl=document.createElement('label');
        var cb=document.createElement('input'); cb.type='checkbox'; cb.checked=visible(i); cb.setAttribute('data-i',i);
        cb.addEventListener('change',function(){ hiddenSet[i]=!cb.checked; renderTable(); });
        lbl.appendChild(cb); lbl.appendChild(document.createTextNode(' '+c));
        pop.appendChild(lbl);
    });
}
function renderSubmission(sub){
    var box=qs('rePipe');
    if(!sub || !sub.total){ box.innerHTML='<div style="font-size:10px;color:#9098a5;">No registration/marks pipeline rows for this scope.</div>'; return; }
    var stages=[['Not Entered',sub.notEntered,'#c3c9d4'],['Entered',sub.entered,'#f0a52b'],['Captured',sub.captured,'#17a2b8'],['Approved',sub.approved,'#2f6fbf'],['Published',sub.published,'#16a34a']];
    var t=Number(sub.total)||1;
    var h='<div class="re-pipe__hd"><span><span class="re-pipe__pct">'+(Number(sub.pctPublished)||0).toFixed(1)+'%</span> <span class="re-pipe__pctl">published</span></span><span style="font-size:9px;color:#888;">'+nfmt(sub.total)+' course regs</span></div>';
    stages.forEach(function(s){
        var w=Math.max(0,Math.round((Number(s[1])||0)*100/t));
        h+='<div class="re-stage"><span class="re-stage__l">'+esc(s[0])+'</span><span class="re-stage__bar"><span style="width:'+w+'%;background:'+s[2]+';"></span></span><span class="re-stage__n">'+nfmt(s[1])+'</span></div>';
    });
    box.innerHTML=h;
}
function perfList(el,arr,hi){
    var ul=qs(el);
    if(!arr||!arr.length){ ul.innerHTML='<li style="color:#9098a5;">No data.</li>'; return; }
    ul.innerHTML=arr.map(function(p,i){
        return '<li><span class="rk">'+(i+1)+'</span><span class="nm">'+esc(p.name||p.regno)+' <small>'+esc(p.regno)+'</small></span><span class="gp '+(hi?'gp--hi':'gp--lo')+'">'+(Number(p.gpa)||0).toFixed(2)+'</span></li>';
    }).join('');
}
var MODE_TITLE={marks:'Marks Sheet (detailed)',summary:'Student Results Summary',course_stats:'Course Performance Statistics',prog_stats:'Programme / Faculty Statistics'};

function renderBreakdown(bd){
    var card=qs('reBreakCard');
    var th=qs('reBreakTable').getElementsByTagName('thead')[0];
    var tb=qs('reBreakTable').getElementsByTagName('tbody')[0];
    if(!bd||!bd.columns||!bd.columns.length){ card.style.display='none'; return; }
    card.style.display='';
    qs('reBreakTitle').textContent=bd.title||'Performance breakdown';
    qs('reBreakMeta').textContent=nfmt((bd.rows||[]).length)+' rows';
    th.innerHTML='<tr>'+bd.columns.map(function(c){return '<th>'+esc(c)+'</th>';}).join('')+'</tr>';
    if(!bd.rows||!bd.rows.length){ tb.innerHTML='<tr><td colspan="'+bd.columns.length+'" style="text-align:center;color:#9098a5;padding:16px;">No data for this selection.</td></tr>'; }
    else tb.innerHTML=bd.rows.map(function(r){ return '<tr>'+r.map(function(v){return '<td>'+esc(v)+'</td>';}).join('')+'</tr>'; }).join('');
}
function srcNote(source,label){
    var el=qs('reSrcNote'); if(!el) return;
    if(source && source!=='published'){
        el.style.display='';
        el.innerHTML='<strong>'+esc(label||source)+'.</strong> These marks are not yet published, so grades, grade points and GPA are computed on the fly from raw scores (NCHE 2015 bands) and are indicative until published.';
    } else { el.style.display='none'; }
}

function preview(){
    hideErr(); setL(true);
    if(mode!==lastMode){ hiddenSet={}; lastMode=mode; }   // columns differ per mode → reset
    var c=config();
    ajax('GetPreview',{ configJson: JSON.stringify(c) }, function(d){
        setL(false);
        if(!d||!d.success){ showErr((d&&d.message)||'Unable to build preview.'); return; }
        qs('reTblTitle').textContent=MODE_TITLE[d.mode]||'Preview';
        srcNote(d.source, d.sourceLabel);
        renderStats(d.stats);
        renderSubmission(d.submission);
        renderBreakdown(d.breakdown);
        perfList('rePerfTop', d.stats?d.stats.topPerformers:[], true);
        perfList('rePerfBot', d.stats?d.stats.bottomPerformers:[], false);
        lastData={ columns:d.columns, rows:d.rows, total:d.total, previewCount:d.previewCount };
        buildCols(d.columns);
        renderTable();
    });
}
function doExport(action){
    config();
    qs('hdnExportAction').value=action;
    var f=document.forms[0]; f.submit();
    setTimeout(function(){ qs('hdnExportAction').value=''; },1500);
}
function doPrint(){
    hideErr(); setL(true); var c=config();
    ajax('GetPrintHtml',{ configJson: JSON.stringify(c) }, function(d){
        setL(false);
        if(!d||!d.success){ showErr((d&&d.message)||'Unable to build print view.'); return; }
        var w=window.open('','_blank'); if(!w){ showErr('Pop-up blocked — allow pop-ups to open the print view.'); return; }
        w.document.open(); w.document.write(d.html); w.document.close();
    });
}

function init(){
    setL(true);
    ajax('GetFilterOptions',{},function(o){
        setL(false);
        if(!o||!o.success){ showErr((o&&o.message)||'Unable to load filters.'); return; }
        qs('reScope').textContent=(o.roleNote||'')+(o.scopeLabel?(' · '+o.scopeLabel):'');
        if(!o.hasAccess){ qs('reMain').style.display='none'; var na=qs('reNoAccess'); na.style.display='block'; na.textContent='Your account is not linked to any faculty or department, so no results data is available. Contact the administrator if this is unexpected.'; return; }
        opts=o;
        fill('fYear',o.years,'All years');
        fill('fFaculty',o.faculties,'All faculties');
        fill('fDept',o.departments,'All departments');
        fill('fProg',o.programmes,'All programmes');
        if(o.currentYear) qs('fYear').value=o.currentYear;
        preview();
    });
}

document.addEventListener('DOMContentLoaded',function(){
    qs('btnApply').addEventListener('click',preview);
    qs('btnCols').addEventListener('click',function(e){ e.stopPropagation(); qs('colPop').classList.toggle('show'); });
    document.addEventListener('click',function(e){ var p=qs('colPop'); if(p&&!p.contains(e.target)&&e.target!==qs('btnCols')) p.classList.remove('show'); });
    qs('btnXlsx').addEventListener('click',function(){ doExport('xlsx'); });
    qs('btnCsv').addEventListener('click',function(){ doExport('csv'); });
    qs('btnPrint').addEventListener('click',doPrint);
    qs('btnXlsxTop').addEventListener('click',function(){ doExport('xlsx'); });
    qs('btnCsvTop').addEventListener('click',function(){ doExport('csv'); });
    qs('btnPrintTop').addEventListener('click',doPrint);
    qs('fFaculty').addEventListener('change',function(){ cascadeDept(); cascadeProg(); });
    qs('fDept').addEventListener('change',cascadeProg);
    qs('fSource').addEventListener('change',preview);
    qs('btnReset').addEventListener('click',function(){
        ['fSem','fStudyYear','fFaculty','fDept','fProg','fGrade'].forEach(function(id){ qs(id).value=''; });
        qs('fCourse').value=''; qs('fRetakes').value='all'; qs('fPassFail').value='all'; qs('fSource').value='published';
        if(opts&&opts.currentYear) qs('fYear').value=opts.currentYear;
        cascadeDept(); cascadeProg(); preview();
    });
    var mb=qs('segMode').querySelectorAll('button');
    for(var i=0;i<mb.length;i++){ (function(btn){ btn.addEventListener('click',function(){
        for(var j=0;j<mb.length;j++) mb[j].classList.remove('on'); btn.classList.add('on');
        mode=btn.getAttribute('data-mode'); preview();
    }); })(mb[i]); }
    init();
});
})();
</script>
</asp:Content>
