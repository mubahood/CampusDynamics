<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="TimetableExport.aspx.cs" Inherits="COOPERP_NewScreens_TimetableExport" Title="Timetable Export - Campus Dynamics" %>
<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.tt-wrap{padding:4px 2px;}
.tt-h__t{font-size:18px;font-weight:800;color:#05275C;}
.tt-h__s{font-size:11.5px;color:#6b7280;margin:2px 0 10px;}
.tt-card{background:#fff;border:1px solid #e0e5ed;margin-bottom:12px;}
.tt-filters{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:12px;}
.tt-sel{border:1px solid #cfd8e3;background:#fff;padding:7px 9px;font-size:12px;color:#1f2937;border-radius:0;font-family:inherit;}
.tt-btn{display:inline-flex;align-items:center;gap:6px;padding:8px 14px;border:1px solid #d2dae6;background:#fff;color:#05275C;text-decoration:none;font-size:12px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;}
.tt-btn:hover{border-color:#174DA4;color:#174DA4;}
.tt-btn--p{background:#05275C;border-color:#05275C;color:#fff;}.tt-btn--p:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.rep{padding:0;}
.rep__head{text-align:center;padding:14px 10px 8px;}
.rep__head h2{margin:0;font-size:16px;color:#05275C;}
.rep__head p{margin:3px 0 0;font-size:11px;color:#6b7280;}
.rep__day{font-size:12px;font-weight:800;color:#05275C;text-transform:uppercase;letter-spacing:.4px;padding:9px 12px;background:#f0f4fa;border-top:1px solid #e0e5ed;}
.rep__tbl{width:100%;border-collapse:collapse;}
.rep__tbl th{font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#6b7280;text-align:left;padding:7px 10px;border-bottom:1px solid #e0e5ed;background:#fafbfc;}
.rep__tbl td{font-size:11.5px;color:#1f2937;padding:7px 10px;border-bottom:1px solid #eef2f6;}
.tt-empty{text-align:center;color:#94a3b8;padding:26px;font-size:13px;}
@media print{
  .no-print{display:none !important;}
  .cd-sidebar,.sidebar,.topbar,nav,header,footer{display:none !important;}
  .tt-card{border:none;margin:0;}
  body{background:#fff;}
}
</style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="tt-wrap">
  <div class="no-print">
    <div class="tt-h__t">Timetable Export</div>
    <div class="tt-h__s">Filter and generate a printable timetable, or download it as CSV.</div>
    <div class="tt-card">
      <div class="tt-filters">
        <select id="fCampus" class="tt-sel"><option value="0">All campuses</option></select>
        <select id="fProg" class="tt-sel"><option value="">All programmes</option></select>
        <select id="fSy" class="tt-sel"><option value="0">Any year</option><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select>
        <select id="fSem" class="tt-sel"><option value="0">Any sem</option><option value="1">Sem 1</option><option value="2">Sem 2</option><option value="3">Sem 3</option></select>
        <select id="fRoom" class="tt-sel"><option value="0">Any room</option></select>
        <select id="fTeacher" class="tt-sel"><option value="0">Any lecturer</option></select>
        <select id="fDay" class="tt-sel"><option value="0">All days</option><option value="1">Monday</option><option value="2">Tuesday</option><option value="3">Wednesday</option><option value="4">Thursday</option><option value="5">Friday</option><option value="6">Saturday</option><option value="7">Sunday</option></select>
        <button type="button" class="tt-btn tt-btn--p" onclick="EX.gen()">Generate</button>
        <button type="button" class="tt-btn" onclick="window.print()">Print / PDF</button>
        <button type="button" class="tt-btn" onclick="EX.csv()">Download CSV</button>
      </div>
    </div>
  </div>
  <div class="tt-card"><div id="repHost" class="rep"><div class="tt-empty">Set filters and click <b>Generate</b>.</div></div></div>
</div>

<script>
var EX = (function(){
  var LK={}, ROWS=[];
  function qs(id){return document.getElementById(id);}
  function esc(s){s=(s==null?'':''+s);return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
  function api(m,b){return fetch('TimetableExport.aspx/'+m,{method:'POST',headers:{'Content-Type':'application/json; charset=utf-8'},body:b?JSON.stringify(b):'{}'}).then(function(r){return r.json();}).then(function(j){return j.d;}).catch(function(){return{ok:false};});}
  var DAYS=['','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY'];

  function init(){
    api('Lookups').then(function(d){
      LK=d||{};
      var ch='<option value="0">All campuses</option>'; (LK.campuses||[]).forEach(function(c){ if(c.id!==0) ch+='<option value="'+c.id+'">'+esc(c.name)+'</option>'; }); qs('fCampus').innerHTML=ch;
      var ph='<option value="">All programmes</option>'; (LK.programmes||[]).forEach(function(p){ ph+='<option value="'+esc(p.code)+'">'+esc(p.name||p.code)+'</option>'; }); qs('fProg').innerHTML=ph;
      var rh='<option value="0">Any room</option>'; (LK.rooms||[]).forEach(function(r){ rh+='<option value="'+r.id+'">'+esc(r.name)+'</option>'; }); qs('fRoom').innerHTML=rh;
      var th='<option value="0">Any lecturer</option>'; (LK.teachers||[]).forEach(function(t){ th+='<option value="'+t.id+'">'+esc(t.name)+'</option>'; }); qs('fTeacher').innerHTML=th;
    });
  }

  function filters(){ return {campusId:parseInt(qs('fCampus').value,10)||0,progcode:qs('fProg').value,studyYear:parseInt(qs('fSy').value,10)||0,semester:parseInt(qs('fSem').value,10)||0,roomId:parseInt(qs('fRoom').value,10)||0,teacherId:parseInt(qs('fTeacher').value,10)||0,dayNo:parseInt(qs('fDay').value,10)||0}; }

  function gen(){
    qs('repHost').innerHTML='<div class="tt-empty">Generating&hellip;</div>';
    api('ExportData',filters()).then(function(d){
      ROWS=(d&&d.rows)||[];
      if(!ROWS.length){ qs('repHost').innerHTML='<div class="tt-empty">No sessions match these filters.</div>'; return; }
      var f=filters();
      var sub=[]; var pn=qs('fProg').selectedOptions[0]; if(pn&&f.progcode) sub.push(pn.text);
      var cn=qs('fCampus').selectedOptions[0]; if(cn&&f.campusId) sub.push(cn.text);
      if(f.studyYear) sub.push('Year '+f.studyYear); if(f.semester) sub.push('Semester '+f.semester);
      var tn=qs('fTeacher').selectedOptions[0]; if(tn&&f.teacherId) sub.push(tn.text);
      var rn=qs('fRoom').selectedOptions[0]; if(rn&&f.roomId) sub.push(rn.text);
      var h='<div class="rep__head"><h2>Muteesa I Royal University &mdash; Timetable</h2><p>'+(sub.length?(esc(sub.join(' &middot; '))+' &middot; '):'')+ROWS.length+' session'+(ROWS.length==1?'':'s')+'</p></div>';
      var curDay=-1;
      for(var i=0;i<ROWS.length;i++){ var r=ROWS[i];
        if(r.dayNo!==curDay){ if(curDay!==-1) h+='</tbody></table>'; curDay=r.dayNo;
          h+='<div class="rep__day">'+esc(DAYS[r.dayNo]||r.dayName)+'</div><table class="rep__tbl"><thead><tr><th>Time</th><th>Course</th><th>Programme</th><th>Yr/Sem</th><th>Lecturer</th><th>Room</th><th>Campus</th><th>Type</th></tr></thead><tbody>';
        }
        h+='<tr><td>'+esc(r.start)+'&ndash;'+esc(r.end)+'</td><td><b>'+esc(r.code)+'</b> '+esc(r.course)+'</td><td>'+esc(r.progname||r.progcode)+'</td><td>Y'+r.studyYear+'/S'+r.semester+'</td><td>'+esc(r.teacher)+'</td><td>'+esc(r.room)+(r.building?(' ('+esc(r.building)+')'):'')+'</td><td>'+esc(r.campus)+'</td><td>'+esc(r.sessionType)+(r.deliveryMode!=='PHYSICAL'?('/'+esc(r.deliveryMode)):'')+'</td></tr>';
      }
      h+='</tbody></table>';
      qs('repHost').innerHTML=h;
    });
  }

  function csv(){
    if(!ROWS.length){ alert('Generate a timetable first.'); return; }
    var head=['Day','Start','End','CourseCode','Course','ProgrammeCode','Programme','Year','Semester','Lecturer','Room','Building','Campus','Type','Delivery'];
    var lines=[head.join(',')];
    ROWS.forEach(function(r){ lines.push([DAYS[r.dayNo]||r.dayName,r.start,r.end,r.code,r.course,r.progcode,r.progname,r.studyYear,r.semester,r.teacher,r.room,r.building,r.campus,r.sessionType,r.deliveryMode].map(cell).join(',')); });
    var blob=new Blob([lines.join('\r\n')],{type:'text/csv;charset=utf-8;'});
    var a=document.createElement('a'); a.href=URL.createObjectURL(blob); a.download='timetable.csv'; document.body.appendChild(a); a.click(); document.body.removeChild(a);
  }
  function cell(v){ v=(v==null?'':''+v); if(/[",\n]/.test(v)) v='"'+v.replace(/"/g,'""')+'"'; return v; }

  init();
  return { gen:gen, csv:csv };
})();
</script>
</asp:Content>
