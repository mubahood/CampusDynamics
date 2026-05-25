<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="LeaveApplicationForm.aspx.cs" Inherits="COOPERP_NewScreens_LeaveApplicationForm" Title="Leave Application - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--brand:#174DA4;--brand-dk:#05275C;--danger:#dc2626;--success:#16a34a;--warn:#b45309;--surf:#f5f7fa;--bdr:#e0e5ed;--txt:#1a1a2e;--muted:#64748b;}

/* ── Page header ─────────────────────────────────────────────────────────── */
.lf-header{background:#fff;border-bottom:1px solid var(--bdr);padding:16px 28px;display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;}
.lf-header__left{display:flex;align-items:center;gap:12px;}
.lf-back{display:inline-flex;align-items:center;gap:4px;font-size:11px;color:var(--muted);text-decoration:none;border:1px solid var(--bdr);padding:4px 10px;background:#fff;}
.lf-back:hover{background:var(--surf);color:var(--brand);}
.lf-header__title{font-size:16px;font-weight:700;color:var(--txt);margin:0;}
.lf-header__sub{font-size:11px;color:var(--muted);}
.lf-header__actions{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}

/* ── Status badge ─────────────────────────────────────────────────────────── */
.lf-status{display:inline-block;padding:3px 10px;border-radius:2px;font-size:11px;font-weight:700;}
.lf-status--draft        {background:#f1f5f9;color:#64748b;}
.lf-status--submitted    {background:#fef9c3;color:#b45309;}
.lf-status--hod_approved {background:#e0f2fe;color:#0369a1;}
.lf-status--hod_declined {background:#fef2f2;color:#dc2626;}
.lf-status--hr_approved  {background:#ede9fe;color:#7c3aed;}
.lf-status--hr_declined  {background:#fef2f2;color:#dc2626;}
.lf-status--vc_granted   {background:#dcfce7;color:#16a34a;}
.lf-status--vc_not_granted{background:#fef2f2;color:#dc2626;}
.lf-status--vc_postponed {background:#fff7ed;color:#b45309;}
.lf-status--cancelled    {background:#f1f5f9;color:#94a3b8;}

/* ── Workflow timeline ───────────────────────────────────────────────────── */
.lf-timeline{background:#fff;border-bottom:1px solid var(--bdr);padding:12px 28px;display:flex;align-items:center;gap:0;overflow-x:auto;}
.lf-step{display:flex;align-items:center;gap:0;flex-shrink:0;}
.lf-step__dot{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;border:2px solid var(--bdr);background:#fff;color:var(--muted);flex-shrink:0;}
.lf-step__dot--done{background:var(--success);border-color:var(--success);color:#fff;}
.lf-step__dot--active{background:var(--brand);border-color:var(--brand);color:#fff;box-shadow:0 0 0 3px rgba(23,77,164,.2);}
.lf-step__dot--declined{background:var(--danger);border-color:var(--danger);color:#fff;}
.lf-step__info{margin-left:8px;}
.lf-step__label{font-size:10px;font-weight:600;color:var(--txt);}
.lf-step__sub{font-size:9px;color:var(--muted);}
.lf-step__arrow{width:40px;height:2px;background:var(--bdr);margin:0 4px;flex-shrink:0;}
.lf-step__arrow--done{background:var(--success);}

/* ── Form document area ──────────────────────────────────────────────────── */
.lf-doc{max-width:860px;margin:24px auto;padding:0 24px 40px;}

/* ── MRU Letterhead ──────────────────────────────────────────────────────── */
.lf-letterhead{background:#fff;border:1px solid var(--bdr);border-radius:2px;padding:20px 28px;margin-bottom:0;text-align:center;border-bottom:3px solid var(--brand-dk);}
.lf-letterhead__title{font-size:14px;font-weight:700;color:var(--brand-dk);letter-spacing:.5px;text-transform:uppercase;margin-bottom:4px;}
.lf-letterhead__policy{font-size:11px;color:#374151;text-align:left;margin-top:10px;line-height:1.7;background:var(--surf);border:1px solid var(--bdr);padding:10px 14px;border-left:3px solid var(--brand);}
.lf-letterhead__policy li{margin-bottom:2px;}

/* ── Section card ─────────────────────────────────────────────────────────── */
.lf-section{background:#fff;border:1px solid var(--bdr);border-radius:2px;margin-top:16px;overflow:hidden;}
.lf-section.lf-section--active{border-color:var(--brand);box-shadow:0 0 0 2px rgba(23,77,164,.12);}
.lf-section.lf-section--completed{border-color:var(--success);}
.lf-section.lf-section--declined{border-color:var(--danger);}
.lf-section.lf-section--locked{opacity:.6;}
.lf-section__head{padding:12px 20px;display:flex;align-items:center;gap:10px;border-bottom:1px solid var(--bdr);}
.lf-section--active   .lf-section__head{background:#eff6ff;}
.lf-section--completed .lf-section__head{background:#f0fdf4;}
.lf-section--declined  .lf-section__head{background:#fef2f2;}
.lf-section--locked    .lf-section__head{background:var(--surf);}
.lf-section__num{width:26px;height:26px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:#fff;flex-shrink:0;}
.lf-section--active    .lf-section__num{background:var(--brand);}
.lf-section--completed .lf-section__num{background:var(--success);}
.lf-section--declined  .lf-section__num{background:var(--danger);}
.lf-section--locked    .lf-section__num{background:var(--muted);}
.lf-section__title{font-size:13px;font-weight:700;color:var(--txt);}
.lf-section__badge{margin-left:auto;font-size:10px;font-weight:700;padding:2px 8px;border-radius:2px;}
.badge--waiting{background:#fef9c3;color:#b45309;}
.badge--approved{background:#dcfce7;color:#16a34a;}
.badge--declined{background:#fef2f2;color:#dc2626;}
.badge--locked{background:#f1f5f9;color:#94a3b8;}
.badge--granted{background:#dcfce7;color:#16a34a;}
.badge--notgranted{background:#fef2f2;color:#dc2626;}
.badge--postponed{background:#fff7ed;color:#b45309;}
.lf-section__body{padding:20px;}

/* ── Form grid ────────────────────────────────────────────────────────────── */
.lf-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px 20px;}
.lf-grid--3{grid-template-columns:1fr 1fr 1fr;}
.lf-grid--full{grid-column:1/-1;}
.lf-field label{display:block;font-size:10px;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:4px;}
.lf-field input[type=text],.lf-field input[type=date],.lf-field input[type=tel],.lf-field input[type=number],.lf-field select,.lf-field textarea{width:100%;height:34px;border:1px solid var(--bdr);font-size:12px;padding:0 10px;outline:none;box-sizing:border-box;background:#fff;color:var(--txt);}
.lf-field input:focus,.lf-field select:focus,.lf-field textarea:focus{border-color:var(--brand);}
.lf-field textarea{height:64px;padding:8px 10px;resize:vertical;}
.lf-field.lf-field--readonly input,.lf-field.lf-field--readonly select,.lf-field.lf-field--readonly textarea{background:var(--surf);color:#374151;cursor:default;}
.lf-read-val{font-size:12px;color:var(--txt);padding:6px 0;border-bottom:1px solid var(--bdr);min-height:30px;}
.lf-read-val--empty{color:var(--muted);font-style:italic;}

/* ── Leave type selector ──────────────────────────────────────────────────── */
.leave-type-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:8px;margin-bottom:4px;}
.leave-type-opt{cursor:pointer;}
.leave-type-opt input[type=radio]{position:absolute;opacity:0;width:0;height:0;}
.leave-type-opt label{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:10px 6px;border:2px solid var(--bdr);font-size:10px;font-weight:600;color:var(--muted);text-align:center;cursor:pointer;line-height:1.3;transition:border-color .15s,color .15s,background .15s;}
.leave-type-opt input:checked + label{border-color:var(--brand);color:var(--brand);background:#eff6ff;}
.leave-type-opt label:hover{border-color:var(--brand);color:var(--brand);}

/* ── Action bar ───────────────────────────────────────────────────────────── */
.lf-actions{background:#fff;border-top:1px solid var(--bdr);padding:14px 28px;display:flex;align-items:center;gap:10px;flex-wrap:wrap;position:sticky;bottom:0;z-index:10;box-shadow:0 -2px 8px rgba(0,0,0,.06);}
.lf-btn{display:inline-flex;align-items:center;gap:5px;padding:7px 18px;font-size:12px;font-weight:600;border:none;cursor:pointer;border-radius:0;white-space:nowrap;}
.lf-btn--primary{background:var(--brand-dk);color:#fff;}
.lf-btn--primary:hover{background:var(--brand);}
.lf-btn--success{background:var(--success);color:#fff;}
.lf-btn--success:hover{background:#15803d;}
.lf-btn--outline{background:#fff;color:#374151;border:1px solid var(--bdr);}
.lf-btn--outline:hover{background:var(--surf);}
.lf-btn--danger{background:#fef2f2;color:var(--danger);border:1px solid #fca5a5;}
.lf-btn--danger:hover{background:var(--danger);color:#fff;}
.lf-btn--warn{background:#fff7ed;color:var(--warn);border:1px solid #fcd34d;}
.lf-btn--warn:hover{background:var(--warn);color:#fff;}
.lf-btn:disabled{opacity:.5;cursor:not-allowed;}
.lf-actions__note{font-size:11px;color:var(--muted);margin-left:auto;}

/* ── Modals ───────────────────────────────────────────────────────────────── */
.pa-modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.46);z-index:1000;align-items:center;justify-content:center;}
.pa-modal-overlay.is-open{display:flex;}
.pa-modal{background:#fff;border-radius:2px;width:500px;max-width:95vw;box-shadow:0 20px 60px rgba(0,0,0,.2);}
.pa-modal--sm{width:420px;}
.pa-modal__head{padding:16px 20px;display:flex;align-items:center;justify-content:space-between;background:var(--brand-dk);color:#fff;}
.pa-modal__head--danger{background:var(--danger);}
.pa-modal__head--success{background:var(--success);}
.pa-modal__head--warn{background:var(--warn);}
.pa-modal__title{font-size:14px;font-weight:600;margin:0;}
.pa-modal__close{background:none;border:none;color:rgba(255,255,255,.7);cursor:pointer;font-size:20px;line-height:1;}
.pa-modal__close:hover{color:#fff;}
.pa-modal__body{padding:22px 20px;}
.pa-modal__foot{padding:12px 20px;border-top:1px solid var(--bdr);display:flex;justify-content:flex-end;gap:8px;}
.urm-field{margin-bottom:16px;}
.urm-field label{display:block;font-size:11px;font-weight:600;color:#374151;margin-bottom:4px;}
.urm-field input[type=text],.urm-field input[type=date],.urm-field textarea,.urm-field select{width:100%;height:34px;border:1px solid var(--bdr);font-size:12px;padding:0 10px;outline:none;box-sizing:border-box;}
.urm-field input:focus,.urm-field textarea:focus,.urm-field select:focus{border-color:var(--brand);}
.urm-field textarea{height:72px;padding:8px 10px;resize:vertical;}
.urm-hint{font-size:10px;color:var(--muted);margin-top:3px;}

/* ── Audit trail ─────────────────────────────────────────────────────────── */
.lf-audit{max-width:860px;margin:0 auto;padding:0 24px 24px;}
.lf-audit__title{font-size:12px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;padding:12px 0 8px;}
.audit-entry{display:flex;gap:12px;padding:8px 0;border-bottom:1px solid #f1f5f9;}
.audit-entry:last-child{border-bottom:none;}
.audit-dot{width:10px;height:10px;border-radius:50%;background:var(--brand);flex-shrink:0;margin-top:4px;}
.audit-dot--ok{background:var(--success);}
.audit-dot--err{background:var(--danger);}
.audit-dot--warn{background:var(--warn);}
.audit-body{flex:1;}
.audit-action{font-size:11px;font-weight:600;color:var(--txt);}
.audit-meta{font-size:10px;color:var(--muted);}
.audit-remark{font-size:11px;color:#374151;margin-top:3px;font-style:italic;}

/* ── Toast ───────────────────────────────────────────────────────────────── */
.pa-toast{display:none;position:fixed;bottom:80px;right:24px;z-index:3000;background:#fff;border:1px solid var(--bdr);border-left:4px solid var(--success);padding:12px 18px;font-size:12px;box-shadow:0 4px 18px rgba(0,0,0,.12);max-width:320px;border-radius:2px;}
.pa-toast.visible{display:block;}
.pa-toast--err{border-left-color:var(--danger);}

/* ── Print styles ─────────────────────────────────────────────────────────── */
@media print {
    .lf-header,.lf-timeline,.lf-actions,.lf-audit,.pa-modal-overlay,.pa-toast,
    .lf-btn,nav,aside,.sidebar { display:none!important; }
    .lf-doc{max-width:100%;margin:0;padding:0;}
    .lf-section{break-inside:avoid;border:1px solid #999;margin-top:12px;}
    .lf-section__head{background:#eee!important;-webkit-print-color-adjust:exact;}
    body{font-size:11pt;}
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="lf-header">
    <div class="lf-header__left">
        <a href="LeaveApplications.aspx" class="lf-back">
            <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
            Leave Applications
        </a>
        <div>
            <div class="lf-header__title">
                <asp:Literal ID="litPageTitle" runat="server">Leave Application</asp:Literal>
                &nbsp;<asp:Literal ID="litStatusBadge" runat="server"></asp:Literal>
            </div>
            <div class="lf-header__sub"><asp:Literal ID="litHeaderSub" runat="server"></asp:Literal></div>
        </div>
    </div>
    <div class="lf-header__actions">
        <asp:Literal ID="litPrintBtn" runat="server"></asp:Literal>
    </div>
</div>

<!-- Workflow Timeline -->
<asp:Literal ID="litTimeline" runat="server"></asp:Literal>

<!-- ══════════════════════════════════════════════════════════════
     DOCUMENT AREA
     ══════════════════════════════════════════════════════════════ -->
<div class="lf-doc">

    <!-- MRU Letterhead -->
    <div class="lf-letterhead">
        <div class="lf-letterhead__title">Muteesa I Royal University — Employee Leave Application Form</div>
        <div class="lf-letterhead__policy">
            MRU wishes to grant you annual leave based on the following:
            <ul style="margin:6px 0 0 16px;padding:0;">
                <li>Entitlement of leave for one month, taken in two or four phases.</li>
                <li>Entitlement to pay for the month granted.</li>
                <li>The leave is entitled to permanent employees.</li>
                <li>Employees are expected to report to the Human Resources office first when commencing duties.</li>
            </ul>
        </div>
    </div>

    <!-- ════════════════════════════════════════════
         SECTION 1 — EMPLOYEE DETAILS
         ════════════════════════════════════════════ -->
    <asp:Literal ID="litSection1" runat="server"></asp:Literal>

    <!-- ════════════════════════════════════════════
         SECTION 2 — HEAD OF DEPARTMENT APPROVAL
         ════════════════════════════════════════════ -->
    <asp:Literal ID="litSection2" runat="server"></asp:Literal>

    <!-- ════════════════════════════════════════════
         SECTION 3 — HUMAN RESOURCES DEPARTMENT
         ════════════════════════════════════════════ -->
    <asp:Literal ID="litSection3" runat="server"></asp:Literal>

    <!-- ════════════════════════════════════════════
         SECTION 4 — VICE CHANCELLOR'S OFFICE
         ════════════════════════════════════════════ -->
    <asp:Literal ID="litSection4" runat="server"></asp:Literal>

</div>

<!-- Audit Trail -->
<div class="lf-audit">
    <asp:Literal ID="litAuditTrail" runat="server"></asp:Literal>
</div>

<!-- ══════════════════════════════════════════════════════════════
     STICKY ACTION BAR
     ══════════════════════════════════════════════════════════════ -->
<div class="lf-actions" id="actionBar">
    <asp:Literal ID="litActionBar" runat="server"></asp:Literal>
</div>

<!-- ══════════════════════════════════════════════════════════════
     MODALS
     ══════════════════════════════════════════════════════════════ -->

<!-- HOD Approve Modal -->
<div class="pa-modal-overlay" id="modalHodApprove">
<div class="pa-modal">
    <div class="pa-modal__head pa-modal__head--success">
        <span class="pa-modal__title">HOD Approval</span>
        <button type="button" class="pa-modal__close" onclick="closeModal('modalHodApprove')">&times;</button>
    </div>
    <div class="pa-modal__body">
        <div class="urm-field">
            <label>Handover To — Full title and name of person taking over duties</label>
            <input type="text" id="hodHandoverTo" placeholder="e.g. Mr. John Doe — Senior Lecturer" />
        </div>
        <div class="urm-field">
            <label>Notes / Remarks <span style="font-weight:400;color:#94a3b8">(optional)</span></label>
            <textarea id="hodNotes" placeholder="Any conditions or instructions…"></textarea>
        </div>
    </div>
    <div class="pa-modal__foot">
        <button type="button" class="lf-btn lf-btn--outline" onclick="closeModal('modalHodApprove')">Cancel</button>
        <button type="button" class="lf-btn lf-btn--success" id="btnHodApproveConfirm" onclick="submitHodApprove()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            Approve &amp; Forward to HR
        </button>
    </div>
</div>
</div>

<!-- HOD Decline Modal -->
<div class="pa-modal-overlay" id="modalHodDecline">
<div class="pa-modal pa-modal--sm">
    <div class="pa-modal__head pa-modal__head--danger">
        <span class="pa-modal__title">Decline Application</span>
        <button type="button" class="pa-modal__close" onclick="closeModal('modalHodDecline')">&times;</button>
    </div>
    <div class="pa-modal__body">
        <p style="font-size:12px;color:#374151;margin:0 0 14px;">Please provide a reason for declining this leave application.</p>
        <div class="urm-field">
            <label>Reason <span style="color:var(--danger)">*</span></label>
            <textarea id="hodDeclineReason" placeholder="State the reason for declining…"></textarea>
        </div>
    </div>
    <div class="pa-modal__foot">
        <button type="button" class="lf-btn lf-btn--outline" onclick="closeModal('modalHodDecline')">Cancel</button>
        <button type="button" class="lf-btn lf-btn--danger" id="btnHodDeclineConfirm" onclick="submitHodDecline()">Decline Application</button>
    </div>
</div>
</div>

<!-- HR Approve Modal -->
<div class="pa-modal-overlay" id="modalHrApprove">
<div class="pa-modal">
    <div class="pa-modal__head pa-modal__head--success">
        <span class="pa-modal__title">HR Department — Approve &amp; Forward</span>
        <button type="button" class="pa-modal__close" onclick="closeModal('modalHrApprove')">&times;</button>
    </div>
    <div class="pa-modal__body">
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">
            <div class="urm-field">
                <label>Effective From <span style="color:var(--danger)">*</span></label>
                <input type="date" id="hrEffFrom" />
            </div>
            <div class="urm-field">
                <label>Effective To <span style="color:var(--danger)">*</span></label>
                <input type="date" id="hrEffTo" />
            </div>
        </div>
        <div class="urm-field">
            <label>HR Notes <span style="font-weight:400;color:#94a3b8">(optional)</span></label>
            <textarea id="hrNotes" placeholder="Benefits confirmation, conditions, etc."></textarea>
        </div>
    </div>
    <div class="pa-modal__foot">
        <button type="button" class="lf-btn lf-btn--outline" onclick="closeModal('modalHrApprove')">Cancel</button>
        <button type="button" class="lf-btn lf-btn--success" id="btnHrApproveConfirm" onclick="submitHrApprove()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            Approve &amp; Forward to VC
        </button>
    </div>
</div>
</div>

<!-- HR Decline Modal -->
<div class="pa-modal-overlay" id="modalHrDecline">
<div class="pa-modal pa-modal--sm">
    <div class="pa-modal__head pa-modal__head--danger">
        <span class="pa-modal__title">HR — Decline Application</span>
        <button type="button" class="pa-modal__close" onclick="closeModal('modalHrDecline')">&times;</button>
    </div>
    <div class="pa-modal__body">
        <div class="urm-field">
            <label>Reason for Declining <span style="color:var(--danger)">*</span></label>
            <textarea id="hrDeclineReason" placeholder="State the reason…"></textarea>
        </div>
    </div>
    <div class="pa-modal__foot">
        <button type="button" class="lf-btn lf-btn--outline" onclick="closeModal('modalHrDecline')">Cancel</button>
        <button type="button" class="lf-btn lf-btn--danger" id="btnHrDeclineConfirm" onclick="submitHrDecline()">Decline</button>
    </div>
</div>
</div>

<!-- VC Grant Modal -->
<div class="pa-modal-overlay" id="modalVcGrant">
<div class="pa-modal">
    <div class="pa-modal__head pa-modal__head--success">
        <span class="pa-modal__title">Vice Chancellor — Grant Leave</span>
        <button type="button" class="pa-modal__close" onclick="closeModal('modalVcGrant')">&times;</button>
    </div>
    <div class="pa-modal__body">
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">
            <div class="urm-field">
                <label>Accumulated Leave Days</label>
                <input type="number" id="vcAccumDays" min="0" placeholder="e.g. 30" />
            </div>
            <div class="urm-field">
                <label>Days Taken (This Grant)</label>
                <input type="number" id="vcDaysTaken" min="0" placeholder="e.g. 15" />
            </div>
        </div>
        <div class="urm-field">
            <label>Remarks <span style="font-weight:400;color:#94a3b8">(optional)</span></label>
            <textarea id="vcGrantReason" placeholder="Any conditions attached to the grant…"></textarea>
        </div>
    </div>
    <div class="pa-modal__foot">
        <button type="button" class="lf-btn lf-btn--outline" onclick="closeModal('modalVcGrant')">Cancel</button>
        <button type="button" class="lf-btn lf-btn--success" id="btnVcGrantConfirm" onclick="submitVcDecision('GRANTED')">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            Grant Leave
        </button>
    </div>
</div>
</div>

<!-- VC Not Grant / Postpone Modal -->
<div class="pa-modal-overlay" id="modalVcOther">
<div class="pa-modal pa-modal--sm">
    <div class="pa-modal__head pa-modal__head--danger">
        <span class="pa-modal__title" id="vcOtherTitle">VC Decision</span>
        <button type="button" class="pa-modal__close" onclick="closeModal('modalVcOther')">&times;</button>
    </div>
    <div class="pa-modal__body">
        <div class="urm-field">
            <label>Reason <span style="color:var(--danger)">*</span></label>
            <textarea id="vcOtherReason" placeholder="Reason for this decision…"></textarea>
        </div>
    </div>
    <div class="pa-modal__foot">
        <button type="button" class="lf-btn lf-btn--outline" onclick="closeModal('modalVcOther')">Cancel</button>
        <button type="button" class="lf-btn lf-btn--danger" id="btnVcOtherConfirm" onclick="submitVcOther()">Confirm</button>
    </div>
</div>
</div>

<!-- Toast -->
<div class="pa-toast" id="paToast"></div>

<!-- Hidden application ID -->
<input type="hidden" id="hdnAppId" value="<asp:Literal ID="litAppId" runat="server"></asp:Literal>" />
<input type="hidden" id="hdnVcOtherDecision" value="" />

<script type="text/javascript">
var APP_ID = parseInt(document.getElementById('hdnAppId').value, 10) || 0;

// ── Modal helpers ─────────────────────────────────────────────────────────────
function openModal(id)  { document.getElementById(id).classList.add('is-open'); }
function closeModal(id) { document.getElementById(id).classList.remove('is-open'); }

// ── AJAX helper ───────────────────────────────────────────────────────────────
function doAction(action, data, btn, btnLabel, onSuccess){
    if(btn){ btn.disabled=true; btn.textContent='Please wait…'; }
    var body = 'id=' + encodeURIComponent(APP_ID);
    for(var k in data) body += '&' + encodeURIComponent(k) + '=' + encodeURIComponent(data[k]);

    fetch('LeaveApplicationForm.aspx?ajax=' + action, {
        method:'POST',
        headers:{'Content-Type':'application/x-www-form-urlencoded'},
        body: body
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
        if(btn){ btn.disabled=false; btn.textContent=btnLabel; }
        if(d.ok){
            onSuccess(d);
        } else showToast(d.error||'Action failed.','err');
    })
    .catch(function(){
        if(btn){ btn.disabled=false; btn.textContent=btnLabel; }
        showToast('Network error — please try again.','err');
    });
}

function reloadSuccess(msg){
    showToast(msg,'ok');
    setTimeout(function(){ location.reload(); }, 1100);
}

// ── Section 1: Save draft ─────────────────────────────────────────────────────
function saveDraft(submit){
    var data = collectSection1();
    if(!data) return;
    data.submit = submit ? '1' : '0';
    if(submit){
        var sup = document.getElementById('supUsername');
        if(sup && !sup.value){ showToast('Please select a Supervisor / HOD.','err'); return; }
        data.supervisor_username = sup ? sup.value : '';
        data.supervisor_name     = sup ? (sup.options[sup.selectedIndex]||{}).text||'' : '';
    }
    var btn = submit ? document.getElementById('btnSubmitApp') : document.getElementById('btnSaveDraft');
    doAction(submit ? 'submit' : 'save_draft', data, btn, submit?'Submit Application':'Save Draft', function(d){
        reloadSuccess(submit ? 'Application submitted for HOD approval.' : 'Draft saved.');
    });
}

function collectSection1(){
    function v(id){ var el=document.getElementById(id); return el?el.value.trim():''; }
    var name=v('empName'), dept=v('empDept'), lType=v('leaveType');
    var lfrom=v('leaveFrom'), lto=v('leaveTo');
    if(!name)  { showToast('Employee name is required.','err'); return null; }
    if(!lType) { showToast('Please select a leave type.','err'); return null; }
    if(!lfrom||!lto){ showToast('Leave dates are required.','err'); return null; }
    if(lfrom > lto){ showToast('End date must be after start date.','err'); return null; }
    // Auto-calculate days
    var days = Math.round((new Date(lto)-new Date(lfrom))/(864e5))+1;
    var daysEl = document.getElementById('numDays');
    if(daysEl) daysEl.value = days;
    return {
        emp_name: name, faculty_dept: dept,
        office_location: v('officeLocation'), position_held: v('positionHeld'),
        residence_address: v('residenceAddress'), mobile_contact: v('mobileContact'),
        nok_name: v('nokName'), nok_address: v('nokAddress'), nok_mobile: v('nokMobile'),
        leave_type: lType, leave_from: lfrom, leave_to: lto, num_days: days,
        substitute_arrangement: v('substituteArrangement')
    };
}

// Auto-compute days on date change
function autoCalcDays(){
    var f=document.getElementById('leaveFrom'), t=document.getElementById('leaveTo'), d=document.getElementById('numDays');
    if(!f||!t||!d||!f.value||!t.value) return;
    var days=Math.round((new Date(t.value)-new Date(f.value))/(864e5))+1;
    d.value = days > 0 ? days : 0;
}

// ── HOD Approve ───────────────────────────────────────────────────────────────
function submitHodApprove(){
    var btn=document.getElementById('btnHodApproveConfirm');
    doAction('hod_approve',{
        hod_handover_to: document.getElementById('hodHandoverTo').value.trim(),
        hod_notes:       document.getElementById('hodNotes').value.trim()
    }, btn, 'Approve & Forward to HR', function(){
        closeModal('modalHodApprove');
        reloadSuccess('Application approved and forwarded to HR.');
    });
}

// ── HOD Decline ───────────────────────────────────────────────────────────────
function submitHodDecline(){
    var reason=document.getElementById('hodDeclineReason').value.trim();
    if(!reason){ showToast('A reason is required.','err'); return; }
    var btn=document.getElementById('btnHodDeclineConfirm');
    doAction('hod_decline',{reason:reason}, btn, 'Decline Application', function(){
        closeModal('modalHodDecline');
        reloadSuccess('Application declined.');
    });
}

// ── HR Approve ────────────────────────────────────────────────────────────────
function submitHrApprove(){
    var ef=document.getElementById('hrEffFrom').value;
    var et=document.getElementById('hrEffTo').value;
    if(!ef||!et){ showToast('Please set effective dates.','err'); return; }
    var btn=document.getElementById('btnHrApproveConfirm');
    doAction('hr_approve',{
        hr_effective_from: ef, hr_effective_to: et,
        hr_notes: document.getElementById('hrNotes').value.trim()
    }, btn, 'Approve & Forward to VC', function(){
        closeModal('modalHrApprove');
        reloadSuccess('Application approved and forwarded to Vice Chancellor.');
    });
}

// ── HR Decline ────────────────────────────────────────────────────────────────
function submitHrDecline(){
    var reason=document.getElementById('hrDeclineReason').value.trim();
    if(!reason){ showToast('A reason is required.','err'); return; }
    var btn=document.getElementById('btnHrDeclineConfirm');
    doAction('hr_decline',{reason:reason}, btn, 'Decline', function(){
        closeModal('modalHrDecline');
        reloadSuccess('Application declined by HR.');
    });
}

// ── VC Grant ──────────────────────────────────────────────────────────────────
function submitVcDecision(decision){
    var btn=document.getElementById('btnVcGrantConfirm');
    doAction('vc_decision',{
        vc_decision:         decision,
        vc_reason:           document.getElementById('vcGrantReason').value.trim(),
        vc_accumulated_days: document.getElementById('vcAccumDays').value.trim(),
        vc_days_taken:       document.getElementById('vcDaysTaken').value.trim()
    }, btn, 'Grant Leave', function(){
        closeModal('modalVcGrant');
        reloadSuccess('Leave granted by the Vice Chancellor.');
    });
}

// ── VC Not Grant / Postpone ───────────────────────────────────────────────────
var _vcOtherDecision = '';
function openVcOther(decision){
    _vcOtherDecision = decision;
    document.getElementById('vcOtherTitle').textContent = decision==='NOT_GRANTED'?'VC — Not Grant':'VC — Postpone';
    document.getElementById('btnVcOtherConfirm').textContent = decision==='NOT_GRANTED'?'Not Grant':'Postpone';
    document.getElementById('vcOtherReason').value='';
    openModal('modalVcOther');
}
function submitVcOther(){
    var reason=document.getElementById('vcOtherReason').value.trim();
    if(!reason){ showToast('A reason is required.','err'); return; }
    var btn=document.getElementById('btnVcOtherConfirm');
    doAction('vc_decision',{
        vc_decision: _vcOtherDecision, vc_reason: reason,
        vc_accumulated_days:'', vc_days_taken:''
    }, btn, btn.textContent, function(){
        closeModal('modalVcOther');
        reloadSuccess(_vcOtherDecision==='NOT_GRANTED'?'Leave not granted.':'Leave postponed.');
    });
}

// ── Print ──────────────────────────────────────────────────────────────────────
function printForm(){ window.print(); }

// ── Toast ──────────────────────────────────────────────────────────────────────
function showToast(msg, type){
    var t=document.getElementById('paToast');
    t.textContent=msg;
    t.className='pa-toast visible'+(type==='err'?' pa-toast--err':'');
    clearTimeout(t._tmr);
    t._tmr=setTimeout(function(){ t.classList.remove('visible'); },3500);
}
</script>
</asp:Content>
