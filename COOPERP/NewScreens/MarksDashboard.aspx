<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarksDashboard.aspx.cs" Inherits="COOPERP_NewScreens_MarksDashboard" Title="Marks Dashboard - Admin" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box;}
.md-wrap{max-width:1320px;margin:0 auto;padding:8px 10px 12px;}
.md-card{background:#fff;border:1px solid #e3e9f2;border-radius:8px;overflow:hidden;margin-bottom:10px;}
.md-filters{padding:10px;display:grid;grid-template-columns:minmax(150px,.8fr) minmax(120px,.7fr) minmax(170px,.9fr) auto auto;gap:8px;align-items:flex-end;}
.md-fg{display:flex;flex-direction:column;gap:3px;min-width:0;}
.md-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;}
.md-select{height:30px;border:1px solid #cdd8e6;padding:4px 8px;font-size:11px;background:#fff;border-radius:6px;color:#1a1a2e;font-family:inherit;}
.md-select:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12);background:#fcfdff;}
.md-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;padding:5px 10px;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;border-radius:6px;min-height:30px;text-decoration:none;}
.md-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff;}
.md-btn--primary{background:#05275C;color:#fff;border-color:#05275C;}
.md-btn--primary:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.md-meta{padding:8px 10px;border-top:1px solid #eef2f6;font-size:10px;color:#64748b;background:#f8fafc;display:flex;justify-content:space-between;gap:8px;flex-wrap:wrap;}
.md-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin-bottom:10px;}
.md-stat{background:#fff;border:1px solid #e3e9f2;border-radius:8px;padding:12px 14px;min-height:90px;display:flex;flex-direction:column;justify-content:center;gap:6px;}
.md-stat__lbl{font-size:10px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;}
.md-stat__val{font-size:28px;font-weight:900;color:#05275C;line-height:1;}
.md-stat__sub{font-size:11px;color:#6b7280;}
.md-card__head{padding:10px 12px;border-bottom:1px solid #eef2f6;display:flex;justify-content:space-between;align-items:center;gap:10px;}
.md-card__title{font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.45px;color:#05275C;}
.md-table-wrap{overflow:auto;scrollbar-color:#b6c5db #f5f8fc;scrollbar-width:thin;background:#fff;}
.md-table{width:100%;min-width:620px;border-collapse:collapse;}
.md-table th{background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;padding:7px 8px;text-align:left;white-space:nowrap;}
.md-table td{border-bottom:1px solid #eef2f6;font-size:11px;color:#1f2937;padding:8px;vertical-align:middle;}
.md-table tbody tr:last-child td{border-bottom:none;}
.md-pill{display:inline-block;padding:2px 7px;font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;border-radius:3px;}
.md-pill--pending{background:#fff3cd;color:#92400e;}
.md-pill--approved{background:#e6f4ea;color:#2e7d32;}
.md-pill--published{background:#e8f0fc;color:#174DA4;}
.md-pill--missing{background:#fef2f2;color:#b42318;}
.md-err{display:none;margin:0 0 10px;padding:9px 11px;background:#fef2f2;border:1px solid #fecaca;color:#b91c1c;border-radius:6px;font-size:11px;}
.md-err.show{display:block;}
.md-loading{opacity:.7;pointer-events:none;}
@media (max-width:1100px){.md-grid{grid-template-columns:repeat(2,minmax(0,1fr));}.md-filters{grid-template-columns:repeat(2,minmax(0,1fr));}}
@media (max-width:720px){.md-grid,.md-filters{grid-template-columns:1fr;}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="md-wrap">
    <div id="mdError" class="md-err"></div>

    <div class="md-card" id="mdFilterCard">
        <div class="md-filters">
            <div class="md-fg">
                <label>Academic Year</label>
                <select id="mdYear" class="md-select"></select>
            </div>
            <div class="md-fg">
                <label>Semester</label>
                <select id="mdSemester" class="md-select">
                    <option value="">All Semesters</option>
                    <option value="1">Sem 1</option>
                    <option value="2">Sem 2</option>
                    <option value="3">Sem 3</option>
                </select>
            </div>
            <div class="md-fg">
                <label>Programme</label>
                <select id="mdProgramme" class="md-select"></select>
            </div>
            <div class="md-fg">
                <label>&nbsp;</label>
                <button type="button" id="mdApply" class="md-btn md-btn--primary">Apply Filters</button>
            </div>
            <div class="md-fg">
                <label>&nbsp;</label>
                <button type="button" id="mdReset" class="md-btn">Reset</button>
            </div>
        </div>
        <div class="md-meta">
            <span>Scope: Students where <strong>new_status = ACTIVE</strong> only.</span>
            <span id="mdScopeText">All years • All semesters • All programmes</span>
        </div>
    </div>

    <div class="md-grid">
        <div class="md-stat"><div class="md-stat__lbl">Active Students</div><div class="md-stat__val" id="kActiveStudents">0</div><div class="md-stat__sub">Distinct active students with marks rows</div></div>
        <div class="md-stat"><div class="md-stat__lbl">Marks Records</div><div class="md-stat__val" id="kMarksRows">0</div><div class="md-stat__sub">Course registration rows in scope</div></div>
        <div class="md-stat"><div class="md-stat__lbl">Courses</div><div class="md-stat__val" id="kCourses">0</div><div class="md-stat__sub">Distinct courses represented</div></div>
        <div class="md-stat"><div class="md-stat__lbl">Published</div><div class="md-stat__val" id="kPublished">0</div><div class="md-stat__sub">Official marks in final published state</div></div>
        <div class="md-stat"><div class="md-stat__lbl">Approved</div><div class="md-stat__val" id="kApproved">0</div><div class="md-stat__sub">Approved and awaiting publication</div></div>
        <div class="md-stat"><div class="md-stat__lbl">Pending Review</div><div class="md-stat__val" id="kPending">0</div><div class="md-stat__sub">Entered marks still pending review</div></div>
    </div>

    <div class="md-card">
        <div class="md-card__head">
            <div class="md-card__title">Data Completeness</div>
        </div>
        <div class="md-table-wrap">
            <table class="md-table">
                <thead>
                    <tr>
                        <th>Metric</th>
                        <th>Count</th>
                        <th>Status</th>
                        <th>Meaning</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Missing Coursework</td>
                        <td id="tMissingCw">0</td>
                        <td><span class="md-pill md-pill--missing">Gap</span></td>
                        <td>Rows where coursework marks are not entered</td>
                    </tr>
                    <tr>
                        <td>Missing Exam</td>
                        <td id="tMissingExam">0</td>
                        <td><span class="md-pill md-pill--missing">Gap</span></td>
                        <td>Rows where exam marks are not entered</td>
                    </tr>
                    <tr>
                        <td>Pending Review</td>
                        <td id="tPending">0</td>
                        <td><span class="md-pill md-pill--pending">Pending</span></td>
                        <td>Rows entered but not approved/published yet</td>
                    </tr>
                    <tr>
                        <td>Approved</td>
                        <td id="tApproved">0</td>
                        <td><span class="md-pill md-pill--approved">Approved</span></td>
                        <td>Rows approved and ready for publishing</td>
                    </tr>
                    <tr>
                        <td>Published</td>
                        <td id="tPublished">0</td>
                        <td><span class="md-pill md-pill--published">Published</span></td>
                        <td>Rows already published to final results</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script type="text/javascript">
(function(){
'use strict';
function qs(id){ return document.getElementById(id); }
function toNum(v){ var n=parseInt(v,10); return isNaN(n)?0:n; }
function fmtNum(v){ return toNum(v).toLocaleString('en-US'); }
function showError(msg){ var el=qs('mdError'); if(!el) return; el.textContent=msg||'Unable to load dashboard data.'; el.className='md-err show'; }
function hideError(){ var el=qs('mdError'); if(el) el.className='md-err'; }
function callAJAX(method,params,cb){
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MarksDashboard.aspx/'+method,true);
    xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
    xhr.onload=function(){
        try{ var o=JSON.parse(xhr.responseText); cb(typeof o.d==='string'?JSON.parse(o.d):o.d); }
        catch(e){ cb({success:false,message:'Invalid server response.'}); }
    };
    xhr.onerror=function(){ cb({success:false,message:'Network error.'}); };
    xhr.send(JSON.stringify(params||{}));
}
function setLoading(isLoading){ var card=qs('mdFilterCard'); if(card) card.className='md-card'+(isLoading?' md-loading':''); }
function fillSelect(selectId,items,includeAllText){
    var el=qs(selectId); if(!el) return;
    var html='<option value="">'+includeAllText+'</option>';
    (items||[]).forEach(function(it){ html+='<option value="'+(it.value||'')+'">'+(it.text||'')+'</option>'; });
    el.innerHTML=html;
}
function setScopeText(){
    var year=qs('mdYear'), sem=qs('mdSemester'), prog=qs('mdProgramme');
    var yearTxt=year && year.value ? year.options[year.selectedIndex].text : 'All years';
    var semTxt=sem && sem.value ? sem.options[sem.selectedIndex].text : 'All semesters';
    var progTxt=prog && prog.value ? prog.options[prog.selectedIndex].text : 'All programmes';
    qs('mdScopeText').textContent=yearTxt+' • '+semTxt+' • '+progTxt;
}
function applyStats(d){
    qs('kActiveStudents').textContent=fmtNum(d.activeStudents);
    qs('kMarksRows').textContent=fmtNum(d.marksRecords);
    qs('kCourses').textContent=fmtNum(d.courseCount);
    qs('kPublished').textContent=fmtNum(d.publishedCount);
    qs('kApproved').textContent=fmtNum(d.approvedCount);
    qs('kPending').textContent=fmtNum(d.pendingCount);
    qs('tMissingCw').textContent=fmtNum(d.missingCourseworkCount);
    qs('tMissingExam').textContent=fmtNum(d.missingExamCount);
    qs('tPending').textContent=fmtNum(d.pendingCount);
    qs('tApproved').textContent=fmtNum(d.approvedCount);
    qs('tPublished').textContent=fmtNum(d.publishedCount);
}
function loadStats(){
    hideError();
    setLoading(true);
    var payload={
        year:qs('mdYear').value,
        semester:qs('mdSemester').value,
        programme:qs('mdProgramme').value
    };
    callAJAX('GetDashboardStats',payload,function(d){
        setLoading(false);
        if(!d || !d.success){ showError((d&&d.message)||'Failed to load stats.'); return; }
        setScopeText();
        applyStats(d.stats||{});
    });
}
function init(){
    setLoading(true);
    callAJAX('GetDashboardInit',{},function(d){
        setLoading(false);
        if(!d || !d.success){ showError((d&&d.message)||'Failed to load filter options.'); return; }
        fillSelect('mdYear',d.years,'All Years');
        fillSelect('mdProgramme',d.programmes,'All Programmes');
        if(qs('mdApply')) qs('mdApply').onclick=function(){ loadStats(); };
        if(qs('mdReset')) qs('mdReset').onclick=function(){
            qs('mdYear').value=''; qs('mdSemester').value=''; qs('mdProgramme').value='';
            loadStats();
        };
        loadStats();
    });
}
init();
})();
</script>
</asp:Content>
