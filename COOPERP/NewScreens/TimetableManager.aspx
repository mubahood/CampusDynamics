<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="TimetableManager.aspx.cs" Inherits="COOPERP_NewScreens_TimetableManager" Title="Timetable Manager - Campus Dynamics" %>
<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.tt-wrap{padding:4px 2px;}
.tt-h__t{font-size:18px;font-weight:800;color:#05275C;}
.tt-h__s{font-size:11.5px;color:#6b7280;margin:2px 0 10px;}
.tt-card{background:#fff;border:1px solid #e0e5ed;margin-bottom:12px;}
.tt-card__h{display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;padding:10px 12px;border-bottom:2px solid #e0e5ed;background:#f8fafc;}
.tt-card__t{font-size:12px;font-weight:800;color:#05275C;text-transform:uppercase;letter-spacing:.4px;}
.tt-filters{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:10px 12px;border-bottom:1px solid #eef1f5;}
.tt-in,.tt-sel{border:1px solid #cfd8e3;background:#fff;padding:7px 9px;font-size:12px;color:#1f2937;border-radius:0;font-family:inherit;}
.tt-in:focus,.tt-sel:focus{outline:none;border-color:#174DA4;}
.tt-search{min-width:220px;}
.tt-chk{font-size:11px;color:#4b5563;display:inline-flex;align-items:center;gap:5px;}
.tt-btn{display:inline-flex;align-items:center;gap:6px;padding:8px 12px;border:1px solid #d2dae6;background:#fff;color:#05275C;text-decoration:none;font-size:12px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;}
.tt-btn:hover{background:#f5f8ff;border-color:#174DA4;color:#174DA4;}
.tt-btn--p{background:#05275C;border-color:#05275C;color:#fff;}.tt-btn--p:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.tt-btn--d{background:#b42318;border-color:#b42318;color:#fff;}.tt-btn--d:hover{background:#991b1b;color:#fff;}
.tt-btn--sm{padding:5px 10px;font-size:11px;}
.tt-tblwrap{overflow-x:auto;}
.tt-tbl{width:100%;border-collapse:separate;border-spacing:0;min-width:720px;}
.tt-tbl th{background:#f8fafc;border-bottom:2px solid #e0e5ed;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.45px;color:#6b7280;padding:9px 10px;text-align:left;white-space:nowrap;}
.tt-tbl td{border-bottom:1px solid #eef2f6;font-size:12px;color:#1f2937;padding:8px 10px;vertical-align:middle;}
.tt-tbl tbody tr:hover td{background:#f9fbff;}
.tt-code{font-family:Consolas,monospace;font-size:11px;color:#174DA4;font-weight:700;}
.tt-muted{color:#9ca3af;font-size:11px;}
.tt-pill{display:inline-block;padding:3px 8px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;}
.tt-pill--sched{background:#e6f4ea;color:#166534;}.tt-pill--none{background:#f1f5f9;color:#94a3b8;}
.tt-pager{display:flex;gap:8px;align-items:center;justify-content:flex-end;padding:8px 12px;font-size:11px;color:#6b7280;}
.tt-pager a{padding:4px 9px;border:1px solid #d2dae6;color:#05275C;text-decoration:none;cursor:pointer;}
.tt-pager a.off{opacity:.4;pointer-events:none;}
/* modal */
.tt-ov{display:none;position:fixed;inset:0;background:rgba(5,25,60,.5);z-index:1500;align-items:flex-start;justify-content:center;padding:28px 12px;overflow:auto;}
.tt-ov.on{display:flex;}
.tt-md{background:#fff;border:1px solid #e0e5ed;width:640px;max-width:100%;box-shadow:0 18px 50px rgba(0,0,0,.28);}
.tt-md--wide{width:720px;}
.tt-md__h{padding:12px 16px;background:#05275C;color:#fff;display:flex;justify-content:space-between;align-items:center;}
.tt-md__h b{font-size:14px;}.tt-md__h small{display:block;font-size:11px;opacity:.85;font-weight:400;}
.tt-md__x{background:none;border:none;color:#fff;font-size:20px;cursor:pointer;line-height:1;}
.tt-md__b{padding:16px;max-height:72vh;overflow:auto;}
.tt-md__f{padding:12px 16px;border-top:1px solid #e0e5ed;background:#fafbfc;display:flex;gap:8px;justify-content:flex-end;align-items:center;}
.tt-fld{margin-bottom:11px;}.tt-fld>label{display:block;font-size:11px;font-weight:700;color:#4b5563;text-transform:uppercase;letter-spacing:.3px;margin-bottom:4px;}
.tt-fld .tt-in,.tt-fld .tt-sel{width:100%;box-sizing:border-box;}
.tt-row{display:flex;gap:10px;flex-wrap:wrap;}.tt-row>*{flex:1;min-width:120px;}
.tt-itemrow{display:flex;align-items:center;gap:10px;padding:9px 11px;border:1px solid #e0e5ed;margin-bottom:6px;background:#fff;}
.tt-itemrow__m{flex:1;min-width:0;}.tt-itemrow__m b{font-size:12.5px;color:#05275C;}.tt-itemrow__m span{display:block;font-size:11px;color:#6b7280;margin-top:2px;}
.tt-warn{background:#fff8e1;border:1px solid #f5d99a;padding:9px 11px;margin-top:8px;font-size:11.5px;color:#8a5a00;}
.tt-warn b{color:#8a5a00;}.tt-warn ul{margin:4px 0 0;padding-left:18px;}
.tt-empty{text-align:center;color:#94a3b8;padding:22px;font-size:13px;}
.tt-toast{position:fixed;bottom:20px;right:20px;z-index:99999;padding:10px 16px;font-size:13px;font-weight:600;color:#fff;background:#05275C;box-shadow:0 3px 10px rgba(0,0,0,.2);opacity:0;transition:opacity .3s;}
.tt-toast.on{opacity:1;}.tt-toast--err{background:#b42318;}
</style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="tt-wrap">
  <div class="tt-h__t">Timetable Manager</div>
  <div class="tt-h__s">Schedule lecture sessions per programme-course. Each session belongs to a course &times; lecturer &times; programme.</div>

  <div class="tt-card">
    <div class="tt-filters">
      <select id="fYear" class="tt-sel" onchange="TM.load(1)"></select>
      <select id="fProg" class="tt-sel" onchange="TM.load(1)"><option value="">All programmes</option></select>
      <select id="fSy" class="tt-sel" onchange="TM.load(1)"><option value="0">Any year</option><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select>
      <select id="fSem" class="tt-sel" onchange="TM.load(1)"><option value="0">Any sem</option><option value="1">Sem 1</option><option value="2">Sem 2</option></select>
      <input type="text" id="fQ" class="tt-in tt-search" placeholder="Search course / programme / lecturer&hellip;" />
      <label class="tt-chk"><input type="checkbox" id="fUn" onchange="TM.load(1)" /> Only unscheduled</label>
      <a class="tt-btn tt-btn--sm" href="RoomsBuildings.aspx">Rooms &amp; buildings</a>
      <a class="tt-btn tt-btn--sm" href="TimetableCalendar.aspx">Calendar</a>
    </div>
    <div class="tt-tblwrap"><table class="tt-tbl"><thead><tr><th>Course</th><th>Programme</th><th>Yr/Sem</th><th>Lecturer</th><th>Sessions</th><th style="text-align:right;">Actions</th></tr></thead><tbody id="pcBody"><tr><td colspan="6" class="tt-empty">Loading&hellip;</td></tr></tbody></table></div>
    <div class="tt-pager" id="pcPager"></div>
  </div>
</div>

<!-- Manage sessions modal -->
<div class="tt-ov" id="mgOv"><div class="tt-md tt-md--wide">
  <div class="tt-md__h"><b id="mgTitle">Sessions</b><button type="button" class="tt-md__x" onclick="TM.close('mgOv')">&times;</button></div>
  <div class="tt-md__b">
    <div id="mgInfo" class="tt-h__s" style="margin:0 0 10px;"></div>
    <div id="mgItems"></div>
    <button type="button" class="tt-btn tt-btn--p" style="margin-top:10px;" onclick="TM.itemEdit(0)">+ Add session</button>
  </div>
</div></div>

<!-- Item editor modal -->
<div class="tt-ov" id="itOv"><div class="tt-md">
  <div class="tt-md__h"><b id="itHead">Add session</b><button type="button" class="tt-md__x" onclick="TM.close('itOv')">&times;</button></div>
  <div class="tt-md__b">
    <input type="hidden" id="itId" value="0" />
    <div class="tt-row">
      <div class="tt-fld"><label>Day</label><select id="itDay" class="tt-sel"><option value="1">Monday</option><option value="2">Tuesday</option><option value="3">Wednesday</option><option value="4">Thursday</option><option value="5">Friday</option><option value="6">Saturday</option><option value="7">Sunday</option></select></div>
      <div class="tt-fld"><label>Start time</label><input type="time" id="itStart" class="tt-in" value="08:00" /></div>
      <div class="tt-fld"><label>Minutes</label><input type="number" id="itDur" class="tt-in" value="120" min="15" step="15" /></div>
    </div>
    <div class="tt-fld"><label>Teacher</label><select id="itTeacher" class="tt-sel"></select></div>
    <div class="tt-row">
      <div class="tt-fld"><label>Campus</label><select id="itCampus" class="tt-sel" onchange="TM.campusChange()"></select></div>
      <div class="tt-fld"><label>Room</label><select id="itRoom" class="tt-sel" onchange="TM.preview()"></select></div>
    </div>
    <div class="tt-fld"><label>Or type a location (online / TBD / external)</label><input type="text" id="itRoomLabel" class="tt-in" placeholder="Leave blank if a room is chosen" /></div>
    <div class="tt-row">
      <div class="tt-fld"><label>Session type</label><select id="itType" class="tt-sel"><option>LECTURE</option><option>TUTORIAL</option><option>PRACTICAL</option><option>SEMINAR</option><option>CAT</option></select></div>
      <div class="tt-fld"><label>Delivery</label><select id="itMode" class="tt-sel" onchange="TM.modeChange()"><option>PHYSICAL</option><option>ONLINE</option><option>HYBRID</option></select></div>
    </div>
    <div class="tt-fld" id="itMeetWrap" style="display:none;"><label>Meeting link</label><input type="text" id="itMeet" class="tt-in" placeholder="https://&hellip;" /></div>
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
</div></div>

<div class="tt-toast" id="ttToast"></div>

<script>
var TM = (function(){
  var LK={campuses:[],teachers:[],years:[],programmes:[]}, ROOMS=[], CUR_PC=null, CUR_YEAR='', PREV_T=null;
  function qs(id){return document.getElementById(id);}
  function esc(s){s=(s==null?'':''+s);return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
  function toast(m,err){var t=qs('ttToast');t.textContent=m;t.className='tt-toast on'+(err?' tt-toast--err':'');setTimeout(function(){t.className='tt-toast';},2600);}
  function api(method,body){return fetch('TimetableManager.aspx/'+method,{method:'POST',headers:{'Content-Type':'application/json; charset=utf-8'},body:body?JSON.stringify(body):'{}'}).then(function(r){return r.json();}).then(function(j){return j.d;}).catch(function(){return {ok:false,message:'Network error'};});}

  function init(){
    api('Lookups').then(function(d){
      if(d&&d.ok){ LK=d; }
      var yh=''; for(var i=0;i<LK.years.length;i++) yh+='<option>'+esc(LK.years[i])+'</option>';
      if(!LK.years.length) yh='<option>2026/2027</option>';
      qs('fYear').innerHTML=yh;
      var ph='<option value="">All programmes</option>'; for(var j=0;j<LK.programmes.length;j++) ph+='<option value="'+esc(LK.programmes[j].code)+'">'+esc(LK.programmes[j].name||LK.programmes[j].code)+'</option>';
      qs('fProg').innerHTML=ph;
      // campus dropdown for editor
      var ch=''; for(var k=0;k<LK.campuses.length;k++){ var c=LK.campuses[k]; ch+='<option value="'+c.id+'">'+esc(c.id===0?'Both / All campuses':c.name)+'</option>'; }
      qs('itCampus').innerHTML=ch;
      load(1);
    });
    var t=null; qs('fQ').addEventListener('input',function(){ clearTimeout(t); t=setTimeout(function(){load(1);},300); });
  }

  function load(page){
    CUR_YEAR=qs('fYear').value;
    api('ListPCs',{acadYear:CUR_YEAR,q:qs('fQ').value.trim(),progcode:qs('fProg').value,studyYear:parseInt(qs('fSy').value,10)||0,semester:parseInt(qs('fSem').value,10)||0,onlyUnscheduled:qs('fUn').checked?1:0,page:page||1})
    .then(function(d){
      var b=qs('pcBody');
      if(!d||!d.ok){ b.innerHTML='<tr><td colspan="6" class="tt-empty">Unable to load.</td></tr>'; qs('pcPager').innerHTML=''; return; }
      if(!d.rows.length){ b.innerHTML='<tr><td colspan="6" class="tt-empty">No programme-courses match.</td></tr>'; qs('pcPager').innerHTML=''; return; }
      b.innerHTML=d.rows.map(function(r){
        var sess = r.sessions>0 ? '<span class="tt-pill tt-pill--sched">'+r.sessions+' session'+(r.sessions==1?'':'s')+'</span>' : '<span class="tt-pill tt-pill--none">None</span>';
        return '<tr><td><span class="tt-code">'+esc(r.courseCode)+'</span><div>'+esc(r.courseName)+'</div></td><td>'+esc(r.progname||r.progcode)+'</td><td>Y'+r.studyYear+' / S'+r.semester+'</td>'
          +'<td>'+(esc(r.lecturerName)||'<span class="tt-muted">Unassigned</span>')+'</td><td>'+sess+'</td>'
          +'<td style="text-align:right;"><button type="button" class="tt-btn tt-btn--sm tt-btn--p" onclick="TM.manage('+r.id+')">Manage sessions</button></td></tr>';
      }).join('');
      var pg=''; if(d.pages>1){ pg='<span>'+d.total+' courses &middot; page '+d.page+'/'+d.pages+'</span>'
        +'<a class="'+(d.page<=1?'off':'')+'" onclick="TM.load('+(d.page-1)+')">&lsaquo; Prev</a>'
        +'<a class="'+(d.page>=d.pages?'off':'')+'" onclick="TM.load('+(d.page+1)+')">Next &rsaquo;</a>'; }
      qs('pcPager').innerHTML=pg;
    });
  }

  function manage(pcId){
    api('GetItems',{pcId:pcId,acadYear:CUR_YEAR}).then(function(d){
      if(!d||!d.ok){ toast((d&&d.message)||'Failed',true); return; }
      CUR_PC=d.pc;
      qs('mgTitle').textContent='Sessions — '+d.pc.courseCode;
      qs('mgInfo').innerHTML=esc(d.pc.courseName)+' &middot; '+esc(d.pc.progname||d.pc.progcode)+' &middot; Year '+d.pc.studyYear+' Sem '+d.pc.semester+' &middot; '+esc(CUR_YEAR)+' &middot; Lecturer: <b>'+(esc(d.pc.lecturerName)||'Unassigned')+'</b>';
      renderItems(d.items);
      qs('mgOv').classList.add('on');
    });
  }
  function renderItems(items){
    if(!items.length){ qs('mgItems').innerHTML='<div class="tt-empty">No sessions yet for this course this year.</div>'; return; }
    qs('mgItems').innerHTML=items.map(function(it){
      var loc = it.roomName ? (esc(it.roomName)+(it.buildingName?(', '+esc(it.buildingName)):'')) : (it.roomLabel?esc(it.roomLabel):'<span class="tt-muted">no room</span>');
      var camp = it.campusId===0?'Both campuses':esc(it.campusName);
      var teach = it.teacherName?esc(it.teacherName):(esc(CUR_PC.lecturerName)||'course lecturer');
      return '<div class="tt-itemrow"><div class="tt-itemrow__m"><b>'+esc(it.dayName||'')+' '+esc(it.start)+'&ndash;'+esc(it.end)+'</b>'
        +'<span>'+esc(it.sessionType)+' &middot; '+loc+' &middot; '+camp+' &middot; '+teach+(it.deliveryMode!=='PHYSICAL'?(' &middot; '+esc(it.deliveryMode)):'')+'</span></div>'
        +'<button type="button" class="tt-btn tt-btn--sm" onclick="TM.itemEdit('+it.id+')">Edit</button> '
        +'<button type="button" class="tt-btn tt-btn--sm tt-btn--d" onclick="TM.itemDel('+it.id+')">Delete</button></div>';
    }).join('');
  }

  var ITEMS_CACHE=[];
  function teacherOpts(defName){
    var h='<option value="0">Default (course lecturer'+(defName?': '+esc(defName):'')+')</option>';
    for(var i=0;i<LK.teachers.length;i++) h+='<option value="'+LK.teachers[i].id+'">'+esc(LK.teachers[i].name)+'</option>';
    return h;
  }
  function itemEdit(itemId){
    qs('itErr').style.display='none'; qs('itWarn').innerHTML=''; qs('itForceBtn').style.display='none'; qs('itOverrideNote').style.display='none';
    qs('itTeacher').innerHTML=teacherOpts(CUR_PC?CUR_PC.lecturerName:'');
    // preload current items to find the one being edited
    api('GetItems',{pcId:CUR_PC.id,acadYear:CUR_YEAR}).then(function(d){
      ITEMS_CACHE=(d&&d.items)||[];
      var it=ITEMS_CACHE.filter(function(x){return x.id===itemId;})[0];
      qs('itHead').textContent=itemId>0?'Edit session':'Add session';
      qs('itId').value=itemId;
      if(it){ qs('itDay').value=it.dayNo; qs('itStart').value=it.start; qs('itDur').value=it.durationMin; qs('itTeacher').value=it.teacherId||0; qs('itCampus').value=it.campusId; qs('itRoomLabel').value=it.roomLabel||''; qs('itType').value=it.sessionType; qs('itMode').value=it.deliveryMode; qs('itMeet').value=it.meetLink||''; qs('itDesc').value=it.description||''; }
      else { qs('itDay').value=1; qs('itStart').value='08:00'; qs('itDur').value=120; qs('itTeacher').value=0; qs('itCampus').value=(LK.campuses[1]?LK.campuses[1].id:1); qs('itRoomLabel').value=''; qs('itType').value='LECTURE'; qs('itMode').value='PHYSICAL'; qs('itMeet').value=''; qs('itDesc').value=''; }
      modeChange();
      loadRooms(it?it.roomId:0);
      qs('itOv').classList.add('on');
    });
  }
  function campusChange(){ loadRooms(0); }
  function loadRooms(selectId){
    api('RoomsForCampus',{campusId:parseInt(qs('itCampus').value,10)||0}).then(function(d){
      ROOMS=(d&&d.rooms)||[];
      var h='<option value="0">&mdash; no room / use location text &mdash;</option>';
      for(var i=0;i<ROOMS.length;i++){ var r=ROOMS[i]; h+='<option value="'+r.id+'">'+esc(r.name)+' ('+(r.building?esc(r.building)+', ':'')+'cap '+r.capacity+')</option>'; }
      qs('itRoom').innerHTML=h; if(selectId) qs('itRoom').value=selectId;
      preview();
    });
  }
  function modeChange(){ qs('itMeetWrap').style.display=(qs('itMode').value!=='PHYSICAL')?'':'none'; }

  function preview(){
    if(!CUR_PC) return;
    clearTimeout(PREV_T);
    PREV_T=setTimeout(function(){
      api('PreviewConflicts',{itemId:parseInt(qs('itId').value,10)||0,pcId:CUR_PC.id,acadYear:CUR_YEAR,dayNo:parseInt(qs('itDay').value,10),start:qs('itStart').value,durationMin:parseInt(qs('itDur').value,10)||60,roomId:parseInt(qs('itRoom').value,10)||0,teacherId:parseInt(qs('itTeacher').value,10)||0,campusId:parseInt(qs('itCampus').value,10)||0})
      .then(function(d){ renderWarn(d&&d.conflicts); });
    },250);
  }
  function renderWarn(conflicts){
    if(!conflicts||!conflicts.length){ qs('itWarn').innerHTML=''; return; }
    qs('itWarn').innerHTML='<div class="tt-warn"><b>Possible conflicts:</b><ul>'+conflicts.map(function(c){return '<li>'+esc(c.message)+'</li>';}).join('')+'</ul></div>';
  }

  function save(force){
    var body={ itemId:parseInt(qs('itId').value,10)||0, pcId:CUR_PC.id, acadYear:CUR_YEAR, dayNo:parseInt(qs('itDay').value,10), start:qs('itStart').value, durationMin:parseInt(qs('itDur').value,10)||60,
      teacherId:parseInt(qs('itTeacher').value,10)||0, campusId:parseInt(qs('itCampus').value,10)||0, buildingId:roomBuilding(parseInt(qs('itRoom').value,10)||0), roomId:parseInt(qs('itRoom').value,10)||0,
      roomLabel:qs('itRoomLabel').value.trim(), sessionType:qs('itType').value, deliveryMode:qs('itMode').value, meetLink:qs('itMeet').value.trim(), description:qs('itDesc').value.trim(), allowConflicts:force?1:0 };
    api('SaveItem',body).then(function(d){
      if(d&&d.ok){ toast('Session saved.'); close('itOv'); manage(CUR_PC.id); load(qsPage()); return; }
      if(d&&d.needsOverride){ renderWarn(d.conflicts); qs('itForceBtn').style.display=''; qs('itOverrideNote').style.display=''; return; }
      var e=qs('itErr'); e.textContent=(d&&d.message)||'Save failed.'; e.style.display='block';
    });
  }
  function roomBuilding(roomId){ for(var i=0;i<ROOMS.length;i++) if(ROOMS[i].id===roomId) return ROOMS[i].buildingId||0; return 0; }
  function qsPage(){ return 1; }
  function itemDel(id){ if(!confirm('Delete this session?')) return; api('DeleteItem',{itemId:id}).then(function(d){ if(d&&d.ok){ toast('Deleted.'); manage(CUR_PC.id); load(1); } else toast((d&&d.message)||'Failed',true); }); }

  function close(id){ qs(id).classList.remove('on'); }
  // wire preview on field changes
  ['itDay','itStart','itDur','itTeacher'].forEach(function(id){ var el=document.getElementById(id); if(el) el.addEventListener('change',preview); });

  init();
  return { load:load, manage:manage, itemEdit:itemEdit, itemDel:itemDel, campusChange:campusChange, modeChange:modeChange, preview:preview, save:save, close:close };
})();
</script>
</asp:Content>
