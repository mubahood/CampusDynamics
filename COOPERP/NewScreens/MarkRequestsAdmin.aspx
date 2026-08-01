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
.mra-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;height:28px;padding:0 8px;border-radius:0;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;white-space:nowrap;text-decoration:none}
.mra-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff}
.mra-btn[disabled]{opacity:.55;cursor:not-allowed}
.mra-btn--primary{background:#05275C;color:#fff;border-color:#05275C}
.mra-btn--primary:hover{background:#174DA4;color:#fff;border-color:#174DA4}
.mra-btn--danger{background:#b42318;color:#fff;border-color:#b42318}
.mra-btn--danger:hover{background:#8e1c15;color:#fff;border-color:#8e1c15}
.mra-btn--warn{background:#92400e;color:#fff;border-color:#92400e}
.mra-btn--warn:hover{background:#78350f;color:#fff;border-color:#78350f}
.mra-btn--cur{background:#05275C;color:#fff;border-color:#05275C;cursor:default}
.mra-btn--cur:hover{background:#05275C;color:#fff;border-color:#05275C}
.mra-btn--sm{height:24px;padding:0 6px;font-size:9px}
.mra-grid{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:8px;margin-bottom:8px}
.mra-stat{background:#fff;border:1px solid #e3e9f2;border-radius:0;padding:7px 8px;min-height:74px;display:flex;flex-direction:column;justify-content:center;gap:4px;min-width:0}
.mra-stat__lbl{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800}
.mra-stat__val{font-size:22px;color:#05275C;line-height:1;font-weight:900;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.mra-stat__sub{font-size:10px;color:#6b7280}
.mra-batch-bar{display:none;padding:6px 8px;background:#ede9fe;border-bottom:1px solid #c4b5fd;align-items:center;gap:8px;flex-wrap:wrap}
.mra-batch-bar.show{display:flex}
.mra-batch-bar__label{font-size:11px;font-weight:800;color:#5b21b6;flex:1}
.mra-head-tools{display:flex;align-items:center;gap:6px;flex-wrap:wrap}
.mra-qs-input{height:28px;border:1px solid #cdd8e6;border-radius:0;background:#fff;padding:4px 6px;font-size:11px;color:#1f2937;font-family:inherit;width:180px}
.mra-qs-input:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12)}
.mra-table-wrap{overflow-x:auto;overflow-y:hidden;background:#fff;max-width:100%}
.mra-table{width:100%;min-width:980px;border-collapse:collapse;table-layout:fixed}
.mra-table th{background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;padding:6px;text-align:left;white-space:normal;word-break:break-word}
.mra-table td{border-bottom:1px solid #eef2f6;font-size:10px;color:#1f2937;padding:6px;vertical-align:top;word-break:break-word;overflow-wrap:anywhere}
.mra-table tbody tr:last-child td{border-bottom:none}
.mra-chk{width:13px;height:13px;cursor:pointer;accent-color:#05275C}
.mra-pill{display:inline-block;padding:2px 6px;border-radius:0;font-size:9px;font-weight:900;letter-spacing:.35px;text-transform:uppercase}
.mra-pill--PENDING_LECTURER{background:#fef3c7;color:#92400e}
.mra-pill--PENDING_SUPERVISOR{background:#e0f2fe;color:#0c4a6e}
.mra-pill--PENDING_ADMIN{background:#ede9fe;color:#5b21b6}
.mra-pill--APPROVED{background:#e6f4ea;color:#2e7d32}
.mra-pill--REJECTED{background:#fee2e2;color:#b42318}
.mra-pill--CANCELLED{background:#f3f4f6;color:#374151}
.mra-chip{display:inline-block;padding:2px 5px;border-radius:0;font-size:9px;font-weight:800;letter-spacing:.3px;text-transform:uppercase}
.mra-chip--change{background:#fef3c7;color:#92400e}
.mra-chip--missing{background:#fee2e2;color:#b42318}
.mra-note{font-size:10px;color:#6b7280;line-height:1.35}
.mra-strong{font-weight:800;color:#05275C}
.mra-code{font-family:monospace;font-size:10px;color:#374151}
.mra-lec-badge{display:inline-block;padding:1px 6px;border-radius:2px;font-size:8px;font-weight:800;letter-spacing:.3px;text-transform:uppercase;background:#eef1f6;color:#64748b}
.mra-lec-badge--assigned{background:#eaf1fc;color:#174DA4}
/* detail + lecturer overlays */
.mrx-ovl{position:fixed;inset:0;background:rgba(10,20,40,.5);z-index:100000;display:none;align-items:center;justify-content:center;padding:20px}
.mrx-ovl.open{display:flex}
.mrx-modal{background:#fff;width:560px;max-width:96vw;max-height:90vh;display:flex;flex-direction:column;border-radius:4px;box-shadow:0 16px 48px rgba(0,0,0,.3);overflow:visible}
.mrx-modal--wide{width:640px}
.mrx-hd{display:flex;align-items:center;justify-content:space-between;padding:13px 18px;border-bottom:1px solid #e5e7eb;font-weight:800;color:#05275C;font-size:14px}
.mrx-x{background:none;border:none;font-size:22px;line-height:1;color:#888;cursor:pointer}
.mrx-bd{padding:16px 18px;overflow-y:auto}
.mrx-ft{padding:12px 18px;border-top:1px solid #e5e7eb;display:flex;justify-content:flex-end;gap:8px}
.mrx-sec{margin-bottom:14px}
.mrx-sec__t{font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:#05275C;margin-bottom:6px;display:flex;align-items:center;justify-content:space-between}
.mrx-kv{display:grid;grid-template-columns:130px 1fr;gap:5px 10px;font-size:12px}
.mrx-kv .k{color:#64748b}
.mrx-kv .v{color:#1a1a2e;font-weight:500;word-break:break-word}
.mrx-quote{background:#f8fafc;border-left:3px solid #cbd5e1;padding:8px 10px;font-size:12px;color:#334155;border-radius:2px;margin-bottom:6px}
.mrx-btn{padding:8px 14px;font-size:12px;font-weight:600;border:1px solid #cdd5e1;background:#fff;color:#05275C;border-radius:4px;cursor:pointer}
.mrx-btn--primary{background:#05275C;color:#fff;border-color:#05275C}
.lc-opt:hover{background:#eef4fd !important}
.mra-action-wrap{display:flex;gap:3px;justify-content:flex-end;flex-wrap:wrap}
.mra-menu-wrap{position:relative;display:inline-block;}
.mra-menu{display:none;position:absolute;right:0;top:100%;min-width:130px;background:#fff;border:1px solid #d5dce8;box-shadow:0 4px 16px rgba(5,39,92,.13);z-index:200;margin-top:1px;}
.mra-menu.open{display:block;}
.mra-menu-item{display:block;width:100%;text-align:left;padding:7px 10px;border:none;border-bottom:1px solid #f1f5f9;background:none;font-size:10px;font-weight:700;color:#1f2937;cursor:pointer;white-space:nowrap;font-family:inherit;}
.mra-menu-item:last-child{border-bottom:none;}
.mra-menu-item:hover{background:#f4f8ff;color:#174DA4;}
.mra-menu-item--danger{color:#b42318;}
.mra-menu-item--danger:hover{background:#fef2f2;color:#b42318;}
.mra-menu-item--warn{color:#92400e;}
.mra-menu-item--warn:hover{background:#fffbeb;color:#92400e;}
.mra-marks-compare{display:flex;gap:4px}
.mra-mark-box{border:1px solid #e3e9f2;padding:4px 5px;min-width:56px;flex:1}
.mra-mark-box__lbl{font-size:8px;text-transform:uppercase;letter-spacing:.3px;color:#94a3b8;font-weight:800;margin-bottom:2px}
.mra-mark-box__row{font-size:9px;color:#374151;line-height:1.4}
.mra-mark-box__row span{font-weight:800;color:#05275C}
.mra-trail-quote{font-size:10px;color:#374151;border-left:2px solid #e3e9f2;padding-left:5px;margin-bottom:3px;line-height:1.35}
.mra-trail-resp{font-size:9px;color:#64748b;line-height:1.35;margin-bottom:2px}
.mra-trail-actors{font-size:9px;color:#94a3b8;margin-top:3px}
.mra-pager{display:flex;align-items:center;justify-content:space-between;padding:8px 10px;border-top:1px solid #e3e9f2;background:#fafbfc;font-size:11px;color:#64748b;flex-wrap:wrap;gap:6px}
.mra-pager__nav{display:flex;gap:4px;flex-wrap:wrap}
/* Modal */
.mra-modal{position:fixed;inset:0;background:rgba(5,39,92,.35);display:none;align-items:center;justify-content:center;padding:12px;z-index:9999}
.mra-modal.show{display:flex}
.mra-modal__panel{width:100%;max-width:480px;background:#fff;border:1px solid #d5dce8;border-radius:0}
.mra-modal__head{padding:8px;border-bottom:1px solid #e8edf5;display:flex;justify-content:space-between;align-items:center;gap:8px}
.mra-modal__title{font-size:11px;font-weight:900;letter-spacing:.4px;text-transform:uppercase;color:#05275C}
.mra-modal__body{padding:8px;display:flex;flex-direction:column;gap:6px}
.mra-modal__hint{font-size:10px;color:#64748b;line-height:1.4}
.mra-modal__ctx{background:#f8fafc;border:1px solid #e3e9f2;padding:6px;font-size:10px;color:#374151;line-height:1.4}
.mra-modal__marks{display:none;border:1px solid #e5eaf3;padding:6px}
.mra-modal__marks.show{display:block}
.mra-modal__marks-hint{font-size:9px;color:#64748b;margin-bottom:5px}
.mra-modal__status{border:1px solid #e5eaf3;padding:8px;margin-bottom:8px}
.mra-modal__slabel{display:block;font-size:9px;color:#64748b;margin:6px 0 3px;text-transform:uppercase;letter-spacing:.4px}
.mra-modal__select{width:100%;padding:7px 8px;font-size:12px;border:1px solid #cdd5e1;background:#fff}
.mra-modal__warn{margin-top:8px;padding:8px 10px;font-size:11px;line-height:1.5;background:#fff7ed;border:1px solid #fed7aa;color:#9a3412}
.mra-modal__warn.danger{background:#fef2f2;border-color:#fecaca;color:#991b1b}
.mra-modal__warn.info{background:#eff6ff;border-color:#bfdbfe;color:#1e40af}
.mra-modal__grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:6px}
.mra-modal__mark{display:flex;flex-direction:column;gap:3px}
.mra-modal__mark label{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800}
.mra-modal__mark input{height:28px;border:1px solid #cdd8e6;border-radius:0;padding:4px 6px;font-size:11px;color:#1f2937;font-family:inherit;width:100%;min-width:0}
.mra-modal__mark input:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12)}
.mra-modal__mark--total input{background:#f8fafc;color:#05275C;font-weight:800}
.mra-modal__textarea{min-height:80px;resize:vertical;border:1px solid #cdd8e6;border-radius:0;padding:6px;font-size:11px;color:#1f2937;font-family:inherit;width:100%}
.mra-modal__textarea:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12)}
.mra-modal__foot{padding:8px;border-top:1px solid #e8edf5;display:flex;justify-content:flex-end;gap:6px;flex-wrap:wrap}
.mra-modal__error{display:none;border:1px solid #fecaca;background:#fef2f2;color:#b42318;padding:6px;font-size:10px}
.mra-modal__error.show{display:block}
.mra-modal__ok{display:none;border:1px solid #bbf7d0;background:#f0fdf4;color:#166534;padding:6px;font-size:10px}
.mra-modal__ok.show{display:block}
@media (max-width:1250px){.mra-grid{grid-template-columns:repeat(3,minmax(0,1fr));}.mra-filters{grid-template-columns:repeat(3,minmax(0,1fr));}.mra-fg--search{grid-column:span 3;}}
@media (max-width:900px){.mra-grid{grid-template-columns:repeat(2,minmax(0,1fr));}.mra-filters{grid-template-columns:repeat(2,minmax(0,1fr));}.mra-fg--search{grid-column:span 2;}}
@media (max-width:640px){.mra-grid,.mra-filters,.mra-modal__grid{grid-template-columns:1fr;}.mra-fg--search{grid-column:span 1;}.mra-head{align-items:flex-start}.mra-action-wrap{justify-content:flex-start}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="mra-wrap">
    <div id="mraGlobalError" class="mra-error"></div>

    <!-- Filter card -->
    <div class="mra-card">
        <div class="mra-head">
            <div>
                <div class="mra-title">Mark Requests &mdash; Admin Controller</div>
                <div class="mra-sub">Full visibility + intervention controls (approve, reject, reopen, push, force close).</div>
            </div>
            <div class="mra-actions">
                <button type="button" class="mra-btn mra-btn--primary" onclick="applyFilters()">Apply</button>
                <button type="button" class="mra-btn" onclick="clearFilters()">Reset</button>
            </div>
        </div>
        <div class="mra-filters">
            <div class="mra-fg">
                <label>Academic Year</label>
                <select id="mraYear" class="mra-select">
                    <option value="">All Years</option>
                    <asp:Literal ID="litYearOpts" runat="server"/>
                </select>
            </div>
            <div class="mra-fg">
                <label>Semester</label>
                <select id="mraSemester" class="mra-select">
                    <option value="">All</option>
                    <option value="1"<%= Sel(FilterSem,"1") %>>Sem 1</option>
                    <option value="2"<%= Sel(FilterSem,"2") %>>Sem 2</option>
                    <option value="3"<%= Sel(FilterSem,"3") %>>Sem 3</option>
                </select>
            </div>
            <div class="mra-fg">
                <label>Type</label>
                <select id="mraType" class="mra-select">
                    <option value=""<%= Sel(FilterType,"") %>>All Types</option>
                    <option value="MARK_CHANGE"<%= Sel(FilterType,"MARK_CHANGE") %>>Mark Change</option>
                    <option value="MISSING_MARK"<%= Sel(FilterType,"MISSING_MARK") %>>Missing Mark</option>
                </select>
            </div>
            <div class="mra-fg">
                <label>Status</label>
                <select id="mraStatus" class="mra-select">
                    <option value="ALL"<%= string.IsNullOrEmpty(FilterStatus) ? " selected" : "" %>>All Statuses</option>
                    <option value="PENDING_LECTURER"<%= Sel(FilterStatus,"PENDING_LECTURER") %>>Pending Lecturer</option>
                    <option value="PENDING_SUPERVISOR"<%= Sel(FilterStatus,"PENDING_SUPERVISOR") %>>Pending Supervisor</option>
                    <option value="PENDING_ADMIN"<%= Sel(FilterStatus,"PENDING_ADMIN") %>>Pending Admin</option>
                    <option value="APPROVED"<%= Sel(FilterStatus,"APPROVED") %>>Approved</option>
                    <option value="REJECTED"<%= Sel(FilterStatus,"REJECTED") %>>Rejected</option>
                    <option value="CANCELLED"<%= Sel(FilterStatus,"CANCELLED") %>>Cancelled</option>
                </select>
            </div>
            <div class="mra-fg mra-fg--search">
                <label>Search</label>
                <input type="text" id="mraSearch" class="mra-input" placeholder="Reg no, name, course..."
                       value="<%= HE(FilterQ) %>"
                       onkeydown="if(event.key==='Enter'){event.preventDefault();applyFilters();}"/>
            </div>
        </div>
    </div>

    <!-- Stats row (server-rendered) -->
    <asp:Literal ID="litStats" runat="server"/>

    <!-- Requests table card -->
    <div class="mra-card">
        <div class="mra-head">
            <div class="mra-title">Requests</div>
            <div class="mra-head-tools">
                <span class="mra-sub"><asp:Literal ID="litCount" runat="server" Text="0"/> records</span>
                <input type="text" id="mraQs" class="mra-qs-input" placeholder="Quick search this page..." oninput="applyQs()"/>
                <select id="mraSize" class="mra-select" style="width:auto;min-width:95px;" onchange="applyFilters()">
                    <option value="25"<%= Sel(FilterSize.ToString(),"25") %>>25 / page</option>
                    <option value="50"<%= Sel(FilterSize.ToString(),"50") %>>50 / page</option>
                    <option value="100"<%= Sel(FilterSize.ToString(),"100") %>>100 / page</option>
                    <option value="200"<%= Sel(FilterSize.ToString(),"200") %>>200 / page</option>
                </select>
                <button type="button" class="mra-btn" onclick="window.location.reload()">Refresh</button>
            </div>
        </div>

        <!-- Batch action bar -->
        <div class="mra-batch-bar" id="mraBatchBar">
            <span class="mra-batch-bar__label" id="mraBatchCount">0 selected</span>
            <button type="button" class="mra-btn mra-btn--primary mra-btn--sm" onclick="openBatchModal('approve')">Approve Selected</button>
            <button type="button" class="mra-btn mra-btn--sm" onclick="openBatchModal('reject')">Reject Selected</button>
            <button type="button" class="mra-btn mra-btn--danger mra-btn--sm" onclick="openBatchModal('force')">Force Close</button>
            <button type="button" class="mra-btn mra-btn--sm" onclick="clearSelection()">Clear Selection</button>
        </div>

        <div class="mra-table-wrap">
            <table class="mra-table" id="mraTable">
                <thead>
                    <tr>
                        <th style="width:28px;text-align:center;"><input type="checkbox" class="mra-chk" id="mraSelectAll" onclick="selectAll(this)" title="Select all"/></th>
                        <th style="width:38px;">ID</th>
                        <th style="width:160px;">Student</th>
                        <th style="width:155px;">Course</th>
                        <th style="width:130px;">Lecturer</th>
                        <th style="width:95px;">Type / Status</th>
                        <th style="width:130px;">Marks</th>
                        <th>Trail</th>
                        <th style="width:170px;text-align:right;">Actions</th>
                    </tr>
                </thead>
                <tbody id="mraRows">
                    <asp:Literal ID="litRows" runat="server"/>
                </tbody>
            </table>
        </div>
        <asp:Literal ID="litPager" runat="server"/>
    </div>

    <!-- Action modal -->
    <div class="mra-modal" id="mraModal" aria-hidden="true">
        <div class="mra-modal__panel" role="dialog" aria-modal="true" aria-labelledby="mraModalTitle">
            <div class="mra-modal__head">
                <div class="mra-modal__title" id="mraModalTitle">Action</div>
                <button type="button" class="mra-btn" id="mraModalClose">Close</button>
            </div>
            <div class="mra-modal__body">
                <div class="mra-modal__hint" id="mraModalHint"></div>
                <div class="mra-modal__ctx" id="mraModalCtx" style="display:none;"></div>
                <div class="mra-modal__marks" id="mraApproveMarks">
                    <div class="mra-modal__marks-hint">Adjust marks before approval (optional). Leave blank to keep existing proposed marks.</div>
                    <div class="mra-modal__grid">
                        <div class="mra-modal__mark">
                            <label>CW (0&ndash;40)</label>
                            <input type="number" id="mraApproveCw" min="0" max="40" placeholder="CW"/>
                        </div>
                        <div class="mra-modal__mark">
                            <label>Exam (0&ndash;60)</label>
                            <input type="number" id="mraApproveExam" min="0" max="60" placeholder="Exam"/>
                        </div>
                        <div class="mra-modal__mark mra-modal__mark--total">
                            <label>Total</label>
                            <input type="number" id="mraApproveTotal" readonly="readonly" placeholder="Auto"/>
                        </div>
                    </div>
                </div>
                <div class="mra-modal__status" id="mraStatusWrap" style="display:none;">
                    <div class="mra-modal__marks-hint">Current status: <b id="mraCurStatus">—</b></div>
                    <label class="mra-modal__slabel" for="mraStatusSelect">Change status to</label>
                    <select id="mraStatusSelect" class="mra-modal__select">
                        <option value="PENDING_LECTURER">Pending Lecturer</option>
                        <option value="PENDING_SUPERVISOR">Pending Supervisor</option>
                        <option value="PENDING_ADMIN">Pending Admin</option>
                        <option value="APPROVED">Approved</option>
                        <option value="REJECTED">Rejected</option>
                        <option value="CANCELLED">Cancelled</option>
                    </select>
                    <div class="mra-modal__warn" id="mraStatusWarn" style="display:none;"></div>
                </div>
                <textarea id="mraModalNote" class="mra-modal__textarea" placeholder="Enter note..."></textarea>
                <div class="mra-modal__error" id="mraModalError"></div>
                <div class="mra-modal__ok" id="mraModalOk"></div>
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
function num(v){var n=parseInt(v,10);return isNaN(n)?0:n;}

// ── Modal state ───────────────────────────────────────────────────────────────
var modalState={action:'',requestId:0,isBatch:false,batchIds:[]};

// ── Filter navigation (GET-based) ─────────────────────────────────────────────
function applyFilters(){
    var sp=new URLSearchParams();
    var year   =byId('mraYear').value;
    var sem    =byId('mraSemester').value;
    var type   =byId('mraType').value;
    var status =byId('mraStatus').value;
    var q      =(byId('mraSearch').value||'').trim();
    var size   =byId('mraSize').value;
    if(year)   sp.set('year',   year);
    if(sem)    sp.set('sem',    sem);
    if(type)   sp.set('type',   type);
    if(status) sp.set('status', status);
    if(q)      sp.set('q',      q);
    if(size && size!=='50') sp.set('size', size);
    var qs=sp.toString();
    window.location.href=window.location.pathname+(qs?'?'+qs:'');
}
function clearFilters(){
    window.location.href=window.location.pathname;
}

// ── Quick search (client-side, filters visible rows) ─────────────────────────
function applyQs(){
    var qs=(byId('mraQs').value||'').trim().toLowerCase();
    var rows=document.querySelectorAll('#mraRows tr[data-search]');
    for(var i=0;i<rows.length;i++){
        var ds=(rows[i].getAttribute('data-search')||'').toLowerCase();
        rows[i].style.display=(!qs||ds.indexOf(qs)>=0)?'':'none';
    }
}

// ── Checkbox / batch selection ────────────────────────────────────────────────
function getSelectedIds(){
    var chks=document.querySelectorAll('.mra-row-chk:checked');
    var ids=[];
    for(var i=0;i<chks.length;i++) ids.push(num(chks[i].value));
    return ids.filter(function(x){return x>0;});
}
function onChkChange(){
    var ids=getSelectedIds();
    var n=ids.length;
    var bar=byId('mraBatchBar');
    var lbl=byId('mraBatchCount');
    if(bar) bar.className='mra-batch-bar'+(n>0?' show':'');
    if(lbl) lbl.textContent=n+' selected';
    // update select-all indeterminate state
    var all=byId('mraSelectAll');
    if(!all) return;
    var total=document.querySelectorAll('.mra-row-chk').length;
    all.indeterminate=(n>0&&n<total);
    all.checked=(n>0&&n===total);
}
function selectAll(el){
    var chks=document.querySelectorAll('.mra-row-chk');
    for(var i=0;i<chks.length;i++) chks[i].checked=el.checked;
    onChkChange();
}
function clearSelection(){
    var chks=document.querySelectorAll('.mra-row-chk');
    for(var i=0;i<chks.length;i++) chks[i].checked=false;
    var all=byId('mraSelectAll');
    if(all){all.checked=false;all.indeterminate=false;}
    onChkChange();
}

// ── Dropdown menus ─────────────────────────────────────────────────────────────
function closeAllMenus(){
    var menus=document.querySelectorAll('.mra-menu.open');
    for(var i=0;i<menus.length;i++) menus[i].className='mra-menu';
}
function toggleMenu(wrapId){
    var wrap=byId(wrapId);
    if(!wrap) return;
    var menu=wrap.querySelector('.mra-menu');
    if(!menu) return;
    var isOpen=menu.className.indexOf('open')>=0;
    closeAllMenus();
    if(!isOpen) menu.className='mra-menu open';
}

// ── Mark helpers ──────────────────────────────────────────────────────────────
function parseMarkOrNull(v){
    if(v===null||v===undefined)return null;
    var s=String(v).trim();
    if(s==='')return null;
    var n=parseInt(s,10);
    return isNaN(n)?null:n;
}
function calcTotal(){
    var cw=parseMarkOrNull(byId('mraApproveCw').value);
    var ex=parseMarkOrNull(byId('mraApproveExam').value);
    var tot=byId('mraApproveTotal');
    if(!tot)return;
    tot.value=(cw!==null&&ex!==null)?String(cw+ex):'';
}

// ── Modal helpers ─────────────────────────────────────────────────────────────
function modalError(msg){
    var e=byId('mraModalError');
    if(!e)return;
    if(msg){e.textContent=msg;e.className='mra-modal__error show';}
    else{e.textContent='';e.className='mra-modal__error';}
}
function modalOk(msg){
    var e=byId('mraModalOk');
    if(!e)return;
    if(msg){e.textContent=msg;e.className='mra-modal__ok show';}
    else{e.textContent='';e.className='mra-modal__ok';}
}

// ── Status-change helpers ─────────────────────────────────────────────────────
function prettyStatus(s){
    var m={PENDING_LECTURER:'Pending Lecturer',PENDING_SUPERVISOR:'Pending Supervisor',PENDING_ADMIN:'Pending Admin',APPROVED:'Approved',REJECTED:'Rejected',CANCELLED:'Cancelled'};
    return m[(s||'').toUpperCase()]||s||'—';
}
function defaultTarget(cur){
    cur=(cur||'').toUpperCase();
    if(cur==='APPROVED')return 'PENDING_ADMIN';
    if(cur==='PENDING_ADMIN')return 'APPROVED';
    return 'PENDING_ADMIN';
}
function updateStatusWarn(cur){
    var sel=byId('mraStatusSelect'),warn=byId('mraStatusWarn');
    if(!sel||!warn)return;
    cur=(cur||'').toUpperCase();
    var tgt=sel.value,html='',cls='info';
    if(tgt===cur){html='This is already the current status — pick a different one.';cls='danger';}
    else if(tgt==='APPROVED'){html='<b>Approving:</b> the proposed marks will be published to the student’s results and GPA/CGPA recalculated.';cls='info';}
    else if(cur==='APPROVED'){html='<b>Heads up:</b> this request is <b>Approved</b> and its mark is live. Changing it will <b>auto-revert the published mark</b> and recalculate GPA/CGPA.';cls='danger';}
    else{html='Moves this request to <b>'+prettyStatus(tgt)+'</b>. No marks are published or changed.';cls='info';}
    warn.innerHTML=html;warn.className='mra-modal__warn '+cls;warn.style.display='block';
}

// ── Open modal — single item ──────────────────────────────────────────────────
function openModal(action,id){
    modalState.action=action;
    modalState.requestId=num(id);
    modalState.isBatch=false;
    modalState.batchIds=[];
    _showModal(action,id);
}

// ── Open modal — batch ────────────────────────────────────────────────────────
function openBatchModal(action){
    var ids=getSelectedIds();
    if(ids.length===0){alert('Select at least one request first.');return;}
    modalState.action=action;
    modalState.requestId=0;
    modalState.isBatch=true;
    modalState.batchIds=ids;
    _showModal(action,null);
}

// ── Internal: configure and show modal ───────────────────────────────────────
function _showModal(action,id){
    var row=id?document.querySelector('tr[data-id="'+id+'"]'):null;
    var title=byId('mraModalTitle'),hint=byId('mraModalHint'),note=byId('mraModalNote'),submit=byId('mraModalSubmit');
    var ctx=byId('mraModalCtx');
    var marksWrap=byId('mraApproveMarks'),cw=byId('mraApproveCw'),ex=byId('mraApproveExam'),tot=byId('mraApproveTotal');
    if(!title||!hint||!note||!submit)return;

    modalError('');modalOk('');
    note.value='';note.disabled=false;submit.disabled=false;
    if(cw)cw.value='';if(ex)ex.value='';if(tot)tot.value='';
    if(marksWrap)marksWrap.className='mra-modal__marks';
    if(ctx)ctx.style.display='none';
    var statusWrap0=byId('mraStatusWrap'); if(statusWrap0)statusWrap0.style.display='none';

    var isBatch=modalState.isBatch;
    var batchN=isBatch?modalState.batchIds.length:0;

    if(action==='approve'){
        title.textContent=isBatch?('Approve '+batchN+' Requests'):'Approve Request #'+id;
        hint.textContent=isBatch
            ?'All selected requests will be approved. Marks will be published where proposed marks are available.'
            :'This request will be approved and marks published if proposed marks are available.';
        note.placeholder='Optional approval note';
        submit.textContent='Approve';
        submit.className='mra-btn mra-btn--primary';
        if(!isBatch){
            if(marksWrap)marksWrap.className='mra-modal__marks show';
            if(row&&cw){cw.value=row.getAttribute('data-pcw')||row.getAttribute('data-ocw')||'';}
            if(row&&ex){ex.value=row.getAttribute('data-pex')||row.getAttribute('data-oex')||'';}
            calcTotal();
        }
        if(isBatch&&ctx){
            ctx.textContent=batchN+' requests selected for batch approval.';
            ctx.style.display='block';
        }
    } else if(action==='reject'){
        title.textContent=isBatch?('Reject '+batchN+' Requests'):'Reject Request #'+id;
        hint.textContent='Provide a rejection reason (minimum 5 characters). Admin can reject any request regardless of current stage.';
        note.placeholder='Required rejection reason';
        submit.textContent='Reject';
        submit.className='mra-btn mra-btn--danger';
        if(isBatch&&ctx){
            ctx.textContent=batchN+' requests selected for batch rejection.';
            ctx.style.display='block';
        }
    } else if(action==='force'){
        title.textContent=isBatch?('Force Close '+batchN+' Requests'):'Force Close Request #'+id;
        hint.textContent='Provide reason (minimum 5 characters). This overrides workflow state and cancels the request.';
        note.placeholder='Required force-close reason';
        submit.textContent='Force Close';
        submit.className='mra-btn mra-btn--danger';
        if(isBatch&&ctx){
            ctx.textContent=batchN+' requests selected for batch force close.';
            ctx.style.display='block';
        }
    } else if(action==='reopen'){
        title.textContent='Reopen Request #'+id;
        hint.textContent='This will reset the request to PENDING_ADMIN so it can be reviewed again. Provide an optional note.';
        note.placeholder='Optional note';
        submit.textContent='Reopen';
        submit.className='mra-btn mra-btn--primary';
    } else if(action==='marks'){
        title.textContent='Update Marks — Request #'+id;
        hint.textContent='Directly update proposed marks on this request. Status remains unchanged.';
        note.placeholder='Optional note';
        submit.textContent='Update Marks';
        submit.className='mra-btn mra-btn--warn';
        if(marksWrap)marksWrap.className='mra-modal__marks show';
        if(row&&cw){cw.value=row.getAttribute('data-pcw')||row.getAttribute('data-ocw')||'';}
        if(row&&ex){ex.value=row.getAttribute('data-pex')||row.getAttribute('data-oex')||'';}
        calcTotal();
    } else if(action==='status'){
        title.textContent='Change Status — Request #'+id;
        hint.textContent='Set this request to any state. Unusual moves are allowed but flagged below.';
        note.placeholder='Reason for this status change (required)';
        submit.textContent='Change Status';
        submit.className='mra-btn mra-btn--primary';
        var curStatus=(row?row.getAttribute('data-status'):'')||'';
        var sw=byId('mraStatusWrap'),sel=byId('mraStatusSelect'),cur=byId('mraCurStatus');
        if(cur)cur.textContent=prettyStatus(curStatus);
        if(sw)sw.style.display='block';
        if(sel){
            sel.value=defaultTarget(curStatus);
            sel.onchange=function(){updateStatusWarn(curStatus);};
        }
        updateStatusWarn(curStatus);
    }

    if(!isBatch&&row&&ctx&&action!=='approve'){
        var name=row.getAttribute('data-name')||'';
        var rn=row.getAttribute('data-regno')||'';
        var course=row.getAttribute('data-course')||'';
        ctx.textContent='#'+id+' — '+name+(rn?' ('+rn+')':'')+' — '+course;
        ctx.style.display='block';
    }

    var modal=byId('mraModal');
    if(modal){modal.className='mra-modal show';modal.setAttribute('aria-hidden','false');}
    setTimeout(function(){note.focus();},80);
}

// ── Close modal ───────────────────────────────────────────────────────────────
function closeModal(){
    var modal=byId('mraModal');
    if(modal){modal.className='mra-modal';modal.setAttribute('aria-hidden','true');}
    modalState.action='';modalState.requestId=0;modalState.isBatch=false;modalState.batchIds=[];
    modalError('');modalOk('');
}

// ── AJAX helper ───────────────────────────────────────────────────────────────
function ajax(method,payload,done){
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MarkRequestsAdmin.aspx/'+method,true);
    xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
    xhr.onload=function(){
        try{
            var raw=JSON.parse(xhr.responseText);
            var data=(raw&&raw.d!==undefined)?raw.d:raw;
            if(typeof data==='string'){data=JSON.parse(data);}
            done(data||{success:false,message:'Empty response'});
        }catch(ex){done({success:false,message:'Invalid response format.'});}
    };
    xhr.onerror=function(){done({success:false,message:'Network error.'});};
    xhr.send(JSON.stringify(payload||{}));
}

// ── Submit modal action ───────────────────────────────────────────────────────
function submitAction(){
    var action=modalState.action;
    var id=modalState.requestId;
    var isBatch=modalState.isBatch;
    var batchIds=modalState.batchIds;
    var noteEl=byId('mraModalNote'),submit=byId('mraModalSubmit');
    if(!action||!noteEl||!submit){modalError('Invalid action context.');return;}

    var txtVal=(noteEl.value||'').trim();
    var method='',payload={};

    if(isBatch){
        // batch actions
        if(action==='approve'||action==='reject'||action==='force'){
            if((action==='reject'||action==='force')&&txtVal.length<5){
                modalError((action==='reject'?'Rejection':'Force-close')+' reason must be at least 5 characters.');return;
            }
            method='AdminBatch';
            payload={ids:batchIds.join(','),action:action,note:txtVal};
        } else {
            modalError('Unknown batch action.');return;
        }
    } else {
        if(!id){modalError('No request selected.');return;}
        if(action==='approve'){
            var cwVal=parseMarkOrNull(byId('mraApproveCw').value);
            var exVal=parseMarkOrNull(byId('mraApproveExam').value);
            var oneProvided=(cwVal!==null||exVal!==null);
            if(oneProvided&&(cwVal===null||exVal===null)){modalError('Please provide both CW and Exam marks, or leave both blank.');return;}
            if(cwVal!==null&&(cwVal<0||cwVal>40)){modalError('CW mark must be 0–40.');return;}
            if(exVal!==null&&(exVal<0||exVal>60)){modalError('Exam mark must be 0–60.');return;}
            method='AdminApprove';
            payload={requestId:id,note:txtVal,adminProposedCw:cwVal,adminProposedExam:exVal};
        } else if(action==='reject'){
            if(txtVal.length<5){modalError('Rejection reason must be at least 5 characters.');return;}
            method='AdminReject';
            payload={requestId:id,reason:txtVal};
        } else if(action==='force'){
            if(txtVal.length<5){modalError('Force close reason must be at least 5 characters.');return;}
            method='AdminForceClose';
            payload={requestId:id,reason:txtVal};
        } else if(action==='reopen'){
            method='AdminReopen';
            payload={requestId:id,note:txtVal};
        } else if(action==='marks'){
            var cwVal=parseMarkOrNull(byId('mraApproveCw').value);
            var exVal=parseMarkOrNull(byId('mraApproveExam').value);
            if(cwVal!==null&&(cwVal<0||cwVal>40)){modalError('CW mark must be 0–40.');return;}
            if(exVal!==null&&(exVal<0||exVal>60)){modalError('Exam mark must be 0–60.');return;}
            method='AdminUpdateMarks';
            payload={requestId:id,cw:cwVal,exam:exVal,note:txtVal};
        } else if(action==='status'){
            var stSel=byId('mraStatusSelect');
            var tgt=stSel?stSel.value:'';
            if(!tgt){modalError('Pick a target status.');return;}
            if(txtVal.length<3){modalError('Please provide a reason (min 3 characters).');return;}
            method='AdminChangeStatus';
            payload={requestId:id,newStatus:tgt,note:txtVal};
        } else {
            modalError('Unknown action.');return;
        }
    }

    modalError('');
    submit.disabled=true;noteEl.disabled=true;
    var oldTxt=submit.textContent;
    submit.textContent='Processing...';

    ajax(method,payload,function(res){
        submit.disabled=false;noteEl.disabled=false;
        submit.textContent=oldTxt;
        if(!res||!res.success){modalError((res&&res.message)||'Action failed.');return;}
        modalOk((res&&res.message)||'Done.');
        submit.disabled=true;
        setTimeout(function(){closeModal();window.location.reload();},900);
    });
}

// ── Event wiring ──────────────────────────────────────────────────────────────
byId('mraModalClose').onclick=closeModal;
byId('mraModalCancel').onclick=closeModal;
byId('mraModalSubmit').onclick=submitAction;
byId('mraModal').addEventListener('click',function(e){if(e.target&&e.target.id==='mraModal')closeModal();});
byId('mraApproveCw').addEventListener('input',calcTotal);
byId('mraApproveExam').addEventListener('input',calcTotal);
document.addEventListener('keydown',function(e){
    if(e.key==='Escape'){closeModal();}
    if(e.key==='Enter'){
        var m=byId('mraModal');
        if(m&&m.className.indexOf('show')>=0&&document.activeElement!==byId('mraModalNote')){
            e.preventDefault();submitAction();
        }
    }
});
// wire up all row checkboxes (including future ones via delegation)
document.getElementById('mraRows').addEventListener('change',function(e){
    if(e.target&&e.target.classList.contains('mra-row-chk'))onChkChange();
});
// close open dropdown menus on outside click or Escape
document.addEventListener('click',function(e){
    if(!e.target.closest||!e.target.closest('.mra-menu-wrap')) closeAllMenus();
});
document.addEventListener('keydown',function(e){
    if(e.key==='Escape') closeAllMenus();
},{capture:true});
/* ── View Details + Change Lecturer (self-contained overlays) ── */
function mrxEsc(s){ s=(s==null?'':''+s); return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function mrxDash(v){ return (v==null||v==='')?'—':v; }
function mrxClose(ov){ if(ov&&ov.parentNode) ov.parentNode.removeChild(ov); }

/* Searchable lecturer combobox (no library). items:[{id,name,is_default,is_taught}]. Returns {value:fn}.
   Uses mousedown+preventDefault so a click registers before the input's blur hides the list. */
function lecCombo(mount, items, preselectId){
    var selId = preselectId || 0;
    mount.innerHTML =
        '<div style="position:relative;">'
        + '<input type="text" class="lc-inp" autocomplete="off" placeholder="Type a name to search all lecturers&hellip;" '
        +   'style="width:100%;padding:8px;border:1px solid #cbd5e1;border-radius:4px;font-size:13px;box-sizing:border-box;" />'
        + '<div class="lc-list" style="display:none;position:absolute;left:0;right:0;top:100%;z-index:60;background:#fff;border:1px solid #cbd5e1;border-top:none;max-height:220px;overflow-y:auto;box-shadow:0 8px 22px rgba(0,0,0,.14);"></div>'
        + '</div>';
    var inp = mount.querySelector('.lc-inp'), listEl = mount.querySelector('.lc-list');
    function tag(it){ return it.is_default ? ' · default' : (it.is_taught ? ' · taught this course' : ''); }
    function render(f){
        f=(f||'').toLowerCase().trim(); var html='', shown=0;
        for(var i=0;i<items.length && shown<250;i++){
            var it=items[i], nm=(it.name||('Staff #'+it.id));
            if(f && nm.toLowerCase().indexOf(f)<0) continue;
            var bg=(it.is_default||it.is_taught)?'#f0f7ff':'#fff';
            html+='<div class="lc-opt" data-id="'+it.id+'" data-nm="'+mrxEsc(nm)+'" style="padding:8px 10px;font-size:13px;cursor:pointer;border-bottom:1px solid #f0f2f6;background:'+bg+';">'
                + mrxEsc(nm) + (tag(it)?'<span style="color:#94a3b8;font-size:11px;">'+mrxEsc(tag(it))+'</span>':'') + '</div>';
            shown++;
        }
        listEl.innerHTML = html || '<div style="padding:10px;color:#94a3b8;font-size:12px;">No lecturer matches.</div>';
        var opts=listEl.querySelectorAll('.lc-opt');
        for(var j=0;j<opts.length;j++){
            opts[j].onmousedown=function(e){ e.preventDefault(); selId=parseInt(this.getAttribute('data-id'),10)||0; inp.value=this.getAttribute('data-nm'); listEl.style.display='none'; };
        }
    }
    inp.oninput=function(){ selId=0; render(inp.value); listEl.style.display='block'; };
    inp.onfocus=function(){ render(inp.value); listEl.style.display='block'; };
    inp.onblur=function(){ setTimeout(function(){ listEl.style.display='none'; },150); };
    if(preselectId){ for(var k=0;k<items.length;k++){ if(items[k].id===preselectId){ inp.value=(items[k].name||('Staff #'+preselectId)); break; } } }
    return { value: function(){ return selId; } };
}

function openDetail(id){
    closeAllMenus();
    var ov=document.createElement('div'); ov.className='mrx-ovl open';
    ov.innerHTML='<div class="mrx-modal mrx-modal--wide"><div class="mrx-hd"><span>Request #'+mrxEsc(id)+'</span><button type="button" class="mrx-x">&times;</button></div>'
        +'<div class="mrx-bd" id="mrxDetBody"><div class="mra-note" style="padding:20px;text-align:center;">Loading&hellip;</div></div>'
        +'<div class="mrx-ft"><button type="button" class="mrx-btn mrx-cancel">Close</button></div></div>';
    document.body.appendChild(ov);
    ov.querySelector('.mrx-x').onclick=function(){ mrxClose(ov); };
    ov.querySelector('.mrx-cancel').onclick=function(){ mrxClose(ov); };
    ov.addEventListener('click',function(e){ if(e.target===ov) mrxClose(ov); });
    ajax('AdminGetRequestDetail',{requestId:parseInt(id,10)},function(d){
        var body=document.getElementById('mrxDetBody'); if(!body) return;
        if(!d||!d.success){ body.innerHTML='<div class="mra-note" style="padding:20px;color:#b91c1c;">'+mrxEsc((d&&d.message)||'Failed to load.')+'</div>'; return; }
        function kv(k,v){ return '<div class="k">'+mrxEsc(k)+'</div><div class="v">'+(v==null||v===''?'—':mrxEsc(v))+'</div>'; }
        var h='';
        h+='<div class="mrx-sec"><div class="mrx-sec__t"><span>Student &amp; course</span><span class="mra-pill mra-pill--'+mrxEsc(d.status)+'">'+mrxEsc((d.status||'').replace(/_/g,' '))+'</span></div><div class="mrx-kv">'
            +kv('Student',(d.student||d.regno)+' ('+d.regno+')')+kv('Course',d.course+(d.course_name&&d.course_name!==d.course?(' — '+d.course_name):''))+kv('Period',d.year+' · Sem '+d.sem)+kv('Type',d.type==='MISSING_MARK'?'Missing mark':'Mark change')+'</div></div>';
        h+='<div class="mrx-sec"><div class="mrx-sec__t"><span>Lecturer</span></div><div class="mrx-kv">'
            +kv(d.is_assigned?'Assigned lecturer':'Course lecturer', d.lecturer_name)
            +(d.lecturer_email?kv('Email',d.lecturer_email):'')
            +((d.is_assigned && d.default_name && d.default_name!==d.lecturer_name)?kv('Course default',d.default_name):'')
            +(d.supervisor_name?kv('Supervisor',d.supervisor_name):'')+'</div></div>';
        h+='<div class="mrx-sec"><div class="mrx-sec__t"><span>Marks</span></div><div class="mrx-kv">'
            +kv('Original','CW '+mrxDash(d.orig_cw)+' · Ex '+mrxDash(d.orig_exam)+' · Tot '+mrxDash(d.orig_total)+(d.orig_grade?(' · '+d.orig_grade):''))
            +kv('Proposed','CW '+mrxDash(d.prop_cw)+' · Ex '+mrxDash(d.prop_exam)+' · Tot '+mrxDash(d.prop_total)+(d.prop_grade?(' · '+d.prop_grade):''))+'</div></div>';
        h+='<div class="mrx-sec"><div class="mrx-sec__t"><span>Trail</span></div>';
        if(d.student_reason) h+='<div class="mrx-quote"><b>Student:</b> '+mrxEsc(d.student_reason)+'</div>';
        if(d.lecturer_response) h+='<div class="mrx-quote"><b>Lecturer'+(d.lec_at?(' · '+d.lec_at):'')+':</b> '+mrxEsc(d.lecturer_response)+'</div>';
        if(d.supervisor_response) h+='<div class="mrx-quote"><b>Supervisor'+(d.sup_at?(' · '+d.sup_at):'')+':</b> '+mrxEsc(d.supervisor_response)+'</div>';
        if(d.admin_response) h+='<div class="mrx-quote"><b>Admin'+(d.admin_username?(' · '+d.admin_username):'')+(d.adm_at?(' · '+d.adm_at):'')+':</b> '+mrxEsc(d.admin_response)+'</div>';
        if(!d.student_reason && !d.lecturer_response && !d.supervisor_response && !d.admin_response) h+='<div class="mra-note">No responses yet.</div>';
        h+='</div>';
        h+='<div class="mrx-sec"><div class="mrx-sec__t"><span>Timeline</span></div><div class="mrx-kv">'+kv('Created',d.created_at)+kv('Last updated',d.updated_at)+'</div></div>';
        body.innerHTML=h;
    });
}

function openLecturerModal(id){
    closeAllMenus();
    var row=document.querySelector('tr[data-id="'+id+'"]');
    var courseId=row?(row.getAttribute('data-courseid')||''):'', year=row?(row.getAttribute('data-year')||''):'',
        sem=row?(parseInt(row.getAttribute('data-sem'),10)||0):0, curLid=row?(parseInt(row.getAttribute('data-lecturerid'),10)||0):0;
    var ov=document.createElement('div'); ov.className='mrx-ovl open';
    ov.innerHTML='<div class="mrx-modal"><div class="mrx-hd"><span>Change assigned lecturer</span><button type="button" class="mrx-x">&times;</button></div>'
        +'<div class="mrx-bd"><p style="font-size:12px;color:#6b7280;margin:0 0 10px;">Search and pick the lecturer this request should route to &mdash; you can choose <strong>any</strong> lecturer.</p>'
        +'<div id="mrxLecCombo"><input type="text" disabled placeholder="Loading lecturers&hellip;" style="width:100%;padding:8px;border:1px solid #cbd5e1;border-radius:4px;font-size:13px;box-sizing:border-box;background:#f8fafc;" /></div>'
        +'<div id="mrxLecMsg" style="font-size:12px;margin-top:8px;"></div></div>'
        +'<div class="mrx-ft"><button type="button" class="mrx-btn mrx-cancel">Cancel</button><button type="button" class="mrx-btn mrx-btn--primary mrx-save">Save</button></div></div>';
    document.body.appendChild(ov);
    ov.querySelector('.mrx-x').onclick=function(){ mrxClose(ov); };
    ov.querySelector('.mrx-cancel').onclick=function(){ mrxClose(ov); };
    ov.addEventListener('click',function(e){ if(e.target===ov) mrxClose(ov); });
    var combo=null, mount=document.getElementById('mrxLecCombo');
    ajax('AdminGetLecturers',{courseId:courseId,acadYear:year,semester:sem},function(d){
        if(d && d.success && d.lecturers && d.lecturers.length){ combo=lecCombo(mount, d.lecturers, curLid); }
        else { mount.innerHTML='<div class="mra-note" style="padding:8px;">'+mrxEsc((d&&d.message)||'No lecturers available.')+'</div>'; }
    });
    ov.querySelector('.mrx-save').onclick=function(){
        var lid=combo?combo.value():0, msg=document.getElementById('mrxLecMsg');
        if(lid<=0){ msg.style.color='#dc3545'; msg.textContent='Please search and pick a lecturer.'; return; }
        var btn=this; btn.disabled=true; btn.textContent='Saving…';
        ajax('AdminSetLecturer',{requestId:parseInt(id,10),lecturerId:lid},function(d){
            if(d && d.success){ mrxClose(ov); location.reload(); }
            else { btn.disabled=false; btn.textContent='Save'; msg.style.color='#dc3545'; msg.textContent=(d&&d.message)||'Failed.'; }
        });
    };
}
document.addEventListener('keydown',function(e){ if(e.key==='Escape'){ var o=document.querySelector('.mrx-ovl.open'); if(o) mrxClose(o); } });

// expose required functions to global scope (onclick attrs in server-rendered HTML)
window.openDetail=openDetail;
window.openLecturerModal=openLecturerModal;
window.openModal=openModal;
window.openBatchModal=openBatchModal;
window.selectAll=selectAll;
window.clearSelection=clearSelection;
window.toggleMenu=toggleMenu;
window.applyFilters=applyFilters;
window.clearFilters=clearFilters;
window.applyQs=applyQs;
})();
</script>
</asp:Content>
