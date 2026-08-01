<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewFaculties.aspx.cs" Inherits="COOPERP_NewScreens_NewFaculties" Title="Faculties - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--brand:#174DA4;--brand-dk:#05275C;--danger:#dc2626;--success:#16a34a;--surf:#f5f7fa;--bdr:#e0e5ed;--txt:#1a1a2e;--muted:#64748b;}
.cd-header{background:#fff;border-bottom:1px solid var(--bdr);padding:20px 28px;display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;}
.cd-header__title{font-size:18px;font-weight:700;color:var(--txt);margin:0;}
.cd-header__sub{font-size:12px;color:var(--muted);margin:2px 0 0;}
.cd-card{background:#fff;border:1px solid var(--bdr);border-radius:4px;margin:20px 28px;}
.cd-toolbar{display:flex;gap:10px;align-items:center;padding:12px 16px;border-bottom:1px solid var(--bdr);flex-wrap:wrap;}
.cd-search{position:relative;flex:1;min-width:200px;max-width:360px;}
.cd-search input{width:100%;height:34px;border:1px solid var(--bdr);background:#fff;font-size:12px;padding:0 10px 0 32px;outline:none;box-sizing:border-box;}
.cd-search input:focus{border-color:var(--brand);}
.cd-search__ico{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:#94a3b8;pointer-events:none;}
.cd-count{font-size:11px;color:var(--muted);}
/* table */
.cd-table-wrap{overflow-x:auto;}
table.cd-table{width:100%;border-collapse:collapse;font-size:12px;}
.cd-table th{background:var(--surf);color:#374151;font-weight:600;font-size:11px;text-align:left;padding:10px 14px;border-bottom:2px solid var(--bdr);white-space:nowrap;}
.cd-table td{padding:10px 14px;border-bottom:1px solid #f1f5f9;color:#374151;vertical-align:middle;}
.cd-table tr:hover td{background:#f8fafc;}
.cd-code{font-family:monospace;font-size:11px;color:var(--brand);background:var(--surf);border:1px solid var(--bdr);padding:2px 8px;}
.cd-abbr{display:inline-block;font-size:10px;font-weight:700;color:#fff;background:var(--brand);border-radius:3px;padding:2px 7px;}
.cd-muted{color:#94a3b8;}
.cd-empty{text-align:center;padding:44px;color:#94a3b8;font-size:13px;}
/* buttons */
.cd-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 14px;font-size:12px;font-weight:600;border:none;cursor:pointer;border-radius:0;white-space:nowrap;text-decoration:none;}
.cd-btn--primary{background:var(--brand-dk);color:#fff;}
.cd-btn--primary:hover{background:var(--brand);}
.cd-btn--sm{padding:4px 10px;font-size:11px;}
.cd-btn--ghost{background:transparent;color:var(--brand);border:1px solid var(--bdr);}
.cd-btn--ghost:hover{background:#eff6ff;border-color:#bfdbfe;}
.cd-btn--danger{background:#fef2f2;color:var(--danger);border:1px solid #fca5a5;}
.cd-btn--danger:hover{background:var(--danger);color:#fff;}
.cd-btn:disabled{opacity:.5;cursor:not-allowed;}
.cd-rowact{display:flex;gap:6px;}
/* modal */
.cd-overlay{display:none;position:fixed;inset:0;background:rgba(8,15,30,.5);z-index:1000;align-items:center;justify-content:center;padding:16px;}
.cd-overlay.open{display:flex;}
.cd-modal{background:#fff;border-radius:4px;width:480px;max-width:100%;box-shadow:0 20px 60px rgba(0,0,0,.25);overflow:hidden;animation:cdpop .14s ease;}
@keyframes cdpop{from{transform:translateY(8px);opacity:.6}to{transform:none;opacity:1}}
.cd-modal__head{background:var(--brand-dk);color:#fff;padding:14px 18px;display:flex;align-items:center;justify-content:space-between;}
.cd-modal__head--danger{background:var(--danger);}
.cd-modal__title{font-size:14px;font-weight:700;}
.cd-modal__x{background:none;border:none;color:rgba(255,255,255,.8);font-size:20px;line-height:1;cursor:pointer;}
.cd-modal__x:hover{color:#fff;}
.cd-modal__body{padding:18px;}
.cd-modal__foot{padding:12px 18px;border-top:1px solid var(--bdr);display:flex;justify-content:flex-end;gap:8px;}
/* searchable dropdown */
.ss{position:relative;}
.ss__input{width:100%;height:36px;border:1px solid var(--bdr);font-size:13px;padding:0 11px;outline:none;box-sizing:border-box;background:#fff;}
.ss__input:focus{border-color:var(--brand);}
.ss__menu{display:none;position:absolute;top:100%;left:0;right:0;background:#fff;border:1px solid var(--bdr);border-top:none;max-height:230px;overflow-y:auto;z-index:20;box-shadow:0 10px 24px rgba(0,0,0,.14);}
.ss__menu.open{display:block;}
.ss__opt{padding:8px 11px;font-size:13px;cursor:pointer;color:var(--txt);border-bottom:1px solid #f1f5f9;}
.ss__opt:last-child{border-bottom:none;}
.ss__opt:hover{background:#eff6ff;}
.ss__opt--none{color:var(--muted);font-style:italic;}
.ss__empty{color:var(--muted);font-style:italic;cursor:default;}
.ss__empty:hover{background:#fff;}
.cd-field{margin-bottom:14px;}
.cd-field label{display:block;font-size:11px;font-weight:600;color:#374151;margin-bottom:5px;}
.cd-field input,.cd-field textarea{width:100%;height:36px;border:1px solid var(--bdr);font-size:13px;padding:0 11px;outline:none;box-sizing:border-box;}
.cd-field input:focus,.cd-field textarea:focus{border-color:var(--brand);}
.cd-field input:read-only{background:var(--surf);color:var(--muted);}
.cd-field__hint{font-size:10px;color:var(--muted);margin-top:4px;}
.cd-req{color:var(--danger);}
.cd-del-box{background:#fef2f2;border:1px solid #fecaca;border-radius:4px;padding:12px 14px;font-size:13px;color:#991b1b;margin-bottom:10px;}
.cd-del-note{font-size:12px;color:var(--muted);line-height:1.5;margin:0;}
/* toast */
.cd-toast{display:none;position:fixed;bottom:24px;right:24px;z-index:3000;background:#fff;border:1px solid var(--bdr);border-left:4px solid var(--success);padding:12px 18px;font-size:12px;box-shadow:0 4px 18px rgba(0,0,0,.14);max-width:340px;border-radius:2px;}
.cd-toast.show{display:block;}
.cd-toast--err{border-left-color:var(--danger);}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="cd-header">
    <div>
        <h1 class="cd-header__title">Faculties</h1>
        <p class="cd-header__sub">Create and manage the university's faculties</p>
    </div>
    <button type="button" class="cd-btn cd-btn--primary" onclick="openCreate()">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        New Faculty
    </button>
</div>

<div class="cd-card">
    <div class="cd-toolbar">
        <div class="cd-search">
            <svg class="cd-search__ico" xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" id="txtSearch" placeholder="Search faculties…" oninput="filterRows()" autocomplete="off" />
        </div>
        <span class="cd-count" id="lblCount"></span>
    </div>
    <div class="cd-table-wrap">
        <table class="cd-table">
            <thead>
                <tr>
                    <th style="width:80px;">Code</th>
                    <th>Faculty Name</th>
                    <th style="width:90px;">Abbrev</th>
                    <th style="min-width:160px;">Dean</th>
                    <th style="width:120px;">Contacts</th>
                    <th style="width:130px;">Actions</th>
                </tr>
            </thead>
            <tbody id="tblBody">
                <asp:Literal ID="litRows" runat="server" />
            </tbody>
        </table>
    </div>
</div>

<!-- ADD / EDIT MODAL -->
<div class="cd-overlay" id="modalEdit">
    <div class="cd-modal">
        <div class="cd-modal__head">
            <span class="cd-modal__title" id="modalTitle">New Faculty</span>
            <button type="button" class="cd-modal__x" onclick="closeModal('modalEdit')">&times;</button>
        </div>
        <div class="cd-modal__body">
            <input type="hidden" id="fOriginalCode" />
            <div class="cd-field">
                <label>Faculty Code <span class="cd-req">*</span></label>
                <input type="text" id="fCode" maxlength="10" placeholder="e.g. 06" />
                <div class="cd-field__hint" id="fCodeHint">Unique short code. Cannot be changed after creation.</div>
            </div>
            <div class="cd-field">
                <label>Faculty Name <span class="cd-req">*</span></label>
                <input type="text" id="fName" maxlength="150" placeholder="e.g. Faculty of Law" />
            </div>
            <div class="cd-field">
                <label>Abbreviation</label>
                <input type="text" id="fAbbrev" maxlength="15" placeholder="e.g. FOL" />
            </div>
            <div class="cd-field">
                <label>Dean</label>
                <div class="ss" id="ssDeanRoot">
                    <input type="text" class="ss__input" id="ssDeanInput" maxlength="150" placeholder="Search staff or type a name…" autocomplete="off" />
                    <div class="ss__menu" id="ssDeanMenu"></div>
                </div>
                <input type="hidden" id="fDean" />
            </div>
            <div class="cd-field">
                <label>Contacts</label>
                <input type="text" id="fContacts" maxlength="45" placeholder="Phone / email" />
            </div>
        </div>
        <div class="cd-modal__foot">
            <button type="button" class="cd-btn cd-btn--ghost" onclick="closeModal('modalEdit')">Cancel</button>
            <button type="button" class="cd-btn cd-btn--primary" id="btnSave" onclick="saveFaculty()">Save Faculty</button>
        </div>
    </div>
</div>

<!-- DELETE MODAL -->
<div class="cd-overlay" id="modalDelete">
    <div class="cd-modal" style="width:420px;">
        <div class="cd-modal__head cd-modal__head--danger">
            <span class="cd-modal__title">Delete Faculty</span>
            <button type="button" class="cd-modal__x" onclick="closeModal('modalDelete')">&times;</button>
        </div>
        <div class="cd-modal__body">
            <div class="cd-del-box" id="delName"></div>
            <p class="cd-del-note">This permanently removes the faculty. It will be blocked if any programmes still belong to it.</p>
            <input type="hidden" id="delCode" />
        </div>
        <div class="cd-modal__foot">
            <button type="button" class="cd-btn cd-btn--ghost" onclick="closeModal('modalDelete')">Cancel</button>
            <button type="button" class="cd-btn cd-btn--danger" id="btnDelete" onclick="confirmDelete()">Delete Faculty</button>
        </div>
    </div>
</div>

<div class="cd-toast" id="toast"></div>

<script type="text/javascript">
var EMP = <asp:Literal ID="litDeanOptions" runat="server" Text="[]" />;
function esc(s){return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
function closeModal(id){document.getElementById(id).classList.remove('open');}

// Reusable searchable dropdown over a list of {v,t}; writes the chosen value to a hidden input.
function mountSearch(o){
    var root=document.getElementById(o.rootId), input=document.getElementById(o.inputId),
        menu=document.getElementById(o.menuId), hidden=document.getElementById(o.hiddenId);
    function render(){
        var q=(input.value||'').toLowerCase().trim(); menu.innerHTML='';
        if(o.noneLabel){
            var n=document.createElement('div'); n.className='ss__opt ss__opt--none'; n.textContent=o.noneLabel;
            n.onclick=function(){ hidden.value=o.noneVal; input.value=''; menu.classList.remove('open'); };
            menu.appendChild(n);
        }
        var shown=0;
        for(var i=0;i<o.items.length && shown<60;i++){
            var it=o.items[i];
            if(q && (''+it.t).toLowerCase().indexOf(q)<0) continue;
            var d=document.createElement('div'); d.className='ss__opt'; d.textContent=it.t;
            (function(it){ d.onclick=function(){ hidden.value=it.v; input.value=it.t; menu.classList.remove('open'); }; })(it);
            menu.appendChild(d); shown++;
        }
        if(shown===0 && !o.noneLabel){ var e=document.createElement('div'); e.className='ss__opt ss__empty'; e.textContent='No matches'; menu.appendChild(e); }
        menu.classList.add('open');
    }
    input.addEventListener('focus',render);
    input.addEventListener('input',function(){ if(o.allowFree) hidden.value=input.value.trim(); render(); });
    document.addEventListener('click',function(e){ if(!root.contains(e.target)) menu.classList.remove('open'); });
    return {
        setByValue:function(v){
            var found=null; for(var i=0;i<o.items.length;i++){ if(String(o.items[i].v)===String(v)){ found=o.items[i]; break; } }
            if(found){ hidden.value=found.v; input.value=found.t; }
            else if(o.allowFree){ hidden.value=(v==null?'':v); input.value=(v==null?'':v); }
            else { hidden.value=o.noneVal; input.value=''; }
        },
        clear:function(){ hidden.value=(o.noneVal!=null?o.noneVal:''); input.value=''; }
    };
}
var ssDean = mountSearch({rootId:'ssDeanRoot',inputId:'ssDeanInput',menuId:'ssDeanMenu',hiddenId:'fDean',items:EMP,allowFree:true});
document.addEventListener('keydown',function(e){if(e.key==='Escape'){closeModal('modalEdit');closeModal('modalDelete');}});

function filterRows(){
    var q=(document.getElementById('txtSearch').value||'').toLowerCase();
    var rows=document.querySelectorAll('#tblBody tr');
    var n=0;
    for(var i=0;i<rows.length;i++){
        if(rows[i].getAttribute('data-empty')!==null && rows[i].getAttribute('data-empty')==='1') continue;
        var s=(rows[i].getAttribute('data-search')||'').toLowerCase();
        var show=!q||s.indexOf(q)>=0;
        rows[i].style.display=show?'':'none';
        if(show)n++;
    }
    var c=document.getElementById('lblCount'); if(c)c.textContent=n+' facult'+(n!==1?'ies':'y');
}

function openCreate(){
    document.getElementById('modalTitle').textContent='New Faculty';
    document.getElementById('fOriginalCode').value='';
    document.getElementById('fCode').value='';   document.getElementById('fCode').readOnly=false;
    document.getElementById('fName').value='';
    document.getElementById('fAbbrev').value='';
    ssDean.clear();
    document.getElementById('fContacts').value='';
    document.getElementById('fCodeHint').textContent='Unique short code. Cannot be changed after creation.';
    var b=document.getElementById('btnSave'); b.disabled=false; b.textContent='Save Faculty';
    document.getElementById('modalEdit').classList.add('open');
    setTimeout(function(){document.getElementById('fCode').focus();},80);
}

document.addEventListener('click',function(e){
    var t=e.target; while(t&&t!==document&&!t.getAttribute('data-act')) t=t.parentNode;
    if(!t||t===document) return;
    var act=t.getAttribute('data-act');
    if(act==='edit'){
        document.getElementById('modalTitle').textContent='Edit Faculty';
        document.getElementById('fOriginalCode').value=t.getAttribute('data-code');
        document.getElementById('fCode').value=t.getAttribute('data-code'); document.getElementById('fCode').readOnly=true;
        document.getElementById('fName').value=t.getAttribute('data-name');
        document.getElementById('fAbbrev').value=t.getAttribute('data-abbrev');
        ssDean.setByValue(t.getAttribute('data-dean'));
        document.getElementById('fContacts').value=t.getAttribute('data-contacts');
        document.getElementById('fCodeHint').textContent='Faculty code cannot be changed.';
        var b=document.getElementById('btnSave'); b.disabled=false; b.textContent='Save Changes';
        document.getElementById('modalEdit').classList.add('open');
    } else if(act==='del'){
        document.getElementById('delCode').value=t.getAttribute('data-code');
        document.getElementById('delName').innerHTML='Delete <strong>'+esc(t.getAttribute('data-name'))+'</strong> ('+esc(t.getAttribute('data-code'))+')?';
        var b=document.getElementById('btnDelete'); b.disabled=false; b.textContent='Delete Faculty';
        document.getElementById('modalDelete').classList.add('open');
    }
});

function saveFaculty(){
    var code=document.getElementById('fCode').value.trim();
    var name=document.getElementById('fName').value.trim();
    var isEdit=document.getElementById('fOriginalCode').value!=='';
    if(!code){showToast('Faculty code is required.','err');return;}
    if(!name){showToast('Faculty name is required.','err');return;}
    var b=document.getElementById('btnSave'); b.disabled=true; b.textContent='Saving…';
    var body='code='+encodeURIComponent(code)+
             '&name='+encodeURIComponent(name)+
             '&abbrev='+encodeURIComponent(document.getElementById('fAbbrev').value.trim())+
             '&dean='+encodeURIComponent(document.getElementById('fDean').value.trim())+
             '&contacts='+encodeURIComponent(document.getElementById('fContacts').value.trim());
    fetch('NewFaculties.aspx?ajax='+(isEdit?'update':'create'),{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:body})
    .then(function(r){return r.json();})
    .then(function(d){
        b.disabled=false; b.textContent=isEdit?'Save Changes':'Save Faculty';
        if(d.ok){closeModal('modalEdit');showToast(isEdit?'Faculty updated.':'Faculty created.','ok');setTimeout(function(){location.reload();},900);}
        else showToast(d.error||'Failed to save.','err');
    })
    .catch(function(){b.disabled=false;b.textContent=isEdit?'Save Changes':'Save Faculty';showToast('Network error.','err');});
}

function confirmDelete(){
    var code=document.getElementById('delCode').value;
    var b=document.getElementById('btnDelete'); b.disabled=true; b.textContent='Deleting…';
    fetch('NewFaculties.aspx?ajax=delete',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'code='+encodeURIComponent(code)})
    .then(function(r){return r.json();})
    .then(function(d){
        b.disabled=false; b.textContent='Delete Faculty';
        if(d.ok){closeModal('modalDelete');showToast('Faculty deleted.','ok');setTimeout(function(){location.reload();},900);}
        else showToast(d.error||'Failed to delete.','err');
    })
    .catch(function(){b.disabled=false;b.textContent='Delete Faculty';showToast('Network error.','err');});
}

var _tt;
function showToast(msg,type){
    var t=document.getElementById('toast'); t.textContent=msg;
    t.className='cd-toast show'+(type==='err'?' cd-toast--err':'');
    clearTimeout(_tt); _tt=setTimeout(function(){t.classList.remove('show');},3500);
}
filterRows();
</script>
</asp:Content>
