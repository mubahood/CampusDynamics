<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AppraisalSessions.aspx.cs" Inherits="COOPERP_NewScreens_AppraisalSessions" Title="Appraisal Sessions - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== PERFORMANCE APPRAISAL SESSIONS ===== */
*,*::before,*::after{box-sizing:border-box;}

:root{--brand:#174DA4;--brand-light:#e8eef8;--brand-dark:#0f3670;--success:#28a745;--danger:#dc3545;--warning:#ffc107;--info:#17a2b8;--grey:#6c757d;--grey-light:#f4f5f7;--border:#dee2e6;--radius:6px;--shadow:0 1px 3px rgba(0,0,0,.08);}

/* ── Page header ── */
.pa-page-header{display:flex;align-items:center;gap:14px;margin-bottom:18px;flex-wrap:wrap;}
.pa-page-header__icon{width:44px;height:44px;border-radius:10px;background:var(--brand);display:flex;align-items:center;justify-content:center;color:#fff;flex-shrink:0;}
.pa-page-header__title{font-size:22px;font-weight:700;color:#1a1a1a;line-height:1.2;}
.pa-page-header__sub{font-size:12px;color:#888;margin-top:1px;}
.pa-page-header__actions{margin-left:auto;}

/* ── Stats bar ── */
.pa-stats{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:18px;}
.pa-stat{background:#fff;border-radius:var(--radius);border:1px solid var(--border);padding:14px 16px;display:flex;align-items:center;gap:12px;transition:box-shadow .15s;}
.pa-stat:hover{box-shadow:0 3px 12px rgba(0,0,0,.1);}
.pa-stat__icon{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.pa-stat--blue   .pa-stat__icon{background:#e8eef8;color:var(--brand);}
.pa-stat--green  .pa-stat__icon{background:#e6f7eb;color:var(--success);}
.pa-stat--amber  .pa-stat__icon{background:#fff8e1;color:#e67e00;}
.pa-stat--purple .pa-stat__icon{background:#f3e8ff;color:#7c3aed;}
.pa-stat--teal   .pa-stat__icon{background:#e0f7fa;color:#00796b;}
.pa-stat__body{min-width:0;}
.pa-stat__val{font-size:22px;font-weight:700;color:#1a1a1a;line-height:1.2;}
.pa-stat__label{font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.3px;}

/* ── Card ── */
.cd-card{background:#fff;border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow);overflow:hidden;}
.cd-card__header{display:flex;align-items:center;justify-content:space-between;padding:16px 20px;border-bottom:1px solid #eee;flex-wrap:wrap;gap:8px;}
.cd-card__title{font-size:15px;font-weight:600;color:#1a1a1a;}

/* ── Filter bar ── */
.pa-filters{padding:14px 20px;background:#fafbfc;border-bottom:1px solid #eee;display:flex;gap:8px;align-items:center;flex-wrap:wrap;}
.pa-search-wrap{position:relative;flex:1;min-width:200px;max-width:400px;}
.pa-search-box{width:100%;padding:7px 12px 7px 34px;border:1px solid var(--border);border-radius:var(--radius);font-size:13px;outline:none;transition:border .15s;}
.pa-search-box:focus{border-color:var(--brand);box-shadow:0 0 0 3px rgba(23,77,164,.12);}
.pa-search-wrap::before{content:'';position:absolute;left:10px;top:50%;transform:translateY(-50%);width:16px;height:16px;background:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23999' stroke-width='2'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E") no-repeat center/contain;}
.pa-filter-select{padding:5px 8px;border:1px solid var(--border);border-radius:4px;font-size:12px;background:#fff;cursor:pointer;}

/* ── Buttons ── */
.hr-btn{display:inline-flex;align-items:center;gap:6px;padding:7px 16px;border:none;border-radius:var(--radius);font-size:13px;font-weight:500;cursor:pointer;transition:all .15s;line-height:1.4;text-decoration:none;}
.hr-btn--primary{background:var(--brand);color:#fff;}.hr-btn--primary:hover{background:var(--brand-dark);}
.hr-btn--success{background:var(--success);color:#fff;}.hr-btn--success:hover{background:#218838;}
.hr-btn--danger{background:var(--danger);color:#fff;}.hr-btn--danger:hover{background:#c82333;}
.hr-btn--outline{background:#fff;color:var(--brand);border:1px solid var(--brand);}.hr-btn--outline:hover{background:var(--brand-light);}
.hr-btn--ghost{background:transparent;color:#555;border:1px solid var(--border);}.hr-btn--ghost:hover{background:#f4f4f4;}
.hr-btn--sm{padding:4px 10px;font-size:12px;}
.hr-btn--warning{background:var(--warning);color:#333;}.hr-btn--warning:hover{background:#e0a800;}

/* ── Badges ── */
.pa-badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600;line-height:1.5;white-space:nowrap;}
.pa-badge--draft{background:#e2e3e5;color:#383d41;}
.pa-badge--active{background:#d4edda;color:#155724;}
.pa-badge--closed{background:#fff3cd;color:#856404;}
.pa-badge--archived{background:#f0f0f0;color:#999;}

/* ── Table ── */
.pa-table-wrap{overflow-x:auto;-webkit-overflow-scrolling:touch;}
.pa-grid{width:100%;border-collapse:collapse;font-size:13px;}
.pa-grid thead th{background:#f8f9fa;padding:10px 12px;text-align:left;font-weight:600;color:#555;font-size:11px;text-transform:uppercase;letter-spacing:.3px;white-space:nowrap;border-bottom:2px solid #dee2e6;position:sticky;top:0;z-index:1;}
.pa-grid tbody td{padding:10px 12px;border-bottom:1px solid #f0f0f0;vertical-align:middle;color:#333;}
.pa-grid tbody tr:hover{background:#f8f9fc;}
.pa-grid tbody tr{cursor:pointer;}
.pa-col-num{width:40px;text-align:center;color:#999;font-size:12px;}
.pa-col-actions{width:100px;text-align:center;}
.pa-empty-state{text-align:center;padding:48px 20px !important;}
.pa-empty-state svg{color:#ccc;margin-bottom:12px;}
.pa-empty-state p{color:#999;font-size:13px;}

/* ── Progress bar ── */
.pa-progress{height:6px;background:#eee;border-radius:3px;overflow:hidden;width:120px;display:inline-block;vertical-align:middle;}
.pa-progress__bar{height:100%;border-radius:3px;transition:width .3s;}
.pa-progress__text{font-size:11px;color:#888;margin-left:6px;}
.pa-progress-empty{font-size:11px;color:#bbb;font-style:italic;}

/* ── Pager ── */
.pa-pager{display:flex;align-items:center;justify-content:space-between;padding:12px 20px;border-top:1px solid #eee;flex-wrap:wrap;gap:8px;}
.pa-pager__info{font-size:12px;color:#999;}
.pa-pager__btns{display:flex;gap:4px;}
.pa-pager__btn{display:inline-flex;align-items:center;justify-content:center;min-width:32px;height:32px;padding:0 8px;border:1px solid var(--border);border-radius:4px;font-size:12px;color:#333;text-decoration:none;transition:all .15s;}
.pa-pager__btn:hover{background:var(--brand-light);border-color:var(--brand);color:var(--brand);}
.pa-pager__btn--active{background:var(--brand);color:#fff;border-color:var(--brand);}
.pa-pager__btn--disabled{color:#ccc;pointer-events:none;}

/* ── Modal ── */
.pa-modal-overlay{display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;padding:20px;}
.pa-modal-overlay.active{display:flex;}
.pa-modal{background:#fff;border-radius:10px;width:100%;max-width:620px;max-height:85vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,.3);animation:paSlide .25s ease-out;}
@keyframes paSlide{from{opacity:0;transform:translateY(-20px);}to{opacity:1;transform:translateY(0);}}
.pa-modal__header{display:flex;align-items:center;justify-content:space-between;padding:18px 24px;border-bottom:1px solid #eee;}
.pa-modal__title{font-size:17px;font-weight:600;color:#1a1a1a;}
.pa-modal__close{background:none;border:none;font-size:22px;color:#999;cursor:pointer;padding:0 4px;}.pa-modal__close:hover{color:#333;}
.pa-modal__body{padding:20px 24px;}
.pa-modal__footer{display:flex;align-items:center;justify-content:flex-end;gap:8px;padding:14px 24px;border-top:1px solid #eee;background:#fafbfc;border-radius:0 0 10px 10px;}

/* ── Form ── */
.pa-form-row{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:14px;}
.pa-form-row--full{grid-template-columns:1fr;}
.pa-form-group{display:flex;flex-direction:column;gap:4px;}
.pa-form-label{font-size:12px;font-weight:600;color:#555;}
.pa-form-label em{color:var(--danger);font-style:normal;}
.pa-form-input,.pa-form-select,.pa-form-textarea{padding:8px 12px;border:1px solid var(--border);border-radius:var(--radius);font-size:13px;outline:none;transition:border .15s;font-family:inherit;}
.pa-form-input:focus,.pa-form-select:focus,.pa-form-textarea:focus{border-color:var(--brand);box-shadow:0 0 0 3px rgba(23,77,164,.12);}
.pa-form-textarea{resize:vertical;min-height:70px;}
.pa-checkbox-group{display:flex;gap:16px;align-items:center;padding:4px 0;}
.pa-checkbox-group label{display:flex;align-items:center;gap:6px;font-size:13px;cursor:pointer;}

/* ── Detail view (drawer) ── */
.pa-detail-section{margin-bottom:20px;}
.pa-detail-section__title{font-size:13px;font-weight:600;color:#555;text-transform:uppercase;letter-spacing:.3px;margin-bottom:10px;padding-bottom:6px;border-bottom:1px solid #eee;}
.pa-detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px 20px;}
.pa-detail-item{display:flex;flex-direction:column;gap:2px;}
.pa-detail-item__label{font-size:11px;color:#999;text-transform:uppercase;letter-spacing:.3px;}
.pa-detail-item__value{font-size:13px;color:#1a1a1a;font-weight:500;}

/* ── Records mini-table ── */
.pa-records-table{width:100%;border-collapse:collapse;font-size:12px;margin-top:8px;}
.pa-records-table th{background:#f8f9fa;padding:6px 8px;text-align:left;font-weight:600;color:#666;font-size:10px;text-transform:uppercase;border-bottom:1px solid #ddd;}
.pa-records-table td{padding:6px 8px;border-bottom:1px solid #f0f0f0;}
.pa-records-table tr:hover{background:#f8f9fc;}

/* ── Status badge (records) ── */
.pa-rec-badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:10px;font-weight:600;}
.pa-rec-badge--pending{background:#e2e3e5;color:#383d41;}
.pa-rec-badge--emp-progress{background:#cce5ff;color:#004085;}
.pa-rec-badge--emp-submitted{background:#d4edda;color:#155724;}
.pa-rec-badge--sup-progress{background:#fff3cd;color:#856404;}
.pa-rec-badge--completed{background:#d4edda;color:#155724;}
.pa-rec-badge--cancelled{background:#f8d7da;color:#721c24;}

/* ── Responsive ── */
@media(max-width:900px){.pa-stats{grid-template-columns:repeat(3,1fr);}.pa-form-row{grid-template-columns:1fr;}}
@media(max-width:600px){.pa-stats{grid-template-columns:repeat(2,1fr);}.pa-page-header{flex-direction:column;align-items:flex-start;}.pa-page-header__actions{margin-left:0;}}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ── Page Header ── -->
<div class="pa-page-header">
    <div class="pa-page-header__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><path d="M9 15l2 2 4-4"/></svg>
    </div>
    <div>
        <div class="pa-page-header__title">Performance Appraisal Sessions</div>
        <div class="pa-page-header__sub">Create, manage, and monitor appraisal periods</div>
    </div>
    <div class="pa-page-header__actions">
        <button type="button" class="hr-btn hr-btn--primary" onclick="openCreateModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            New Session
        </button>
    </div>
</div>

<!-- ── Stats Bar ── -->
<div class="pa-stats">
    <div class="pa-stat pa-stat--blue">
        <div class="pa-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        </div>
        <div class="pa-stat__body">
            <div class="pa-stat__val"><asp:Literal ID="litStatTotal" runat="server" Text="0" /></div>
            <div class="pa-stat__label">Total Sessions</div>
        </div>
    </div>
    <div class="pa-stat pa-stat--green">
        <div class="pa-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
        </div>
        <div class="pa-stat__body">
            <div class="pa-stat__val"><asp:Literal ID="litStatActive" runat="server" Text="0" /></div>
            <div class="pa-stat__label">Active</div>
        </div>
    </div>
    <div class="pa-stat pa-stat--amber">
        <div class="pa-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
        </div>
        <div class="pa-stat__body">
            <div class="pa-stat__val"><asp:Literal ID="litStatDraft" runat="server" Text="0" /></div>
            <div class="pa-stat__label">Draft</div>
        </div>
    </div>
    <div class="pa-stat pa-stat--purple">
        <div class="pa-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
        <div class="pa-stat__body">
            <div class="pa-stat__val"><asp:Literal ID="litStatAppraisals" runat="server" Text="0" /></div>
            <div class="pa-stat__label">Total Appraisals</div>
        </div>
    </div>
    <div class="pa-stat pa-stat--teal">
        <div class="pa-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div class="pa-stat__body">
            <div class="pa-stat__val"><asp:Literal ID="litStatCompleted" runat="server" Text="0" /></div>
            <div class="pa-stat__label">Completed</div>
        </div>
    </div>
</div>

<!-- ── Sessions Grid Card ── -->
<div class="cd-card">
    <div class="cd-card__header">
        <span class="cd-card__title">Appraisal Sessions</span>
    </div>

    <!-- Filter bar -->
    <div class="pa-filters">
        <div class="pa-search-wrap">
            <input type="text" id="txtSearch" class="pa-search-box" placeholder="Search sessions..." value="<%= HttpUtility.HtmlAttributeEncode(Request.QueryString["q"] ?? "") %>" />
        </div>
        <select id="ddlStatusFilter" class="pa-filter-select" onchange="applyFilters()">
            <option value="">All Statuses</option>
            <option value="DRAFT">Draft</option>
            <option value="ACTIVE">Active</option>
            <option value="CLOSED">Closed</option>
            <option value="ARCHIVED">Archived</option>
        </select>
    </div>

    <!-- Table -->
    <div class="pa-table-wrap">
        <table class="pa-grid">
            <thead>
                <tr>
                    <th class="pa-col-num">#</th>
                    <th>Session Title</th>
                    <th>Period</th>
                    <th>Deadline</th>
                    <th>Categories</th>
                    <th>Status</th>
                    <th>Progress</th>
                    <th class="pa-col-actions">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litGridBody" runat="server" />
            </tbody>
        </table>
    </div>

    <!-- Pager -->
    <div class="pa-pager">
        <div class="pa-pager__info"><asp:Literal ID="litPagerInfo" runat="server" /></div>
        <div class="pa-pager__btns"><asp:Literal ID="litPager" runat="server" /></div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════════════
     CREATE SESSION MODAL
     ══════════════════════════════════════════════════════════════════ -->
<div id="createModal" class="pa-modal-overlay" onclick="if(event.target===this)closeCreateModal()">
    <div class="pa-modal">
        <div class="pa-modal__header">
            <span class="pa-modal__title">Create Appraisal Session</span>
            <button type="button" class="pa-modal__close" onclick="closeCreateModal()">&times;</button>
        </div>
        <div class="pa-modal__body">
            <div class="pa-form-row pa-form-row--full">
                <div class="pa-form-group">
                    <label class="pa-form-label">Session Title <em>*</em></label>
                    <asp:TextBox ID="txtTitle" runat="server" CssClass="pa-form-input" placeholder="e.g. Annual Performance Appraisal 2025/2026" />
                </div>
            </div>
            <div class="pa-form-row pa-form-row--full">
                <div class="pa-form-group">
                    <label class="pa-form-label">Description</label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="pa-form-textarea" TextMode="MultiLine" placeholder="Optional description of this appraisal period..." />
                </div>
            </div>
            <div class="pa-form-row">
                <div class="pa-form-group">
                    <label class="pa-form-label">Period Start <em>*</em></label>
                    <asp:TextBox ID="txtPeriodStart" runat="server" CssClass="pa-form-input" TextMode="Date" />
                </div>
                <div class="pa-form-group">
                    <label class="pa-form-label">Period End <em>*</em></label>
                    <asp:TextBox ID="txtPeriodEnd" runat="server" CssClass="pa-form-input" TextMode="Date" />
                </div>
            </div>
            <div class="pa-form-row">
                <div class="pa-form-group">
                    <label class="pa-form-label">Submission Deadline <em>*</em></label>
                    <asp:TextBox ID="txtDeadline" runat="server" CssClass="pa-form-input" TextMode="Date" />
                </div>
                <div class="pa-form-group">
                    <label class="pa-form-label">Target Staff Categories</label>
                    <div class="pa-checkbox-group">
                        <label><asp:CheckBox ID="chkAcademic" runat="server" Checked="true" /> Academic</label>
                        <label><asp:CheckBox ID="chkAdministrative" runat="server" Checked="true" /> Administrative</label>
                        <label><asp:CheckBox ID="chkSupport" runat="server" Checked="true" /> Support</label>
                    </div>
                </div>
            </div>
        </div>
        <div class="pa-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="closeCreateModal()">Cancel</button>
            <asp:Button ID="btnCreateSession" runat="server" CssClass="hr-btn hr-btn--primary" Text="Create Session" OnClick="btnCreateSession_Click" />
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════════════
     EDIT SESSION MODAL
     ══════════════════════════════════════════════════════════════════ -->
<div id="editModal" class="pa-modal-overlay" onclick="if(event.target===this)closeEditModal()">
    <div class="pa-modal">
        <div class="pa-modal__header">
            <span class="pa-modal__title">Edit Session</span>
            <button type="button" class="pa-modal__close" onclick="closeEditModal()">&times;</button>
        </div>
        <div class="pa-modal__body">
            <asp:HiddenField ID="hfEditSessionId" runat="server" />
            <div class="pa-form-row pa-form-row--full">
                <div class="pa-form-group">
                    <label class="pa-form-label">Session Title <em>*</em></label>
                    <asp:TextBox ID="txtEditTitle" runat="server" CssClass="pa-form-input" />
                </div>
            </div>
            <div class="pa-form-row pa-form-row--full">
                <div class="pa-form-group">
                    <label class="pa-form-label">Description</label>
                    <asp:TextBox ID="txtEditDescription" runat="server" CssClass="pa-form-textarea" TextMode="MultiLine" />
                </div>
            </div>
            <div class="pa-form-row">
                <div class="pa-form-group">
                    <label class="pa-form-label">Period Start <em>*</em></label>
                    <asp:TextBox ID="txtEditPeriodStart" runat="server" CssClass="pa-form-input" TextMode="Date" />
                </div>
                <div class="pa-form-group">
                    <label class="pa-form-label">Period End <em>*</em></label>
                    <asp:TextBox ID="txtEditPeriodEnd" runat="server" CssClass="pa-form-input" TextMode="Date" />
                </div>
            </div>
            <div class="pa-form-row">
                <div class="pa-form-group">
                    <label class="pa-form-label">Submission Deadline <em>*</em></label>
                    <asp:TextBox ID="txtEditDeadline" runat="server" CssClass="pa-form-input" TextMode="Date" />
                </div>
                <div class="pa-form-group">
                    <label class="pa-form-label">Target Staff Categories</label>
                    <div class="pa-checkbox-group">
                        <label><asp:CheckBox ID="chkEditAcademic" runat="server" /> Academic</label>
                        <label><asp:CheckBox ID="chkEditAdministrative" runat="server" /> Administrative</label>
                        <label><asp:CheckBox ID="chkEditSupport" runat="server" /> Support</label>
                    </div>
                </div>
            </div>
        </div>
        <div class="pa-modal__footer">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="closeEditModal()">Cancel</button>
            <asp:Button ID="btnEditSession" runat="server" CssClass="hr-btn hr-btn--primary" Text="Save Changes" OnClick="btnEditSession_Click" />
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════════════
     VIEW SESSION DETAIL MODAL
     ══════════════════════════════════════════════════════════════════ -->
<div id="detailModal" class="pa-modal-overlay" onclick="if(event.target===this)closeDetailModal()">
    <div class="pa-modal" style="max-width:820px;">
        <div class="pa-modal__header">
            <span class="pa-modal__title" id="detailTitle">Session Details</span>
            <button type="button" class="pa-modal__close" onclick="closeDetailModal()">&times;</button>
        </div>
        <div class="pa-modal__body" id="detailBody">
            <div style="text-align:center;padding:30px;color:#999;">Loading...</div>
        </div>
        <div class="pa-modal__footer" id="detailFooter">
            <asp:HiddenField ID="hfActionSessionId" runat="server" />
            <button type="button" class="hr-btn hr-btn--ghost" onclick="closeDetailModal()">Close</button>
            <asp:Button ID="btnActivateSession" runat="server" CssClass="hr-btn hr-btn--success" Text="Activate" OnClick="btnActivateSession_Click" style="display:none" />
            <button type="button" id="btnGenerate" class="hr-btn hr-btn--warning" style="display:none" onclick="generateAppraisals()">Generate Appraisals</button>
            <asp:Button ID="btnCloseSession" runat="server" CssClass="hr-btn hr-btn--outline" Text="Close Session" OnClick="btnCloseSession_Click" style="display:none" />
            <asp:Button ID="btnArchiveSession" runat="server" CssClass="hr-btn hr-btn--ghost" Text="Archive" OnClick="btnArchiveSession_Click" style="display:none" />
            <asp:Button ID="btnDeleteSession" runat="server" CssClass="hr-btn hr-btn--danger hr-btn--sm" Text="Delete" OnClick="btnDeleteSession_Click" style="display:none" />
        </div>
    </div>
</div>

<script type="text/javascript">
// ═══════════════════════════════════════════════════════════════════
//  FILTER / SEARCH
// ═══════════════════════════════════════════════════════════════════
(function () {
    var searchBox = document.getElementById('txtSearch');
    var statusDdl = document.getElementById('ddlStatusFilter');
    var timer = null;

    // Pre-select current filter from URL
    var urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('status')) statusDdl.value = urlParams.get('status');

    searchBox.addEventListener('keyup', function () {
        clearTimeout(timer);
        timer = setTimeout(function () { applyFilters(); }, 400);
    });
    searchBox.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); applyFilters(); }
    });
})();

function applyFilters() {
    var q = document.getElementById('txtSearch').value.trim();
    var st = document.getElementById('ddlStatusFilter').value;
    var url = 'AppraisalSessions.aspx?';
    if (q) url += 'q=' + encodeURIComponent(q) + '&';
    if (st) url += 'status=' + encodeURIComponent(st) + '&';
    window.location.href = url.replace(/&$/, '');
}

// ═══════════════════════════════════════════════════════════════════
//  CREATE MODAL
// ═══════════════════════════════════════════════════════════════════
function openCreateModal() {
    document.getElementById('createModal').classList.add('active');
}
function closeCreateModal() {
    document.getElementById('createModal').classList.remove('active');
}

// ═══════════════════════════════════════════════════════════════════
//  EDIT MODAL
// ═══════════════════════════════════════════════════════════════════
function openEditModal(sessionId) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'AppraisalSessions.aspx?ajax=get_session&id=' + sessionId, true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        try {
            var d = JSON.parse(xhr.responseText);
            if (d.error) { alert(d.error); return; }

            document.getElementById('<%= hfEditSessionId.ClientID %>').value = d.session_id;
            document.getElementById('<%= txtEditTitle.ClientID %>').value = d.session_title;
            document.getElementById('<%= txtEditDescription.ClientID %>').value = d.session_description || '';
            document.getElementById('<%= txtEditPeriodStart.ClientID %>').value = d.period_start;
            document.getElementById('<%= txtEditPeriodEnd.ClientID %>').value = d.period_end;
            document.getElementById('<%= txtEditDeadline.ClientID %>').value = d.deadline;

            var cats = (d.target_categories || '').toUpperCase();
            document.getElementById('<%= chkEditAcademic.ClientID %>').checked = cats.indexOf('ACADEMIC') >= 0;
            document.getElementById('<%= chkEditAdministrative.ClientID %>').checked = cats.indexOf('ADMINISTRATIVE') >= 0;
            document.getElementById('<%= chkEditSupport.ClientID %>').checked = cats.indexOf('SUPPORT') >= 0;

            document.getElementById('editModal').classList.add('active');
        } catch (ex) { alert('Error loading session data.'); }
    };
    xhr.send();
}
function closeEditModal() {
    document.getElementById('editModal').classList.remove('active');
}

// ═══════════════════════════════════════════════════════════════════
//  VIEW / DETAIL MODAL
// ═══════════════════════════════════════════════════════════════════
var _currentDetailId = 0;

function viewSession(sessionId) {
    _currentDetailId = sessionId;
    document.getElementById('<%= hfActionSessionId.ClientID %>').value = sessionId;
    document.getElementById('detailBody').innerHTML = '<div style="text-align:center;padding:30px;color:#999;">Loading...</div>';

    // Hide all action buttons initially
    document.getElementById('<%= btnActivateSession.ClientID %>').style.display = 'none';
    document.getElementById('btnGenerate').style.display = 'none';
    document.getElementById('<%= btnCloseSession.ClientID %>').style.display = 'none';
    document.getElementById('<%= btnArchiveSession.ClientID %>').style.display = 'none';
    document.getElementById('<%= btnDeleteSession.ClientID %>').style.display = 'none';

    document.getElementById('detailModal').classList.add('active');

    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'AppraisalSessions.aspx?ajax=get_session_detail&id=' + sessionId, true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        try {
            var d = JSON.parse(xhr.responseText);
            if (d.error) { document.getElementById('detailBody').innerHTML = '<p style="color:red;">' + d.error + '</p>'; return; }
            renderDetail(d);
        } catch (ex) {
            document.getElementById('detailBody').innerHTML = '<p style="color:red;">Error loading details.</p>';
        }
    };
    xhr.send();
}

function renderDetail(d) {
    document.getElementById('detailTitle').textContent = d.session_title;

    var pct = d.progress_pct || 0;
    var html = '';

    // Info section
    html += '<div class="pa-detail-section">';
    html += '<div class="pa-detail-section__title">Session Information</div>';
    html += '<div class="pa-detail-grid">';
    html += detailItem('Status', '<span class=\'pa-badge pa-badge--' + d.status.toLowerCase() + '\'>' + d.status + '</span>');
    html += detailItem('Created By', esc(d.created_by_name));
    html += detailItem('Period', esc(d.period_start) + ' &mdash; ' + esc(d.period_end));
    html += detailItem('Deadline', esc(d.deadline));
    html += detailItem('Categories', esc(d.target_categories));
    html += detailItem('Progress', pct + '%');
    html += '</div></div>';

    // Stats
    html += '<div class="pa-detail-section">';
    html += '<div class="pa-detail-section__title">Appraisal Statistics</div>';
    html += '<div class="pa-detail-grid">';
    html += detailItem('Total', d.total);
    html += detailItem('Pending', d.pending);
    html += detailItem('In Progress', d.in_progress);
    html += detailItem('Completed', d.completed);
    html += detailItem('Cancelled', d.cancelled);
    html += '</div></div>';

    // Records
    if (d.records && d.records.length > 0) {
        html += '<div class="pa-detail-section">';
        html += '<div class="pa-detail-section__title">Individual Appraisals (' + d.records.length + ')</div>';
        html += '<div style="max-height:300px;overflow-y:auto;">';
        html += '<table class="pa-records-table"><thead><tr>';
        html += '<th>#</th><th>Employee</th><th>Code</th><th>Category</th><th>Reviewer</th><th>Status</th><th>Score</th>';
        html += '</tr></thead><tbody>';
        for (var i = 0; i < d.records.length; i++) {
            var r = d.records[i];
            var badgeCls = getRecBadgeClass(r.status);
            html += '<tr>';
            html += '<td>' + (i + 1) + '</td>';
            html += '<td>' + esc(r.emp_name) + '</td>';
            html += '<td>' + esc(r.EMP_CODE) + '</td>';
            html += '<td style="font-size:11px;">' + esc(r.staff_category) + '</td>';
            html += '<td>' + esc(r.reviewer_name) + '</td>';
            html += '<td><span class="pa-rec-badge ' + badgeCls + '">' + formatRecStatus(r.status) + '</span></td>';
            html += '<td>' + (r.final_percentage ? r.final_percentage + '%' : '&mdash;') + '</td>';
            html += '</tr>';
        }
        html += '</tbody></table></div></div>';
    }

    document.getElementById('detailBody').innerHTML = html;

    // Show appropriate action buttons based on status
    var status = d.status.toUpperCase();
    if (status === 'DRAFT') {
        document.getElementById('<%= btnActivateSession.ClientID %>').style.display = '';
        document.getElementById('<%= btnDeleteSession.ClientID %>').style.display = '';
    }
    if (status === 'ACTIVE') {
        document.getElementById('btnGenerate').style.display = '';
        document.getElementById('<%= btnCloseSession.ClientID %>').style.display = '';
    }
    if (status === 'CLOSED') {
        document.getElementById('<%= btnArchiveSession.ClientID %>').style.display = '';
    }
}

function detailItem(label, value) {
    return '<div class="pa-detail-item"><div class="pa-detail-item__label">' + label + '</div><div class="pa-detail-item__value">' + value + '</div></div>';
}

function getRecBadgeClass(status) {
    switch (status) {
        case 'PENDING': return 'pa-rec-badge--pending';
        case 'EMPLOYEE_IN_PROGRESS': return 'pa-rec-badge--emp-progress';
        case 'EMPLOYEE_SUBMITTED': return 'pa-rec-badge--emp-submitted';
        case 'SUPERVISOR_IN_PROGRESS': return 'pa-rec-badge--sup-progress';
        case 'COMPLETED': return 'pa-rec-badge--completed';
        case 'CANCELLED': return 'pa-rec-badge--cancelled';
        default: return 'pa-rec-badge--pending';
    }
}

function formatRecStatus(status) {
    return (status || '').replace(/_/g, ' ');
}

function esc(val) {
    if (!val) return '';
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(val));
    return div.innerHTML;
}

function closeDetailModal() {
    document.getElementById('detailModal').classList.remove('active');
}

// ═══════════════════════════════════════════════════════════════════
//  GENERATE APPRAISALS
// ═══════════════════════════════════════════════════════════════════
function generateAppraisals() {
    if (!confirm('Generate individual appraisal records for all eligible employees in this session?\n\nThis will create one appraisal record per employee.')) return;

    var btn = document.getElementById('btnGenerate');
    btn.disabled = true;
    btn.textContent = 'Generating...';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'AppraisalSessions.aspx?ajax=generate_appraisals&id=' + _currentDetailId, true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        btn.disabled = false;
        btn.textContent = 'Generate Appraisals';
        try {
            var d = JSON.parse(xhr.responseText);
            if (d.error) { alert(d.error); return; }
            alert('Successfully generated ' + d.count + ' appraisal record(s).');
            // Refresh detail view
            viewSession(_currentDetailId);
            // Re-bind grid on close (refresh page)
            window._needsRefresh = true;
        } catch (ex) { alert('Error generating appraisals.'); }
    };
    xhr.send();
}

// Refresh page if needed when closing detail modal
var _origClose = closeDetailModal;
closeDetailModal = function () {
    _origClose();
    if (window._needsRefresh) {
        window._needsRefresh = false;
        window.location.reload();
    }
};
</script>

</asp:Content>
