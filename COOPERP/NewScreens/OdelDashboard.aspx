<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="OdelDashboard.aspx.cs" Inherits="COOPERP_NewScreens_OdelDashboard" Title="ODEL Monitoring - Campus Dynamics" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
<style type="text/css">
    .od-wrap{padding:12px;color:#1a1a2e;}
    .od-hd{display:flex;justify-content:space-between;align-items:center;background:#05275C;color:#fff;padding:12px 18px;}
    .od-hd__t{font-size:16px;font-weight:700;} .od-hd__s{font-size:11px;opacity:.8;} .od-chip{font-size:10px;background:rgba(255,255,255,.15);padding:3px 9px;border-radius:10px;}
    .od-kpis{display:grid;grid-template-columns:repeat(5,1fr);gap:8px;margin-top:12px;}
    .od-kpi{background:#fff;border:1px solid #e0e5ed;border-left:3px solid #174DA4;padding:10px 12px;}
    .od-kpi b{display:block;font-size:19px;font-weight:700;color:#05275C;} .od-kpi span{font-size:9px;text-transform:uppercase;color:#888;}
    .od-grid{display:grid;grid-template-columns:1fr 2fr;gap:12px;margin-top:12px;}
    .od-card{background:#fff;border:1px solid #e0e5ed;} .od-card__h{padding:8px 12px;border-bottom:1px solid #e0e5ed;background:#f5f7fa;font-size:11px;font-weight:600;color:#05275C;}
    .od-card__b{padding:10px;} .od-chartbox{position:relative;height:220px;}
    .od-tbl{width:100%;border-collapse:collapse;font-size:10px;} .od-tbl th{background:#05275C;color:#fff;padding:6px 8px;text-align:left;font-size:9px;text-transform:uppercase;position:sticky;top:0;}
    .od-tbl td{padding:5px 8px;border-bottom:1px solid #eef0f4;} .od-tblwrap{max-height:420px;overflow:auto;}
    .od-badge{font-size:9px;padding:1px 6px;border-radius:8px;} .b-ok{background:#e6f4ea;color:#155724;} .b-warn{background:#fff8e1;color:#b45309;}
    .od-msg{font-size:12px;color:#888;padding:20px;text-align:center;}
    @media(max-width:1000px){.od-kpis{grid-template-columns:repeat(2,1fr);}.od-grid{grid-template-columns:1fr;}}
</style>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="od-wrap">
    <div class="od-hd"><div><div class="od-hd__t">ODEL Monitoring</div><div class="od-hd__s">Online learning activity, compliance and coursework flow</div></div><div class="od-chip" id="odScope">&nbsp;</div></div>
    <div id="odBody"><div class="od-msg">Loading&hellip;</div></div>
</div>
<script type="text/javascript">
(function(){
'use strict';
var chart=null;
function qs(id){return document.getElementById(id);}
function esc(s){return s==null?'':String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function n(v){return (Number(v)||0).toLocaleString('en-US');}
function ajax(m,p,cb){var x=new XMLHttpRequest();x.open('POST','OdelDashboard.aspx/'+m,true);x.setRequestHeader('Content-Type','application/json; charset=utf-8');x.onload=function(){try{var o=JSON.parse(x.responseText);cb(typeof o.d==='string'?JSON.parse(o.d):o.d);}catch(e){cb({success:false});}};x.onerror=function(){cb({success:false});};x.send(JSON.stringify(p||{}));}
function load(){
    ajax('GetDashboard',{},function(d){
        var b=qs('odBody');
        if(!d||!d.success){ b.innerHTML='<div class="od-msg">'+esc((d&&d.message)||'Unable to load.')+'</div>'; return; }
        qs('odScope').textContent=(d.roleNote||'')+(d.scopeLabel?(' · '+d.scopeLabel):'');
        var k=d.kpi;
        b.innerHTML='<div class="od-kpis">'+
            kpi(k.spaces,'Active spaces')+kpi(k.assignments,'Assignments')+kpi(k.subsWeek,'Submissions (7d)')+kpi(k.ungraded,'Awaiting grading')+kpi(k.cwViaOdel,'CW via ODEL')+
            '</div>'+
            '<div class="od-kpis" style="margin-top:8px;">'+
            kpi(k.materials,'Materials')+kpi(k.subsTotal,'Total submissions')+kpi(k.students,'Students active')+kpi(k.pushes,'Coursework pushes')+kpi(0,'')+
            '</div>'+
            '<div class="od-grid"><div class="od-card"><div class="od-card__h">Submissions (last 8 weeks)</div><div class="od-card__b"><div class="od-chartbox"><canvas id="odChart"></canvas></div></div></div>'+
            '<div class="od-card"><div class="od-card__h">Course compliance — assignments conducted</div><div class="od-card__b" style="padding:0;"><div class="od-tblwrap"><table class="od-tbl"><thead><tr><th>Course</th><th>Term</th><th>Assign.</th><th>Roster</th><th>To grade</th><th>Push</th><th></th></tr></thead><tbody id="odTb"></tbody></table></div></div></div></div>';
        qs('odTb').innerHTML=d.compliance.map(function(c){
            var ok=c.assignments>=2;
            return '<tr><td>'+esc(c.courseID)+'</td><td>'+esc(c.term)+'</td><td>'+c.assignments+'</td><td>'+c.roster+'</td><td>'+c.ungraded+'</td><td>'+(c.pushed>0?('v'+c.pushed):'–')+'</td>'+
            '<td>'+(ok?'<span class="od-badge b-ok">on track</span>':'<span class="od-badge b-warn">below min</span>')+'</td></tr>';
        }).join('') || '<tr><td colspan="7" style="color:#888;padding:14px;">No active spaces.</td></tr>';
        if(chart)chart.destroy();
        chart=new Chart(qs('odChart').getContext('2d'),{type:'bar',data:{labels:d.trend.map(function(t){return t.label;}),datasets:[{data:d.trend.map(function(t){return t.count;}),backgroundColor:'#174DA4'}]},options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{font:{size:9}}},x:{ticks:{font:{size:8}},grid:{display:false}}}}});
    });
}
function kpi(v,l){ return l===''?'<div></div>':'<div class="od-kpi"><b>'+n(v)+'</b><span>'+esc(l)+'</span></div>'; }
document.addEventListener('DOMContentLoaded',load);
})();
</script>
</asp:Content>
