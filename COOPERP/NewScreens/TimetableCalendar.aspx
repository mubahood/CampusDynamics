<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="TimetableCalendar.aspx.cs" Inherits="COOPERP_NewScreens_TimetableCalendar" Title="Timetable Calendar - Campus Dynamics" %>
<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.tt-wrap{padding:2px 2px 8px;}
.tt-top{display:flex;align-items:flex-end;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:8px;}
.tt-h__t{font-size:17px;font-weight:800;color:#05275C;line-height:1.1;}
.tt-h__s{font-size:11px;color:#6b7280;margin-top:2px;}
.tt-top__act{display:flex;gap:6px;}
.tt-card{background:#fff;border:1px solid #e0e5ed;}
/* filters — one compact row */
.tt-filters{display:flex;gap:7px;align-items:center;flex-wrap:wrap;padding:9px 10px;border-bottom:1px solid #eef1f5;}
.tt-fl{display:flex;flex-direction:column;gap:2px;}
.tt-fl>span{font-size:8px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:#9aa6b8;padding-left:1px;}
.tt-sel,.tt-in{border:1px solid #cfd8e3;background:#fff;padding:6px 8px;font-size:12px;color:#1f2937;border-radius:0;font-family:inherit;height:31px;box-sizing:border-box;}
.tt-sel:focus,.tt-in:focus{outline:none;border-color:#174DA4;}
.tt-chk{display:flex;align-items:center;gap:5px;font-size:11px;color:#374151;cursor:pointer;user-select:none;height:31px;}
.tt-chk input{width:14px;height:14px;accent-color:#174DA4;cursor:pointer;}
.tt-btn{display:inline-flex;align-items:center;gap:5px;padding:6px 11px;border:1px solid #d2dae6;background:#fff;color:#05275C;text-decoration:none;font-size:11.5px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;height:31px;box-sizing:border-box;}
.tt-btn:hover{border-color:#174DA4;color:#174DA4;}
.tt-btn--p{background:#05275C;border-color:#05275C;color:#fff;}.tt-btn--p:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.tt-fl__sp{flex:1;}
.tt-seg{display:flex;border:1px solid #cfd8e3;height:31px;}
.tt-seg button{font-size:11px;font-weight:700;padding:0 12px;border:0;border-right:1px solid #cfd8e3;background:#fff;color:#556;cursor:pointer;font-family:inherit;}
.tt-seg button:last-child{border-right:0;}
.tt-seg button.on{background:#05275C;color:#fff;}
/* list view */
.ttl{padding:6px 12px 12px;}
.ttl-day{display:flex;align-items:center;gap:8px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;margin:14px 0 6px;}
.ttl-day span{font-size:9.5px;font-weight:700;color:#fff;background:#94a3b8;padding:1px 7px;}
.ttl-row{display:flex;align-items:center;gap:12px;background:#fff;border:1px solid #e0e5ed;border-left:3px solid #05275C;padding:9px 12px;margin-bottom:5px;cursor:pointer;transition:border-color .12s,box-shadow .12s;}
.ttl-row:hover{border-color:#cdd8e6;border-left-color:#174DA4;box-shadow:0 2px 8px rgba(5,39,92,.10);}
.ttl-row--TUTORIAL{border-left-color:#174DA4;}.ttl-row--PRACTICAL{border-left-color:#16a34a;}.ttl-row--SEMINAR{border-left-color:#b45309;}.ttl-row--CAT{border-left-color:#7c3aed;}
.ttl-row--clash{outline:2px solid #dc2626;outline-offset:-2px;}
.ttl-time{font-size:13px;font-weight:800;color:#05275C;min-width:50px;text-align:center;}
.ttl-time span{display:block;font-size:10px;color:#9ca3af;font-weight:600;}
.ttl-main{flex:1;min-width:0;}
.ttl-main b{font-size:12.5px;color:#1a1a2e;display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.ttl-main span{display:block;font-size:10.5px;color:#6b7280;margin-top:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.ttl-tag{font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;padding:3px 7px;color:#166534;background:#dcfce7;}
.ttl-tag--clash{color:#fff;background:#dc2626;}
.ttl-chev{font-size:20px;color:#c3ccda;font-weight:700;line-height:1;}
.ttl-row:hover .ttl-chev{color:#174DA4;}
/* searchable combo */
.tt-combo{position:relative;} .tt-combo>input{width:100%;box-sizing:border-box;}
.tt-combo__list{position:absolute;top:100%;left:0;right:0;z-index:60;background:#fff;border:1px solid #cfd8e3;max-height:250px;overflow:auto;display:none;box-shadow:0 6px 18px rgba(0,0,0,.13);}
.tt-combo__list.on{display:block;}
.tt-combo__i{padding:7px 10px;font-size:12px;cursor:pointer;border-bottom:1px solid #f0f2f5;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.tt-combo__i:hover{background:#eef4ff;} .tt-combo__i--none{color:#9ca3af;cursor:default;}
/* stats + legend */
.tt-meta{display:flex;align-items:stretch;flex-wrap:wrap;border-bottom:1px solid #eef1f5;}
.tt-stat{padding:7px 14px;border-right:1px solid #eef1f5;min-width:74px;}
.tt-stat__n{font-size:16px;font-weight:800;color:#05275C;line-height:1;}
.tt-stat__n.warn{color:#dc2626;}
.tt-stat__l{font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#9aa6b8;margin-top:3px;}
.tt-legend{display:flex;gap:11px;flex-wrap:wrap;align-items:center;padding:7px 14px;font-size:10px;color:#6b7280;margin-left:auto;}
.tt-legend i{display:inline-block;width:10px;height:10px;margin-right:4px;vertical-align:middle;}
/* calendar grid */
.cal-scroll{overflow:auto;max-height:70vh;}
.cal{display:grid;grid-template-columns:48px repeat(7,minmax(120px,1fr));min-width:900px;}
.cal__corner{position:sticky;top:0;left:0;z-index:5;background:#f8fafc;border-bottom:2px solid #e0e5ed;border-right:1px solid #eef2f6;}
.cal__dh{position:sticky;top:0;z-index:4;background:#05275C;color:#fff;font-size:11px;font-weight:800;text-align:center;padding:7px 4px;text-transform:uppercase;letter-spacing:.3px;border-right:1px solid #0a3a7a;}
.cal__dh--off{background:#7b8aa3;}
.cal__gutter{border-right:1px solid #eef2f6;position:relative;background:#fafbfc;}
.cal__hr{position:absolute;left:0;right:0;font-size:9px;color:#9ca3af;text-align:right;padding-right:5px;transform:translateY(-6px);}
.cal__day{position:relative;border-right:1px solid #eef2f6;border-bottom:1px solid #eef2f6;background:linear-gradient(#f4f7fb 1px,transparent 1px);background-size:100% 60px;}
.cal__ev{position:absolute;border-left:3px solid #05275C;background:#eef2fb;color:#1f2937;padding:3px 5px;overflow:hidden;font-size:10px;box-shadow:0 1px 2px rgba(5,39,92,.10);cursor:pointer;transition:box-shadow .12s,transform .12s;}
.cal__ev:hover{box-shadow:0 3px 10px rgba(5,39,92,.26);transform:translateY(-1px);z-index:3;}
.cal__ev b{display:block;font-size:10.5px;font-weight:800;color:#05275C;line-height:1.15;}
.cal__ev em{display:block;font-style:normal;color:#1a1a2e;font-size:9px;font-weight:600;line-height:1.15;margin:1px 0;overflow:hidden;text-overflow:ellipsis;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;}
.cal__ev span{display:block;color:#6b7280;font-size:9px;line-height:1.2;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.cal__ev--TUTORIAL{border-left-color:#174DA4;background:#e9f0fc;}
.cal__ev--PRACTICAL{border-left-color:#16a34a;background:#e9f6ee;}
.cal__ev--SEMINAR{border-left-color:#b45309;background:#fdf3e5;}
.cal__ev--CAT{border-left-color:#7c3aed;background:#f1ebfd;}
.cal__ev--clash{outline:2px solid #dc2626;outline-offset:-2px;}
.cal__ev--clash b:after{content:" \26A0";color:#dc2626;}
.tt-empty{text-align:center;color:#94a3b8;padding:34px;font-size:13px;}
/* detail drawer */
.ttd-ov{position:fixed;inset:0;background:rgba(9,20,40,.44);z-index:1000;display:none;justify-content:flex-end;}
.ttd-ov.on{display:flex;}
.ttd-drawer{width:390px;max-width:94vw;height:100%;background:#f5f7fa;box-shadow:-8px 0 28px rgba(0,0,0,.22);overflow-y:auto;position:relative;animation:ttdslide .18s ease-out;}
@keyframes ttdslide{from{transform:translateX(26px);opacity:.4;}to{transform:translateX(0);opacity:1;}}
.ttd-x{position:absolute;top:10px;right:10px;z-index:2;width:30px;height:30px;border:0;background:rgba(255,255,255,.18);color:#fff;font-size:20px;line-height:1;cursor:pointer;}
.ttd-x:hover{background:rgba(255,255,255,.34);}
.ttd-top{padding:20px 20px 18px;color:#fff;background:#05275C;border-left:5px solid #9db6e0;}
.ttd-top--TUTORIAL{background:#123a7a;}.ttd-top--PRACTICAL{background:#14532d;}.ttd-top--SEMINAR{background:#7c400a;}.ttd-top--CAT{background:#4c1d95;}
.ttd-badge{display:inline-block;font-size:9.5px;font-weight:800;text-transform:uppercase;letter-spacing:.6px;background:rgba(255,255,255,.20);padding:3px 9px;margin-bottom:10px;}
.ttd-badge--clash{background:#dc2626;margin-left:6px;}
.ttd-code{font-size:22px;font-weight:800;letter-spacing:-.3px;}
.ttd-course{font-size:13px;opacity:.9;margin-top:3px;line-height:1.35;}
.ttd-when{display:flex;align-items:baseline;gap:10px;flex-wrap:wrap;padding:14px 20px;background:#fff;border-bottom:1px solid #e0e5ed;}
.ttd-when__d{font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.ttd-when__t{font-size:15px;font-weight:800;color:#1a1a2e;}
.ttd-when__x{font-size:11px;font-weight:700;color:#fff;background:#174DA4;padding:2px 9px;}
.ttd-r{display:flex;justify-content:space-between;gap:14px;padding:11px 20px;border-bottom:1px solid #eef2f6;background:#fff;}
.ttd-r__l{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#94a3b8;flex-shrink:0;padding-top:2px;}
.ttd-r__v{font-size:12.5px;color:#1a1a2e;font-weight:600;text-align:right;}
.ttd-actions{padding:16px 20px 22px;display:flex;flex-direction:column;gap:8px;}
.ttd-abtn{display:flex;align-items:center;justify-content:center;gap:8px;font-size:12.5px;font-weight:700;padding:11px 12px;text-decoration:none;border:1px solid #cdd8e6;background:#fff;color:#05275C;cursor:pointer;font-family:inherit;text-align:center;}
.ttd-abtn--p{background:#05275C;border-color:#05275C;color:#fff;}.ttd-abtn--p:hover{background:#174DA4;border-color:#174DA4;}
.ttd-abtn--s:hover{border-color:#174DA4;color:#174DA4;}
.ttd-ic{flex-shrink:0;display:block;}
</style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="tt-wrap">
  <div class="tt-top">
    <div>
      <div class="tt-h__t">Timetable Calendar</div>
      <div class="tt-h__s">Institution-wide weekly view &mdash; filter, click any session for details. Overlapping clashes are outlined red.</div>
    </div>
    <div class="tt-top__act">
      <a class="tt-btn" href="TimetableManager.aspx">Manage</a>
      <a class="tt-btn" href="RoomsBuildings.aspx">Rooms</a>
      <button type="button" class="tt-btn" onclick="CAL.csv()">&#8681; CSV</button>
      <button type="button" class="tt-btn tt-btn--p" onclick="CAL.print()">&#128424; Print / PDF</button>
    </div>
  </div>

  <div class="tt-card">
    <div class="tt-filters">
      <div class="tt-fl"><span>Campus</span><select id="fCampus" class="tt-sel" onchange="CAL.load()"><option value="0">All</option></select></div>
      <div class="tt-fl" style="min-width:190px;"><span>Programme</span><div id="cProg"></div></div>
      <div class="tt-fl" style="min-width:180px;"><span>Course</span><div id="cCourse"></div></div>
      <div class="tt-fl"><span>Year</span><select id="fSy" class="tt-sel" onchange="CAL.load()"><option value="0">Any</option><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select></div>
      <div class="tt-fl"><span>Sem</span><select id="fSem" class="tt-sel" onchange="CAL.load()"><option value="0">Any</option><option value="1">1</option><option value="2">2</option><option value="3">3</option></select></div>
      <div class="tt-fl" style="min-width:160px;"><span>Room</span><div id="cRoom"></div></div>
      <div class="tt-fl" style="min-width:170px;"><span>Lecturer</span><div id="cTeacher"></div></div>
      <div class="tt-fl"><span>Type</span><select id="fType" class="tt-sel" onchange="CAL.refine()"><option value="">All</option><option value="LECTURE">Lecture</option><option value="TUTORIAL">Tutorial</option><option value="PRACTICAL">Practical</option><option value="SEMINAR">Seminar</option><option value="CAT">CAT</option></select></div>
      <div class="tt-fl"><span>&nbsp;</span><label class="tt-chk"><input type="checkbox" id="fClash" onchange="CAL.refine()"> Clashes only</label></div>
      <div class="tt-fl__sp"></div>
      <div class="tt-fl"><span>View</span><div class="tt-seg"><button type="button" id="vGrid" class="on" onclick="CAL.view('grid')">Grid</button><button type="button" id="vList" onclick="CAL.view('list')">List</button></div></div>
      <div class="tt-fl"><span>&nbsp;</span><button type="button" class="tt-btn" onclick="CAL.reset()">Clear</button></div>
    </div>
    <div class="tt-meta" id="calMeta" style="display:none;">
      <div class="tt-stat"><div class="tt-stat__n" id="stSess">0</div><div class="tt-stat__l">Sessions</div></div>
      <div class="tt-stat"><div class="tt-stat__n" id="stClash">0</div><div class="tt-stat__l">Clashes</div></div>
      <div class="tt-stat"><div class="tt-stat__n" id="stCourses">0</div><div class="tt-stat__l">Courses</div></div>
      <div class="tt-stat"><div class="tt-stat__n" id="stRooms">0</div><div class="tt-stat__l">Rooms</div></div>
      <div class="tt-stat"><div class="tt-stat__n" id="stTeach">0</div><div class="tt-stat__l">Lecturers</div></div>
      <div class="tt-stat"><div class="tt-stat__n" id="stDays">0</div><div class="tt-stat__l">Days</div></div>
      <div class="tt-legend">
        <span><i style="background:#05275C"></i>Lecture</span><span><i style="background:#174DA4"></i>Tutorial</span>
        <span><i style="background:#16a34a"></i>Practical</span><span><i style="background:#b45309"></i>Seminar</span>
        <span><i style="background:#7c3aed"></i>CAT</span><span><i style="outline:2px solid #dc2626;background:#fff"></i>Clash</span>
      </div>
    </div>
    <div id="calHost"><div class="tt-empty">Loading&hellip;</div></div>
  </div>
</div>

<!-- session detail drawer -->
<div class="ttd-ov" id="ttdOv"><div class="ttd-drawer"><button type="button" class="ttd-x" onclick="CAL.closeDetail()">&times;</button><div class="ttd-body"></div></div></div>

<script>
var CAL = (function(){
  var LK={}, DAY_START=7*60, DAY_END=21*60, SCALE=0.85;
  var LAST=[], VIS=[], CURDET=null, MODE='grid';
  var progCombo=null, courseCombo=null, roomCombo=null, teacherCombo=null;
  var DAYS=['','Mon','Tue','Wed','Thu','Fri','Sat','Sun'], DAYFULL=['','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY'];
  var TYPES={LECTURE:'Lecture',TUTORIAL:'Tutorial',PRACTICAL:'Practical',SEMINAR:'Seminar',CAT:'CAT'};
  function qs(id){return document.getElementById(id);}
  function esc(s){s=(s==null?'':''+s);return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
  function typeName(t){return TYPES[t]||(t?(t.charAt(0)+t.slice(1).toLowerCase()):'Session');}
  function dur(s){var m=Math.max(0,(s.em||0)-(s.sm||0));var h=Math.floor(m/60),mm=m%60;return (h?h+'h':'')+(mm?(h?' ':'')+mm+'m':(h?'':'0m'));}
  function api(m,b){return fetch('TimetableCalendar.aspx/'+m,{method:'POST',headers:{'Content-Type':'application/json; charset=utf-8'},body:b?JSON.stringify(b):'{}'}).then(function(r){return r.json();}).then(function(j){return j.d;}).catch(function(){return{ok:false};});}

  // reusable searchable combo. items:[{value,label}]
  function makeCombo(host, items, placeholder, onPick){
    host.className='tt-combo';
    host.innerHTML='<input type="text" class="tt-in" placeholder="'+esc(placeholder)+'" autocomplete="off"><div class="tt-combo__list"></div>';
    var inp=host.querySelector('input'), list=host.querySelector('.tt-combo__list'), val='';
    function draw(f){
      f=(f||'').toLowerCase();
      var m=items.filter(function(it){ return !f || (it.label||'').toLowerCase().indexOf(f)>=0; });
      if(!m.length){ list.innerHTML='<div class="tt-combo__i tt-combo__i--none">No match</div>'; return; }
      list.innerHTML=m.slice(0,80).map(function(it){ return '<div class="tt-combo__i" data-v="'+esc(it.value)+'" title="'+esc(it.label)+'">'+esc(it.label)+'</div>'; }).join('');
      Array.prototype.forEach.call(list.querySelectorAll('.tt-combo__i[data-v]'),function(el){ el.onmousedown=function(e){ e.preventDefault(); val=el.getAttribute('data-v'); inp.value=el.textContent; list.classList.remove('on'); if(onPick) onPick(val); }; });
    }
    inp.addEventListener('focus',function(){ draw(inp.value); list.classList.add('on'); });
    inp.addEventListener('input',function(){ val=''; draw(inp.value); list.classList.add('on'); });
    inp.addEventListener('blur',function(){ setTimeout(function(){ list.classList.remove('on'); },150); });
    return { value:function(){return val;}, set:function(v){ var it=items.filter(function(x){return String(x.value)===String(v);})[0]; if(it){val=it.value;inp.value=it.label;} else {val='';inp.value='';} }, setItems:function(n){ items=n||[]; } };
  }

  function init(){
    api('Lookups').then(function(d){
      LK=d||{};
      var ch='<option value="0">All</option>'; (LK.campuses||[]).forEach(function(c){ if(c.id!==0) ch+='<option value="'+c.id+'">'+esc(c.name)+'</option>'; }); qs('fCampus').innerHTML=ch;
      progCombo=makeCombo(qs('cProg'), [{value:'',label:'All programmes'}].concat((LK.programmes||[]).map(function(p){return {value:p.code,label:(p.name||p.code)};})), 'All programmes', function(){ load(); });
      courseCombo=makeCombo(qs('cCourse'), [{value:'',label:'All courses'}].concat((LK.courses||[]).map(function(c){return {value:c.code,label:c.code+' — '+c.name};})), 'All courses', function(){ load(); });
      roomCombo=makeCombo(qs('cRoom'), [{value:'',label:'All rooms'}].concat((LK.rooms||[]).map(function(r){return {value:String(r.id),label:r.name};})), 'All rooms', function(){ load(); });
      teacherCombo=makeCombo(qs('cTeacher'), [{value:'',label:'All lecturers'}].concat((LK.teachers||[]).map(function(t){return {value:String(t.id),label:t.name};})), 'All lecturers', function(){ load(); });
      progCombo.set(''); courseCombo.set(''); roomCombo.set(''); teacherCombo.set('');
      restoreFromQuery();
      load();
    });
  }

  // ── GET-state: filters live in the URL query string (bookmark / refresh safe) ──
  function readQuery(){ var q={}, s=(location.search||'').replace(/^\?/,''); s.split('&').forEach(function(kv){ if(!kv) return; var p=kv.split('='); q[decodeURIComponent(p[0])]=decodeURIComponent((p[1]||'').replace(/\+/g,' ')); }); return q; }
  function restoreFromQuery(){
    var q=readQuery();
    if(q.campus) qs('fCampus').value=q.campus;
    if(q.sy) qs('fSy').value=q.sy;
    if(q.sem) qs('fSem').value=q.sem;
    if(q.type) qs('fType').value=q.type;
    if(q.clash==='1') qs('fClash').checked=true;
    if(q.prog&&progCombo) progCombo.set(q.prog);
    if(q.course&&courseCombo) courseCombo.set(q.course);
    if(q.room&&roomCombo) roomCombo.set(q.room);
    if(q.teacher&&teacherCombo) teacherCombo.set(q.teacher);
    if(q.view==='list'){ MODE='list'; qs('vGrid').className=''; qs('vList').className='on'; }
  }
  function syncUrl(){
    var parts=[];
    function add(k,v){ if(v&&v!=='0'&&v!=='') parts.push(k+'='+encodeURIComponent(v)); }
    add('campus',qs('fCampus').value);
    add('prog',progCombo?progCombo.value():'');
    add('course',courseCombo?courseCombo.value():'');
    add('sy',qs('fSy').value); add('sem',qs('fSem').value);
    add('room',roomCombo?roomCombo.value():''); add('teacher',teacherCombo?teacherCombo.value():'');
    add('type',qs('fType').value);
    if(qs('fClash').checked) parts.push('clash=1');
    if(MODE==='list') parts.push('view=list');
    try{ history.replaceState(null,'',location.pathname+(parts.length?('?'+parts.join('&')):'')); }catch(e){}
  }

  function load(){
    qs('calHost').innerHTML='<div class="tt-empty">Loading&hellip;</div>';
    syncUrl();
    api('CalendarData',{
      campusId:parseInt(qs('fCampus').value,10)||0, progcode:progCombo?progCombo.value():'',
      studyYear:parseInt(qs('fSy').value,10)||0, semester:parseInt(qs('fSem').value,10)||0,
      roomId:parseInt(roomCombo?roomCombo.value():'',10)||0, teacherId:parseInt(teacherCombo?teacherCombo.value():'',10)||0,
      courseCode:courseCombo?courseCombo.value():''
    }).then(function(d){ LAST=(d&&d.sessions)||[]; markClashes(LAST); refine(); });
  }
  function reset(){
    qs('fCampus').value='0'; qs('fSy').value='0'; qs('fSem').value='0'; qs('fType').value=''; qs('fClash').checked=false;
    if(progCombo)progCombo.set(''); if(courseCombo)courseCombo.set(''); if(roomCombo)roomCombo.set(''); if(teacherCombo)teacherCombo.set('');
    load();
  }

  function markClashes(list){
    for(var i=0;i<list.length;i++) list[i].clash=false;
    for(var i=0;i<list.length;i++) for(var j=i+1;j<list.length;j++){
      var a=list[i],b=list[j];
      if(a.dayNo!==b.dayNo) continue;
      if(!(a.sm<b.em && b.sm<a.em)) continue;
      var sameRoom=a.roomId>0&&a.roomId===b.roomId;
      var sameTeach=a.teacherId>0&&a.teacherId===b.teacherId;
      var sameCohort=a.progcode&&a.progcode===b.progcode&&a.studyYear===b.studyYear&&a.semester===b.semester;
      if(sameRoom||sameTeach||sameCohort){ a.clash=true; b.clash=true; }
    }
  }

  // apply client-side refinements (type, clashes-only) + render
  function refine(){
    var ftype=qs('fType').value, clashOnly=qs('fClash').checked;
    VIS=LAST.filter(function(s){ if(ftype&&s.sessionType!==ftype) return false; if(clashOnly&&!s.clash) return false; return true; });
    syncUrl(); renderStats(); draw();
  }
  function draw(){ if(MODE==='list') renderList(); else renderGrid(); }
  function view(m){ MODE=m; qs('vGrid').className=(m==='grid'?'on':''); qs('vList').className=(m==='list'?'on':''); syncUrl(); draw(); }

  function renderStats(){
    if(!LAST.length){ qs('calMeta').style.display='none'; return; }
    qs('calMeta').style.display='flex';
    var courses={},rooms={},teach={},days={},clash=0;
    VIS.forEach(function(s){ if(s.code)courses[s.code]=1; if(s.roomId>0)rooms[s.roomId]=1; if(s.teacherId>0)teach[s.teacherId]=1; if(s.dayNo)days[s.dayNo]=1; if(s.clash)clash++; });
    qs('stSess').textContent=VIS.length;
    var ec=qs('stClash'); ec.textContent=clash; ec.className='tt-stat__n'+(clash?' warn':'');
    qs('stCourses').textContent=Object.keys(courses).length;
    qs('stRooms').textContent=Object.keys(rooms).length;
    qs('stTeach').textContent=Object.keys(teach).length;
    qs('stDays').textContent=Object.keys(days).length;
  }

  function renderGrid(){
    var list=VIS;
    if(!list.length){ qs('calHost').innerHTML='<div class="tt-empty">No sessions match these filters.</div>'; return; }
    list.forEach(function(s,i){ s._i=i; });
    var minS=DAY_START,maxE=DAY_END;
    list.forEach(function(s){ if(s.sm<minS) minS=Math.max(0,s.sm-30); if(s.em>maxE) maxE=Math.min(1439,s.em+30); });
    var winStart=Math.min(DAY_START,minS), winEnd=Math.max(DAY_END,maxE), colH=(winEnd-winStart)*SCALE;
    var byDay={}; for(var d=1;d<=7;d++) byDay[d]=[];
    list.forEach(function(s){ if(s.dayNo>=1&&s.dayNo<=7) byDay[s.dayNo].push(s); });
    var used={}, laneCount={};
    for(var d=1;d<=7;d++){
      var arr=byDay[d].sort(function(a,b){return a.sm-b.sm;}), lanes=[];
      if(arr.length) used[d]=1;
      arr.forEach(function(s){ var placed=false; for(var i=0;i<lanes.length;i++){ if(lanes[i]<=s.sm){ s.lane=i; lanes[i]=s.em; placed=true; break; } } if(!placed){ s.lane=lanes.length; lanes.push(s.em); } });
      laneCount[d]=Math.max(1,lanes.length);
    }
    var h='<div class="cal-scroll"><div class="cal"><div class="cal__corner"></div>';
    for(var d=1;d<=7;d++) h+='<div class="cal__dh'+(used[d]?'':' cal__dh--off')+'">'+DAYS[d]+'</div>';
    h+='<div class="cal__gutter" style="height:'+colH+'px;">';
    for(var m=Math.ceil(winStart/60)*60;m<=winEnd;m+=60){ var top=(m-winStart)*SCALE; h+='<div class="cal__hr" style="top:'+top+'px;">'+String(Math.floor(m/60)).replace(/^(\d)$/,'0$1')+':00</div>'; }
    h+='</div>';
    for(var d=1;d<=7;d++){
      h+='<div class="cal__day" style="height:'+colH+'px;">';
      var lc=laneCount[d];
      byDay[d].forEach(function(s){
        var top=(s.sm-winStart)*SCALE, ht=Math.max(16,(s.em-s.sm)*SCALE-2), w=100/lc, left=s.lane*w;
        var loc=s.room?esc(s.room):(s.roomLabel?esc(s.roomLabel):(s.deliveryMode&&s.deliveryMode!=='PHYSICAL'?'Online':''));
        var tip=esc(s.code)+' '+esc(s.course)+' | '+esc(s.start)+'-'+esc(s.end)+(loc?(' | '+loc):'')+(s.teacher?(' | '+esc(s.teacher)):'')+(s.campus?(' | '+esc(s.campus)):'');
        h+='<div class="cal__ev cal__ev--'+esc(s.sessionType)+(s.clash?' cal__ev--clash':'')+'" data-idx="'+s._i+'" title="'+tip+'" style="top:'+top+'px;height:'+ht+'px;left:calc('+left+'% + 2px);width:calc('+w+'% - 4px);">'
          +'<b>'+esc(s.code)+'</b>'+(ht>42?'<em>'+esc(s.course)+'</em>':'')
          +'<span>'+esc(s.start)+(loc?(' · '+loc):'')+'</span>'+(ht>72&&s.teacher?('<span>'+esc(s.teacher)+'</span>'):'')+'</div>';
      });
      h+='</div>';
    }
    h+='</div></div>';
    qs('calHost').innerHTML=h;
    bindClicks();
  }
  function bindClicks(){
    var host=qs('calHost');
    host.onclick=function(e){ var t=e.target; while(t&&t!==host&&!t.getAttribute('data-idx')) t=t.parentNode; if(t&&t!==host){ var i=parseInt(t.getAttribute('data-idx'),10); if(!isNaN(i)) showDetail(VIS[i]); } };
  }
  function renderList(){
    var list=VIS;
    if(!list.length){ qs('calHost').innerHTML='<div class="tt-empty">No sessions match these filters.</div>'; return; }
    list.forEach(function(s,i){ s._i=i; });
    var byDay={}; list.forEach(function(s){ (byDay[s.dayNo]=byDay[s.dayNo]||[]).push(s); });
    var h='<div class="ttl">';
    for(var d=1;d<=7;d++){
      if(!byDay[d]||!byDay[d].length) continue;
      var arr=byDay[d].sort(function(a,b){return a.sm-b.sm;});
      h+='<div class="ttl-day">'+DAYFULL[d]+'<span>'+arr.length+'</span></div>';
      arr.forEach(function(s){
        var online=(s.deliveryMode&&s.deliveryMode!=='PHYSICAL');
        var loc=s.room?esc(s.room)+(s.building?(', '+esc(s.building)):''):(s.roomLabel?esc(s.roomLabel):(online?'Online':'TBD'));
        var meta=[typeName(s.sessionType),loc].concat(s.campus?[esc(s.campus)]:[]).concat(s.progcode?['Y'+s.studyYear+'/S'+s.semester+' '+esc(s.progcode)]:[]).concat(s.teacher?[esc(s.teacher)]:[]);
        h+='<div class="ttl-row ttl-row--'+esc(s.sessionType)+(s.clash?' ttl-row--clash':'')+'" data-idx="'+s._i+'">'
          +'<div class="ttl-time">'+esc(s.start)+'<span>'+esc(s.end)+'</span></div>'
          +'<div class="ttl-main"><b>'+esc(s.code)+' &middot; '+esc(s.course)+'</b><span>'+meta.join(' &middot; ')+'</span></div>'
          +(s.clash?'<span class="ttl-tag ttl-tag--clash">Clash</span>':(online?'<span class="ttl-tag">Online</span>':''))
          +'<span class="ttl-chev">&rsaquo;</span></div>';
      });
    }
    h+='</div>';
    qs('calHost').innerHTML=h;
    bindClicks();
  }

  /* ── CSV + branded print (respect current filters) ── */
  function activeFilterMeta(){
    var m=[];
    var cs=qs('fCampus'); if(cs.value!=='0'&&cs.selectedOptions[0]) m.push(cs.selectedOptions[0].text);
    if(progCombo&&progCombo.value()){ var p=(LK.programmes||[]).filter(function(x){return x.code===progCombo.value();})[0]; m.push(p?(p.name||p.code):progCombo.value()); }
    if(courseCombo&&courseCombo.value()) m.push(courseCombo.value());
    if(qs('fSy').value!=='0') m.push('Year '+qs('fSy').value);
    if(qs('fSem').value!=='0') m.push('Semester '+qs('fSem').value);
    if(roomCombo&&roomCombo.value()){ var r=(LK.rooms||[]).filter(function(x){return String(x.id)===roomCombo.value();})[0]; if(r) m.push(r.name); }
    if(teacherCombo&&teacherCombo.value()){ var t=(LK.teachers||[]).filter(function(x){return String(x.id)===teacherCombo.value();})[0]; if(t) m.push(t.name); }
    if(qs('fType').value) m.push(typeName(qs('fType').value));
    if(qs('fClash').checked) m.push('Clashes only');
    return m;
  }
  function csvCell(v){ v=(v==null?'':''+v); if(/[",\n]/.test(v)) v='"'+v.replace(/"/g,'""')+'"'; return v; }
  function csv(){
    if(!VIS.length){ alert('No sessions to export.'); return; }
    var head=['Day','Start','End','CourseCode','Course','ProgrammeCode','Programme','Year','Semester','Lecturer','Room','Building','Campus','Type','Delivery'];
    var lines=[head.join(',')];
    VIS.slice().sort(function(a,b){return (a.dayNo-b.dayNo)||(a.sm-b.sm);}).forEach(function(s){
      lines.push([DAYFULL[s.dayNo],s.start,s.end,s.code,s.course,s.progcode,s.progname,s.studyYear,s.semester,s.teacher,s.room,s.building,s.campusFull||s.campus,s.sessionType,s.deliveryMode].map(csvCell).join(','));
    });
    var blob=new Blob([lines.join('\r\n')],{type:'text/csv;charset=utf-8;'});
    var a=document.createElement('a'); a.href=URL.createObjectURL(blob); a.download='timetable.csv'; document.body.appendChild(a); a.click(); document.body.removeChild(a);
  }
  function print(){
    if(!VIS.length){ alert('No sessions to print.'); return; }
    var list=VIS.slice().sort(function(a,b){return (a.dayNo-b.dayNo)||(a.sm-b.sm);});
    var mins=0,codes={},clash=0; list.forEach(function(s){ mins+=Math.max(0,(s.em||0)-(s.sm||0)); if(s.code)codes[s.code]=1; if(s.clash)clash++; });
    var meta=activeFilterMeta();
    meta.push(list.length+' session'+(list.length===1?'':'s'));
    meta.push((Math.round(mins/60*10)/10)+' hrs');
    meta.push(Object.keys(codes).length+' course'+(Object.keys(codes).length===1?'':'s'));
    if(clash) meta.push(clash+' clash'+(clash===1?'':'es'));
    var now=new Date(), MON=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var stamp=now.getDate()+' '+MON[now.getMonth()]+' '+now.getFullYear();
    var byDay={}; list.forEach(function(s){ (byDay[s.dayNo]=byDay[s.dayNo]||[]).push(s); });
    var body='';
    for(var d=1;d<=7;d++){
      if(!byDay[d]||!byDay[d].length) continue;
      var rows='';
      byDay[d].forEach(function(s){
        var online=(s.deliveryMode&&s.deliveryMode!=='PHYSICAL');
        var loc=s.room?(esc(s.room)+(s.building?('<i>, '+esc(s.building)+'</i>'):'')):(s.roomLabel?esc(s.roomLabel):(online?'Online':'TBD'));
        rows+='<tr'+(s.clash?' class="cl"':'')+'><td class="tm">'+esc(s.start)+'&ndash;'+esc(s.end)+'</td>'
          +'<td><b>'+esc(s.code)+'</b> '+esc(s.course)+'</td>'
          +'<td>'+esc(s.progname||s.progcode)+' <i>(Y'+(s.studyYear||'-')+'/S'+(s.semester||'-')+')</i></td>'
          +'<td>'+esc(typeName(s.sessionType))+(online?' <i>('+esc(s.deliveryMode.toLowerCase())+')</i>':'')+'</td>'
          +'<td>'+loc+'</td><td>'+esc(s.campus||'-')+'</td><td>'+esc(s.teacher||'-')+'</td></tr>';
      });
      body+='<table class="pt"><thead><tr class="pd"><th colspan="7">'+DAYFULL[d]+'</th></tr>'
        +'<tr class="ph2"><th>Time</th><th>Course</th><th>Programme (Yr/Sem)</th><th>Type</th><th>Room / Location</th><th>Campus</th><th>Lecturer</th></tr></thead><tbody>'+rows+'</tbody></table>';
    }
    var logo=(location.origin||'')+'/COOPERP/images/welcomelogo.png';
    var css='@page{size:A4 landscape;margin:11mm 11mm 13mm;}*{box-sizing:border-box;}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;color:#1a1a2e;margin:0;font-size:10.5px;}'
      +'.hd{display:flex;align-items:center;gap:13px;border-bottom:3px solid #05275C;padding-bottom:8px;margin-bottom:11px;}.hd img{height:44px;}'
      +'.hd .u{font-size:15px;font-weight:800;color:#05275C;letter-spacing:.3px;line-height:1.1;}.hd .t{font-size:12px;font-weight:700;color:#174DA4;margin-top:2px;}'
      +'.hd .m{font-size:9.5px;color:#555;margin-top:3px;}.hd .m span{color:#c3ccda;margin:0 5px;}'
      +'table.pt{width:100%;border-collapse:collapse;margin-bottom:9px;}tr{page-break-inside:avoid;}'
      +'.pd th{background:#05275C;color:#fff;text-align:left;font-size:10.5px;font-weight:800;letter-spacing:.5px;text-transform:uppercase;padding:5px 8px;}'
      +'.ph2 th{background:#eef2f8;color:#5b6b85;text-align:left;font-size:8px;font-weight:800;letter-spacing:.4px;text-transform:uppercase;padding:4px 8px;border-bottom:1px solid #d6deea;}'
      +'td{padding:4px 8px;border-bottom:1px solid #edf1f6;vertical-align:top;font-size:10px;}td.tm{white-space:nowrap;font-weight:700;color:#05275C;}'
      +'td b{color:#05275C;}i{color:#7a8699;font-style:normal;font-size:9px;}tbody tr:nth-child(even) td{background:#fafbfd;}tr.cl td{background:#fdecec;}tr.cl td.tm{color:#dc2626;}'
      +'.ft{margin-top:6px;border-top:1px solid #e0e5ed;padding-top:6px;font-size:9px;color:#94a3b8;display:flex;justify-content:space-between;}';
    var html='<!doctype html><html><head><meta charset="utf-8"><title>Timetable</title><style>'+css+'</style></head><body>'
      +'<div class="hd"><img src="'+logo+'" onerror="this.style.display=\'none\'" alt=""/><div>'
      +'<div class="u">Muteesa I Royal University</div><div class="t">Timetable</div>'
      +'<div class="m">'+meta.map(esc).join('<span>&bull;</span>')+'</div></div></div>'+body
      +'<div class="ft"><span>Generated '+stamp+'</span><span>eadmin.mru.ac.ug</span></div></body></html>';
    var w=window.open('','_blank'); if(!w){ alert('Please allow pop-ups to open the printable timetable.'); return; }
    w.document.open(); w.document.write(html); w.document.close(); w.focus();
    setTimeout(function(){ try{ w.print(); }catch(e){} },350);
  }

  /* ── detail drawer ── */
  function row(l,v){ return v?'<div class="ttd-r"><span class="ttd-r__l">'+l+'</span><span class="ttd-r__v">'+esc(v)+'</span></div>':''; }
  function showDetail(s){
    if(!s) return; CURDET=s;
    var online=(s.deliveryMode&&s.deliveryMode!=='PHYSICAL');
    var loc=s.room?(s.room+(s.building?(' · '+s.building):'')):(s.roomLabel||(online?'Online session':'To be advised'));
    var cohort=(s.progname||s.progcode)+((s.studyYear?' · Year '+s.studyYear:'')+(s.semester?' · Sem '+s.semester:''));
    var h='<div class="ttd-top ttd-top--'+esc(s.sessionType)+'"><span class="ttd-badge">'+esc(typeName(s.sessionType))+(online?' · '+esc(s.deliveryMode.charAt(0)+s.deliveryMode.slice(1).toLowerCase()):'')+'</span>'
      +(s.clash?'<span class="ttd-badge ttd-badge--clash">Clash</span>':'')
      +'<div class="ttd-code">'+esc(s.code)+'</div><div class="ttd-course">'+esc(s.course)+'</div></div>';
    h+='<div class="ttd-when"><div class="ttd-when__d">'+esc(DAYFULL[s.dayNo]||'')+'</div><div class="ttd-when__t">'+esc(s.start)+' – '+esc(s.end)+'</div><div class="ttd-when__x">'+dur(s)+'</div></div>';
    h+=row('Location',loc)+row('Campus',s.campusFull||s.campus)+row('Programme',cohort)+row('Lecturer',s.teacher)+(online&&s.meetLink?row('Meet link',s.meetLink):'');
    var q='TimetableManager.aspx?prog='+encodeURIComponent(s.progcode||'')+'&sy='+(s.studyYear||'')+'&sem='+(s.semester||'')+'&q='+encodeURIComponent(s.code||'');
    h+='<div class="ttd-actions"><a class="ttd-abtn ttd-abtn--p" href="'+esc(q)+'">'
      +'<svg class="ttd-ic" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.12 2.12 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>'
      +'<span>Open in Manager</span></a>'
      +'<button type="button" class="ttd-abtn ttd-abtn--s" id="ttdCopy" onclick="CAL.copy()">'
      +'<svg class="ttd-ic" viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>'
      +'<span id="ttdCopyTxt">Copy details</span></button></div>';
    qs('ttdOv').querySelector('.ttd-body').innerHTML=h;
    qs('ttdOv').classList.add('on');
  }
  function closeDetail(){ qs('ttdOv').classList.remove('on'); }
  function copy(){
    var s=CURDET; if(!s) return;
    var txt=s.code+' '+s.course+' ('+typeName(s.sessionType)+')\n'+(DAYFULL[s.dayNo]||'')+' '+s.start+'-'+s.end
      +'\nRoom: '+(s.room||s.roomLabel||'-')+(s.building?', '+s.building:'')+'\nCampus: '+(s.campusFull||s.campus||'-')
      +'\nProgramme: '+(s.progname||s.progcode)+' (Year '+s.studyYear+', Sem '+s.semester+')\nLecturer: '+(s.teacher||'-');
    var done=function(){ var b=qs('ttdCopyTxt'); if(b){ var o=b.textContent; b.textContent='Copied!'; setTimeout(function(){b.textContent=o;},1400); } };
    if(navigator.clipboard&&navigator.clipboard.writeText){ navigator.clipboard.writeText(txt).then(done,function(){window.prompt('Copy:',txt);}); }
    else window.prompt('Copy:',txt);
  }
  qs('ttdOv').addEventListener('click',function(e){ if(e.target===qs('ttdOv')) closeDetail(); });
  document.addEventListener('keydown',function(e){ if(e.key==='Escape') closeDetail(); });

  init();
  return { load:load, reset:reset, refine:refine, view:view, print:print, csv:csv, closeDetail:closeDetail, copy:copy };
})();
</script>
</asp:Content>
