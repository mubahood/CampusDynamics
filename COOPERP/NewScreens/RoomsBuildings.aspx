<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="RoomsBuildings.aspx.cs" Inherits="COOPERP_NewScreens_RoomsBuildings" Title="Rooms & Buildings - Campus Dynamics" %>
<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.tt-wrap{padding:4px 2px;}
.tt-h{display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;margin-bottom:10px;}
.tt-h__t{font-size:18px;font-weight:800;color:#05275C;}
.tt-h__s{font-size:11.5px;color:#6b7280;margin-top:2px;}
.tt-tabs{display:flex;gap:2px;border-bottom:2px solid #e0e5ed;margin-bottom:14px;flex-wrap:wrap;}
.tt-tab{font-size:12px;font-weight:700;padding:9px 16px;border:none;background:none;color:#6b7280;cursor:pointer;border-bottom:2px solid transparent;margin-bottom:-2px;font-family:inherit;}
.tt-tab.on{color:#174DA4;border-bottom-color:#174DA4;}
.tt-card{background:#fff;border:1px solid #e0e5ed;margin-bottom:12px;}
.tt-card__h{display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;padding:10px 12px;border-bottom:2px solid #e0e5ed;background:#f8fafc;}
.tt-card__t{font-size:12px;font-weight:800;color:#05275C;text-transform:uppercase;letter-spacing:.4px;}
.tt-btn{display:inline-flex;align-items:center;gap:6px;padding:8px 12px;border:1px solid #d2dae6;background:#fff;color:#05275C;text-decoration:none;font-size:12px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;}
.tt-btn:hover{background:#f5f8ff;border-color:#174DA4;color:#174DA4;}
.tt-btn--p{background:#05275C;border-color:#05275C;color:#fff;}.tt-btn--p:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.tt-btn--d{background:#b42318;border-color:#b42318;color:#fff;}.tt-btn--d:hover{background:#991b1b;color:#fff;}
.tt-btn--sm{padding:5px 10px;font-size:11px;}
.tt-tblwrap{overflow-x:auto;}
.tt-tbl{width:100%;border-collapse:separate;border-spacing:0;min-width:560px;}
.tt-tbl th{background:#f8fafc;border-bottom:2px solid #e0e5ed;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.45px;color:#6b7280;padding:9px 10px;text-align:left;white-space:nowrap;}
.tt-tbl td{border-bottom:1px solid #eef2f6;font-size:12px;color:#1f2937;padding:8px 10px;vertical-align:middle;}
.tt-tbl tbody tr:hover td{background:#f9fbff;}
.tt-pill{display:inline-block;padding:3px 8px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;}
.tt-pill--on{background:#e6f4ea;color:#166534;}.tt-pill--off{background:#f1f5f9;color:#94a3b8;}
.tt-muted{color:#6b7280;font-size:11px;}
.tt-in,.tt-sel{width:100%;border:1px solid #cfd8e3;background:#fff;padding:8px 10px;font-size:13px;color:#1f2937;border-radius:0;box-sizing:border-box;font-family:inherit;}
.tt-in:focus,.tt-sel:focus{outline:none;border-color:#174DA4;}
.tt-fld{margin-bottom:11px;}.tt-fld>label{display:block;font-size:11px;font-weight:700;color:#4b5563;text-transform:uppercase;letter-spacing:.3px;margin-bottom:4px;}
.tt-row2{display:flex;gap:10px;}.tt-row2>*{flex:1;}
.tt-ov{display:none;position:fixed;inset:0;background:rgba(5,25,60,.5);z-index:1500;align-items:flex-start;justify-content:center;padding:34px 12px;overflow:auto;}
.tt-ov.on{display:flex;}
.tt-md{background:#fff;border:1px solid #e0e5ed;width:520px;max-width:100%;box-shadow:0 18px 50px rgba(0,0,0,.28);}
.tt-md__h{padding:12px 16px;background:#05275C;color:#fff;display:flex;justify-content:space-between;align-items:center;}
.tt-md__h b{font-size:14px;}.tt-md__x{background:none;border:none;color:#fff;font-size:20px;cursor:pointer;line-height:1;}
.tt-md__b{padding:16px;}
.tt-md__f{padding:12px 16px;border-top:1px solid #e0e5ed;background:#fafbfc;display:flex;gap:8px;justify-content:flex-end;}
.tt-empty{text-align:center;color:#94a3b8;padding:26px;font-size:13px;}
.tt-free{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:8px;margin-top:12px;}
.tt-freecard{border:1px solid #e0e5ed;background:#fff;padding:10px 12px;}
.tt-freecard b{color:#05275C;font-size:13px;}.tt-freecard span{display:block;font-size:10.5px;color:#6b7280;margin-top:2px;}
.tt-toast{position:fixed;bottom:20px;right:20px;z-index:99999;padding:10px 16px;font-size:13px;font-weight:600;color:#fff;background:#05275C;box-shadow:0 3px 10px rgba(0,0,0,.2);opacity:0;transition:opacity .3s;}
.tt-toast.on{opacity:1;}.tt-toast--err{background:#b42318;}
</style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="tt-wrap">
  <div class="tt-h">
    <div><div class="tt-h__t">Rooms &amp; Buildings</div><div class="tt-h__s">Manage teaching venues used by the timetable &mdash; and see what's free.</div></div>
  </div>
  <div class="tt-tabs">
    <button type="button" class="tt-tab on" data-tab="rooms" onclick="TT.tab(this,'rooms')">Rooms</button>
    <button type="button" class="tt-tab" data-tab="buildings" onclick="TT.tab(this,'buildings')">Buildings</button>
    <button type="button" class="tt-tab" data-tab="free" onclick="TT.tab(this,'free')">Find a free room</button>
  </div>

  <div id="paneRooms" class="tt-pane">
    <div class="tt-card"><div class="tt-card__h"><span class="tt-card__t">Rooms</span><button type="button" class="tt-btn tt-btn--p" onclick="TT.roomEdit(0)">+ Add room</button></div>
      <div class="tt-tblwrap"><table class="tt-tbl"><thead><tr><th>Room</th><th>Capacity</th><th>Building</th><th>Campus</th><th>Type</th><th>Status</th><th style="text-align:right;">Actions</th></tr></thead><tbody id="roomsBody"><tr><td colspan="7" class="tt-empty">Loading&hellip;</td></tr></tbody></table></div>
    </div>
  </div>

  <div id="paneBuildings" class="tt-pane" style="display:none;">
    <div class="tt-card"><div class="tt-card__h"><span class="tt-card__t">Buildings</span><button type="button" class="tt-btn tt-btn--p" onclick="TT.bldgEdit(0)">+ Add building</button></div>
      <div class="tt-tblwrap"><table class="tt-tbl"><thead><tr><th>Building</th><th>Code</th><th>Campus</th><th>Floors</th><th>Rooms</th><th>Status</th><th style="text-align:right;">Actions</th></tr></thead><tbody id="bldgsBody"><tr><td colspan="7" class="tt-empty">Loading&hellip;</td></tr></tbody></table></div>
    </div>
  </div>

  <div id="paneFree" class="tt-pane" style="display:none;">
    <div class="tt-card"><div class="tt-card__h"><span class="tt-card__t">Find a free room</span></div>
      <div style="padding:14px;">
        <div class="tt-row2">
          <div class="tt-fld"><label>Academic year</label><input type="text" id="fAy" class="tt-in" value="2026/2027" /></div>
          <div class="tt-fld"><label>Day</label><select id="fDay" class="tt-sel"><option value="1">Monday</option><option value="2">Tuesday</option><option value="3">Wednesday</option><option value="4">Thursday</option><option value="5">Friday</option><option value="6">Saturday</option><option value="7">Sunday</option></select></div>
          <div class="tt-fld"><label>Start</label><input type="time" id="fStart" class="tt-in" value="08:00" /></div>
          <div class="tt-fld"><label>Minutes</label><input type="number" id="fDur" class="tt-in" value="120" min="15" step="15" /></div>
        </div>
        <div class="tt-row2">
          <div class="tt-fld"><label>Campus</label><select id="fCampus" class="tt-sel"></select></div>
          <div class="tt-fld"><label>Min capacity</label><input type="number" id="fCap" class="tt-in" value="0" min="0" /></div>
          <div class="tt-fld" style="display:flex;align-items:flex-end;"><button type="button" class="tt-btn tt-btn--p" onclick="TT.findFree()" style="width:100%;">Search</button></div>
        </div>
        <div id="freeResult"></div>
      </div>
    </div>
  </div>
</div>

<!-- Room modal -->
<div class="tt-ov" id="roomOv"><div class="tt-md">
  <div class="tt-md__h"><b id="roomHead">Add room</b><button type="button" class="tt-md__x" onclick="TT.close('roomOv')">&times;</button></div>
  <div class="tt-md__b">
    <input type="hidden" id="rId" value="0" />
    <div class="tt-fld"><label>Room name</label><input type="text" id="rName" class="tt-in" placeholder="e.g. CHWA 1 / ICT LAB 2" /></div>
    <div class="tt-row2">
      <div class="tt-fld"><label>Capacity</label><input type="number" id="rCap" class="tt-in" value="60" min="0" /></div>
      <div class="tt-fld"><label>Campus</label><select id="rCampus" class="tt-sel"></select></div>
    </div>
    <div class="tt-row2">
      <div class="tt-fld"><label>Building</label><select id="rBldg" class="tt-sel"></select></div>
      <div class="tt-fld"><label>Type</label><select id="rType" class="tt-sel"><option value="">&mdash;</option><option>LECTURE</option><option>LAB</option><option>SEMINAR</option><option>HALL</option><option>OFFICE</option></select></div>
    </div>
    <div class="tt-fld"><label><input type="checkbox" id="rActive" checked="checked" /> Active</label></div>
    <div id="roomErr" style="display:none;color:#b42318;font-size:12px;"></div>
  </div>
  <div class="tt-md__f"><button type="button" class="tt-btn" onclick="TT.close('roomOv')">Cancel</button><button type="button" class="tt-btn tt-btn--p" onclick="TT.roomSave()">Save room</button></div>
</div></div>

<!-- Building modal -->
<div class="tt-ov" id="bldgOv"><div class="tt-md">
  <div class="tt-md__h"><b id="bldgHead">Add building</b><button type="button" class="tt-md__x" onclick="TT.close('bldgOv')">&times;</button></div>
  <div class="tt-md__b">
    <input type="hidden" id="bId" value="0" />
    <div class="tt-fld"><label>Building name</label><input type="text" id="bName" class="tt-in" placeholder="e.g. CHWA Block" /></div>
    <div class="tt-row2">
      <div class="tt-fld"><label>Code</label><input type="text" id="bCode" class="tt-in" placeholder="Optional" /></div>
      <div class="tt-fld"><label>Campus</label><select id="bCampus" class="tt-sel"></select></div>
      <div class="tt-fld"><label>Floors</label><input type="number" id="bFloors" class="tt-in" value="1" min="0" /></div>
    </div>
    <div class="tt-fld"><label>Notes</label><input type="text" id="bNotes" class="tt-in" /></div>
    <div class="tt-fld"><label><input type="checkbox" id="bActive" checked="checked" /> Active</label></div>
    <div id="bldgErr" style="display:none;color:#b42318;font-size:12px;"></div>
  </div>
  <div class="tt-md__f"><button type="button" class="tt-btn" onclick="TT.close('bldgOv')">Cancel</button><button type="button" class="tt-btn tt-btn--p" onclick="TT.bldgSave()">Save building</button></div>
</div></div>

<div class="tt-toast" id="ttToast"></div>

<script>
var TT = (function(){
  var LK = { campuses:[], buildings:[] };
  function qs(id){ return document.getElementById(id); }
  function esc(s){ s=(s==null?'':''+s); return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function toast(msg,err){ var t=qs('ttToast'); t.textContent=msg; t.className='tt-toast on'+(err?' tt-toast--err':''); setTimeout(function(){ t.className='tt-toast'; },2600); }
  function api(method, body){
    return fetch('RoomsBuildings.aspx/'+method,{method:'POST',headers:{'Content-Type':'application/json; charset=utf-8'},body:body?JSON.stringify(body):'{}'})
      .then(function(r){ return r.json(); }).then(function(j){ return j.d; })
      .catch(function(){ return { ok:false, message:'Network error' }; });
  }
  function campusOpts(sel, withAll){
    var h = withAll ? '' : '';
    for(var i=0;i<LK.campuses.length;i++){ var c=LK.campuses[i]; if(!withAll && c.id===0) continue; h+='<option value="'+c.id+'">'+esc(c.id===0?'Both / All campuses':c.name)+'</option>'; }
    sel.innerHTML=h;
  }
  function bldgOpts(sel){
    var h='<option value="0">&mdash; none &mdash;</option>';
    for(var i=0;i<LK.buildings.length;i++){ var b=LK.buildings[i]; h+='<option value="'+b.id+'">'+esc(b.name)+'</option>'; }
    sel.innerHTML=h;
  }

  function tab(btn,name){
    var t=document.querySelectorAll('.tt-tab'); for(var i=0;i<t.length;i++) t[i].classList.remove('on'); btn.classList.add('on');
    ['Rooms','Buildings','Free'].forEach(function(p){ qs('pane'+p).style.display='none'; });
    qs('pane'+name.charAt(0).toUpperCase()+name.slice(1)).style.display='';
    if(name==='rooms') loadRooms(); else if(name==='buildings') loadBuildings();
  }

  function loadLookups(cb){ api('GetLookups').then(function(d){ if(d&&d.ok){ LK.campuses=d.campuses||[]; LK.buildings=d.buildings||[]; } if(cb) cb(); }); }

  function loadRooms(){
    api('ListRooms').then(function(d){
      var b=qs('roomsBody');
      if(!d||!d.ok){ b.innerHTML='<tr><td colspan="7" class="tt-empty">Unable to load.</td></tr>'; return; }
      if(!d.rows.length){ b.innerHTML='<tr><td colspan="7" class="tt-empty">No rooms yet. Click <b>Add room</b>.</td></tr>'; return; }
      b.innerHTML=d.rows.map(function(r){
        return '<tr><td><b>'+esc(r.name)+'</b></td><td>'+r.capacity+'</td><td>'+(esc(r.buildingName)||'<span class="tt-muted">&mdash;</span>')+'</td><td>'+esc(r.campusName)+'</td><td>'+(esc(r.roomType)||'<span class="tt-muted">&mdash;</span>')+'</td>'
          +'<td><span class="tt-pill '+(r.active?'tt-pill--on':'tt-pill--off')+'">'+(r.active?'Active':'Inactive')+'</span></td>'
          +'<td style="text-align:right;white-space:nowrap;"><button type="button" class="tt-btn tt-btn--sm" onclick="TT.roomEdit('+r.id+')">Edit</button> <button type="button" class="tt-btn tt-btn--sm tt-btn--d" onclick="TT.roomDel('+r.id+',\''+esc(r.name).replace(/\'/g,"")+'\')">Delete</button></td></tr>';
      }).join('');
    });
  }
  var ROOMS=[];
  function roomEdit(id){
    campusOpts(qs('rCampus'), true); bldgOpts(qs('rBldg'));
    qs('roomErr').style.display='none';
    if(id>0){
      api('ListRooms').then(function(d){ var r=(d.rows||[]).filter(function(x){return x.id===id;})[0]; if(!r) return;
        qs('roomHead').textContent='Edit room'; qs('rId').value=id; qs('rName').value=r.name; qs('rCap').value=r.capacity;
        qs('rCampus').value=r.campusId; qs('rBldg').value=r.buildingId||0; qs('rType').value=r.roomType||''; qs('rActive').checked=!!r.active; qs('roomOv').classList.add('on');
      });
    } else { qs('roomHead').textContent='Add room'; qs('rId').value=0; qs('rName').value=''; qs('rCap').value=60; qs('rBldg').value=0; qs('rType').value=''; qs('rActive').checked=true; qs('roomOv').classList.add('on'); }
  }
  function roomSave(){
    var name=qs('rName').value.trim(); if(!name){ var e=qs('roomErr'); e.textContent='Room name is required.'; e.style.display='block'; return; }
    api('SaveRoom',{ id:parseInt(qs('rId').value,10)||0, name:name, capacity:parseInt(qs('rCap').value,10)||0, campusId:parseInt(qs('rCampus').value,10)||0, buildingId:parseInt(qs('rBldg').value,10)||0, roomType:qs('rType').value, active:qs('rActive').checked?1:0 })
      .then(function(d){ if(d&&d.ok){ toast('Room saved.'); close('roomOv'); loadRooms(); loadLookups(); } else { var e=qs('roomErr'); e.textContent=(d&&d.message)||'Save failed.'; e.style.display='block'; } });
  }
  function roomDel(id,name){ if(!confirm('Delete room "'+name+'"?')) return; api('DeleteRoom',{id:id}).then(function(d){ if(d&&d.ok){ toast('Room deleted.'); loadRooms(); } else toast((d&&d.message)||'Failed',true); }); }

  function loadBuildings(){
    api('ListBuildings').then(function(d){
      var b=qs('bldgsBody');
      if(!d||!d.ok){ b.innerHTML='<tr><td colspan="7" class="tt-empty">Unable to load.</td></tr>'; return; }
      if(!d.rows.length){ b.innerHTML='<tr><td colspan="7" class="tt-empty">No buildings yet. Click <b>Add building</b>.</td></tr>'; return; }
      b.innerHTML=d.rows.map(function(r){
        return '<tr><td><b>'+esc(r.name)+'</b></td><td>'+(esc(r.code)||'<span class="tt-muted">&mdash;</span>')+'</td><td>'+esc(r.campusName)+'</td><td>'+r.floors+'</td><td>'+r.rooms+'</td>'
          +'<td><span class="tt-pill '+(r.active?'tt-pill--on':'tt-pill--off')+'">'+(r.active?'Active':'Inactive')+'</span></td>'
          +'<td style="text-align:right;white-space:nowrap;"><button type="button" class="tt-btn tt-btn--sm" onclick="TT.bldgEdit('+r.id+')">Edit</button> <button type="button" class="tt-btn tt-btn--sm tt-btn--d" onclick="TT.bldgDel('+r.id+',\''+esc(r.name).replace(/\'/g,"")+'\')">Delete</button></td></tr>';
      }).join('');
    });
  }
  function bldgEdit(id){
    campusOpts(qs('bCampus'), true); qs('bldgErr').style.display='none';
    if(id>0){
      api('ListBuildings').then(function(d){ var r=(d.rows||[]).filter(function(x){return x.id===id;})[0]; if(!r) return;
        qs('bldgHead').textContent='Edit building'; qs('bId').value=id; qs('bName').value=r.name; qs('bCode').value=r.code; qs('bCampus').value=r.campusId; qs('bFloors').value=r.floors; qs('bNotes').value=r.notes; qs('bActive').checked=!!r.active; qs('bldgOv').classList.add('on');
      });
    } else { qs('bldgHead').textContent='Add building'; qs('bId').value=0; qs('bName').value=''; qs('bCode').value=''; qs('bFloors').value=1; qs('bNotes').value=''; qs('bActive').checked=true; qs('bldgOv').classList.add('on'); }
  }
  function bldgSave(){
    var name=qs('bName').value.trim(); if(!name){ var e=qs('bldgErr'); e.textContent='Building name is required.'; e.style.display='block'; return; }
    api('SaveBuilding',{ id:parseInt(qs('bId').value,10)||0, name:name, code:qs('bCode').value.trim(), campusId:parseInt(qs('bCampus').value,10)||0, floors:parseInt(qs('bFloors').value,10)||0, notes:qs('bNotes').value.trim(), active:qs('bActive').checked?1:0 })
      .then(function(d){ if(d&&d.ok){ toast('Building saved.'); close('bldgOv'); loadBuildings(); loadLookups(); } else { var e=qs('bldgErr'); e.textContent=(d&&d.message)||'Save failed.'; e.style.display='block'; } });
  }
  function bldgDel(id,name){ if(!confirm('Delete building "'+name+'"? Its rooms stay but lose the building link.')) return; api('DeleteBuilding',{id:id}).then(function(d){ if(d&&d.ok){ toast('Building deleted.'); loadBuildings(); loadLookups(); } else toast((d&&d.message)||'Failed',true); }); }

  function findFree(){
    var body={ acadYear:qs('fAy').value.trim(), dayNo:parseInt(qs('fDay').value,10), start:qs('fStart').value, durationMin:parseInt(qs('fDur').value,10)||60, campusId:parseInt(qs('fCampus').value,10)||0, minCapacity:parseInt(qs('fCap').value,10)||0 };
    qs('freeResult').innerHTML='<div class="tt-empty">Searching&hellip;</div>';
    api('FindFreeRooms',body).then(function(d){
      if(!d||!d.ok){ qs('freeResult').innerHTML='<div class="tt-empty">'+esc((d&&d.message)||'Search failed')+'</div>'; return; }
      if(!d.rooms.length){ qs('freeResult').innerHTML='<div class="tt-empty">No free rooms match that slot.</div>'; return; }
      qs('freeResult').innerHTML='<div class="tt-free">'+d.rooms.map(function(r){ return '<div class="tt-freecard"><b>'+esc(r.name)+'</b><span>Capacity '+r.capacity+(r.building?(' &middot; '+esc(r.building)):'')+(r.campus?(' &middot; '+esc(r.campus)):'')+'</span></div>'; }).join('')+'</div>';
    });
  }

  function close(id){ qs(id).classList.remove('on'); }

  // init
  loadLookups(function(){ campusOpts(qs('fCampus'), true); loadRooms(); });

  return { tab:tab, roomEdit:roomEdit, roomSave:roomSave, roomDel:roomDel, bldgEdit:bldgEdit, bldgSave:bldgSave, bldgDel:bldgDel, findFree:findFree, close:close };
})();
</script>
</asp:Content>
