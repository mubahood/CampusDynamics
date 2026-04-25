<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarkRequestsAdmin.aspx.cs" Inherits="COOPERP_NewScreens_MarkRequestsAdmin" Title="Mark Requests Admin Controller" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box}
.mra-wrap{max-width:1460px;margin:0 auto;padding:8px 10px 14px}
.mra-error{display:none;margin:0 0 10px;padding:10px 12px;border:1px solid #fecaca;background:#fef2f2;color:#b42318;border-radius:8px;font-size:12px}
.mra-error.show{display:block}
.mra-card{background:#fff;border:1px solid #e3e9f2;border-radius:10px;overflow:hidden;margin-bottom:10px}
.mra-head{padding:11px 13px;border-bottom:1px solid #eef2f6;display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap}
.mra-title{font-size:12px;font-weight:900;letter-spacing:.45px;text-transform:uppercase;color:#05275C}
.mra-sub{font-size:11px;color:#64748b}
.mra-filters{padding:11px 13px;display:grid;grid-template-columns:repeat(6,minmax(120px,1fr));gap:8px;align-items:end}
.mra-fg{display:flex;flex-direction:column;gap:4px;min-width:0}
.mra-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800}
.mra-input,.mra-select{height:32px;border:1px solid #cdd8e6;border-radius:7px;background:#fff;padding:6px 8px;font-size:11px;color:#1f2937;font-family:inherit}
.mra-input:focus,.mra-select:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12)}
.mra-actions{display:flex;gap:8px;align-items:center;flex-wrap:wrap}
.mra-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;height:32px;padding:0 11px;border-radius:7px;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:11px;font-weight:800;cursor:pointer}
.mra-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff}
.mra-btn--primary{background:#05275C;color:#fff;border-color:#05275C}
.mra-btn--primary:hover{background:#174DA4;color:#fff;border-color:#174DA4}
.mra-btn--danger{background:#b42318;color:#fff;border-color:#b42318}
.mra-btn--danger:hover{background:#8e1c15;color:#fff;border-color:#8e1c15}
.mra-grid{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:10px;margin-bottom:10px}
.mra-stat{background:#fff;border:1px solid #e3e9f2;border-radius:10px;padding:11px 12px;min-height:90px;display:flex;flex-direction:column;justify-content:center;gap:6px}
.mra-stat__lbl{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800}
.mra-stat__val{font-size:25px;color:#05275C;line-height:1;font-weight:900}
.mra-stat__sub{font-size:11px;color:#6b7280}
.mra-table-wrap{overflow:auto;background:#fff}
.mra-table{width:100%;min-width:1300px;border-collapse:collapse}
.mra-table th{background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;padding:8px;text-align:left;white-space:nowrap}
.mra-table td{border-bottom:1px solid #eef2f6;font-size:11px;color:#1f2937;padding:8px;vertical-align:top}
.mra-table tbody tr:last-child td{border-bottom:none}
.mra-pill{display:inline-block;padding:3px 8px;border-radius:999px;font-size:9px;font-weight:900;letter-spacing:.35px;text-transform:uppercase}
.mra-pill--PENDING_LECTURER{background:#fef3c7;color:#92400e}
.mra-pill--PENDING_SUPERVISOR{background:#e0f2fe;color:#0c4a6e}
.mra-pill--PENDING_ADMIN{background:#ede9fe;color:#5b21b6}
.mra-pill--APPROVED{background:#e6f4ea;color:#2e7d32}
.mra-pill--REJECTED{background:#fee2e2;color:#b42318}
.mra-pill--CANCELLED{background:#f3f4f6;color:#374151}
.mra-note{font-size:10px;color:#6b7280;line-height:1.35}
.mra-strong{font-weight:800;color:#05275C}
.mra-loading{opacity:.7;pointer-events:none}
.mra-right{text-align:right}
@media (max-width:1250px){.mra-grid{grid-template-columns:repeat(3,minmax(0,1fr));}.mra-filters{grid-template-columns:repeat(3,minmax(0,1fr));}}
@media (max-width:850px){.mra-grid{grid-template-columns:repeat(2,minmax(0,1fr));}.mra-filters{grid-template-columns:repeat(2,minmax(0,1fr));}}
@media (max-width:620px){.mra-grid,.mra-filters{grid-template-columns:1fr;}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="mra-wrap" id="mraWrap">
    <div id="mraError" class="mra-error"></div>

    <div class="mra-card" id="mraFilterCard">
        <div class="mra-head">
            <div>
                <div class="mra-title">Mark Requests Admin Controller</div>
                <div class="mra-sub">360° visibility + full intervention controls (approve, reject, force close).</div>
            </div>
            <div class="mra-actions">
                <button type="button" class="mra-btn mra-btn--primary" id="mraApply">Apply</button>
                <button type="button" class="mra-btn" id="mraReset">Reset</button>
                <button type="button" class="mra-btn" id="mraRefresh">Refresh</button>
            </div>
        </div>

        <div class="mra-filters">
            <div class="mra-fg">
                <label>Academic Year</label>
                <select id="mraYear" class="mra-select"></select>
            </div>
            <div class="mra-fg">
                <label>Semester</label>
                <select id="mraSemester" class="mra-select">
                    <option value="">All Semesters</option>
                    <option value="1">Sem 1</option>
                    <option value="2">Sem 2</option>
                    <option value="3">Sem 3</option>
                </select>
            </div>
            <div class="mra-fg">
                <label>Request Type</label>
                <select id="mraType" class="mra-select">
                    <option value="ALL">All Types</option>
                    <option value="MARK_CHANGE">Mark Change</option>
                    <option value="MISSING_MARK">Missing Mark</option>
                </select>
            </div>
            <div class="mra-fg">
                <label>Status</label>
                <select id="mraStatus" class="mra-select">
                    <option value="ALL">All Statuses</option>
                    <option value="PENDING_LECTURER">Pending Lecturer</option>
                    <option value="PENDING_SUPERVISOR">Pending Supervisor</option>
                    <option value="PENDING_ADMIN">Pending Admin</option>
                    <option value="APPROVED">Approved</option>
                    <option value="REJECTED">Rejected</option>
                    <option value="CANCELLED">Cancelled</option>
                </select>
            </div>
            <div class="mra-fg" style="grid-column:span 2">
                <label>Search</label>
                <input type="text" id="mraSearch" class="mra-input" placeholder="Reg no, student, course" />
            </div>
        </div>
    </div>

    <div class="mra-grid">
        <div class="mra-stat"><div class="mra-stat__lbl">Total</div><div class="mra-stat__val" id="sTotal">0</div><div class="mra-stat__sub">All requests in scope</div></div>
        <div class="mra-stat"><div class="mra-stat__lbl">Pending Admin</div><div class="mra-stat__val" id="sPendingAdmin">0</div><div class="mra-stat__sub">Requires immediate action</div></div>
        <div class="mra-stat"><div class="mra-stat__lbl">Pending Supervisor/Lecturer</div><div class="mra-stat__val" id="sPendingOther">0</div><div class="mra-stat__sub">Stuck before admin stage</div></div>
        <div class="mra-stat"><div class="mra-stat__lbl">Approved</div><div class="mra-stat__val" id="sApproved">0</div><div class="mra-stat__sub">Resolved as approved</div></div>
        <div class="mra-stat"><div class="mra-stat__lbl">Rejected + Cancelled</div><div class="mra-stat__val" id="sClosed">0</div><div class="mra-stat__sub">Closed without approval</div></div>
    </div>

    <div class="mra-card">
        <div class="mra-head">
            <div class="mra-title">Requests</div>
            <div class="mra-sub"><span id="mraCount">0</span> records</div>
        </div>
        <div class="mra-table-wrap">
            <table class="mra-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Student / Course</th>
                        <th>Scope</th>
                        <th>Type / Status</th>
                        <th>Original</th>
                        <th>Proposed</th>
                        <th>Trail</th>
                        <th class="mra-right">Actions</th>
                    </tr>
                </thead>
                <tbody id="mraRows">
                    <tr><td colspan="8" class="mra-note">Loading...</td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script type="text/javascript">
(function(){
'use strict';
function byId(id){return document.getElementById(id);} 
function txt(v){return (v===null||v===undefined||v==='')?'-':String(v);} 
function num(v){var n=parseInt(v,10);return isNaN(n)?0:n;} 
function esc(s){return String(s||'').replace(/[&<>\"']/g,function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c];});}
function money(v){var n=num(v); return n.toLocaleString('en-US');}

function showError(msg){var e=byId('mraError'); if(!e)return; e.textContent=msg||'Something went wrong.'; e.className='mra-error show';}
function hideError(){var e=byId('mraError'); if(e)e.className='mra-error';}
function setLoading(on){var w=byId('mraWrap'); if(!w)return; w.className='mra-wrap'+(on?' mra-loading':'');}

function ajax(method, payload, done){
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MarkRequestsAdmin.aspx/'+method,true);
    xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
    xhr.onload=function(){
        try{
            var raw=JSON.parse(xhr.responseText);
            var data=(raw&&raw.d!==undefined)?raw.d:raw;
            if(typeof data==='string'){ data=JSON.parse(data); }
            done(data||{success:false,message:'Empty response'});
        }catch(ex){ done({success:false,message:'Invalid response format.'}); }
    };
    xhr.onerror=function(){ done({success:false,message:'Network error.'}); };
    xhr.send(JSON.stringify(payload||{}));
}

function filters(){
    return {
        year: byId('mraYear').value || '',
        semester: byId('mraSemester').value || '',
        requestType: byId('mraType').value || 'ALL',
        statusFilter: byId('mraStatus').value || 'ALL',
        search: (byId('mraSearch').value || '').trim()
    };
}

function setYears(years){
    var el=byId('mraYear'); if(!el)return;
    var html='<option value="">All Years</option>';
    (years||[]).forEach(function(y){ html+='<option value="'+esc(y.value||'')+'">'+esc(y.text||'')+'</option>'; });
    el.innerHTML=html;
}

function applyStats(s){
    s=s||{};
    var pendingOther=num(s.pendingLecturer)+num(s.pendingSupervisor);
    byId('sTotal').textContent=money(s.total);
    byId('sPendingAdmin').textContent=money(s.pendingAdmin);
    byId('sPendingOther').textContent=money(pendingOther);
    byId('sApproved').textContent=money(s.approved);
    byId('sClosed').textContent=money(num(s.rejected)+num(s.cancelled));
}

function canAct(status){
    status=(status||'').toUpperCase();
    return status==='PENDING_LECTURER' || status==='PENDING_SUPERVISOR' || status==='PENDING_ADMIN';
}

function rowHtml(r){
    var status=txt(r.status).toUpperCase();
    var action='';
    if(canAct(status)){
        action += '<button class="mra-btn mra-btn--primary" data-act="approve" data-id="'+esc(r.id)+'">Approve</button> ';
        action += '<button class="mra-btn" data-act="reject" data-id="'+esc(r.id)+'">Reject</button> ';
    }
    action += '<button class="mra-btn mra-btn--danger" data-act="force" data-id="'+esc(r.id)+'">Force Close</button>';

    var trail=[];
    if(r.student_reason){ trail.push('<div class="mra-note"><span class="mra-strong">Student:</span> '+esc(r.student_reason)+'</div>'); }
    if(r.lecturer_response){ trail.push('<div class="mra-note"><span class="mra-strong">Lecturer:</span> '+esc(r.lecturer_response)+'</div>'); }
    if(r.supervisor_response){ trail.push('<div class="mra-note"><span class="mra-strong">Supervisor:</span> '+esc(r.supervisor_response)+'</div>'); }
    if(r.admin_response){ trail.push('<div class="mra-note"><span class="mra-strong">Admin:</span> '+esc(r.admin_response)+'</div>'); }
    if(trail.length===0){ trail.push('<div class="mra-note">-</div>'); }

    var scope='Y'+esc(r.acad_year)+' / S'+esc(r.semester);
    return ''+
    '<tr data-id="'+esc(r.id)+'">'+
      '<td>#'+esc(r.id)+'</td>'+
      '<td><div class="mra-strong">'+esc(r.student_name||r.regno)+'</div><div class="mra-note">'+esc(r.regno)+'</div><div class="mra-note">'+esc(r.course_name||r.course_id)+' ('+esc(r.course_id)+')</div></td>'+
      '<td><div>'+scope+'</div><div class="mra-note">Created: '+esc(r.created_at)+'</div><div class="mra-note">Updated: '+esc(r.updated_at)+'</div></td>'+
      '<td><div class="mra-note">'+esc((r.request_type||'').replace('_',' '))+'</div><span class="mra-pill mra-pill--'+esc(status)+'">'+esc(status.replace(/_/g,' '))+'</span></td>'+
      '<td><div class="mra-note">CW: '+txt(r.orig_cw)+'</div><div class="mra-note">Exam: '+txt(r.orig_exam)+'</div><div class="mra-note"><span class="mra-strong">Total: '+txt(r.orig_total)+'</span></div><div class="mra-note">Grade: '+txt(r.orig_grade)+'</div></td>'+
      '<td><div class="mra-note">CW: '+txt(r.proposed_cw)+'</div><div class="mra-note">Exam: '+txt(r.proposed_exam)+'</div><div class="mra-note"><span class="mra-strong">Total: '+txt(r.proposed_total)+'</span></div></td>'+
      '<td>'+trail.join('')+'<div class="mra-note">Lec: '+txt(r.lecturer_name)+'</div><div class="mra-note">Sup: '+txt(r.supervisor_name)+'</div><div class="mra-note">Admin: '+txt(r.admin_username)+'</div></td>'+
      '<td class="mra-right">'+action+'</td>'+
    '</tr>';
}

function renderRows(items){
    var tbody=byId('mraRows'); if(!tbody)return;
    if(!items || !items.length){
        tbody.innerHTML='<tr><td colspan="8" class="mra-note">No mark requests found for the selected filters.</td></tr>';
        byId('mraCount').textContent='0';
        return;
    }
    var html='';
    for(var i=0;i<items.length;i++){ html+=rowHtml(items[i]); }
    tbody.innerHTML=html;
    byId('mraCount').textContent=String(items.length);
}

function loadStatsAndRequests(){
    hideError();
    setLoading(true);
    var f=filters();
    ajax('GetStats',{year:f.year,semester:f.semester,requestType:f.requestType},function(sRes){
        if(!sRes || !sRes.success){ setLoading(false); showError((sRes&&sRes.message)||'Failed to load stats.'); return; }
        applyStats(sRes.stats||{});
        ajax('GetRequests',f,function(rRes){
            setLoading(false);
            if(!rRes || !rRes.success){ showError((rRes&&rRes.message)||'Failed to load requests.'); return; }
            renderRows(rRes.requests||[]);
        });
    });
}

function doAction(action,id){
    id=num(id);
    if(!id){ showError('Invalid request id.'); return; }

    if(action==='approve'){
        var note=window.prompt('Optional admin note before approval:','');
        if(note===null) return;
        setLoading(true);
        ajax('AdminApprove',{requestId:id,note:note},function(res){
            setLoading(false);
            if(!res || !res.success){ showError((res&&res.message)||'Approval failed.'); return; }
            hideError();
            loadStatsAndRequests();
        });
        return;
    }

    if(action==='reject'){
        var reason=window.prompt('Enter rejection reason (required):','');
        if(reason===null) return;
        if((reason||'').trim().length<5){ showError('Rejection reason must be at least 5 characters.'); return; }
        setLoading(true);
        ajax('AdminReject',{requestId:id,reason:reason},function(res){
            setLoading(false);
            if(!res || !res.success){ showError((res&&res.message)||'Reject failed.'); return; }
            hideError();
            loadStatsAndRequests();
        });
        return;
    }

    if(action==='force'){
        var why=window.prompt('Force close reason (required):','');
        if(why===null) return;
        if((why||'').trim().length<5){ showError('Force close reason must be at least 5 characters.'); return; }
        if(!window.confirm('Force close request #'+id+'? This overrides workflow state.')) return;
        setLoading(true);
        ajax('AdminForceClose',{requestId:id,reason:why},function(res){
            setLoading(false);
            if(!res || !res.success){ showError((res&&res.message)||'Force close failed.'); return; }
            hideError();
            loadStatsAndRequests();
        });
    }
}

function bindEvents(){
    byId('mraApply').onclick=loadStatsAndRequests;
    byId('mraRefresh').onclick=loadStatsAndRequests;
    byId('mraReset').onclick=function(){
        byId('mraYear').value='';
        byId('mraSemester').value='';
        byId('mraType').value='ALL';
        byId('mraStatus').value='ALL';
        byId('mraSearch').value='';
        loadStatsAndRequests();
    };
    byId('mraSearch').addEventListener('keydown',function(e){ if(e.key==='Enter'){ loadStatsAndRequests(); } });
    byId('mraRows').addEventListener('click',function(e){
        var btn=e.target && e.target.closest ? e.target.closest('button[data-act]') : null;
        if(!btn) return;
        doAction(btn.getAttribute('data-act'), btn.getAttribute('data-id'));
    });
}

function init(){
    hideError();
    setLoading(true);
    ajax('GetInit',{},function(res){
        setLoading(false);
        if(!res || !res.success){ showError((res&&res.message)||'Failed to initialize page.'); return; }
        setYears(res.years||[]);
        bindEvents();
        loadStatsAndRequests();
    });
}

init();
})();
</script>
</asp:Content>
