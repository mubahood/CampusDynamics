<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="OnlineApplicationsController.aspx.cs"
    Inherits="COOPERP_NewScreens_OnlineApplicationsController"
    Title="Online Applications - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ONLINE APPLICATIONS CONTROLLER (prefix: oa-) ========================= */

.oa-hdr{display:flex;align-items:center;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #e0e5ed;background:#fff;}
.oa-hdr__left{display:flex;align-items:center;gap:10px;}
.oa-hdr__icon{width:36px;height:36px;background:#05275C;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.oa-hdr__title{font-size:15px;font-weight:700;color:#05275C;line-height:1.2;}
.oa-hdr__sub{font-size:10px;color:#888;margin-top:1px;}
.oa-hdr__actions{display:flex;align-items:center;gap:8px;}

/* Stats */
.oa-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:10px;padding:14px 16px;background:#fafbfc;border-bottom:1px solid #e0e5ed;}
.oa-stat{background:#fff;border:1px solid #e0e5ed;padding:12px 14px;position:relative;overflow:hidden;}
.oa-stat::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--sc,#ccc);}
.oa-stat__label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#888;margin-bottom:3px;}
.oa-stat__value{font-size:22px;font-weight:800;letter-spacing:-.5px;color:var(--sc,#333);}
.oa-stat--total{--sc:#05275C;}
.oa-stat--draft{--sc:#9ca3af;}
.oa-stat--submitted{--sc:#174DA4;}
.oa-stat--review{--sc:#d97706;}
.oa-stat--admitted{--sc:#d97706;}
.oa-stat--rejected{--sc:#c62828;}

/* Filter bar */
.oa-filters{padding:10px 14px;border-bottom:1px solid #e0e5ed;background:#f8f9fa;}
.oa-filters__row{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
.oa-search-wrap{position:relative;flex:1;min-width:200px;max-width:320px;}
.oa-search-wrap svg{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:#999;pointer-events:none;}
.oa-search{width:100%;border:1px solid #ddd;padding:6px 10px 6px 30px;font-size:12px;font-family:inherit;background:#fff;}
.oa-search:focus{border-color:#174DA4;outline:none;}
.oa-select{border:1px solid #ddd;padding:6px 8px;font-size:11px;font-family:inherit;background:#fff;color:#333;min-width:130px;}
.oa-select:focus{border-color:#174DA4;outline:none;}
.oa-filters__count{font-size:11px;color:#174DA4;font-weight:600;background:rgba(23,77,164,.07);padding:4px 10px;margin-left:auto;}

/* Buttons */
.oa-btn{padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:5px;white-space:nowrap;font-family:inherit;transition:all .15s;}
.oa-btn--primary{background:#05275C;color:#fff;}.oa-btn--primary:hover{background:#174DA4;}
.oa-btn--amber{background:#d97706;color:#fff;}.oa-btn--amber:hover{background:#b45309;}
.oa-btn--danger{background:#c62828;color:#fff;}.oa-btn--danger:hover{background:#b71c1c;}
.oa-btn--ghost{background:#fff;border:1px solid #cdd3de;color:#555;}.oa-btn--ghost:hover{border-color:#174DA4;color:#174DA4;}
.oa-btn--sm{padding:4px 10px;font-size:10px;}
.oa-btn:disabled{opacity:.5;cursor:not-allowed;}

/* Table */
.oa-table-wrap{overflow-x:auto;}
.oa-table{width:100%;border-collapse:collapse;font-size:11px;}
.oa-table th{background:#f5f7fa;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#666;padding:9px 12px;text-align:left;border-bottom:2px solid #e0e5ed;white-space:nowrap;}
.oa-table td{padding:8px 12px;border-bottom:1px solid #f0f2f5;color:#222;vertical-align:middle;}
.oa-table tr:hover td{background:#f5f9ff;}
.oa-name{font-weight:600;color:#05275C;}
.oa-eno{font-family:monospace;font-size:11px;color:#555;font-weight:600;}
.oa-actions-cell{display:flex;gap:4px;flex-wrap:nowrap;}

/* Status badges */
.oa-badge{display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;border:1px solid transparent;white-space:nowrap;}
.oa-badge--draft{background:#f5f5f5;color:#555;border-color:#e0e0e0;}
.oa-badge--submitted{background:#e8f0fc;color:#174DA4;border-color:#bbdefb;}
.oa-badge--under_review{background:#fff8e1;color:#b45309;border-color:#fde68a;}
.oa-badge--admitted{background:#fef9ec;color:#d97706;border-color:#fde68a;}
.oa-badge--rejected{background:#fde8e8;color:#c62828;border-color:#f5c6cb;}
.oa-badge--withdrawn{background:#f5f5f5;color:#757575;border-color:#e0e0e0;}

/* Empty / loading */
.oa-empty{text-align:center;padding:40px 20px;color:#aaa;font-size:12px;}

/* Pagination */
.oa-pager{display:flex;align-items:center;justify-content:space-between;padding:10px 16px;border-top:1px solid #e0e5ed;font-size:11px;color:#666;background:#fafbfc;}
.oa-pager__nav{display:flex;gap:4px;}
.oa-pager__btn{border:1px solid #ddd;background:#fff;padding:4px 10px;font-size:11px;cursor:pointer;color:#333;font-family:inherit;text-decoration:none;display:inline-block;}
.oa-pager__btn:hover{background:#f0f4ff;border-color:#174DA4;color:#174DA4;}

/* Detail modal */
.oa-modal-bg{display:none;position:fixed;inset:0;z-index:9100;background:rgba(0,0,0,.5);align-items:flex-start;justify-content:center;padding-top:40px;overflow-y:auto;}
.oa-modal-bg.open{display:flex;}
.oa-modal{background:#fff;width:740px;max-width:96vw;box-shadow:0 20px 60px rgba(0,0,0,.25);max-height:85vh;display:flex;flex-direction:column;}
.oa-modal__hdr{display:flex;align-items:center;justify-content:space-between;padding:13px 18px;background:#05275C;color:#fff;flex-shrink:0;}
.oa-modal__hdr h3{margin:0;font-size:14px;font-weight:700;}
.oa-modal__close{background:none;border:none;color:rgba(255,255,255,.8);font-size:22px;cursor:pointer;line-height:1;padding:0 4px;}
.oa-modal__close:hover{color:#fff;}
.oa-modal__body{padding:0;overflow-y:auto;flex:1;}
.oa-modal__tabs{display:flex;border-bottom:2px solid #e0e5ed;background:#f8f9fa;flex-shrink:0;}
.oa-modal__tab{padding:10px 16px;font-size:11px;font-weight:600;cursor:pointer;border:none;background:none;color:#666;border-bottom:2px solid transparent;margin-bottom:-2px;font-family:inherit;}
.oa-modal__tab.active{color:#05275C;border-bottom-color:#05275C;background:#fff;}
.oa-modal__tab:hover{color:#174DA4;}
.oa-tab-panel{display:none;padding:16px 18px;}
.oa-tab-panel.active{display:block;}
.oa-section{margin-bottom:16px;}
.oa-section__title{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#888;border-bottom:1px solid #f0f0f0;padding-bottom:5px;margin-bottom:10px;}
.oa-grid-2{display:grid;grid-template-columns:1fr 1fr;gap:10px 20px;}
.oa-grid-3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px 20px;}
.oa-field label{font-size:10px;font-weight:700;text-transform:uppercase;color:#888;letter-spacing:.3px;display:block;margin-bottom:2px;}
.oa-field__val{font-size:12px;font-weight:600;color:#05275C;}
.oa-field__val--light{font-weight:400;color:#444;}
.oa-modal__foot{display:flex;align-items:center;justify-content:space-between;padding:12px 18px;border-top:1px solid #e0e5ed;background:#fafbfc;flex-shrink:0;flex-wrap:wrap;gap:8px;}
.oa-modal__foot-right{display:flex;gap:8px;flex-wrap:wrap;}
.oa-info-row{display:flex;align-items:center;gap:6px;padding:8px 12px;font-size:11px;border:1px solid #e0e0e0;margin-bottom:10px;background:#f8f9fa;}
.oa-info-row svg{color:#174DA4;flex-shrink:0;}
.oa-warn-row{background:#fff8e1;border-color:#fde68a;color:#b45309;}

/* Toast */
.oa-toast{position:fixed;bottom:24px;right:24px;z-index:9999;padding:11px 18px;font-size:12px;font-weight:600;border:1px solid transparent;display:none;min-width:240px;box-shadow:0 4px 20px rgba(0,0,0,.15);}
.oa-toast.show{display:block;}
.oa-toast--ok{background:#e8f5e9;color:#155724;border-color:#c3e6cb;}
.oa-toast--err{background:#fde8e8;color:#c62828;border-color:#f5c6cb;}

/* Doc list in modal */
.oa-doc-list{list-style:none;margin:0;padding:0;}
.oa-doc-list li{display:flex;align-items:center;gap:8px;padding:6px 0;border-bottom:1px solid #f0f2f5;font-size:11px;}
.oa-doc-list li:last-child{border-bottom:none;}
.oa-doc-list .oa-doc-icon{width:26px;height:26px;background:#f0f4ff;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.oa-doc-label{font-weight:600;color:#05275C;flex:1;}
.oa-doc-file{color:#888;font-size:10px;}

@media (max-width:900px){
    .oa-hdr{flex-direction:column;align-items:flex-start;gap:10px;}
    .oa-filters__row{align-items:stretch;}
    .oa-search-wrap{max-width:none;flex:1 1 100%;}
    .oa-select{min-width:0;flex:1 1 150px;}
    .oa-filters__count{margin-left:0;}
}
@media (max-width:640px){
    .oa-stats{grid-template-columns:repeat(2,minmax(0,1fr));padding:12px;}
    .oa-stat__value{font-size:18px;}
    .oa-table{font-size:10px;}
    .oa-table th,.oa-table td{padding:7px 8px;}
    .oa-modal-bg{padding-top:10px;}
    .oa-modal{width:100%;max-width:100vw;max-height:92vh;}
    .oa-grid-2,.oa-grid-3{grid-template-columns:1fr;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="oa-hdr">
    <div class="oa-hdr__left">
        <div class="oa-hdr__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        </div>
        <div>
            <div class="oa-hdr__title">Online Applications</div>
            <div class="oa-hdr__sub">Review and process applications submitted through the student portal</div>
        </div>
    </div>
    <div class="oa-hdr__actions">
        <a href="AdmissionsController.aspx" class="oa-btn oa-btn--ghost">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
            Admissions Controller
        </a>
        <button type="button" class="oa-btn oa-btn--ghost" onclick="window.location.reload()" title="Refresh">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
            Refresh
        </button>
    </div>
</div>

<!-- Stats (server-rendered) -->
<asp:Literal ID="litStats" runat="server"/>

<!-- Filters -->
<div class="oa-filters">
    <div class="oa-filters__row">
        <div class="oa-search-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" id="oa-q" class="oa-search" placeholder="Search name, entry no, email…"
                value="<%= HE(FilterQ) %>"
                onkeydown="if(event.key==='Enter'){event.preventDefault();applyFilters();}">
        </div>
        <select id="oa-status" class="oa-select">
            <option value="">All Statuses</option>
            <option value="DRAFT"<%= Sel(FilterStatus,"DRAFT") %>>Draft</option>
            <option value="SUBMITTED"<%= Sel(FilterStatus,"SUBMITTED") %>>Submitted</option>
            <option value="UNDER_REVIEW"<%= Sel(FilterStatus,"UNDER_REVIEW") %>>Under Review</option>
            <option value="ADMITTED"<%= Sel(FilterStatus,"ADMITTED") %>>Admitted</option>
            <option value="REJECTED"<%= Sel(FilterStatus,"REJECTED") %>>Rejected</option>
            <option value="WITHDRAWN"<%= Sel(FilterStatus,"WITHDRAWN") %>>Withdrawn</option>
        </select>
        <select id="oa-prog" class="oa-select" style="max-width:200px;">
            <option value="">All Programmes</option>
            <asp:Literal ID="litProgOptions" runat="server"/>
        </select>
        <select id="oa-year" class="oa-select">
            <option value="">All Years</option>
            <asp:Literal ID="litYearOptions" runat="server"/>
        </select>
        <select id="oa-session" class="oa-select">
            <option value="">All Sessions</option>
            <option value="DAY"<%= Sel(FilterSession,"DAY") %>>Day</option>
            <option value="EVENING"<%= Sel(FilterSession,"EVENING") %>>Evening</option>
            <option value="WEEKEND"<%= Sel(FilterSession,"WEEKEND") %>>Weekend</option>
            <option value="DISTANCE"<%= Sel(FilterSession,"DISTANCE") %>>Distance</option>
        </select>
        <button type="button" class="oa-btn oa-btn--primary" onclick="applyFilters()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="4" y1="6" x2="20" y2="6"/><line x1="8" y1="12" x2="16" y2="12"/><line x1="11" y1="18" x2="13" y2="18"/></svg>
            Filter
        </button>
        <button type="button" class="oa-btn oa-btn--ghost" onclick="clearFilters()">Clear</button>
        <select id="oa-pagesize" class="oa-select" style="min-width:90px;" onchange="applyFilters()">
            <option value="25"<%= Sel(FilterSize.ToString(),"25") %>>25 / page</option>
            <option value="50"<%= Sel(FilterSize.ToString(),"50") %>>50 / page</option>
            <option value="100"<%= Sel(FilterSize.ToString(),"100") %>>100 / page</option>
            <option value="200"<%= Sel(FilterSize.ToString(),"200") %>>200 / page</option>
        </select>
        <span class="oa-filters__count"><asp:Literal ID="litCount" runat="server" Text="—"/></span>
    </div>
</div>

<!-- Table -->
<div class="oa-table-wrap">
    <table class="oa-table">
        <thead>
            <tr>
                <th style="width:28px;">#</th>
                <th>Entry No</th>
                <th>Applicant Name</th>
                <th>Programme</th>
                <th>Session</th>
                <th>Year</th>
                <th>Status</th>
                <th>Submitted</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <asp:Literal ID="litTableRows" runat="server"/>
        </tbody>
    </table>
</div>

<!-- Pagination (server-rendered) -->
<asp:Literal ID="litPager" runat="server"/>

<!-- ═══ DETAIL MODAL ═══════════════════════════════════════════════ -->
<div class="oa-modal-bg" id="oa-modal-bg">
    <div class="oa-modal">
        <div class="oa-modal__hdr">
            <h3 id="oa-modal-title">Application Details</h3>
            <button type="button" class="oa-modal__close" onclick="closeModal()">&times;</button>
        </div>
        <div class="oa-modal__tabs">
            <button type="button" class="oa-modal__tab active" onclick="switchTab(this,'tab-personal')">Personal</button>
            <button type="button" class="oa-modal__tab" onclick="switchTab(this,'tab-education')">Education</button>
            <button type="button" class="oa-modal__tab" onclick="switchTab(this,'tab-programme')">Programme</button>
            <button type="button" class="oa-modal__tab" onclick="switchTab(this,'tab-documents')">Documents</button>
        </div>
        <div class="oa-modal__body">
            <div id="oa-status-row" style="padding:10px 18px 0;"></div>

            <!-- Personal -->
            <div class="oa-tab-panel active" id="tab-personal">
                <div class="oa-section">
                    <div class="oa-section__title">Personal Details</div>
                    <div class="oa-grid-3">
                        <div class="oa-field"><label>Entry No</label><div class="oa-field__val" id="d-eno">—</div></div>
                        <div class="oa-field"><label>Full Name</label><div class="oa-field__val" id="d-name">—</div></div>
                        <div class="oa-field"><label>Email</label><div class="oa-field__val oa-field__val--light" id="d-email">—</div></div>
                        <div class="oa-field"><label>Phone</label><div class="oa-field__val oa-field__val--light" id="d-phone">—</div></div>
                        <div class="oa-field"><label>Date of Birth</label><div class="oa-field__val oa-field__val--light" id="d-dob">—</div></div>
                        <div class="oa-field"><label>Gender</label><div class="oa-field__val oa-field__val--light" id="d-gender">—</div></div>
                        <div class="oa-field"><label>Nationality</label><div class="oa-field__val oa-field__val--light" id="d-nationality">—</div></div>
                        <div class="oa-field"><label>National ID / Passport</label><div class="oa-field__val oa-field__val--light" id="d-natid">—</div></div>
                        <div class="oa-field"><label>Religion</label><div class="oa-field__val oa-field__val--light" id="d-religion">—</div></div>
                        <div class="oa-field"><label>Marital Status</label><div class="oa-field__val oa-field__val--light" id="d-marital">—</div></div>
                        <div class="oa-field"><label>Disability</label><div class="oa-field__val oa-field__val--light" id="d-disability">—</div></div>
                        <div class="oa-field"><label>Address</label><div class="oa-field__val oa-field__val--light" id="d-address">—</div></div>
                    </div>
                </div>
            </div>

            <!-- Education -->
            <div class="oa-tab-panel" id="tab-education">
                <div class="oa-section">
                    <div class="oa-section__title">O-Level</div>
                    <div class="oa-grid-3">
                        <div class="oa-field"><label>School</label><div class="oa-field__val oa-field__val--light" id="d-oschool">—</div></div>
                        <div class="oa-field"><label>Index No</label><div class="oa-field__val oa-field__val--light" id="d-oidx">—</div></div>
                        <div class="oa-field"><label>Year</label><div class="oa-field__val oa-field__val--light" id="d-oyr">—</div></div>
                        <div class="oa-field"><label>Aggregate</label><div class="oa-field__val oa-field__val--light" id="d-oagg">—</div></div>
                    </div>
                </div>
                <div class="oa-section">
                    <div class="oa-section__title">A-Level</div>
                    <div class="oa-grid-3">
                        <div class="oa-field"><label>School</label><div class="oa-field__val oa-field__val--light" id="d-aschool">—</div></div>
                        <div class="oa-field"><label>Index No</label><div class="oa-field__val oa-field__val--light" id="d-aidx">—</div></div>
                        <div class="oa-field"><label>Year</label><div class="oa-field__val oa-field__val--light" id="d-ayr">—</div></div>
                        <div class="oa-field"><label>Points</label><div class="oa-field__val oa-field__val--light" id="d-apts">—</div></div>
                    </div>
                </div>
                <div class="oa-section">
                    <div class="oa-section__title">Other Qualifications</div>
                    <div class="oa-grid-3">
                        <div class="oa-field"><label>Institution</label><div class="oa-field__val oa-field__val--light" id="d-oinst">—</div></div>
                        <div class="oa-field"><label>Qualification</label><div class="oa-field__val oa-field__val--light" id="d-oqual">—</div></div>
                        <div class="oa-field"><label>Year</label><div class="oa-field__val oa-field__val--light" id="d-oqyr">—</div></div>
                        <div class="oa-field"><label>Grade</label><div class="oa-field__val oa-field__val--light" id="d-oqgr">—</div></div>
                    </div>
                </div>
            </div>

            <!-- Programme -->
            <div class="oa-tab-panel" id="tab-programme">
                <div class="oa-section">
                    <div class="oa-section__title">Programme Choice</div>
                    <div class="oa-grid-2">
                        <div class="oa-field"><label>Programme (1st Choice)</label><div class="oa-field__val" id="d-prog">—</div></div>
                        <div class="oa-field"><label>Session</label><div class="oa-field__val oa-field__val--light" id="d-session">—</div></div>
                        <div class="oa-field"><label>Campus</label><div class="oa-field__val oa-field__val--light" id="d-campus">—</div></div>
                        <div class="oa-field"><label>Intake</label><div class="oa-field__val oa-field__val--light" id="d-intake">—</div></div>
                        <div class="oa-field"><label>Sponsor</label><div class="oa-field__val oa-field__val--light" id="d-sponsor">—</div></div>
                        <div class="oa-field"><label>Entry Year</label><div class="oa-field__val oa-field__val--light" id="d-year">—</div></div>
                    </div>
                </div>
                <div class="oa-section">
                    <div class="oa-section__title">Emergency Contact</div>
                    <div class="oa-grid-2">
                        <div class="oa-field"><label>Name</label><div class="oa-field__val oa-field__val--light" id="d-emname">—</div></div>
                        <div class="oa-field"><label>Relationship</label><div class="oa-field__val oa-field__val--light" id="d-emrel">—</div></div>
                        <div class="oa-field"><label>Phone</label><div class="oa-field__val oa-field__val--light" id="d-emphone">—</div></div>
                    </div>
                </div>
                <div class="oa-section">
                    <div class="oa-section__title">Reviewer Notes</div>
                    <div class="oa-field">
                        <label for="d-notes">Internal notes (visible to admissions staff only)</label>
                        <textarea id="d-notes" style="width:100%;min-height:90px;border:1px solid #d8e0eb;padding:10px;font:inherit;resize:vertical;box-sizing:border-box;"></textarea>
                    </div>
                </div>
            </div>

            <!-- Documents -->
            <div class="oa-tab-panel" id="tab-documents">
                <div class="oa-section">
                    <div class="oa-section__title">Uploaded Documents</div>
                    <ul class="oa-doc-list" id="d-docs">
                        <li style="color:#aaa;font-size:12px;">Loading…</li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="oa-modal__foot">
            <button type="button" class="oa-btn oa-btn--ghost" onclick="closeModal()">Close</button>
            <div class="oa-modal__foot-right" id="oa-modal-actions"></div>
        </div>
    </div>
</div>

<!-- Toast -->
<div class="oa-toast" id="oa-toast"></div>

<script type="text/javascript">
/* ═══════════════════════════════════════════════════════════════════
   ONLINE APPLICATIONS CONTROLLER
   ═══════════════════════════════════════════════════════════════════ */
var _pageUrl       = '<%= ResolveUrl("~/COOPERP/NewScreens/OnlineApplicationsController.aspx") %>';
var _currentEno    = null;
var _currentDetail = null;

// ── Filters → GET navigation ─────────────────────────────────────
function applyFilters() {
    var sp      = new URLSearchParams();
    var q       = (document.getElementById('oa-q').value || '').trim();
    var status  = document.getElementById('oa-status').value;
    var prog    = document.getElementById('oa-prog').value;
    var year    = document.getElementById('oa-year').value;
    var session = document.getElementById('oa-session').value;
    var psSel   = document.getElementById('oa-pagesize');
    var psVal   = psSel ? psSel.value : '50';
    if (q)                   sp.set('q',       q);
    if (status)              sp.set('status',  status);
    if (prog)                sp.set('prog',    prog);
    if (year)                sp.set('year',    year);
    if (session)             sp.set('session', session);
    if (psVal && psVal !== '50') sp.set('size', psVal);
    var qs = sp.toString();
    window.location.href = window.location.pathname + (qs ? '?' + qs : '');
}
function clearFilters() {
    window.location.href = window.location.pathname;
}

// ── Detail modal ─────────────────────────────────────────────────
function openDetail(eno) {
    _currentEno = eno;
    setText('oa-modal-title', 'Application — ' + eno);
    document.getElementById('oa-status-row').innerHTML =
        '<div style="padding:10px 18px;color:#174DA4;font-size:12px;">Loading…</div>';
    clearDetailFields();
    document.getElementById('oa-modal-actions').innerHTML = '';
    document.getElementById('d-docs').innerHTML = '<li style="color:#aaa;">Loading…</li>';
    document.getElementById('oa-modal-bg').classList.add('open');
    switchTabById('tab-personal');

    fetch(_pageUrl + '?ajax=detail&eno=' + encodeURIComponent(eno))
        .then(function (r) {
            if (r.status === 403) {
                document.getElementById('oa-status-row').innerHTML =
                    '<div style="padding:10px 18px;color:#c62828;font-size:12px;">&#9888; Your session has expired. '
                  + '<a href="' + window.location.href + '" style="color:#c62828;font-weight:700;text-decoration:underline;">Reload the page</a> to continue.</div>';
                return null;
            }
            return r.json();
        })
        .then(function (d) {
            if (!d) return;
            if (!d.ok) {
                var msg = d.error === 'session_expired'
                    ? 'Session expired — reload the page to continue.'
                    : (d.error || 'Failed to load detail.');
                document.getElementById('oa-status-row').innerHTML =
                    '<div style="padding:10px 18px;color:#c62828;font-size:12px;">&#9888; ' + h(msg) + '</div>';
                return;
            }
            _currentDetail = d;
            populateDetail(d);
        })
        .catch(function () {
            document.getElementById('oa-status-row').innerHTML =
                '<div style="padding:10px 18px;color:#c62828;">Failed to load application detail. Check your connection and try again.</div>';
        });
}

function closeModal() {
    document.getElementById('oa-modal-bg').classList.remove('open');
    _currentEno = null;
    _currentDetail = null;
}
document.getElementById('oa-modal-bg').addEventListener('click', function (e) {
    if (e.target === this) closeModal();
});
document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeModal();
});

function clearDetailFields() {
    var ids = ['d-eno','d-name','d-email','d-phone','d-dob','d-gender','d-nationality','d-natid',
               'd-religion','d-marital','d-disability','d-address',
               'd-oschool','d-oidx','d-oyr','d-oagg','d-aschool','d-aidx','d-ayr','d-apts',
               'd-oinst','d-oqual','d-oqyr','d-oqgr',
               'd-prog','d-session','d-campus','d-intake','d-sponsor','d-year',
               'd-emname','d-emrel','d-emphone'];
    for (var i = 0; i < ids.length; i++) {
        var el = document.getElementById(ids[i]);
        if (el) el.textContent = '—';
    }
    var notes = document.getElementById('d-notes');
    if (notes) notes.value = '';
}

function populateDetail(d) {
    setText('d-eno',        d.eno);
    setText('d-name',       d.name);
    setText('d-email',      d.email);
    setText('d-phone',      d.phone);
    setText('d-dob',        d.dob);
    setText('d-gender',     d.gender);
    setText('d-nationality',d.nationality);
    setText('d-natid',      d.natid);
    setText('d-religion',   d.religion);
    setText('d-marital',    d.marital);
    setText('d-disability', d.disability);
    setText('d-address',    d.address);
    setText('d-oschool',    d.olevel_school);
    setText('d-oidx',       d.olevel_index);
    setText('d-oyr',        d.olevel_year);
    setText('d-oagg',       d.olevel_agg);
    setText('d-aschool',    d.alevel_school);
    setText('d-aidx',       d.alevel_index);
    setText('d-ayr',        d.alevel_year);
    setText('d-apts',       d.alevel_points);
    setText('d-oinst',      d.other_inst);
    setText('d-oqual',      d.other_qual);
    setText('d-oqyr',       d.other_year);
    setText('d-oqgr',       d.other_grade);
    setText('d-prog',       d.programme);
    setText('d-session',    d.session);
    setText('d-campus',     d.campus);
    setText('d-intake',     d.intake);
    setText('d-sponsor',    d.sponsor);
    setText('d-year',       d.entry_year);
    setText('d-emname',     d.emerg_name);
    setText('d-emrel',      d.emerg_rel);
    setText('d-emphone',    d.emerg_phone);

    var notes = document.getElementById('d-notes');
    if (notes) notes.value = d.reviewer_notes || '';

    var sclass = (d.status === 'SUBMITTED' || d.status === 'UNDER_REVIEW') ? 'oa-warn-row' : '';
    document.getElementById('oa-status-row').innerHTML =
        '<div class="oa-info-row ' + sclass + '" style="margin:10px 18px 0;">'
      + '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">'
      + '<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>'
      + '&nbsp;Status: ' + statusBadge(d.status)
      + (d.submitted_at ? '&nbsp;&nbsp;|&nbsp;&nbsp;Submitted: <strong>' + h(d.submitted_at) + '</strong>' : '')
      + (d.updated_at   ? '&nbsp;&nbsp;|&nbsp;&nbsp;Updated: <strong>'   + h(d.updated_at)   + '</strong>' : '')
      + '</div>';

    setText('oa-modal-title', h(d.name) + ' — ' + h(d.eno));

    // Documents
    var docHtml = '';
    if (d.docs && d.docs.length) {
        for (var i = 0; i < d.docs.length; i++) {
            var doc = d.docs[i];
            docHtml += '<li>';
            docHtml += '<div class="oa-doc-icon"><svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>';
            docHtml += '<span class="oa-doc-label">' + h(doc.label) + '</span>';
            docHtml += '<span class="oa-doc-file">' + h(doc.filename) + '</span>';
            docHtml += '</li>';
        }
    } else {
        docHtml = '<li style="color:#aaa;font-size:11px;">No documents uploaded yet.</li>';
    }
    document.getElementById('d-docs').innerHTML = docHtml;

    buildModalActions(d);
}

function buildModalActions(d) {
    var acts = document.getElementById('oa-modal-actions');
    acts.innerHTML = '';

    if (d.status === 'SUBMITTED') {
        acts.innerHTML +=
            '<button type="button" class="oa-btn oa-btn--amber" onclick="moveToReview(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + 'Mark Under Review</button>';
    }
    if (d.status === 'SUBMITTED' || d.status === 'UNDER_REVIEW') {
        acts.innerHTML +=
            '<button type="button" class="oa-btn oa-btn--danger" onclick="rejectOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>'
          + ' Reject</button>'
          + '<button type="button" class="oa-btn oa-btn--amber" onclick="admitOne(\'' + escJ(d.eno) + '\',\'' + escJ(d.name) + '\')">'
          + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>'
          + ' Admit</button>';
    }
    if (d.status === 'ADMITTED') {
        acts.innerHTML +=
            '<a href="AdmissionsController.aspx?q=' + encodeURIComponent(d.eno) + '" class="oa-btn oa-btn--primary" target="_blank">'
          + 'Open in Admissions Controller</a>';
    }
    acts.innerHTML +=
        '<button type="button" class="oa-btn oa-btn--ghost" onclick="saveNotes()">'
      + '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>'
      + ' Save Notes</button>';
}

// ── Actions ──────────────────────────────────────────────────────
function moveToReview(eno, name) {
    if (!confirm('Mark ' + name + ' (' + eno + ') as Under Review?')) return;
    postAction('review', eno, {}, function () {
        showToast('✓ ' + name + ' moved to Under Review.', true);
        setTimeout(function () { window.location.reload(); }, 1200);
    });
}

function admitOne(eno, name) {
    if (!confirm('Admit ' + name + ' (' + eno + ')?\n\nThis will mark the application as ADMITTED and also update the admissions record.')) return;
    postAction('admit', eno, {}, function () {
        showToast('✓ ' + name + ' admitted successfully.', true);
        setTimeout(function () { window.location.reload(); }, 1200);
    });
}

function rejectOne(eno, name) {
    var reason = prompt('Reason for rejecting the application of ' + name + ':');
    if (reason === null) return;
    if (!reason.trim()) { alert('A reason is required.'); return; }
    postAction('reject', eno, { reason: reason }, function () {
        showToast('✓ Application rejected.', true);
        setTimeout(function () { window.location.reload(); }, 1200);
    });
}

function saveNotes() {
    if (!_currentEno) return;
    var notesEl = document.getElementById('d-notes');
    var notes = notesEl ? notesEl.value || '' : '';
    postAction('note', _currentEno, { notes: notes }, function () {
        showToast('✓ Notes saved.', true);
    });
}

// ── Generic POST ─────────────────────────────────────────────────
function postAction(action, eno, extra, onOk, onErr) {
    var payload = { eno: eno };
    var keys = Object.keys(extra);
    for (var i = 0; i < keys.length; i++) payload[keys[i]] = extra[keys[i]];
    fetch(_pageUrl + '?ajax=' + action, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
    .then(function (r) {
        if (r.status === 403) {
            showToast('✗ Session expired — please reload the page.', false);
            return null;
        }
        return r.json();
    })
    .then(function (d) {
        if (!d) return;
        if (!d.ok) { showToast('✗ ' + (d.error === 'session_expired' ? 'Session expired — reload the page.' : (d.error || 'Action failed.')), false); if (onErr) onErr(d.error); return; }
        if (onOk) onOk(d);
    })
    .catch(function (e) {
        showToast('✗ Network error — check your connection.', false);
        if (onErr) onErr(e);
    });
}

// ── Status badge (used in modal status row) ───────────────────────
function statusBadge(s) {
    var map = {
        DRAFT:        'oa-badge--draft',
        SUBMITTED:    'oa-badge--submitted',
        UNDER_REVIEW: 'oa-badge--under_review',
        ADMITTED:     'oa-badge--admitted',
        REJECTED:     'oa-badge--rejected',
        WITHDRAWN:    'oa-badge--withdrawn'
    };
    var label = (s === 'UNDER_REVIEW') ? 'Under Review' : (s || '—');
    return '<span class="oa-badge ' + (map[s] || '') + '">' + h(label) + '</span>';
}

// ── Tabs ─────────────────────────────────────────────────────────
function switchTab(btn, panelId) {
    var tabs   = document.querySelectorAll('.oa-modal__tab');
    var panels = document.querySelectorAll('.oa-tab-panel');
    for (var i = 0; i < tabs.length;   i++) tabs[i].classList.remove('active');
    for (var j = 0; j < panels.length; j++) panels[j].classList.remove('active');
    btn.classList.add('active');
    var panel = document.getElementById(panelId);
    if (panel) panel.classList.add('active');
}
function switchTabById(panelId) {
    var tabs   = document.querySelectorAll('.oa-modal__tab');
    var panels = document.querySelectorAll('.oa-tab-panel');
    for (var i = 0; i < tabs.length;   i++) tabs[i].classList.remove('active');
    for (var j = 0; j < panels.length; j++) panels[j].classList.remove('active');
    if (tabs.length)   tabs[0].classList.add('active');
    var panel = document.getElementById(panelId);
    if (panel) panel.classList.add('active');
    else if (panels.length) panels[0].classList.add('active');
}

// ── Helpers ──────────────────────────────────────────────────────
function showToast(msg, ok) {
    var t = document.getElementById('oa-toast');
    t.textContent = msg;
    t.className   = 'oa-toast show ' + (ok ? 'oa-toast--ok' : 'oa-toast--err');
    clearTimeout(t._tmr);
    t._tmr = setTimeout(function () { t.className = 'oa-toast'; }, 5000);
}
function setText(id, val) {
    var el = document.getElementById(id);
    if (el) el.textContent = (val !== null && val !== undefined && String(val).length) ? val : '—';
}
function fmtN(n) { return (parseInt(n, 10) || 0).toLocaleString(); }
function h(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function escJ(s) { return String(s || '').replace(/\\/g,'\\\\').replace(/'/g,"\\'"); }
</script>

</asp:Content>
