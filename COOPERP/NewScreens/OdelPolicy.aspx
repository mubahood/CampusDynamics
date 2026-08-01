<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="OdelPolicy.aspx.cs" Inherits="COOPERP_NewScreens_OdelPolicy" Title="ODEL Policy Centre - Campus Dynamics" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style type="text/css">
    .op-wrap{padding:12px;color:#1a1a2e;max-width:820px;}
    .op-hd{background:#05275C;color:#fff;padding:12px 18px;} .op-hd__t{font-size:16px;font-weight:700;} .op-hd__s{font-size:11px;opacity:.8;}
    .op-tbl{width:100%;border-collapse:collapse;font-size:12px;background:#fff;margin-top:12px;}
    .op-tbl th{background:#05275C;color:#fff;padding:7px 10px;text-align:left;font-size:9px;text-transform:uppercase;}
    .op-tbl td{padding:7px 10px;border-bottom:1px solid #eef0f4;} .op-tbl input{padding:5px 7px;border:1px solid #cdd3de;width:110px;}
    .op-btn{font-size:11px;padding:5px 12px;border:0;background:#05275C;color:#fff;cursor:pointer;}
    .op-lbl{font-size:11px;} .op-def{font-size:9px;color:#999;}
    .op-msg{font-size:12px;padding:8px;margin:8px 0;display:none;} .op-msg.ok{display:block;background:#e6f4ea;color:#155724;} .op-msg.err{display:block;background:#fef5f5;color:#dc3545;}
    .op-note{font-size:10px;color:#888;margin-top:10px;}
</style>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="op-wrap">
    <div class="op-hd"><div class="op-hd__t">ODEL Policy Centre</div><div class="op-hd__s">Institution-wide rules governing online learning &amp; coursework</div></div>
    <div class="op-msg" id="opMsg"></div>
    <table class="op-tbl"><thead><tr><th>Policy</th><th>Value</th><th></th></tr></thead><tbody id="opTb"></tbody></table>
    <div class="op-note">Changes are versioned and audited. Per-course-term overrides can be added via the API; institution values apply everywhere unless overridden. Marks-affecting keys (coursework share, push mode) should be changed with care.</div>
</div>
<script type="text/javascript">
(function(){
'use strict';
function qs(id){return document.getElementById(id);}
function esc(s){return s==null?'':String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function ajax(m,p,cb){var x=new XMLHttpRequest();x.open('POST','OdelPolicy.aspx/'+m,true);x.setRequestHeader('Content-Type','application/json; charset=utf-8');x.onload=function(){try{var o=JSON.parse(x.responseText);cb(typeof o.d==='string'?JSON.parse(o.d):o.d);}catch(e){cb({success:false});}};x.onerror=function(){cb({success:false});};x.send(JSON.stringify(p||{}));}
function msg(t,ok){var e=qs('opMsg');e.textContent=t;e.className='op-msg '+(ok?'ok':'err');setTimeout(function(){e.className='op-msg';},4000);}
function load(){
    ajax('GetPolicies',{},function(d){
        if(!d||!d.success){ msg((d&&d.message)||'Unable to load.',false); return; }
        qs('opTb').innerHTML=d.policies.map(function(p){
            return '<tr><td><div class="op-lbl">'+esc(p.label)+'</div><div class="op-def">'+esc(p.key)+' · default '+esc(p['default'])+'</div></td>'+
            '<td><input type="text" id="v_'+esc(p.key)+'" value="'+esc(p.value)+'"></td>'+
            '<td><button class="op-btn" onclick="opSave(\''+esc(p.key)+'\')">Save</button></td></tr>';
        }).join('');
    });
}
window.opSave=function(key){
    var v=qs('v_'+key).value;
    ajax('SavePolicy',{key:key,value:v,scopeLevel:'INSTITUTION',scopeRef:''},function(d){ if(d&&d.success){ msg('Saved: '+key+' = '+v,true); } else msg((d&&d.message)||'Failed',false); });
};
document.addEventListener('DOMContentLoaded',load);
})();
</script>
</asp:Content>
