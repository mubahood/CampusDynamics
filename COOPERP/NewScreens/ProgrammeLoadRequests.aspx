<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ProgrammeLoadRequests.aspx.cs" Inherits="COOPERP_NewScreens_ProgrammeLoadRequests" Title="Programme Load Requests - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.plr-hero{background:#05275C;color:#fff;padding:14px 16px;margin-bottom:12px;border-bottom:3px solid #041d45;display:flex;justify-content:space-between;align-items:flex-start;gap:10px;flex-wrap:wrap;}
.plr-hero__title{font-size:16px;font-weight:800;margin:0 0 4px;}
.plr-hero__sub{font-size:11px;opacity:.84;margin:0;}
.plr-hero__period{background:rgba(255,255,255,.14);padding:7px 10px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.35px;}

.plr-stats{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px;margin-bottom:12px;}
.plr-stat{background:#fff;border:1px solid #e0e5ed;padding:11px 12px;}
.plr-stat__label{font-size:10px;text-transform:uppercase;letter-spacing:.35px;color:#6b7280;font-weight:700;}
.plr-stat__value{font-size:20px;color:#05275C;font-weight:800;margin-top:6px;line-height:1.05;}
.plr-stat__sub{font-size:10px;color:#7b8493;margin-top:3px;}

.plr-card{background:#fff;border:1px solid #e0e5ed;margin-bottom:12px;}
.plr-card__head{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:10px 12px;border-bottom:1px solid #e0e5ed;background:#f8fafc;flex-wrap:wrap;}
.plr-card__title{font-size:12px;font-weight:800;color:#05275C;text-transform:uppercase;letter-spacing:.4px;}

.plr-filters{padding:10px 12px;border-bottom:1px solid #e8edf3;background:#f8fafc;}
.plr-filter-grid{display:flex;gap:8px;align-items:flex-end;flex-wrap:wrap;}
.plr-fg{display:flex;flex-direction:column;gap:4px;min-width:132px;}
.plr-fg--wide{min-width:220px;flex:1;}
.plr-fg label{font-size:10px;text-transform:uppercase;letter-spacing:.35px;color:#6b7280;font-weight:700;}
.plr-input,.plr-select{height:32px;border:1px solid #cfd7e3;padding:7px 8px;font-size:12px;background:#fff;}
.plr-input:focus,.plr-select:focus{outline:none;border-color:#174DA4;}

.plr-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 10px;border:1px solid #d2dae6;background:#fff;color:#05275C;text-decoration:none;font-size:11px;font-weight:700;cursor:pointer;}
.plr-btn:hover{background:#f5f8ff;border-color:#174DA4;color:#174DA4;text-decoration:none;}
.plr-btn--primary{background:#05275C;border-color:#05275C;color:#fff;}
.plr-btn--primary:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.plr-btn--ok{background:#166534;border-color:#166534;color:#fff;}
.plr-btn--ok:hover{background:#15803d;border-color:#15803d;color:#fff;}
.plr-btn--danger{background:#b42318;border-color:#b42318;color:#fff;}
.plr-btn--danger:hover{background:#dc2626;border-color:#dc2626;color:#fff;}

.plr-txtbtn{background:none;border:none;padding:0;font-size:11px;font-weight:700;color:#174DA4;cursor:pointer;text-decoration:none;line-height:1.3;}
.plr-txtbtn:hover{text-decoration:underline;color:#05275C;}
.plr-txtbtn--ok{color:#166534;}
.plr-txtbtn--danger{color:#b42318;}
.plr-txtbtn:disabled{opacity:.45;cursor:not-allowed;text-decoration:none;}

.plr-batch{display:flex;align-items:center;gap:6px;flex-wrap:wrap;}
.plr-batch__count{font-size:11px;color:#4b5563;font-weight:700;padding:2px 6px;border:1px solid #dbe4ef;background:#fff;}
.plr-check{width:14px;height:14px;vertical-align:middle;}

.plr-meta{display:flex;justify-content:space-between;align-items:center;gap:8px;padding:8px 12px;border-bottom:1px solid #eef1f5;font-size:11px;color:#4b5563;flex-wrap:wrap;}
.plr-meta strong{color:#05275C;}

.plr-table-wrap{overflow:auto;}
.plr-table{width:100%;border-collapse:collapse;min-width:1180px;}
.plr-table th{background:#f8fafc;border-bottom:2px solid #e0e5ed;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.35px;color:#6b7280;padding:8px 9px;text-align:left;white-space:nowrap;}
.plr-table td{border-bottom:1px solid #eef2f6;font-size:12px;color:#1f2937;padding:8px 9px;vertical-align:top;}
.plr-table tbody tr:hover td{background:#f9fbff;}
.plr-code{font-family:Consolas,"Courier New",monospace;font-size:11px;color:#174DA4;font-weight:700;}
.plr-muted{font-size:11px;color:#6b7280;}
.plr-pill{display:inline-block;padding:3px 7px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;}
.plr-pill--pending{background:#fff4e5;color:#b45309;}
.plr-pill--approved{background:#e8f5e9;color:#2e7d32;}
.plr-pill--rejected{background:#fde8e8;color:#b42318;}
.plr-actions{display:flex;align-items:center;gap:5px;flex-wrap:wrap;}
.plr-empty{padding:24px;text-align:center;color:#6b7280;font-size:12px;}

.plr-pager{display:flex;justify-content:space-between;align-items:center;gap:8px;padding:9px 12px;border-top:1px solid #e0e5ed;background:#f8fafc;flex-wrap:wrap;font-size:11px;color:#4b5563;}
.plr-pager__links{display:flex;gap:4px;flex-wrap:wrap;}
.plr-pager__links a,.plr-pager__links span{border:1px solid #d4dbe8;background:#fff;color:#334155;font-size:11px;text-decoration:none;padding:4px 9px;}
.plr-pager__links .active{background:#05275C;border-color:#05275C;color:#fff;}

.plr-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:9000;}
.plr-overlay.show{display:block;}
.plr-modal{display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background:#fff;border:1px solid #e0e5ed;width:92%;max-width:760px;max-height:86vh;overflow:auto;z-index:9001;}
.plr-modal.show{display:block;}
.plr-modal__head{padding:10px 12px;border-bottom:1px solid #e7ebf1;background:#f8fafc;display:flex;justify-content:space-between;align-items:center;gap:8px;}
.plr-modal__title{font-size:12px;font-weight:800;color:#05275C;text-transform:uppercase;letter-spacing:.35px;}
.plr-close{background:none;border:none;font-size:20px;line-height:1;color:#6b7280;cursor:pointer;}
.plr-modal__body{padding:10px 12px;}
.plr-modal__foot{padding:10px 12px;border-top:1px solid #e7ebf1;background:#f8fafc;display:flex;justify-content:flex-end;gap:8px;flex-wrap:wrap;}
.plr-fg-modal{display:flex;flex-direction:column;gap:4px;margin-bottom:10px;}
.plr-fg-modal label{font-size:10px;text-transform:uppercase;letter-spacing:.35px;color:#6b7280;font-weight:700;}
.plr-textarea{border:1px solid #cfd7e3;padding:8px;font-size:12px;resize:vertical;min-height:78px;}
.plr-textarea:focus{outline:none;border-color:#174DA4;}
.plr-alert{display:none;padding:8px 10px;font-size:11px;margin-bottom:8px;}
.plr-alert.show{display:block;}
.plr-alert--err{background:#fde8e8;color:#b42318;}
.plr-alert--ok{background:#e8f5e9;color:#2e7d32;}

@media (max-width:1000px){.plr-stats{grid-template-columns:repeat(2,minmax(0,1fr));}}
@media (max-width:640px){.plr-stats{grid-template-columns:1fr;}}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="plr-hero">
    <div>
        <div class="plr-hero__title">Programme Load Requests</div>
        <p class="plr-hero__sub">Admin review controller for lecturer allocation requests raised from Staff Courses.</p>
    </div>
    <div class="plr-hero__period">Current Period: <asp:Literal ID="litCurrentPeriod" runat="server" Text="-" /></div>
</div>

<div class="plr-stats">
    <div class="plr-stat"><div class="plr-stat__label">Pending Requests</div><div class="plr-stat__value"><asp:Literal ID="litPendingCount" runat="server" Text="0" /></div><div class="plr-stat__sub">Awaiting review</div></div>
    <div class="plr-stat"><div class="plr-stat__label">Approved</div><div class="plr-stat__value"><asp:Literal ID="litApprovedCount" runat="server" Text="0" /></div><div class="plr-stat__sub">Allocation confirmed</div></div>
    <div class="plr-stat"><div class="plr-stat__label">Rejected</div><div class="plr-stat__value"><asp:Literal ID="litRejectedCount" runat="server" Text="0" /></div><div class="plr-stat__sub">Need follow-up</div></div>
    <div class="plr-stat"><div class="plr-stat__label">Rows in View</div><div class="plr-stat__value"><asp:Literal ID="litTotalDisplay" runat="server" Text="0" /></div><div class="plr-stat__sub">Current filters</div></div>
</div>

<div class="plr-card">
    <div class="plr-card__head">
        <div class="plr-card__title">Request Queue</div>
        <div class="plr-batch">
            <span id="plrSelectedCount" class="plr-batch__count">0 selected</span>
            <button type="button" class="plr-btn" onclick="submitBatchDecision('Pending')">Batch Pending</button>
            <button type="button" class="plr-btn plr-btn--danger" onclick="submitBatchDecision('Rejected')">Batch Reject</button>
            <button type="button" class="plr-btn plr-btn--ok" onclick="submitBatchDecision('Approved')">Batch Approve</button>
        </div>
    </div>

    <div class="plr-filters">
        <div class="plr-filter-grid">
            <div class="plr-fg">
                <label>Semester</label>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="plr-select">
                    <asp:ListItem Value="" Text="All"></asp:ListItem>
                    <asp:ListItem Value="1" Text="Semester 1"></asp:ListItem>
                    <asp:ListItem Value="2" Text="Semester 2"></asp:ListItem>
                    <asp:ListItem Value="3" Text="Semester 3"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="plr-fg">
                <label>Programme</label>
                <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="plr-select"></asp:DropDownList>
            </div>
            <div class="plr-fg">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="plr-select">
                    <asp:ListItem Value="" Text="All"></asp:ListItem>
                    <asp:ListItem Value="pending" Text="Pending"></asp:ListItem>
                    <asp:ListItem Value="approved" Text="Approved"></asp:ListItem>
                    <asp:ListItem Value="rejected" Text="Rejected"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="plr-fg">
                <label>Rows / Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="plr-select">
                    <asp:ListItem Value="25" Text="25"></asp:ListItem>
                    <asp:ListItem Value="50" Text="50" Selected="True"></asp:ListItem>
                    <asp:ListItem Value="100" Text="100"></asp:ListItem>
                    <asp:ListItem Value="200" Text="200"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="plr-fg plr-fg--wide">
                <label>Search</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="plr-input" placeholder="Course, programme, requester, message..."></asp:TextBox>
            </div>
            <div class="plr-fg" style="justify-content:flex-end;">
                <label>&nbsp;</label>
                <div style="display:flex;gap:6px;">
                    <button type="button" class="plr-btn plr-btn--primary" onclick="applyFilters()">Apply</button>
                    <button type="button" class="plr-btn" onclick="resetFilters()">Reset</button>
                </div>
            </div>
        </div>
    </div>

    <div class="plr-meta">
        <span>Showing <strong><asp:Literal ID="litPageInfo" runat="server" Text="Page 1 of 1" /></strong></span>
        <span>Total: <strong><asp:Literal ID="litTotalRows" runat="server" Text="0" /></strong></span>
    </div>

    <div class="plr-table-wrap">
        <table class="plr-table">
            <thead>
                <tr>
                    <th style="width:34px;"><input type="checkbox" id="plrChkAll" class="plr-check" onclick="toggleAllRows(this)" /></th>
                    <th>Course</th>
                    <th>Programme Context</th>
                    <th>Requested By</th>
                    <th>Current Assigned</th>
                    <th>Requested On</th>
                    <th>Request Message</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litRows" runat="server" />
            </tbody>
        </table>
    </div>

    <div class="plr-pager">
        <span class="plr-muted">Decision updates are applied immediately.</span>
        <div class="plr-pager__links"><asp:Literal ID="litPager" runat="server" /></div>
    </div>
</div>

<div class="plr-overlay" id="plrOverlay"></div>
<div class="plr-modal" id="plrModal">
    <div class="plr-modal__head">
        <div class="plr-modal__title">Review Allocation Request</div>
        <button type="button" class="plr-close" onclick="closeReviewModal()">&times;</button>
    </div>
    <div class="plr-modal__body">
        <div class="plr-alert plr-alert--err" id="plrErr"></div>
        <div class="plr-alert plr-alert--ok" id="plrOk"></div>

        <div class="plr-fg-modal"><label>Course</label><div id="plrCourseCtx" class="plr-muted">-</div></div>
        <div class="plr-fg-modal"><label>Requester</label><div id="plrRequester" class="plr-muted">-</div></div>
        <div class="plr-fg-modal"><label>Current Assigned</label><div id="plrAssigned" class="plr-muted">-</div></div>
        <div class="plr-fg-modal"><label>Lecturer Message</label><div id="plrRequestMsg" class="plr-muted" style="white-space:pre-wrap;line-height:1.45;">-</div></div>

        <div class="plr-fg-modal">
            <label>Admin Message</label>
            <textarea id="plrAdminMsg" class="plr-textarea" placeholder="Optional feedback to requester..."></textarea>
        </div>
    </div>
    <div class="plr-modal__foot">
        <button type="button" class="plr-btn" onclick="closeReviewModal()">Cancel</button>
        <button type="button" class="plr-btn" onclick="submitDecision('Pending')">Mark Pending</button>
        <button type="button" class="plr-btn plr-btn--danger" onclick="submitDecision('Rejected')">Reject</button>
        <button type="button" class="plr-btn plr-btn--ok" onclick="submitDecision('Approved')">Approve</button>
    </div>
</div>

<script type="text/javascript">
function byId(id){ return document.getElementById(id); }
function escH(s){ var d=document.createElement('div'); d.appendChild(document.createTextNode(s||'')); return d.innerHTML; }

function setOrDel(qs,key,val){ if(val&&val.length>0) qs.set(key,val); else qs.delete(key); }
function applyFilters(){
    var qs = new URLSearchParams(window.location.search);
    qs.set('page','1');
    setOrDel(qs,'sem',byId('<%= ddlSemester.ClientID %>').value);
    setOrDel(qs,'prog',byId('<%= ddlProgramme.ClientID %>').value);
    setOrDel(qs,'status',byId('<%= ddlStatus.ClientID %>').value);
    setOrDel(qs,'q',byId('<%= txtSearch.ClientID %>').value.trim());
    setOrDel(qs,'size',byId('<%= ddlPageSize.ClientID %>').value);
    window.location.href = window.location.pathname + '?' + qs.toString();
}
function resetFilters(){ window.location.href = window.location.pathname; }

function getSelectedIds(){
    var nodes=document.querySelectorAll('.plr-row-check:checked');
    var ids=[];
    for(var i=0;i<nodes.length;i++){
        var id=parseInt(nodes[i].getAttribute('data-id')||'0',10);
        if(id>0) ids.push(id);
    }
    return ids;
}

function updateSelectedCount(){
    var c=getSelectedIds().length;
    var lbl=byId('plrSelectedCount');
    if(lbl) lbl.textContent=c+' selected';
}

function toggleAllRows(el){
    var rows=document.querySelectorAll('.plr-row-check');
    for(var i=0;i<rows.length;i++) rows[i].checked=!!el.checked;
    updateSelectedCount();
}

var __reviewId = 0;
function openReviewModal(el){
    __reviewId = parseInt(el.getAttribute('data-id')||'0',10)||0;
    byId('plrCourseCtx').innerHTML = escH(el.getAttribute('data-coursectx')||'-');
    byId('plrRequester').innerHTML = escH(el.getAttribute('data-requester')||'-');
    byId('plrAssigned').innerHTML = escH(el.getAttribute('data-assigned')||'-');
    byId('plrRequestMsg').innerHTML = escH(el.getAttribute('data-reqmsg')||'-');
    byId('plrAdminMsg').value = el.getAttribute('data-adminmsg')||'';
    hideReviewAlerts();
    byId('plrOverlay').classList.add('show');
    byId('plrModal').classList.add('show');
}
function closeReviewModal(){ byId('plrOverlay').classList.remove('show'); byId('plrModal').classList.remove('show'); }
function hideReviewAlerts(){ byId('plrErr').classList.remove('show'); byId('plrOk').classList.remove('show'); }
function showReviewErr(msg){ var e=byId('plrErr'); e.textContent=msg||'Request failed.'; e.classList.add('show'); }
function showReviewOk(msg){ var e=byId('plrOk'); e.textContent=msg||'Done.'; e.classList.add('show'); }

function parseResp(text){
    var outer = JSON.parse(text || '{}');
    var payload = (outer && typeof outer.d !== 'undefined') ? outer.d : outer;
    if (typeof payload === 'string') payload = JSON.parse(payload);
    return payload || {};
}

function submitDecision(decision){
    hideReviewAlerts();
    if(!__reviewId || __reviewId<=0){ showReviewErr('Invalid row selected.'); return; }

    var adminMessage = (byId('plrAdminMsg').value||'').trim();
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'ProgrammeLoadRequests.aspx/ProcessRequestDecision', true);
    xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
    xhr.onload = function(){
        if(xhr.status !== 200){ showReviewErr('HTTP ' + xhr.status); return; }
        try{
            var r = parseResp(xhr.responseText);
            if(r && r.Success===true){
                showReviewOk(r.Message || 'Decision saved.');
                setTimeout(function(){ window.location.reload(); }, 700);
            }else{
                showReviewErr((r && r.Message) || 'Unable to save decision.');
            }
        }catch(e){ showReviewErr('Parse error: ' + e.message); }
    };
    xhr.onerror = function(){ showReviewErr('Network error while saving decision.'); };
    xhr.send(JSON.stringify({ programmeCourseId: __reviewId, decision: decision, adminMessage: adminMessage }));
}

function quickDecision(id, decision){
    __reviewId = parseInt(id||'0',10)||0;
    if(!__reviewId) return;
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'ProgrammeLoadRequests.aspx/ProcessRequestDecision', true);
    xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
    xhr.onload = function(){
        if(xhr.status!==200) { alert('HTTP ' + xhr.status); return; }
        try{
            var r = parseResp(xhr.responseText);
            if(r && r.Success===true) window.location.reload();
            else alert((r&&r.Message) || 'Action failed.');
        }catch(e){ alert('Parse error: '+e.message); }
    };
    xhr.onerror = function(){ alert('Network error.'); };
    xhr.send(JSON.stringify({ programmeCourseId: __reviewId, decision: decision, adminMessage: '' }));
}

function submitBatchDecision(decision){
    var ids=getSelectedIds();
    if(ids.length===0){ alert('Select at least one row for batch action.'); return; }
    if(!confirm('Apply '+decision+' to '+ids.length+' selected request(s)?')) return;

    var xhr=new XMLHttpRequest();
    xhr.open('POST','ProgrammeLoadRequests.aspx/ProcessBatchRequestDecision',true);
    xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
    xhr.onload=function(){
        if(xhr.status!==200){ alert('HTTP '+xhr.status); return; }
        try{
            var r=parseResp(xhr.responseText);
            if(r && r.Success===true){
                alert(r.Message || 'Batch action completed.');
                window.location.reload();
            }else{
                alert((r&&r.Message) || 'Batch action failed.');
            }
        }catch(e){ alert('Parse error: '+e.message); }
    };
    xhr.onerror=function(){ alert('Network error.'); };
    xhr.send(JSON.stringify({ programmeCourseIds: ids, decision: decision, adminMessage: '' }));
}

document.addEventListener('DOMContentLoaded', function(){
    var ids=['<%= ddlSemester.ClientID %>','<%= ddlProgramme.ClientID %>','<%= ddlStatus.ClientID %>','<%= ddlPageSize.ClientID %>'];
    for(var i=0;i<ids.length;i++){ var el=byId(ids[i]); if(el) el.addEventListener('change', applyFilters); }
    var q=byId('<%= txtSearch.ClientID %>');
    if(q) q.addEventListener('keydown', function(e){ if(e.key==='Enter'){ e.preventDefault(); applyFilters(); } });

    var checks=document.querySelectorAll('.plr-row-check');
    for(var j=0;j<checks.length;j++) checks[j].addEventListener('change', updateSelectedCount);
    updateSelectedCount();

    var ov=byId('plrOverlay');
    if(ov) ov.addEventListener('click', function(e){ if(e.target===ov) closeReviewModal(); });
});
</script>
</asp:Content>
