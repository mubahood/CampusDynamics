<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarkRequestsAdmin.aspx.cs" Inherits="COOPERP_NewScreens_MarkRequestsAdmin" Title="Mark Requests Admin Controller" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box}
.mra-wrap{width:100%;max-width:100%;margin:0 auto;padding:6px 8px 10px;overflow-x:hidden}
.mra-error{display:none;margin:0 0 8px;padding:7px 8px;border:1px solid #fecaca;background:#fef2f2;color:#b42318;border-radius:0;font-size:11px}
.mra-error.show{display:block}
.mra-card{background:#fff;border:1px solid #e3e9f2;border-radius:0;overflow:hidden;margin-bottom:8px}
.mra-head{padding:7px 8px;border-bottom:1px solid #eef2f6;display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap}
.mra-title{font-size:12px;font-weight:900;letter-spacing:.45px;text-transform:uppercase;color:#05275C}
.mra-sub{font-size:10px;color:#64748b}
.mra-filters{padding:7px 8px;display:grid;grid-template-columns:repeat(6,minmax(100px,1fr));gap:6px;align-items:end}
.mra-fg{display:flex;flex-direction:column;gap:3px;min-width:0}
.mra-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800}
.mra-fg--search{grid-column:span 2}
.mra-input,.mra-select{height:28px;border:1px solid #cdd8e6;border-radius:0;background:#fff;padding:4px 6px;font-size:11px;color:#1f2937;font-family:inherit;min-width:0;width:100%}
.mra-input:focus,.mra-select:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12)}
.mra-actions{display:flex;gap:6px;align-items:center;flex-wrap:wrap}
.mra-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;height:28px;padding:0 8px;border-radius:0;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;white-space:nowrap}
.mra-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff}
.mra-btn[disabled]{opacity:.55;cursor:not-allowed}
.mra-btn--primary{background:#05275C;color:#fff;border-color:#05275C}
.mra-btn--primary:hover{background:#174DA4;color:#fff;border-color:#174DA4}
.mra-btn--danger{background:#b42318;color:#fff;border-color:#b42318}
.mra-btn--danger:hover{background:#8e1c15;color:#fff;border-color:#8e1c15}
.mra-grid{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:8px;margin-bottom:8px}
.mra-stat{background:#fff;border:1px solid #e3e9f2;border-radius:0;padding:7px 8px;min-height:74px;display:flex;flex-direction:column;justify-content:center;gap:4px;min-width:0}
.mra-stat__lbl{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800}
.mra-stat__val{font-size:22px;color:#05275C;line-height:1;font-weight:900;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.mra-stat__sub{font-size:10px;color:#6b7280}
.mra-table-wrap{overflow-x:auto;overflow-y:hidden;background:#fff;max-width:100%}
.mra-table{width:100%;min-width:0;border-collapse:collapse;table-layout:fixed}
.mra-table th{background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;padding:6px 6px;text-align:left;white-space:normal;word-break:break-word}
.mra-table td{border-bottom:1px solid #eef2f6;font-size:10px;color:#1f2937;padding:6px;vertical-align:top;word-break:break-word;overflow-wrap:anywhere}
.mra-table tbody tr:last-child td{border-bottom:none}
.mra-pill{display:inline-block;padding:2px 6px;border-radius:0;font-size:9px;font-weight:900;letter-spacing:.35px;text-transform:uppercase}
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
.mra-action-wrap{display:flex;gap:4px;justify-content:flex-end;flex-wrap:wrap}
.mra-modal{position:fixed;inset:0;background:rgba(5,39,92,.35);display:none;align-items:center;justify-content:center;padding:12px;z-index:9999}
.mra-modal.show{display:flex}
.mra-modal__panel{width:100%;max-width:460px;background:#fff;border:1px solid #d5dce8;border-radius:0}
.mra-modal__head{padding:8px;border-bottom:1px solid #e8edf5;display:flex;justify-content:space-between;align-items:center;gap:8px}
.mra-modal__title{font-size:11px;font-weight:900;letter-spacing:.4px;text-transform:uppercase;color:#05275C}
.mra-modal__body{padding:8px;display:flex;flex-direction:column;gap:6px}
.mra-modal__hint{font-size:10px;color:#64748b;line-height:1.35}
.mra-modal__marks{display:none;border:1px solid #e5eaf3;padding:6px}
.mra-modal__marks.show{display:block}
.mra-modal__grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:6px}
.mra-modal__mark{display:flex;flex-direction:column;gap:3px}
.mra-modal__mark label{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800}
.mra-modal__mark input{height:28px;border:1px solid #cdd8e6;border-radius:0;padding:4px 6px;font-size:11px;color:#1f2937;font-family:inherit;width:100%;min-width:0}
.mra-modal__mark input:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12)}
.mra-modal__mark--total input{background:#f8fafc;color:#05275C;font-weight:800}
.mra-modal__textarea{min-height:92px;resize:vertical;border:1px solid #cdd8e6;border-radius:0;padding:6px;font-size:11px;color:#1f2937;font-family:inherit}
.mra-modal__textarea:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12)}
.mra-modal__foot{padding:8px;border-top:1px solid #e8edf5;display:flex;justify-content:flex-end;gap:6px;flex-wrap:wrap}
.mra-modal__error{display:none;border:1px solid #fecaca;background:#fef2f2;color:#b42318;padding:6px;font-size:10px}
.mra-modal__error.show{display:block}
@media (max-width:1250px){.mra-grid{grid-template-columns:repeat(3,minmax(0,1fr));}.mra-filters{grid-template-columns:repeat(3,minmax(0,1fr));}.mra-fg--search{grid-column:span 3;}}
@media (max-width:900px){.mra-grid{grid-template-columns:repeat(2,minmax(0,1fr));}.mra-filters{grid-template-columns:repeat(2,minmax(0,1fr));}.mra-fg--search{grid-column:span 2;}}
@media (max-width:640px){.mra-grid,.mra-filters,.mra-modal__grid{grid-template-columns:1fr;}.mra-fg--search{grid-column:span 1;}.mra-head{align-items:flex-start}.mra-right{text-align:left}.mra-action-wrap{justify-content:flex-start}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="mra-wrap" id="mraWrap">
    <div id="mraError" class="mra-error"></div>

    <div class="mra-card" id="mraFilterCard">
        <div class="mra-head">
            <div>
                <div class="mra-title">Mark Requests Admin Controller</div>
                <div class="mra-sub">Full visibility + intervention controls (approve, reject, force close).</div>
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
            <div class="mra-fg mra-fg--search">
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

    <div class="mra-modal" id="mraModal" aria-hidden="true">
        <div class="mra-modal__panel" role="dialog" aria-modal="true" aria-labelledby="mraModalTitle">
            <div class="mra-modal__head">
                <div class="mra-modal__title" id="mraModalTitle">Action</div>
                <button type="button" class="mra-btn" id="mraModalClose">Close</button>
            </div>
            <div class="mra-modal__body">
                <div class="mra-modal__hint" id="mraModalHint"></div>
                <div class="mra-modal__marks" id="mraApproveMarks">
                    <div class="mra-modal__hint">Adjust marks before approval (optional). Leave blank to keep existing proposed marks.</div>
                    <div class="mra-modal__grid">
                        <div class="mra-modal__mark">
                            <label>CW (0-100)</label>
                            <input type="number" id="mraApproveCw" min="0" max="100" placeholder="CW" />
                        </div>
                        <div class="mra-modal__mark">
                            <label>Exam (0-100)</label>
                            <input type="number" id="mraApproveExam" min="0" max="100" placeholder="Exam" />
                        </div>
                        <div class="mra-modal__mark mra-modal__mark--total">
                            <label>Total</label>
                            <input type="number" id="mraApproveTotal" readonly="readonly" placeholder="Auto" />
                        </div>
                    </div>
                </div>
                <textarea id="mraModalNote" class="mra-modal__textarea" placeholder="Enter note..."></textarea>
                <div class="mra-modal__error" id="mraModalError"></div>
            </div>
            <div class="mra-modal__foot">
                <button type="button" class="mra-btn" id="mraModalCancel">Cancel</button>
                <button type="button" class="mra-btn mra-btn--primary" id="mraModalSubmit">Submit</button>
            </div>
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
var modalState={action:'',requestId:0};
var _mraRowsById={};

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
        action += '<button type="button" class="mra-btn mra-btn--primary" data-act="approve" data-id="'+esc(r.id)+'">Approve</button> ';
        action += '<button type="button" class="mra-btn" data-act="reject" data-id="'+esc(r.id)+'">Reject</button> ';
    }
    action += '<button type="button" class="mra-btn mra-btn--danger" data-act="force" data-id="'+esc(r.id)+'">Force Close</button>';

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
            '<td class="mra-right"><div class="mra-action-wrap">'+action+'</div></td>'+
    '</tr>';
}

function renderRows(items){
    var tbody=byId('mraRows'); if(!tbody)return;
    _mraRowsById={};
    if(!items || !items.length){
        tbody.innerHTML='<tr><td colspan="8" class="mra-note">No mark requests found for the selected filters.</td></tr>';
        byId('mraCount').textContent='0';
        return;
    }
    for(var j=0;j<items.length;j++){
        _mraRowsById[String(items[j].id)]=items[j];
    }
    var html='';
    for(var i=0;i<items.length;i++){ html+=rowHtml(items[i]); }
    tbody.innerHTML=html;
    byId('mraCount').textContent=String(items.length);
}

function parseMarkOrNull(v){
    if(v===null || v===undefined) return null;
    var s=String(v).trim();
    if(s==='') return null;
    var n=parseInt(s,10);
    return isNaN(n)?null:n;
}

function setApproveTotal(){
    var cw=parseMarkOrNull(byId('mraApproveCw').value);
    var ex=parseMarkOrNull(byId('mraApproveExam').value);
    var total=byId('mraApproveTotal');
    if(!total) return;
    total.value=(cw!==null && ex!==null)? String(cw+ex) : '';
}

function loadStatsAndRequests(showBusy){
    hideError();
    if(showBusy!==false) setLoading(true);
    var f=filters();
    ajax('GetStats',{year:f.year,semester:f.semester,requestType:f.requestType},function(sRes){
        if(!sRes || !sRes.success){ if(showBusy!==false) setLoading(false); showError((sRes&&sRes.message)||'Failed to load stats.'); return; }
        applyStats(sRes.stats||{});
        ajax('GetRequests',f,function(rRes){
            if(showBusy!==false) setLoading(false);
            if(!rRes || !rRes.success){ showError((rRes&&rRes.message)||'Failed to load requests.'); return; }
            renderRows(rRes.requests||[]);
        });
    });
}

function modalError(msg){
    var e=byId('mraModalError');
    if(!e) return;
    if(msg){ e.textContent=msg; e.className='mra-modal__error show'; }
    else { e.textContent=''; e.className='mra-modal__error'; }
}

function openModal(action,id){
    modalState.action=action;
    modalState.requestId=num(id);
    var row=_mraRowsById[String(id)] || null;
    var title=byId('mraModalTitle'), hint=byId('mraModalHint'), note=byId('mraModalNote'), submit=byId('mraModalSubmit');
    var marksWrap=byId('mraApproveMarks'), cw=byId('mraApproveCw'), ex=byId('mraApproveExam'), total=byId('mraApproveTotal');
    if(!title||!hint||!note||!submit) return;
    modalError('');
    note.value='';
    note.disabled=false;
    submit.disabled=false;
    if(cw) cw.value='';
    if(ex) ex.value='';
    if(total) total.value='';
    if(marksWrap) marksWrap.className='mra-modal__marks';

    if(action==='approve'){
        title.textContent='Approve Request #'+modalState.requestId;
        hint.textContent='Optional admin note. This request will be approved and marks published if proposed marks are available.';
        note.placeholder='Optional approval note';
        submit.textContent='Approve';
        submit.className='mra-btn mra-btn--primary';
        if(marksWrap) marksWrap.className='mra-modal__marks show';
        if(cw && row){
            var prefCw = (row.proposed_cw!==null && row.proposed_cw!==undefined) ? row.proposed_cw : row.orig_cw;
            cw.value = (prefCw!==null && prefCw!==undefined) ? String(prefCw) : '';
        }
        if(ex && row){
            var prefEx = (row.proposed_exam!==null && row.proposed_exam!==undefined) ? row.proposed_exam : row.orig_exam;
            ex.value = (prefEx!==null && prefEx!==undefined) ? String(prefEx) : '';
        }
        setApproveTotal();
    } else if(action==='reject'){
        title.textContent='Reject Request #'+modalState.requestId;
        hint.textContent='Provide rejection reason (minimum 5 characters).';
        note.placeholder='Required rejection reason';
        submit.textContent='Reject';
        submit.className='mra-btn';
    } else if(action==='force'){
        title.textContent='Force Close Request #'+modalState.requestId;
        hint.textContent='Provide reason (minimum 5 characters). This overrides workflow state.';
        note.placeholder='Required force-close reason';
        submit.textContent='Force Close';
        submit.className='mra-btn mra-btn--danger';
    }

    var modal=byId('mraModal');
    if(modal){ modal.className='mra-modal show'; modal.setAttribute('aria-hidden','false'); }
    note.focus();
}

function closeModal(){
    var modal=byId('mraModal');
    if(modal){ modal.className='mra-modal'; modal.setAttribute('aria-hidden','true'); }
    modalState.action='';
    modalState.requestId=0;
    modalError('');
}

function submitModalAction(){
    var id=modalState.requestId;
    var action=modalState.action;
    var noteEl=byId('mraModalNote'), submit=byId('mraModalSubmit');
    if(!id || !action || !noteEl || !submit){ modalError('Invalid action context.'); return; }

    var txtVal=(noteEl.value||'').trim();
    var method='', payload={requestId:id};

    if(action==='approve'){
        var cwVal=parseMarkOrNull(byId('mraApproveCw').value);
        var exVal=parseMarkOrNull(byId('mraApproveExam').value);
        var oneProvided = (cwVal!==null || exVal!==null);
        if(oneProvided && (cwVal===null || exVal===null)){
            modalError('Please provide both CW and Exam marks, or leave both blank.');
            return;
        }
        if(cwVal!==null && (cwVal<0 || cwVal>100)){ modalError('CW mark must be 0-100.'); return; }
        if(exVal!==null && (exVal<0 || exVal>100)){ modalError('Exam mark must be 0-100.'); return; }
        method='AdminApprove';
        payload.note=txtVal;
        payload.adminProposedCw=cwVal;
        payload.adminProposedExam=exVal;
    } else if(action==='reject'){
        if(txtVal.length<5){ modalError('Rejection reason must be at least 5 characters.'); return; }
        method='AdminReject';
        payload.reason=txtVal;
    } else if(action==='force'){
        if(txtVal.length<5){ modalError('Force close reason must be at least 5 characters.'); return; }
        method='AdminForceClose';
        payload.reason=txtVal;
    } else {
        modalError('Unknown action.');
        return;
    }

    modalError('');
    submit.disabled=true;
    noteEl.disabled=true;
    var oldText=submit.textContent;
    submit.textContent='Processing...';

    ajax(method,payload,function(res){
        submit.disabled=false;
        noteEl.disabled=false;
        submit.textContent=oldText;
        if(!res || !res.success){ modalError((res&&res.message)||'Action failed.'); return; }
        closeModal();
        hideError();
        loadStatsAndRequests(false);
    });
}

function doAction(action,id){
    id=num(id);
    if(!id){ showError('Invalid request id.'); return; }
    if(action==='approve' || action==='reject' || action==='force'){
        openModal(action,id);
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
    byId('mraSearch').addEventListener('keydown',function(e){ if(e.key==='Enter'){ e.preventDefault(); loadStatsAndRequests(); } });
    byId('mraRows').addEventListener('click',function(e){
        var btn=e.target && e.target.closest ? e.target.closest('button[data-act]') : null;
        if(!btn) return;
        e.preventDefault();
        doAction(btn.getAttribute('data-act'), btn.getAttribute('data-id'));
    });

    byId('mraModalClose').onclick=closeModal;
    byId('mraModalCancel').onclick=closeModal;
    byId('mraModalSubmit').onclick=submitModalAction;
    byId('mraModal').addEventListener('click',function(e){
        if(e.target && e.target.id==='mraModal') closeModal();
    });
    byId('mraApproveCw').addEventListener('input',setApproveTotal);
    byId('mraApproveExam').addEventListener('input',setApproveTotal);
    document.addEventListener('keydown',function(e){
        if(e.key==='Escape'){ closeModal(); }
        if(e.key==='Enter'){
            var m=byId('mraModal');
            if(m && m.className.indexOf('show')>=0 && document.activeElement!==byId('mraModalNote')){
                e.preventDefault();
                submitModalAction();
            }
        }
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
