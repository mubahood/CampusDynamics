<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="TimetableManager.aspx.cs" Inherits="COOPERP_NewScreens_TimetableManager" Title="Timetable Manager - Campus Dynamics" %>
<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.tt-wrap{padding:4px 2px;}
.tt-h__t{font-size:18px;font-weight:800;color:#05275C;}
.tt-h__s{font-size:11.5px;color:#6b7280;margin:2px 0 10px;}
.tt-card{background:#fff;border:1px solid #e0e5ed;margin-bottom:12px;}
.tt-bar{display:flex;gap:7px;align-items:center;flex-wrap:wrap;padding:9px 11px;border-bottom:1px solid #eef1f5;}
.tt-bar .sp{flex:1 1 auto;}
.tt-in,.tt-sel{border:1px solid #cfd8e3;background:#fff;padding:7px 9px;font-size:12px;color:#1f2937;border-radius:0;font-family:inherit;height:34px;box-sizing:border-box;}
.tt-in:focus,.tt-sel:focus{outline:none;border-color:#174DA4;}
.tt-search{min-width:180px;}
.tt-btn{display:inline-flex;align-items:center;gap:6px;padding:8px 12px;border:1px solid #d2dae6;background:#fff;color:#05275C;text-decoration:none;font-size:12px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;height:34px;box-sizing:border-box;}
.tt-btn:hover{background:#f5f8ff;border-color:#174DA4;color:#174DA4;}
.tt-btn--p{background:#05275C;border-color:#05275C;color:#fff;}.tt-btn--p:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.tt-btn--d{background:#b42318;border-color:#b42318;color:#fff;}.tt-btn--d:hover{background:#991b1b;color:#fff;}
.tt-btn--sm{padding:5px 10px;font-size:11px;height:auto;}
/* searchable combo */
.tt-combo{position:relative;} .tt-combo>input{width:100%;box-sizing:border-box;}
.tt-combo__list{position:absolute;top:100%;left:0;right:0;z-index:60;background:#fff;border:1px solid #cfd8e3;max-height:230px;overflow:auto;display:none;box-shadow:0 6px 18px rgba(0,0,0,.13);}
.tt-combo__list.on{display:block;}
.tt-combo__i{padding:7px 10px;font-size:12px;cursor:pointer;border-bottom:1px solid #f0f2f5;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.tt-combo__i:hover{background:#eef4ff;} .tt-combo__i--none{color:#9ca3af;cursor:default;}
/* table */
.tt-tblwrap{overflow-x:auto;}
.tt-tbl{width:100%;border-collapse:separate;border-spacing:0;min-width:680px;}
.tt-tbl th{background:#f8fafc;border-bottom:2px solid #e0e5ed;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.45px;color:#6b7280;padding:9px 10px;text-align:left;white-space:nowrap;}
.tt-tbl td{border-bottom:1px solid #eef2f6;font-size:12px;color:#1f2937;padding:8px 10px;vertical-align:middle;}
.tt-tbl tbody tr:hover td{background:#f9fbff;}
.tt-tbl tbody tr:nth-child(even) td{background:#fafbfc;}
.tt-tbl tbody tr:nth-child(even):hover td{background:#f0f5ff;}
.tt-code{font-family:Consolas,monospace;font-size:11px;color:#174DA4;font-weight:700;}
.tt-cname{color:#1f2937;font-size:12px;margin-top:1px;}
.tt-muted{color:#9ca3af;font-size:11px;}
.tt-yr{display:inline-block;font-size:10px;font-weight:800;color:#475569;background:#eef2f7;padding:2px 7px;}
.tt-pill{display:inline-block;padding:3px 9px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;cursor:pointer;}
.tt-pill--sched{background:#e6f4ea;color:#166534;}.tt-pill--none{background:#f1f5f9;color:#94a3b8;}
.tt-pager{display:flex;gap:8px;align-items:center;justify-content:flex-end;padding:8px 12px;font-size:11px;color:#6b7280;}
.tt-pager a{padding:4px 9px;border:1px solid #d2dae6;color:#05275C;text-decoration:none;cursor:pointer;}
.tt-pager a.off{opacity:.4;pointer-events:none;}
/* modal */
.tt-ov{display:none;position:fixed;inset:0;background:rgba(5,25,60,.5);z-index:1500;align-items:flex-start;justify-content:center;padding:26px 12px;overflow:auto;}
.tt-ov.on{display:flex;}
.tt-md{background:#fff;border:1px solid #e0e5ed;width:640px;max-width:100%;box-shadow:0 18px 50px rgba(0,0,0,.28);}
.tt-md__h{padding:12px 16px;background:#05275C;color:#fff;display:flex;justify-content:space-between;align-items:center;}
.tt-md__h b{font-size:14px;}
.tt-md__x{background:none;border:none;color:#fff;font-size:20px;cursor:pointer;line-height:1;}
.tt-md__b{padding:16px;max-height:74vh;overflow:auto;}
.tt-md__f{padding:12px 16px;border-top:1px solid #e0e5ed;background:#fafbfc;display:flex;gap:8px;justify-content:flex-end;align-items:center;}
.tt-fld{margin-bottom:12px;}.tt-fld>label{display:block;font-size:11px;font-weight:700;color:#4b5563;text-transform:uppercase;letter-spacing:.3px;margin-bottom:5px;}
.tt-fld .tt-in,.tt-fld .tt-sel{width:100%;box-sizing:border-box;}
.tt-row{display:flex;gap:10px;flex-wrap:wrap;}.tt-row>*{flex:1;min-width:120px;}
.tt-radios{display:flex;gap:6px;flex-wrap:wrap;}
.tt-radio{font-size:11px;font-weight:700;padding:7px 13px;border:1px solid #cfd8e3;background:#fff;color:#555;cursor:pointer;border-radius:0;font-family:inherit;}
.tt-radio.on{background:#05275C;border-color:#05275C;color:#fff;}
.tt-hint{font-size:10.5px;color:#6b7280;margin-top:4px;}
.tt-avail{font-size:11px;font-weight:700;margin-top:5px;}
.tt-avail--ok{color:#166534;}.tt-avail--busy{color:#b42318;}
.tt-itemrow{display:flex;align-items:center;gap:10px;padding:9px 11px;border:1px solid #e0e5ed;margin-bottom:6px;background:#fff;}
.tt-itemrow__m{flex:1;min-width:0;}.tt-itemrow__m b{font-size:12.5px;color:#05275C;}.tt-itemrow__m span{display:block;font-size:11px;color:#6b7280;margin-top:2px;}
.tt-warn{background:#fff8e1;border:1px solid #f5d99a;padding:9px 11px;margin-top:8px;font-size:11.5px;color:#8a5a00;}
.tt-warn b{color:#8a5a00;}.tt-warn ul{margin:4px 0 0;padding-left:18px;}
.tt-empty{text-align:center;color:#94a3b8;padding:22px;font-size:13px;}
.tt-toast{position:fixed;bottom:20px;right:20px;z-index:99999;padding:10px 16px;font-size:13px;font-weight:600;color:#fff;background:#05275C;box-shadow:0 3px 10px rgba(0,0,0,.2);opacity:0;transition:opacity .3s;}
.tt-toast.on{opacity:1;}.tt-toast--err{background:#b42318;}
.tt-saving{display:none;position:absolute;inset:0;background:rgba(255,255,255,.85);z-index:20;flex-direction:column;align-items:center;justify-content:center;gap:12px;font-size:13px;font-weight:700;color:#05275C;}
.tt-saving.on{display:flex;}
.tt-spin{width:34px;height:34px;border:3px solid #dbe3ee;border-top-color:#174DA4;border-radius:50%;animation:ttspin .7s linear infinite;}
@keyframes ttspin{to{transform:rotate(360deg);}}
.tt-sbadge{font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;padding:2px 7px;margin-left:6px;}
.tt-sbadge--active{background:#e6f4ea;color:#166534;}.tt-sbadge--draft{background:#fff8e1;color:#8a5a00;}.tt-sbadge--arch{background:#eef0f4;color:#6b7280;}
.tt-itemrow--draft{background:#fffdf5;}.tt-itemrow--arch{opacity:.66;}
</style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="tt-wrap">
  <div class="tt-h__t">Timetable Manager</div>
  <div class="tt-h__s">Schedule weekly sessions per programme-course. Timetables are perpetual &mdash; once set they apply every year until changed.</div>

  <div class="tt-card">
    <div class="tt-bar">
      <select id="fSy" class="tt-sel"><option value="0">Any year</option><option value="1">Year 1</option><option value="2">Year 2</option><option value="3">Year 3</option><option value="4">Year 4</option><option value="5">Year 5</option></select>
      <select id="fSem" class="tt-sel"><option value="0">Any sem</option><option value="1">Semester 1</option><option value="2">Semester 2</option><option value="3">Semester 3</option></select>
      <div id="fProgCombo" style="min-width:210px;"></div>
      <input type="text" id="fQ" class="tt-in tt-search" placeholder="Search course / lecturer&hellip;" />
      <label style="font-size:11px;color:#4b5563;display:inline-flex;align-items:center;gap:5px;"><input type="checkbox" id="fUn" /> Unscheduled</label>
      <button type="button" class="tt-btn tt-btn--p" onclick="TM.apply()">Apply</button>
      <span class="sp"></span>
      <a class="tt-btn tt-btn--sm" href="TimetableExport.aspx">Export</a>
      <button type="button" class="tt-btn tt-btn--sm" onclick="TM.importLegacy()">Import legacy</button>
    </div>
    <div class="tt-tblwrap"><table class="tt-tbl"><thead><tr><th style="min-width:200px;">Course</th><th>Programme</th><th>Yr/Sem</th><th>Lecturer</th><th>Sessions</th><th style="text-align:right;">Actions</th></tr></thead><tbody id="pcBody"><tr><td colspan="6" class="tt-empty">Loading&hellip;</td></tr></tbody></table></div>
    <div class="tt-pager" id="pcPager"></div>
  </div>
</div>

<!-- Manage sessions -->
<div class="tt-ov" id="mgOv"><div class="tt-md">
  <div class="tt-md__h"><b id="mgTitle">Sessions</b><button type="button" class="tt-md__x" onclick="TM.close('mgOv')">&times;</button></div>
  <div class="tt-md__b">
    <div id="mgInfo" class="tt-h__s" style="margin:0 0 10px;"></div>
    <div id="mgItems"></div>
    <button type="button" class="tt-btn tt-btn--p" style="margin-top:10px;" onclick="TM.itemEdit(0)">+ Add session</button>
  </div>
</div></div>

<!-- Item editor -->
<div class="tt-ov" id="itOv"><div class="tt-md" style="position:relative;">
  <div class="tt-md__h"><b id="itHead">Add session</b><button type="button" class="tt-md__x" onclick="TM.close('itOv')">&times;</button></div>
  <div class="tt-md__b">
    <input type="hidden" id="itId" value="0" />
    <div class="tt-row">
      <div class="tt-fld"><label>Day of week</label><select id="itDay" class="tt-sel"><option value="1">Monday</option><option value="2">Tuesday</option><option value="3">Wednesday</option><option value="4">Thursday</option><option value="5">Friday</option><option value="6">Saturday</option><option value="7">Sunday</option></select></div>
      <div class="tt-fld"><label>Start time</label><input type="time" id="itStart" class="tt-in" value="08:00" /></div>
      <div class="tt-fld"><label>Duration (min)</label><input type="number" id="itDur" class="tt-in" value="120" min="15" step="15" /></div>
    </div>
    <div class="tt-fld"><label>Teacher</label><div id="itTeacherCombo"></div><div class="tt-hint" id="itTeacherHint"></div></div>
    <div class="tt-fld"><label>Campus</label><div class="tt-radios" id="grpCampus"></div></div>
    <div class="tt-fld"><label>Room</label><div id="itRoomCombo"></div><div class="tt-avail" id="itAvail"></div></div>
    <div class="tt-fld"><label>Session type</label><div class="tt-radios" id="grpType"></div></div>
    <div class="tt-fld"><label>Delivery</label><div class="tt-radios" id="grpMode"></div></div>
    <div class="tt-fld" id="itMeetWrap" style="display:none;"><label>Meeting link</label><input type="text" id="itMeet" class="tt-in" placeholder="https://&hellip;" /></div>
    <div class="tt-fld"><label>Status</label><div class="tt-radios" id="grpStatus"></div><div class="tt-hint">Only <b>Active</b> sessions show on the calendar, exports and to lecturers/students.</div></div>
    <div class="tt-fld"><label>Description (optional)</label><input type="text" id="itDesc" class="tt-in" /></div>
    <div id="itWarn"></div>
    <div id="itErr" style="display:none;color:#b42318;font-size:12px;margin-top:6px;"></div>
  </div>
  <div class="tt-md__f">
    <span id="itOverrideNote" style="display:none;font-size:11px;color:#8a5a00;margin-right:auto;">Conflicts found &mdash; review above.</span>
    <button type="button" class="tt-btn" onclick="TM.close('itOv')">Cancel</button>
    <button type="button" class="tt-btn tt-btn--p" id="itSaveBtn" onclick="TM.save(0)">Save session</button>
    <button type="button" class="tt-btn tt-btn--d" id="itForceBtn" style="display:none;" onclick="TM.save(1)">Save anyway</button>
  </div>
  <div class="tt-saving" id="itSaving"><div class="tt-spin"></div>Saving&hellip;</div>
</div></div>

<div class="tt-toast" id="ttToast"></div>

<script>
var TM = (function(){
  var LK={campuses:[],teachers:[],programmes:[]}, ROOMS=[], CUR_PC=null, PREV_T=null, PAGE=1;
  var progCombo=null, teacherCombo=null, roomCombo=null;
  function qs(id){return document.getElementById(id);}
  function esc(s){s=(s==null?'':''+s);return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
  function toast(m,err){var t=qs('ttToast');t.textContent=m;t.className='tt-toast on'+(err?' tt-toast--err':'');setTimeout(function(){t.className='tt-toast';},2600);}
  function api(method,body){return fetch('TimetableManager.aspx/'+method,{method:'POST',headers:{'Content-Type':'application/json; charset=utf-8'},body:body?JSON.stringify(body):'{}'}).then(function(r){return r.json();}).then(function(j){return j.d;}).catch(function(){return {ok:false,message:'Network error'};});}

  // reusable searchable combo. items:[{value,label}]
  function makeCombo(host, items, placeholder, onPick){
    host.className='tt-combo';
    host.innerHTML='<input type="text" class="tt-in" placeholder="'+esc(placeholder)+'" autocomplete="off"><div class="tt-combo__list"></div>';
    var inp=host.querySelector('input'), list=host.querySelector('.tt-combo__list'), val='';
    function render(f){
      f=(f||'').toLowerCase();
      var m=items.filter(function(it){ return !f || (it.label||'').toLowerCase().indexOf(f)>=0; });
      if(!m.length){ list.innerHTML='<div class="tt-combo__i tt-combo__i--none">No match</div>'; return; }
      list.innerHTML=m.slice(0,60).map(function(it){ return '<div class="tt-combo__i" data-v="'+esc(it.value)+'" title="'+esc(it.label)+'">'+esc(it.label)+'</div>'; }).join('');
      Array.prototype.forEach.call(list.querySelectorAll('.tt-combo__i[data-v]'),function(el){ el.onmousedown=function(e){ e.preventDefault(); val=el.getAttribute('data-v'); inp.value=el.textContent; list.classList.remove('on'); if(onPick) onPick(val); }; });
    }
    inp.addEventListener('focus',function(){ render(inp.value); list.classList.add('on'); });
    inp.addEventListener('input',function(){ val=''; render(inp.value); list.classList.add('on'); });
    inp.addEventListener('blur',function(){ setTimeout(function(){ list.classList.remove('on'); },150); });
    return { value:function(){return val;}, set:function(v){ var it=items.filter(function(x){return String(x.value)===String(v);})[0]; if(it){val=it.value;inp.value=it.label;} else {val='';inp.value='';} }, clear:function(){val='';inp.value='';}, setItems:function(n){ items=n||[]; } };
  }
  // radio-group of buttons. items:[{value,label}]
  function radioGroup(host, items, onChange){
    host.innerHTML=items.map(function(it,i){ return '<button type="button" class="tt-radio'+(i===0?' on':'')+'" data-v="'+esc(it.value)+'">'+esc(it.label)+'</button>'; }).join('');
    Array.prototype.forEach.call(host.querySelectorAll('.tt-radio'),function(b){ b.onclick=function(){ Array.prototype.forEach.call(host.querySelectorAll('.tt-radio'),function(x){x.classList.remove('on');}); b.classList.add('on'); if(onChange) onChange(b.getAttribute('data-v')); }; });
    return { value:function(){ var on=host.querySelector('.tt-radio.on'); return on?on.getAttribute('data-v'):(items[0]?items[0].value:''); }, set:function(v){ Array.prototype.forEach.call(host.querySelectorAll('.tt-radio'),function(x){ x.classList.toggle('on', x.getAttribute('data-v')===String(v)); }); } };
  }
  var campusGrp=null, typeGrp=null, modeGrp=null, statusGrp=null;

  function init(){
    api('Lookups').then(function(d){
      if(d&&d.ok) LK=d;
      var progItems=[{value:'',label:'All programmes'}].concat((LK.programmes||[]).map(function(p){ return {value:p.code,label:(p.name||p.code)}; }));
      progCombo=makeCombo(qs('fProgCombo'), progItems, 'All programmes');
      var teachItems=[{value:'0',label:'Default (course lecturer)'}].concat((LK.teachers||[]).map(function(t){ return {value:String(t.id),label:t.name}; }));
      teacherCombo=makeCombo(qs('itTeacherCombo'), teachItems, 'Search lecturer…');
      var campusItems=(LK.campuses||[]).filter(function(c){return true;}).map(function(c){ return {value:String(c.id),label:(c.id===0?'Both':c.name.replace(/ CAMPUS/i,''))}; });
      // put Kakeeka/Kirumba first then Both
      campusItems.sort(function(a,b){ return (a.value==='0'?1:0)-(b.value==='0'?1:0); });
      campusGrp=radioGroup(qs('grpCampus'), campusItems.length?campusItems:[{value:'1',label:'Kakeeka'},{value:'2',label:'Kirumba'},{value:'0',label:'Both'}], function(){ loadRooms(0); });
      typeGrp=radioGroup(qs('grpType'), [{value:'LECTURE',label:'Lecture'},{value:'TUTORIAL',label:'Tutorial'},{value:'PRACTICAL',label:'Practical'},{value:'SEMINAR',label:'Seminar'},{value:'CAT',label:'CAT'}]);
      modeGrp=radioGroup(qs('grpMode'), [{value:'PHYSICAL',label:'Physical'},{value:'ONLINE',label:'Online'},{value:'HYBRID',label:'Hybrid'}], function(v){ qs('itMeetWrap').style.display=(v!=='PHYSICAL')?'':'none'; });
      statusGrp=radioGroup(qs('grpStatus'), [{value:'ACTIVE',label:'Active'},{value:'DRAFT',label:'Draft'},{value:'ARCHIVED',label:'Archived'}]);
      roomCombo=makeCombo(qs('itRoomCombo'), [], 'Search room…', function(){ roomAvailNote(); preview(); });
      load(initFromQuery());  // restore filters from the URL (GET) then load
    });
    qs('fQ').addEventListener('keydown',function(e){ if(e.key==='Enter') apply(); });
    ['itDay','itStart','itDur'].forEach(function(id){ qs(id).addEventListener('change',function(){ loadRooms(parseInt(roomCombo.value(),10)||0); }); });
  }

  // ── GET-state: filters live in the URL query string (bookmark/refresh safe) ──
  function readQuery(){
    var q={}, s=(location.search||'').replace(/^\?/,'');
    s.split('&').forEach(function(kv){ if(!kv) return; var p=kv.split('='); q[decodeURIComponent(p[0])]=decodeURIComponent((p[1]||'').replace(/\+/g,' ')); });
    return q;
  }
  function initFromQuery(){
    var q=readQuery();
    if(q.sy) qs('fSy').value=q.sy;
    if(q.sem) qs('fSem').value=q.sem;
    if(q.un==='1') qs('fUn').checked=true;
    if(q.q) qs('fQ').value=q.q;
    if(q.prog&&progCombo) progCombo.set(q.prog);
    return parseInt(q.page,10)||1;
  }
  function syncUrl(){
    var parts=[], sy=qs('fSy').value, sem=qs('fSem').value, prog=progCombo?progCombo.value():'', q=qs('fQ').value.trim(), un=qs('fUn').checked?1:0;
    if(sy&&sy!=='0') parts.push('sy='+encodeURIComponent(sy));
    if(sem&&sem!=='0') parts.push('sem='+encodeURIComponent(sem));
    if(prog) parts.push('prog='+encodeURIComponent(prog));
    if(q) parts.push('q='+encodeURIComponent(q));
    if(un) parts.push('un=1');
    if(PAGE>1) parts.push('page='+PAGE);
    try{ history.replaceState(null,'',location.pathname+(parts.length?('?'+parts.join('&')):'')); }catch(e){}
  }

  function apply(){ PAGE=1; load(1); }
  function load(page){
    PAGE=page||1;
    syncUrl();
    api('ListPCs',{q:qs('fQ').value.trim(),progcode:progCombo?progCombo.value():'',studyYear:parseInt(qs('fSy').value,10)||0,semester:parseInt(qs('fSem').value,10)||0,onlyUnscheduled:qs('fUn').checked?1:0,page:PAGE})
    .then(function(d){
      var b=qs('pcBody');
      if(!d||!d.ok){ b.innerHTML='<tr><td colspan="6" class="tt-empty">Unable to load.</td></tr>'; qs('pcPager').innerHTML=''; return; }
      if(!d.rows.length){ b.innerHTML='<tr><td colspan="6" class="tt-empty">No programme-courses match.</td></tr>'; qs('pcPager').innerHTML=''; return; }
      b.innerHTML=d.rows.map(function(r){
        var sess = r.sessions>0 ? '<span class="tt-pill tt-pill--sched" onclick="TM.manage('+r.id+')">'+r.sessions+' set</span>' : '<span class="tt-pill tt-pill--none" onclick="TM.manage('+r.id+')">None</span>';
        return '<tr><td><span class="tt-code">'+esc(r.courseCode)+'</span><div class="tt-cname">'+esc(r.courseName)+'</div></td><td>'+esc(r.progname||r.progcode)+'</td><td><span class="tt-yr">Y'+r.studyYear+' S'+r.semester+'</span></td>'
          +'<td>'+(esc(r.lecturerName)||'<span class="tt-muted">Unassigned</span>')+'</td><td>'+sess+'</td>'
          +'<td style="text-align:right;"><button type="button" class="tt-btn tt-btn--sm tt-btn--p" onclick="TM.manage('+r.id+')">Manage</button></td></tr>';
      }).join('');
      var pg=''; if(d.pages>1){ pg='<span>'+d.total+' courses &middot; page '+d.page+'/'+d.pages+'</span>'
        +'<a class="'+(d.page<=1?'off':'')+'" onclick="TM.load('+(d.page-1)+')">&lsaquo; Prev</a>'
        +'<a class="'+(d.page>=d.pages?'off':'')+'" onclick="TM.load('+(d.page+1)+')">Next &rsaquo;</a>'; }
      qs('pcPager').innerHTML=pg;
    });
  }

  function manage(pcId){
    api('GetItems',{pcId:pcId}).then(function(d){
      if(!d||!d.ok){ toast((d&&d.message)||'Failed',true); return; }
      CUR_PC=d.pc;
      qs('mgTitle').textContent='Sessions — '+d.pc.courseCode;
      qs('mgInfo').innerHTML=esc(d.pc.courseName)+' &middot; '+esc(d.pc.progname||d.pc.progcode)+' &middot; Year '+d.pc.studyYear+' Sem '+d.pc.semester+' &middot; Lecturer: <b>'+(esc(d.pc.lecturerName)||'Unassigned')+'</b>';
      renderItems(d.items);
      qs('mgOv').classList.add('on');
    });
  }
  function renderItems(items){
    if(!items.length){ qs('mgItems').innerHTML='<div class="tt-empty">No sessions yet for this course.</div>'; return; }
    qs('mgItems').innerHTML=items.map(function(it){
      var loc = it.roomName ? (esc(it.roomName)+(it.buildingName?(', '+esc(it.buildingName)):'')) : (it.roomLabel?esc(it.roomLabel):'<span class="tt-muted">no room</span>');
      var camp = it.campusId===0?'Both campuses':esc(it.campusName);
      var teach = it.teacherName?esc(it.teacherName):(esc(CUR_PC.lecturerName)||'course lecturer');
      var stb = it.status==='DRAFT'?'<span class="tt-sbadge tt-sbadge--draft">Draft</span>':it.status==='ARCHIVED'?'<span class="tt-sbadge tt-sbadge--arch">Archived</span>':'<span class="tt-sbadge tt-sbadge--active">Active</span>';
      var rc = it.status==='DRAFT'?' tt-itemrow--draft':it.status==='ARCHIVED'?' tt-itemrow--arch':'';
      return '<div class="tt-itemrow'+rc+'"><div class="tt-itemrow__m"><b>'+esc(it.dayName||'')+' '+esc(it.start)+'&ndash;'+esc(it.end)+stb+'</b>'
        +'<span>'+esc(it.sessionType)+' &middot; '+loc+' &middot; '+camp+' &middot; '+teach+(it.deliveryMode!=='PHYSICAL'?(' &middot; '+esc(it.deliveryMode)):'')+'</span></div>'
        +'<button type="button" class="tt-btn tt-btn--sm" onclick="TM.itemEdit('+it.id+')">Edit</button> '
        +'<button type="button" class="tt-btn tt-btn--sm" onclick="TM.dupe('+it.id+')">Duplicate</button> '
        +'<button type="button" class="tt-btn tt-btn--sm tt-btn--d" onclick="TM.itemDel('+it.id+')">Delete</button></div>';
    }).join('');
  }

  function itemEdit(itemId){
    qs('itErr').style.display='none'; qs('itWarn').innerHTML=''; qs('itForceBtn').style.display='none'; qs('itOverrideNote').style.display='none';
    api('GetItems',{pcId:CUR_PC.id}).then(function(d){
      var it=((d&&d.items)||[]).filter(function(x){return x.id===itemId;})[0];
      qs('itHead').textContent=itemId>0?'Edit session':'Add session';
      qs('itId').value=itemId;
      teacherCombo.set(it?(it.teacherId||0):0); qs('itTeacherHint').textContent='Blank/Default uses the course lecturer'+(CUR_PC.lecturerName?(': '+CUR_PC.lecturerName):'.');
      if(it){ qs('itDay').value=it.dayNo; qs('itStart').value=it.start; qs('itDur').value=it.durationMin; campusGrp.set(it.campusId); typeGrp.set(it.sessionType); modeGrp.set(it.deliveryMode); qs('itMeet').value=it.meetLink||''; qs('itDesc').value=it.description||''; statusGrp.set(it.status||'ACTIVE'); }
      else { qs('itDay').value=1; qs('itStart').value='08:00'; qs('itDur').value=120; campusGrp.set((LK.campuses[1]?LK.campuses[1].id:1)); typeGrp.set('LECTURE'); modeGrp.set('PHYSICAL'); qs('itMeet').value=''; qs('itDesc').value=''; statusGrp.set('ACTIVE'); }
      qs('itMeetWrap').style.display=(modeGrp.value()!=='PHYSICAL')?'':'none';
      loadRooms(it?it.roomId:0);
      qs('itOv').classList.add('on');
    });
  }
  function loadRooms(selectId){
    api('RoomsForSlot',{campusId:parseInt(campusGrp.value(),10)||0,dayNo:parseInt(qs('itDay').value,10),start:qs('itStart').value,durationMin:parseInt(qs('itDur').value,10)||60,excludeItemId:parseInt(qs('itId').value,10)||0}).then(function(d){
      ROOMS=(d&&d.rooms)||[];
      var items=[{value:'0',label:'— No room (online / not needed) —'}].concat(ROOMS.map(function(r){ return {value:String(r.id), label:r.name+' ('+(r.building?r.building+', ':'')+'cap '+r.capacity+') — '+(r.busy?'BUSY':'free')}; }));
      roomCombo.setItems(items); roomCombo.set(String(selectId||0));
      roomAvailNote(); preview();
    });
  }
  function roomAvailNote(){
    var id=parseInt(roomCombo.value(),10)||0, el=qs('itAvail');
    if(!id){ el.textContent=''; return; }
    var r=ROOMS.filter(function(x){return x.id===id;})[0];
    if(r&&r.busy){ el.className='tt-avail tt-avail--busy'; el.textContent='Occupied at this time by: '+r.busyWith; }
    else { el.className='tt-avail tt-avail--ok'; el.textContent='Room is free at this time.'; }
  }

  function preview(){
    if(!CUR_PC) return;
    clearTimeout(PREV_T);
    PREV_T=setTimeout(function(){
      api('PreviewConflicts',{itemId:parseInt(qs('itId').value,10)||0,pcId:CUR_PC.id,dayNo:parseInt(qs('itDay').value,10),start:qs('itStart').value,durationMin:parseInt(qs('itDur').value,10)||60,roomId:parseInt(roomCombo.value(),10)||0,teacherId:parseInt(teacherCombo.value(),10)||0,campusId:parseInt(campusGrp.value(),10)||0})
      .then(function(d){ renderWarn(d&&d.conflicts); });
    },250);
  }
  function renderWarn(conflicts){
    if(!conflicts||!conflicts.length){ qs('itWarn').innerHTML=''; return; }
    qs('itWarn').innerHTML='<div class="tt-warn"><b>Possible conflicts:</b><ul>'+conflicts.map(function(c){return '<li>'+esc(c.message)+'</li>';}).join('')+'</ul></div>';
  }

  function setSaving(on){ qs('itSaving').classList.toggle('on', !!on); qs('itSaveBtn').disabled=!!on; qs('itForceBtn').disabled=!!on; }
  function save(force){
    var rid=parseInt(roomCombo.value(),10)||0;
    var body={ itemId:parseInt(qs('itId').value,10)||0, pcId:CUR_PC.id, dayNo:parseInt(qs('itDay').value,10), start:qs('itStart').value, durationMin:parseInt(qs('itDur').value,10)||60,
      teacherId:parseInt(teacherCombo.value(),10)||0, campusId:parseInt(campusGrp.value(),10)||0, buildingId:roomBuilding(rid), roomId:rid,
      roomLabel:'', sessionType:typeGrp.value(), deliveryMode:modeGrp.value(), meetLink:qs('itMeet').value.trim(), description:qs('itDesc').value.trim(), status:statusGrp.value(), allowConflicts:force?1:0 };
    qs('itErr').style.display='none'; setSaving(true);
    api('SaveItem',body).then(function(d){
      setSaving(false);
      if(d&&d.ok){ toast('Session saved.'); close('itOv'); manage(CUR_PC.id); load(PAGE); return; }
      if(d&&d.needsOverride){ renderWarn(d.conflicts); qs('itForceBtn').style.display=''; qs('itOverrideNote').style.display=''; return; }
      var e=qs('itErr'); e.textContent=(d&&d.message)||'Save failed.'; e.style.display='block';
    });
  }
  function roomBuilding(roomId){ for(var i=0;i<ROOMS.length;i++) if(ROOMS[i].id===roomId) return ROOMS[i].buildingId||0; return 0; }
  function itemDel(id){ if(!confirm('Delete this session?')) return; api('DeleteItem',{itemId:id}).then(function(d){ if(d&&d.ok){ toast('Deleted.'); manage(CUR_PC.id); load(PAGE); } else toast((d&&d.message)||'Failed',true); }); }
  function dupe(id){ api('DuplicateItem',{itemId:id}).then(function(d){ if(d&&d.ok){ toast('Duplicated as draft.'); manage(CUR_PC.id); load(PAGE); } else toast((d&&d.message)||'Failed',true); }); }

  function importLegacy(){
    api('ImportPreview').then(function(d){
      if(!d||!d.ok){ toast((d&&d.message)||'Preview failed',true); return; }
      var toImport=d.distinct-d.already;
      if(!confirm('Import the legacy timetable into the new system?\n\nDistinct sessions found: '+d.distinct+'\nAlready imported (skipped): '+d.already+'\nWill import now: '+toImport+'\nUnmatched legacy rows (skipped): '+d.unmatched+'\n\nProceed?')) return;
      api('ImportRun').then(function(r){ if(r&&r.ok){ toast('Imported '+r.imported+' session'+(r.imported==1?'':'s')+'.'); load(1); } else toast((r&&r.message)||'Import failed',true); });
    });
  }

  function close(id){ qs(id).classList.remove('on'); }
  init();
  return { apply:apply, load:load, manage:manage, itemEdit:itemEdit, itemDel:itemDel, dupe:dupe, preview:preview, save:save, close:close, importLegacy:importLegacy };
})();
</script>
</asp:Content>
