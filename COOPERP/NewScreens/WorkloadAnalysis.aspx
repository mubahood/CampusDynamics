<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="WorkloadAnalysis.aspx.cs" Inherits="COOPERP_NewScreens_WorkloadAnalysis" Title="Workload Analysis - Campus Dynamics" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== WORKLOAD ANALYSIS (timetable-driven) — prefix wa- / ttd- ========= */
.wa-wrap{padding:2px 2px 8px;}
.wa-top{display:flex;align-items:flex-end;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:9px;}
.wa-h__t{font-size:17px;font-weight:800;color:#05275C;line-height:1.1;}
.wa-h__s{font-size:11px;color:#6b7280;margin-top:2px;}
.wa-top__act{display:flex;gap:6px;}
.wa-btn{display:inline-flex;align-items:center;gap:5px;padding:6px 11px;border:1px solid #d2dae6;background:#fff;color:#05275C;text-decoration:none;font-size:11.5px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;height:31px;box-sizing:border-box;}
.wa-btn:hover{border-color:#174DA4;color:#174DA4;}
.wa-btn--p{background:#05275C;border-color:#05275C;color:#fff;}.wa-btn--p:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.wa-card{background:#fff;border:1px solid #e0e5ed;}
/* filters — one compact row */
.wa-filters{display:flex;gap:7px;align-items:flex-end;flex-wrap:wrap;padding:9px 10px;border-bottom:1px solid #eef1f5;}
.wa-fl{display:flex;flex-direction:column;gap:2px;}
.wa-fl>span{font-size:8px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:#9aa6b8;padding-left:1px;}
.wa-sel,.wa-in{border:1px solid #cfd8e3;background:#fff;padding:6px 8px;font-size:12px;color:#1f2937;border-radius:0;font-family:inherit;height:31px;box-sizing:border-box;}
.wa-sel:focus,.wa-in:focus{outline:none;border-color:#174DA4;}
.wa-fl__sp{flex:1;}
/* searchable combo */
.wa-combo{position:relative;} .wa-combo>input{width:100%;box-sizing:border-box;}
.wa-combo__list{position:absolute;top:100%;left:0;right:0;z-index:60;background:#fff;border:1px solid #cfd8e3;max-height:250px;overflow:auto;display:none;box-shadow:0 6px 18px rgba(0,0,0,.13);}
.wa-combo__list.on{display:block;}
.wa-combo__i{padding:7px 10px;font-size:12px;cursor:pointer;border-bottom:1px solid #f0f2f5;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.wa-combo__i:hover{background:#eef4ff;} .wa-combo__i--none{color:#9ca3af;cursor:default;}
/* stats strip */
.wa-meta{display:flex;align-items:stretch;flex-wrap:wrap;border-bottom:1px solid #eef1f5;}
.wa-stat{padding:8px 15px;border-right:1px solid #eef1f5;min-width:82px;}
.wa-stat__n{font-size:17px;font-weight:800;color:#05275C;line-height:1;font-variant-numeric:tabular-nums;}
.wa-stat__n.warn{color:#c62828;} .wa-stat__n.heavy{color:#e65100;}
.wa-stat__l{font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#9aa6b8;margin-top:3px;}
/* table */
.wa-table{width:100%;border-collapse:collapse;font-size:11.5px;}
.wa-table th{background:#f5f7fa;padding:7px 12px;text-align:left;font-size:10px;text-transform:uppercase;letter-spacing:.3px;color:#555;font-weight:700;border-bottom:2px solid #e0e5ed;white-space:nowrap;}
.wa-table th.num{text-align:center;}
.wa-table td{padding:6px 12px;border-bottom:1px solid #f0f2f5;color:#1a1a2e;vertical-align:middle;}
.wa-table td.num{text-align:center;font-variant-numeric:tabular-nums;}
.wa-table tbody tr{cursor:pointer;}
.wa-table tbody tr:hover{background:#f0f4ff;}
.wa-table tfoot .wa-total td{position:sticky;bottom:0;background:#eef2f8;border-top:2px solid #05275C;font-weight:800;color:#05275C;padding:8px 12px;font-size:11.5px;}
.wa-rank{color:#b0b8c6;font-size:10px;font-weight:700;width:22px;text-align:center;}
.wa-badge{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;}
.wa-badge--normal{background:#e6f4ea;color:#2e7d32;} .wa-badge--heavy{background:#fff3e0;color:#e65100;} .wa-badge--overloaded{background:#fce4ec;color:#c62828;}
.wa-bar-wrap{width:82px;height:7px;background:#e8ebef;display:inline-block;vertical-align:middle;}
.wa-bar{height:7px;display:block;}
.wa-bar--green{background:#2e7d32;} .wa-bar--orange{background:#e65100;} .wa-bar--red{background:#c62828;}
.wa-empty{text-align:center;color:#94a3b8;padding:34px;font-size:13px;}
.wa-loading{text-align:center;color:#174DA4;padding:24px;font-size:12px;}
/* detail drawer (shared look with the calendar) */
.ttd-ov{position:fixed;inset:0;background:rgba(9,20,40,.44);z-index:1000;display:none;justify-content:flex-end;}
.ttd-ov.on{display:flex;}
.ttd-drawer{width:430px;max-width:95vw;height:100%;background:#f5f7fa;box-shadow:-8px 0 28px rgba(0,0,0,.22);overflow-y:auto;position:relative;animation:ttdslide .18s ease-out;}
@keyframes ttdslide{from{transform:translateX(26px);opacity:.4;}to{transform:translateX(0);opacity:1;}}
.ttd-x{position:absolute;top:10px;right:10px;z-index:2;width:30px;height:30px;border:0;background:rgba(255,255,255,.18);color:#fff;font-size:20px;line-height:1;cursor:pointer;}
.ttd-x:hover{background:rgba(255,255,255,.34);}
.ttd-top{padding:20px 20px 18px;color:#fff;background:#05275C;border-left:5px solid #9db6e0;}
.ttd-top--heavy{background:#8a4b12;border-left-color:#f0b070;} .ttd-top--overloaded{background:#8a1b3c;border-left-color:#f090ac;}
.ttd-badge{display:inline-block;font-size:9.5px;font-weight:800;text-transform:uppercase;letter-spacing:.6px;background:rgba(255,255,255,.20);padding:3px 9px;margin-bottom:10px;}
.ttd-name{font-size:20px;font-weight:800;letter-spacing:-.2px;}
.ttd-sub{font-size:12px;opacity:.9;margin-top:3px;}
.ttd-kpis{display:flex;background:#fff;border-bottom:1px solid #e0e5ed;}
.ttd-kpi{flex:1;padding:12px 10px;text-align:center;border-right:1px solid #eef2f6;}
.ttd-kpi:last-child{border-right:0;}
.ttd-kpi__n{font-size:18px;font-weight:800;color:#05275C;line-height:1;font-variant-numeric:tabular-nums;}
.ttd-kpi__l{font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#94a3b8;margin-top:4px;}
.ttd-day{font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;background:#eef2f8;padding:5px 20px;border-top:1px solid #e0e5ed;}
.ttd-sess{display:flex;gap:10px;padding:9px 20px;background:#fff;border-bottom:1px solid #f0f2f5;}
.ttd-sess__t{font-size:11.5px;font-weight:800;color:#05275C;min-width:82px;white-space:nowrap;}
.ttd-sess__m{flex:1;min-width:0;}
.ttd-sess__m b{font-size:12px;color:#1a1a2e;display:block;}
.ttd-sess__m span{font-size:10.5px;color:#6b7280;display:block;margin-top:1px;}
.ttd-actions{padding:16px 20px 22px;display:flex;flex-direction:column;gap:8px;}
.ttd-abtn{display:flex;align-items:center;justify-content:center;gap:8px;font-size:12.5px;font-weight:700;padding:11px 12px;text-decoration:none;border:1px solid #cdd8e6;background:#fff;color:#05275C;cursor:pointer;font-family:inherit;text-align:center;}
.ttd-abtn--p{background:#05275C;border-color:#05275C;color:#fff;}.ttd-abtn--p:hover{background:#174DA4;border-color:#174DA4;}
.ttd-abtn--s:hover{border-color:#174DA4;color:#174DA4;}
.ttd-ic{flex-shrink:0;display:block;}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="wa-wrap">
  <div class="wa-top">
    <div>
      <div class="wa-h__t">Workload Analysis</div>
      <div class="wa-h__s" id="waSub">Loading&hellip;</div>
    </div>
    <div class="wa-top__act">
      <a class="wa-btn" href="TimetableCalendar.aspx">Calendar</a>
      <button type="button" class="wa-btn" onclick="WA.csv()">&#8681; CSV</button>
      <button type="button" class="wa-btn wa-btn--p" onclick="WA.print()">&#128424; Print / PDF</button>
    </div>
  </div>

  <div class="wa-card">
    <div class="wa-filters">
      <div class="wa-fl"><span>Semester</span><select id="fSem" class="wa-sel" onchange="WA.reload()"><option value="0">All</option><option value="1">Semester 1</option><option value="2">Semester 2</option><option value="3">Semester 3</option></select></div>
      <div class="wa-fl"><span>Campus</span><select id="fCampus" class="wa-sel" onchange="WA.reload()"><option value="0">All</option></select></div>
      <div class="wa-fl" style="min-width:180px;"><span>Faculty</span><div id="cFac"></div></div>
      <div class="wa-fl" style="min-width:190px;"><span>Programme</span><div id="cProg"></div></div>
      <div class="wa-fl"><span>Contract</span><select id="fContract" class="wa-sel" onchange="WA.refine()"><option value="">All</option><option value="FULL TIME">Full Time</option><option value="PART TIME">Part Time</option></select></div>
      <div class="wa-fl" style="min-width:160px;"><span>Search lecturer</span><input type="text" id="fQ" class="wa-in" placeholder="Name / EMP / dept&hellip;" oninput="WA.refine()" /></div>
      <div class="wa-fl__sp"></div>
      <div class="wa-fl"><span>Sort by</span><select id="fSort" class="wa-sel" onchange="WA.refine()"><option value="hours">Hours (high&rarr;low)</option><option value="sessions">Sessions</option><option value="courses">Courses</option><option value="name">Name (A&rarr;Z)</option></select></div>
      <div class="wa-fl"><span>&nbsp;</span><button type="button" class="wa-btn" onclick="WA.reset()">Clear</button></div>
    </div>
    <div class="wa-meta" id="waMeta" style="display:none;">
      <div class="wa-stat"><div class="wa-stat__n" id="stLect">0</div><div class="wa-stat__l">Lecturers</div></div>
      <div class="wa-stat"><div class="wa-stat__n" id="stAvg">0</div><div class="wa-stat__l">Avg hrs / wk</div></div>
      <div class="wa-stat"><div class="wa-stat__n" id="stOver">0</div><div class="wa-stat__l">Overloaded &gt;18h</div></div>
      <div class="wa-stat"><div class="wa-stat__n" id="stHeavy">0</div><div class="wa-stat__l">Heavy &gt;12h</div></div>
      <div class="wa-stat"><div class="wa-stat__n" id="stSess">0</div><div class="wa-stat__l">Weekly sessions</div></div>
      <div class="wa-stat"><div class="wa-stat__n" id="stHrs">0</div><div class="wa-stat__l">Total hrs / wk</div></div>
      <div class="wa-stat"><div class="wa-stat__n" id="stHrsMo">0</div><div class="wa-stat__l">Total hrs / mo</div></div>
    </div>
    <div id="waHost"><div class="wa-loading">Loading workload&hellip;</div></div>
  </div>
</div>

<div class="ttd-ov" id="ttdOv"><div class="ttd-drawer"><button type="button" class="ttd-x" onclick="WA.closeDetail()">&times;</button><div class="ttd-body"></div></div></div>

<script type="text/javascript">window.__WA_INIT = <%= InitJson %>;</script>
<script type="text/javascript">
var WA = (function(){
  var _rows=[], _details={}, _faculties=[], _programmes=[], _campuses=[], VIS=[], CURDET=null;
  var facCombo=null, progCombo=null;
  var HEAVY=12, OVER=18, WPM=4.33;   // weeks per month (52/12) for monthly-hour projection
  function monthly(w){ return (w||0)*WPM; }
  var DAYFULL=['','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
  var DAYORD={Mon:1,Tue:2,Wed:3,Thu:4,Fri:5,Sat:6,Sun:7};
  function qs(id){return document.getElementById(id);}
  function esc(s){s=(s==null?'':''+s);return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}

  function makeCombo(host, items, placeholder, onPick){
    host.className='wa-combo';
    host.innerHTML='<input type="text" class="wa-in" placeholder="'+esc(placeholder)+'" autocomplete="off"><div class="wa-combo__list"></div>';
    var inp=host.querySelector('input'), list=host.querySelector('.wa-combo__list'), val='';
    function draw(f){
      f=(f||'').toLowerCase();
      var m=items.filter(function(it){ return !f || (it.label||'').toLowerCase().indexOf(f)>=0; });
      if(!m.length){ list.innerHTML='<div class="wa-combo__i wa-combo__i--none">No match</div>'; return; }
      list.innerHTML=m.slice(0,80).map(function(it){ return '<div class="wa-combo__i" data-v="'+esc(it.value)+'" title="'+esc(it.label)+'">'+esc(it.label)+'</div>'; }).join('');
      Array.prototype.forEach.call(list.querySelectorAll('.wa-combo__i[data-v]'),function(el){ el.onmousedown=function(e){ e.preventDefault(); val=el.getAttribute('data-v'); inp.value=el.textContent; list.classList.remove('on'); if(onPick) onPick(val); }; });
    }
    inp.addEventListener('focus',function(){ draw(inp.value); list.classList.add('on'); });
    inp.addEventListener('input',function(){ val=''; draw(inp.value); list.classList.add('on'); });
    inp.addEventListener('blur',function(){ setTimeout(function(){ list.classList.remove('on'); },150); });
    return { value:function(){return val;}, set:function(v){ var it=items.filter(function(x){return String(x.value)===String(v);})[0]; if(it){val=it.value;inp.value=it.label;} else {val='';inp.value='';} }, setItems:function(n){ items=n||[]; } };
  }

  /* ── GET state ── */
  function readQuery(){ var q={}, s=(location.search||'').replace(/^\?/,''); s.split('&').forEach(function(kv){ if(!kv) return; var p=kv.split('='); q[decodeURIComponent(p[0])]=decodeURIComponent((p[1]||'').replace(/\+/g,' ')); }); return q; }
  function syncUrl(){
    var parts=[];
    function add(k,v){ if(v&&v!=='0'&&v!=='') parts.push(k+'='+encodeURIComponent(v)); }
    add('sem',qs('fSem').value); add('campus',qs('fCampus').value);
    add('fac',facCombo?facCombo.value():''); add('prog',progCombo?progCombo.value():'');
    add('contract',qs('fContract').value); add('q',qs('fQ').value.trim());
    if(qs('fSort').value!=='hours') parts.push('sort='+encodeURIComponent(qs('fSort').value));
    try{ history.replaceState(null,'',location.pathname+(parts.length?('?'+parts.join('&')):'')); }catch(e){}
  }

  // Semester/Campus change = a real page navigation (server scope), carrying the
  // client-side filters along so they survive the reload. No AJAX.
  function reload(){
    var parts=['sem='+encodeURIComponent(qs('fSem').value||'0'),'campus='+encodeURIComponent(qs('fCampus').value||'0')];
    function add(k,v){ if(v&&v!=='') parts.push(k+'='+encodeURIComponent(v)); }
    add('fac',facCombo?facCombo.value():''); add('prog',progCombo?progCombo.value():'');
    add('contract',qs('fContract').value); add('q',qs('fQ').value.trim());
    if(qs('fSort').value!=='hours') add('sort',qs('fSort').value);
    location.href='WorkloadAnalysis.aspx?'+parts.join('&');
  }

  function init(){
    var q=readQuery();
    if(q.sort) qs('fSort').value=q.sort;
    if(q.contract) qs('fContract').value=q.contract;
    if(q.q) qs('fQ').value=q.q;
    var d=window.__WA_INIT||{};
    if(!d.ok){ showEmpty(d.error||'Unable to load workload.'); return; }
    _rows=d.rows||[]; _details=d.details||{}; _faculties=d.faculties||[]; _programmes=d.programmes||[]; _campuses=d.campuses||[];
    qs('fSem').value=String(d.semester||'0');
    buildFilters(q, String(d.campusId||'0'));
    refine();
  }

  function buildFilters(restore, campusVal){
    var ch='<option value="0">All</option>'; _campuses.forEach(function(c){ ch+='<option value="'+esc(c.id)+'">'+esc(c.name)+'</option>'; }); qs('fCampus').innerHTML=ch;
    qs('fCampus').value=campusVal||'0';
    facCombo=makeCombo(qs('cFac'), [{value:'',label:'All faculties'}].concat(_faculties.map(function(f){return {value:f.code,label:f.name};})), 'All faculties', function(){ syncUrl(); render(); });
    progCombo=makeCombo(qs('cProg'), [{value:'',label:'All programmes'}].concat(_programmes.map(function(p){return {value:p.code,label:p.display};})), 'All programmes', function(){ syncUrl(); render(); });
    facCombo.set(restore&&restore.fac?restore.fac:''); progCombo.set(restore&&restore.prog?restore.prog:'');
  }

  function matchRow(r){
    var fac=facCombo?facCombo.value():'', prog=progCombo?progCombo.value():'', contract=qs('fContract').value, q=(qs('fQ').value||'').toLowerCase();
    if(fac){ if((r.faculties_list||[]).indexOf(fac)<0) return false; }
    if(prog){ if((r.programmes_list||[]).indexOf(prog)<0) return false; }
    if(contract && r.contractType!==contract) return false;
    if(q && (r.lecturerName+' '+r.empCode+' '+r.department).toLowerCase().indexOf(q)<0) return false;
    return true;
  }
  function sortRows(rows){
    var by=qs('fSort').value;
    return rows.slice().sort(function(a,b){
      if(by==='name') return (a.lecturerName||'').localeCompare(b.lecturerName||'');
      if(by==='sessions') return b.sessionCount-a.sessionCount;
      if(by==='courses') return b.courseCount-a.courseCount;
      return b.weeklyHours-a.weeklyHours;
    });
  }
  function refine(){ syncUrl(); render(); }
  function render(){ VIS=sortRows(_rows.filter(matchRow)); renderStats(); renderGrid(); }

  function band(h){ if(h>OVER) return {bar:'wa-bar--red',badge:'wa-badge--overloaded',label:'Overloaded',top:'ttd-top--overloaded'}; if(h>HEAVY) return {bar:'wa-bar--orange',badge:'wa-badge--heavy',label:'Heavy',top:'ttd-top--heavy'}; return {bar:'wa-bar--green',badge:'wa-badge--normal',label:'Normal',top:''}; }

  function renderStats(){
    if(!_rows.length){ qs('waMeta').style.display='none'; } else qs('waMeta').style.display='flex';
    var hrs=0,sess=0,over=0,heavy=0;
    VIS.forEach(function(r){ hrs+=r.weeklyHours; sess+=r.sessionCount; if(r.weeklyHours>OVER) over++; else if(r.weeklyHours>HEAVY) heavy++; });
    qs('stLect').textContent=VIS.length;
    qs('stAvg').textContent=VIS.length?(hrs/VIS.length).toFixed(1):'0';
    var eo=qs('stOver'); eo.textContent=over; eo.className='wa-stat__n'+(over?' warn':'');
    var eh=qs('stHeavy'); eh.textContent=heavy; eh.className='wa-stat__n'+(heavy?' heavy':'');
    qs('stSess').textContent=sess;
    qs('stHrs').textContent=Math.round(hrs);
    qs('stHrsMo').textContent=Math.round(monthly(hrs));
    var semSel=qs('fSem'), camSel=qs('fCampus');
    var scope=(semSel.value==='0'?'All semesters':'Semester '+semSel.value)+' · '+(camSel.selectedOptions[0]?camSel.selectedOptions[0].text:'All')+' campus';
    qs('waSub').textContent=scope+' · from active timetable · '+VIS.length+' lecturer'+(VIS.length===1?'':'s')+' · '+Math.round(hrs)+' contact hrs/week';
  }

  function renderGrid(){
    if(!VIS.length){ qs('waHost').innerHTML='<div class="wa-empty">No timetable sessions found for the selected scope / filters.</div>'; return; }
    VIS.forEach(function(r,i){ r._i=i; });
    var tSess=0,tWk=0,tCourse=0,tProg=0;
    var h='<table class="wa-table"><thead><tr><th class="wa-rank">#</th><th>Lecturer</th><th>EMP</th><th>Department</th><th>Contract</th>'
      +'<th class="num">Sessions</th><th class="num">Hrs/wk</th><th class="num" title="Weekly hours &times; 4.33">Hrs/mo</th><th class="num">Courses</th><th class="num">Progs</th><th>Load</th><th>Status</th></tr></thead><tbody>';
    VIS.forEach(function(r,i){
      var b=band(r.weeklyHours), pct=Math.min(r.weeklyHours/24*100,100);
      tSess+=r.sessionCount; tWk+=r.weeklyHours; tCourse+=r.courseCount; tProg+=r.programmeCount;
      h+='<tr data-idx="'+i+'" title="Click for the weekly breakdown">'
        +'<td class="wa-rank">'+(i+1)+'</td>'
        +'<td><strong>'+esc(r.lecturerName)+'</strong></td>'
        +'<td>'+esc(r.empCode)+'</td>'
        +'<td>'+esc(r.department)+'</td>'
        +'<td>'+esc(r.contractType||'—')+'</td>'
        /* Classes actually held. Where several cohorts share a class the extra timetable rows
           are noted rather than counted, so the figure is not silently smaller than the list. */
        +'<td class="num" style="font-weight:700;">'+r.sessionCount
          +(r.itemCount>r.sessionCount
              ? '<span style="display:block;font-weight:400;font-size:9.5px;color:#b45309;" title="'
                +(r.itemCount-r.sessionCount)+' further timetable row(s) share these classes — cohorts taught together, counted once">+'
                +(r.itemCount-r.sessionCount)+' shared</span>'
              : '')
        +'</td>'
        +'<td class="num" style="font-weight:700;">'+r.weeklyHours.toFixed(1)+'</td>'
        +'<td class="num">'+monthly(r.weeklyHours).toFixed(1)+'</td>'
        +'<td class="num">'+r.courseCount+'</td>'
        +'<td class="num">'+r.programmeCount+'</td>'
        +'<td><span class="wa-bar-wrap"><span class="wa-bar '+b.bar+'" style="width:'+pct+'%;"></span></span></td>'
        +'<td><span class="wa-badge '+b.badge+'">'+b.label+'</span></td></tr>';
    });
    h+='</tbody><tfoot><tr class="wa-total"><td></td><td>TOTAL &mdash; '+VIS.length+' lecturer'+(VIS.length===1?'':'s')+'</td><td></td><td></td><td></td>'
      +'<td class="num">'+tSess+'</td><td class="num">'+tWk.toFixed(1)+'</td><td class="num">'+monthly(tWk).toFixed(1)+'</td>'
      +'<td class="num">'+tCourse+'</td><td class="num">'+tProg+'</td><td></td><td></td></tr></tfoot></table>';
    qs('waHost').innerHTML=h;
    var host=qs('waHost');
    host.onclick=function(e){ var t=e.target; while(t&&t!==host&&!t.getAttribute('data-idx')) t=t.parentNode; if(t&&t!==host){ var i=parseInt(t.getAttribute('data-idx'),10); if(!isNaN(i)) showDetail(VIS[i]); } };
  }

  /* ── detail drawer: full weekly breakdown for one lecturer ── */
  function showDetail(r){
    if(!r) return; CURDET=r;
    var b=band(r.weeklyHours);
    var items=(_details[r.staffCode]||[]).slice().sort(function(a,c){ return (DAYORD[a.day]||9)-(DAYORD[c.day]||9) || (a.startTime||'').localeCompare(c.startTime||''); });
    var cu={}; items.forEach(function(s){ if(s.courseCode) cu[s.courseCode]=s.creditUnit; });
    var totCU=0; for(var k in cu) if(cu.hasOwnProperty(k)) totCU+=cu[k];
    var h='<div class="ttd-top '+b.top+'"><span class="ttd-badge">'+esc(b.label)+' workload</span>'
      +'<div class="ttd-name">'+esc(r.lecturerName)+'</div>'
      +'<div class="ttd-sub">'+esc(r.department||'—')+(r.contractType?(' · '+esc(r.contractType)):'')+(r.empCode?(' · '+esc(r.empCode)):'')+'</div></div>';
    h+='<div class="ttd-kpis">'
      +'<div class="ttd-kpi"><div class="ttd-kpi__n">'+r.weeklyHours.toFixed(1)+'</div><div class="ttd-kpi__l">Hrs / week</div></div>'
      +'<div class="ttd-kpi"><div class="ttd-kpi__n">'+monthly(r.weeklyHours).toFixed(1)+'</div><div class="ttd-kpi__l">Hrs / month</div></div>'
      +'<div class="ttd-kpi"><div class="ttd-kpi__n">'+r.sessionCount+'</div><div class="ttd-kpi__l">Sessions</div></div>'
      +'<div class="ttd-kpi"><div class="ttd-kpi__n">'+r.courseCount+'</div><div class="ttd-kpi__l">Courses</div></div>'
      +'<div class="ttd-kpi"><div class="ttd-kpi__n">'+totCU+'</div><div class="ttd-kpi__l">Credits</div></div></div>';
    if(!items.length){ h+='<div class="wa-empty">No sessions.</div>'; }
    else {
      var curDay='';
      items.forEach(function(s){
        if(s.day!==curDay){ curDay=s.day; h+='<div class="ttd-day">'+esc(DAYFULL[DAYORD[s.day]]||s.day||'Unscheduled')+'</div>'; }
        var loc=s.room?esc(s.room):'';
        h+='<div class="ttd-sess"><div class="ttd-sess__t">'+esc(s.startTime)+'–'+esc(s.endTime)+'</div>'
          +'<div class="ttd-sess__m"><b>'+esc(s.courseCode)+' · '+esc(s.courseName)+'</b>'
          +'<span>'+esc(s.progAbbrev)+' Yr'+esc(s.cyear)+' · '+esc(s.sessionType||'')+(loc?(' · '+loc):'')+' · '+(s.creditUnit||0)+' CU</span></div></div>';
      });
    }
    var calUrl='TimetableCalendar.aspx?teacher='+encodeURIComponent(r.staffCode);
    h+='<div class="ttd-actions"><a class="ttd-abtn ttd-abtn--p" href="'+esc(calUrl)+'">'
      +'<svg class="ttd-ic" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>'
      +'<span>View in timetable calendar</span></a>'
      +'<button type="button" class="ttd-abtn ttd-abtn--s" onclick="WA.copy()">'
      +'<svg class="ttd-ic" viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>'
      +'<span id="ttdCopyTxt">Copy summary</span></button></div>';
    qs('ttdOv').querySelector('.ttd-body').innerHTML=h;
    qs('ttdOv').classList.add('on');
  }
  function closeDetail(){ qs('ttdOv').classList.remove('on'); }
  function copy(){
    var r=CURDET; if(!r) return;
    var items=_details[r.staffCode]||[];
    var txt=r.lecturerName+' — '+r.weeklyHours.toFixed(1)+' hrs/week, '+r.sessionCount+' sessions, '+r.courseCount+' courses\n'
      +(r.department||'')+(r.contractType?(' · '+r.contractType):'')+'\n';
    items.forEach(function(s){ txt+='  '+(s.day||'—')+' '+s.startTime+'-'+s.endTime+'  '+s.courseCode+' '+s.courseName+' ('+(s.sessionType||'')+', '+(s.room||'—')+')\n'; });
    var done=function(){ var e=qs('ttdCopyTxt'); if(e){ var o=e.textContent; e.textContent='Copied!'; setTimeout(function(){e.textContent=o;},1400); } };
    if(navigator.clipboard&&navigator.clipboard.writeText){ navigator.clipboard.writeText(txt).then(done,function(){window.prompt('Copy:',txt);}); } else window.prompt('Copy:',txt);
  }
  qs('ttdOv').addEventListener('click',function(e){ if(e.target===qs('ttdOv')) closeDetail(); });
  document.addEventListener('keydown',function(e){ if(e.key==='Escape') closeDetail(); });

  function reset(){ qs('fSem').value='0'; qs('fCampus').value='0'; qs('fContract').value=''; qs('fQ').value=''; qs('fSort').value='hours'; if(facCombo)facCombo.set(''); if(progCombo)progCombo.set(''); reload(); }

  function showEmpty(m){ qs('waHost').innerHTML='<div class="wa-empty">'+esc(m)+'</div>'; qs('waMeta').style.display='none'; }

  /* ── CSV + branded print ── */
  function scopeMeta(){
    var m=[], sem=qs('fSem'), cam=qs('fCampus');
    m.push(sem.value==='0'?'All semesters':'Semester '+sem.value);
    if(cam.value!=='0'&&cam.selectedOptions[0]) m.push(cam.selectedOptions[0].text);
    if(facCombo&&facCombo.value()){ var f=_faculties.filter(function(x){return x.code===facCombo.value();})[0]; if(f) m.push(f.name); }
    if(progCombo&&progCombo.value()){ var p=_programmes.filter(function(x){return x.code===progCombo.value();})[0]; if(p) m.push(p.display); }
    if(qs('fContract').value) m.push(qs('fContract').value);
    return m;
  }
  function csvCell(v){ v=(v==null?'':''+v); if(/[",\n]/.test(v)) v='"'+v.replace(/"/g,'""')+'"'; return v; }
  function csv(){
    if(!VIS.length){ alert('No rows to export.'); return; }
    var head=['Rank','Lecturer','EMP','Department','Contract','Sessions','WeeklyHours','MonthlyHours','Courses','Programmes','Credits','Status'];
    var lines=[head.join(',')];
    var tSess=0,tWk=0,tCourse=0,tProg=0,tCU=0;
    VIS.forEach(function(r,i){
      tSess+=r.sessionCount; tWk+=r.weeklyHours; tCourse+=r.courseCount; tProg+=r.programmeCount; tCU+=r.totalCredits;
      lines.push([i+1,r.lecturerName,r.empCode,r.department,r.contractType,r.sessionCount,r.weeklyHours.toFixed(1),monthly(r.weeklyHours).toFixed(1),r.courseCount,r.programmeCount,r.totalCredits,band(r.weeklyHours).label].map(csvCell).join(','));
    });
    lines.push(['','TOTAL ('+VIS.length+' lecturers)','','','',tSess,tWk.toFixed(1),monthly(tWk).toFixed(1),tCourse,tProg,tCU,''].map(csvCell).join(','));
    var blob=new Blob([lines.join('\r\n')],{type:'text/csv;charset=utf-8;'});
    var a=document.createElement('a'); a.href=URL.createObjectURL(blob); a.download='workload_analysis.csv'; document.body.appendChild(a); a.click(); document.body.removeChild(a);
  }
  function print(){
    if(!VIS.length){ alert('No rows to print.'); return; }
    var hrs=0,sess=0,over=0; VIS.forEach(function(r){ hrs+=r.weeklyHours; sess+=r.sessionCount; if(r.weeklyHours>OVER) over++; });
    var meta=scopeMeta();
    meta.push(VIS.length+' lecturer'+(VIS.length===1?'':'s')); meta.push(Math.round(hrs)+' hrs/week'); meta.push(sess+' sessions'); if(over) meta.push(over+' overloaded');
    var now=new Date(), MON=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var stamp=now.getDate()+' '+MON[now.getMonth()]+' '+now.getFullYear();
    var rows='', tSess=0,tWk=0,tCourse=0,tProg=0,tCU=0;
    VIS.forEach(function(r,i){
      var st=band(r.weeklyHours).label, cl=r.weeklyHours>OVER?' class="cl"':(r.weeklyHours>HEAVY?' class="hv"':'');
      tSess+=r.sessionCount; tWk+=r.weeklyHours; tCourse+=r.courseCount; tProg+=r.programmeCount; tCU+=r.totalCredits;
      rows+='<tr'+cl+'><td class="n">'+(i+1)+'</td><td><b>'+esc(r.lecturerName)+'</b></td><td>'+esc(r.empCode)+'</td><td>'+esc(r.department)+'</td><td>'+esc(r.contractType||'-')+'</td>'
        +'<td class="c">'+r.sessionCount+'</td><td class="c"><b>'+r.weeklyHours.toFixed(1)+'</b></td><td class="c">'+monthly(r.weeklyHours).toFixed(1)+'</td><td class="c">'+r.courseCount+'</td><td class="c">'+r.programmeCount+'</td><td class="c">'+r.totalCredits+'</td><td class="c">'+esc(st)+'</td></tr>';
    });
    rows+='<tr class="tot"><td></td><td><b>TOTAL — '+VIS.length+' lecturer'+(VIS.length===1?'':'s')+'</b></td><td></td><td></td><td></td>'
      +'<td class="c">'+tSess+'</td><td class="c">'+tWk.toFixed(1)+'</td><td class="c">'+monthly(tWk).toFixed(1)+'</td><td class="c">'+tCourse+'</td><td class="c">'+tProg+'</td><td class="c">'+tCU+'</td><td></td></tr>';
    var logo=(location.origin||'')+'/COOPERP/images/welcomelogo.png';
    var css='@page{size:A4 landscape;margin:11mm 11mm 13mm;}*{box-sizing:border-box;}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;color:#1a1a2e;margin:0;font-size:10.5px;}'
      +'.hd{display:flex;align-items:center;gap:13px;border-bottom:3px solid #05275C;padding-bottom:8px;margin-bottom:11px;}.hd img{height:44px;}'
      +'.hd .u{font-size:15px;font-weight:800;color:#05275C;letter-spacing:.3px;line-height:1.1;}.hd .t{font-size:12px;font-weight:700;color:#174DA4;margin-top:2px;}'
      +'.hd .m{font-size:9.5px;color:#555;margin-top:3px;}.hd .m span{color:#c3ccda;margin:0 5px;}'
      +'table{width:100%;border-collapse:collapse;}tr{page-break-inside:avoid;}'
      +'thead th{background:#05275C;color:#fff;text-align:left;font-size:9px;font-weight:800;letter-spacing:.4px;text-transform:uppercase;padding:5px 7px;}'
      +'th.c,td.c{text-align:center;}td.n{color:#94a3b8;}'
      +'td{padding:4px 7px;border-bottom:1px solid #edf1f6;font-size:10px;}td b{color:#05275C;}tbody tr:nth-child(even) td{background:#fafbfd;}'
      +'tr.cl td{background:#fdecec;}tr.hv td{background:#fff6ec;}'
      +'tr.tot td{background:#eef2f8;border-top:2px solid #05275C;font-weight:800;color:#05275C;}'
      +'.ft{margin-top:6px;border-top:1px solid #e0e5ed;padding-top:6px;font-size:9px;color:#94a3b8;display:flex;justify-content:space-between;}';
    var html='<!doctype html><html><head><meta charset="utf-8"><title>Workload Analysis</title><style>'+css+'</style></head><body>'
      +'<div class="hd"><img src="'+logo+'" onerror="this.style.display=\'none\'" alt=""/><div>'
      +'<div class="u">Muteesa I Royal University</div><div class="t">Lecturer Workload Analysis</div>'
      +'<div class="m">'+meta.map(esc).join('<span>&bull;</span>')+'</div></div></div>'
      +'<table><thead><tr><th>#</th><th>Lecturer</th><th>EMP</th><th>Department</th><th>Contract</th><th class="c">Sessions</th><th class="c">Hrs/wk</th><th class="c">Hrs/mo</th><th class="c">Courses</th><th class="c">Progs</th><th class="c">CU</th><th class="c">Status</th></tr></thead><tbody>'+rows+'</tbody></table>'
      +'<div class="ft"><span>Generated '+stamp+'</span><span>eadmin.mru.ac.ug</span></div></body></html>';
    var w=window.open('','_blank'); if(!w){ alert('Please allow pop-ups to open the printable report.'); return; }
    w.document.open(); w.document.write(html); w.document.close(); w.focus();
    setTimeout(function(){ try{ w.print(); }catch(e){} },350);
  }

  init();
  return { reload:reload, refine:refine, reset:reset, closeDetail:closeDetail, copy:copy, csv:csv, print:print };
})();
</script>
</asp:Content>
