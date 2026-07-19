<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="TimetableCalendar.aspx.cs" Inherits="COOPERP_NewScreens_TimetableCalendar" Title="Timetable Calendar - Campus Dynamics" %>
<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.tt-wrap{padding:4px 2px;}
.tt-h__t{font-size:18px;font-weight:800;color:#05275C;}
.tt-h__s{font-size:11.5px;color:#6b7280;margin:2px 0 10px;}
.tt-card{background:#fff;border:1px solid #e0e5ed;margin-bottom:12px;}
.tt-filters{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:10px 12px;border-bottom:1px solid #eef1f5;}
.tt-sel,.tt-in{border:1px solid #cfd8e3;background:#fff;padding:7px 9px;font-size:12px;color:#1f2937;border-radius:0;font-family:inherit;}
.tt-sel:focus,.tt-in:focus{outline:none;border-color:#174DA4;}
.tt-btn{display:inline-flex;align-items:center;gap:6px;padding:7px 12px;border:1px solid #d2dae6;background:#fff;color:#05275C;text-decoration:none;font-size:12px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;}
.tt-btn:hover{border-color:#174DA4;color:#174DA4;}
.tt-legend{display:flex;gap:12px;flex-wrap:wrap;padding:8px 12px;font-size:10.5px;color:#6b7280;border-bottom:1px solid #eef1f5;}
.tt-legend i{display:inline-block;width:11px;height:11px;margin-right:4px;vertical-align:middle;}
/* calendar grid */
.cal-scroll{overflow:auto;max-height:74vh;}
.cal{display:grid;grid-template-columns:52px repeat(7,minmax(120px,1fr));min-width:900px;}
.cal__corner{position:sticky;top:0;left:0;z-index:5;background:#f8fafc;border-bottom:2px solid #e0e5ed;border-right:1px solid #eef2f6;}
.cal__dh{position:sticky;top:0;z-index:4;background:#05275C;color:#fff;font-size:11px;font-weight:800;text-align:center;padding:8px 4px;text-transform:uppercase;letter-spacing:.3px;border-right:1px solid #0a3a7a;}
.cal__gutter{border-right:1px solid #eef2f6;position:relative;background:#fafbfc;}
.cal__hr{position:absolute;left:0;right:0;font-size:9px;color:#9ca3af;text-align:right;padding-right:5px;transform:translateY(-6px);}
.cal__day{position:relative;border-right:1px solid #eef2f6;border-bottom:1px solid #eef2f6;background:linear-gradient(#f4f7fb 1px,transparent 1px);background-size:100% 60px;}
.cal__ev{position:absolute;left:2px;right:2px;border-left:3px solid #05275C;background:#eef2fb;color:#1f2937;padding:3px 5px;overflow:hidden;font-size:10px;box-shadow:0 1px 3px rgba(0,0,0,.08);cursor:default;}
.cal__ev b{display:block;font-size:10.5px;color:#05275C;line-height:1.15;}
.cal__ev span{display:block;color:#6b7280;font-size:9px;line-height:1.2;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.cal__ev--LECTURE{border-left-color:#05275C;background:#eef2fb;}
.cal__ev--TUTORIAL{border-left-color:#174DA4;background:#e9f0fc;}
.cal__ev--PRACTICAL{border-left-color:#16a34a;background:#e9f6ee;}
.cal__ev--SEMINAR{border-left-color:#b45309;background:#fdf3e5;}
.cal__ev--CAT{border-left-color:#7c3aed;background:#f1ebfd;}
.cal__ev--clash{outline:2px solid #dc2626;outline-offset:-2px;}
.cal__ev--clash b:after{content:" \26A0";color:#dc2626;}
.tt-empty{text-align:center;color:#94a3b8;padding:30px;font-size:13px;}
</style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="tt-wrap">
  <div class="tt-h__t">Timetable Calendar</div>
  <div class="tt-h__s">Weekly view of scheduled sessions &mdash; filter by campus, programme, room or lecturer. Overlapping clashes are outlined red.</div>
  <div class="tt-card">
    <div class="tt-filters">
      <select id="fCampus" class="tt-sel" onchange="CAL.load()"><option value="0">All campuses</option></select>
      <select id="fProg" class="tt-sel" onchange="CAL.load()"><option value="">All programmes</option></select>
      <select id="fSy" class="tt-sel" onchange="CAL.load()"><option value="0">Any year</option><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select>
      <select id="fSem" class="tt-sel" onchange="CAL.load()"><option value="0">Any sem</option><option value="1">Sem 1</option><option value="2">Sem 2</option><option value="3">Sem 3</option></select>
      <select id="fRoom" class="tt-sel" onchange="CAL.load()"><option value="0">Any room</option></select>
      <select id="fTeacher" class="tt-sel" onchange="CAL.load()"><option value="0">Any lecturer</option></select>
      <a class="tt-btn" href="TimetableManager.aspx">Manage</a>
      <a class="tt-btn" href="TimetableExport.aspx">Export</a>
    </div>
    <div class="tt-legend">
      <span><i style="background:#05275C"></i>Lecture</span><span><i style="background:#174DA4"></i>Tutorial</span>
      <span><i style="background:#16a34a"></i>Practical</span><span><i style="background:#b45309"></i>Seminar</span>
      <span><i style="background:#7c3aed"></i>CAT</span><span><i style="outline:2px solid #dc2626;background:#fff"></i>Clash</span>
    </div>
    <div id="calHost"><div class="tt-empty">Loading&hellip;</div></div>
  </div>
</div>

<script>
var CAL = (function(){
  var LK={}, DAY_START=7*60, DAY_END=21*60, SCALE=0.85; // px per minute
  function qs(id){return document.getElementById(id);}
  function esc(s){s=(s==null?'':''+s);return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
  function api(m,b){return fetch('TimetableCalendar.aspx/'+m,{method:'POST',headers:{'Content-Type':'application/json; charset=utf-8'},body:b?JSON.stringify(b):'{}'}).then(function(r){return r.json();}).then(function(j){return j.d;}).catch(function(){return{ok:false};});}
  var DAYS=['','Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  function init(){
    api('Lookups').then(function(d){
      LK=d||{};
      var ch='<option value="0">All campuses</option>'; (LK.campuses||[]).forEach(function(c){ if(c.id!==0) ch+='<option value="'+c.id+'">'+esc(c.name)+'</option>'; }); qs('fCampus').innerHTML=ch;
      var ph='<option value="">All programmes</option>'; (LK.programmes||[]).forEach(function(p){ ph+='<option value="'+esc(p.code)+'">'+esc(p.name||p.code)+'</option>'; }); qs('fProg').innerHTML=ph;
      var rh='<option value="0">Any room</option>'; (LK.rooms||[]).forEach(function(r){ rh+='<option value="'+r.id+'">'+esc(r.name)+'</option>'; }); qs('fRoom').innerHTML=rh;
      var th='<option value="0">Any lecturer</option>'; (LK.teachers||[]).forEach(function(t){ th+='<option value="'+t.id+'">'+esc(t.name)+'</option>'; }); qs('fTeacher').innerHTML=th;
      load();
    });
  }

  function load(){
    api('CalendarData',{campusId:parseInt(qs('fCampus').value,10)||0,progcode:qs('fProg').value,studyYear:parseInt(qs('fSy').value,10)||0,semester:parseInt(qs('fSem').value,10)||0,roomId:parseInt(qs('fRoom').value,10)||0,teacherId:parseInt(qs('fTeacher').value,10)||0})
    .then(function(d){ render((d&&d.sessions)||[]); });
  }

  function markClashes(list){
    for(var i=0;i<list.length;i++) list[i].clash=false;
    for(var i=0;i<list.length;i++) for(var j=i+1;j<list.length;j++){
      var a=list[i],b=list[j];
      if(a.dayNo!==b.dayNo) continue;
      if(!(a.sm<b.em && b.sm<a.em)) continue; // no time overlap
      var sameRoom=a.roomId>0&&a.roomId===b.roomId;
      var sameTeach=a.teacherId>0&&a.teacherId===b.teacherId;
      var sameCohort=a.progcode&&a.progcode===b.progcode&&a.studyYear===b.studyYear&&a.semester===b.semester;
      if(sameRoom||sameTeach||sameCohort){ a.clash=true; b.clash=true; }
    }
  }

  function render(list){
    if(!list.length){ qs('calHost').innerHTML='<div class="tt-empty">No sessions match these filters.</div>'; return; }
    markClashes(list);
    // clamp window to data
    var minS=DAY_START,maxE=DAY_END;
    list.forEach(function(s){ if(s.sm<minS) minS=Math.max(0,s.sm-30); if(s.em>maxE) maxE=Math.min(1439,s.em+30); });
    var winStart=Math.min(DAY_START,minS), winEnd=Math.max(DAY_END,maxE);
    var colH=(winEnd-winStart)*SCALE;

    // per-day lane packing
    var byDay={}; for(var d=1;d<=7;d++) byDay[d]=[];
    list.forEach(function(s){ byDay[s.dayNo].push(s); });
    var laneCount={};
    for(var d=1;d<=7;d++){
      var arr=byDay[d].sort(function(a,b){return a.sm-b.sm;});
      var lanes=[];
      arr.forEach(function(s){ var placed=false; for(var i=0;i<lanes.length;i++){ if(lanes[i]<=s.sm){ s.lane=i; lanes[i]=s.em; placed=true; break; } } if(!placed){ s.lane=lanes.length; lanes.push(s.em); } });
      laneCount[d]=Math.max(1,lanes.length);
    }

    // build grid
    var h='<div class="cal-scroll"><div class="cal">';
    h+='<div class="cal__corner"></div>';
    for(var d=1;d<=7;d++) h+='<div class="cal__dh">'+DAYS[d]+'</div>';
    // gutter
    h+='<div class="cal__gutter" style="height:'+colH+'px;">';
    for(var m=Math.ceil(winStart/60)*60;m<=winEnd;m+=60){ var top=(m-winStart)*SCALE; h+='<div class="cal__hr" style="top:'+top+'px;">'+String(Math.floor(m/60)).replace(/^(\d)$/,'0$1')+':00</div>'; }
    h+='</div>';
    // day columns
    for(var d=1;d<=7;d++){
      h+='<div class="cal__day" style="height:'+colH+'px;">';
      var lc=laneCount[d];
      byDay[d].forEach(function(s){
        var top=(s.sm-winStart)*SCALE, ht=Math.max(16,(s.em-s.sm)*SCALE-2);
        var w=100/lc, left=s.lane*w;
        var loc=s.room?esc(s.room):(s.roomLabel?esc(s.roomLabel):'');
        var tip=esc(s.code)+' '+esc(s.course)+' | '+esc(s.start)+'-'+esc(s.end)+' | '+loc+(s.teacher?(' | '+esc(s.teacher)):'')+(s.campus?(' | '+esc(s.campus)):'');
        h+='<div class="cal__ev cal__ev--'+esc(s.sessionType)+(s.clash?' cal__ev--clash':'')+'" title="'+tip+'" style="top:'+top+'px;height:'+ht+'px;left:calc('+left+'% + 2px);width:calc('+w+'% - 4px);">'
          +'<b>'+esc(s.code)+'</b><span>'+esc(s.start)+' '+loc+'</span>'+(ht>34&&s.teacher?('<span>'+esc(s.teacher)+'</span>'):'')+'</div>';
      });
      h+='</div>';
    }
    h+='</div></div>';
    qs('calHost').innerHTML=h;
  }

  init();
  return { load:load };
})();
</script>
</asp:Content>
