<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="BillingHealth.aspx.cs" Inherits="COOPERP_NewScreens_BillingHealth" Title="Billing Health - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.bh-wrap { font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif; color:#1a1a2e; padding:4px 2px; }
.bh-head { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; margin-bottom:14px; }
.bh-head h1 { font-size:18px; font-weight:700; color:#05275C; margin:0; }
.bh-head p { font-size:12px; color:#5a6472; margin:2px 0 0; }
.bh-actions { display:flex; gap:8px; }
.bh-btn { border:1px solid #05275C; background:#05275C; color:#fff; font-size:12px; font-weight:600; padding:8px 14px; border-radius:0; cursor:pointer; }
.bh-btn--ghost { background:#fff; color:#05275C; }
.bh-btn:hover { opacity:.92; }
.bh-section { background:#fff; border:1px solid #e0e5ed; border-radius:4px; padding:16px; margin-bottom:14px; }
.bh-section__h { font-size:13px; font-weight:700; color:#05275C; margin:0 0 12px; text-transform:uppercase; letter-spacing:.4px; }
.bh-cards { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.bh-cards--single { grid-template-columns:1fr; }
.bh-card { border:1px solid #e0e5ed; border-radius:4px; padding:14px; background:#f5f7fa; }
.bh-card__head { display:flex; align-items:center; justify-content:space-between; margin-bottom:12px; }
.bh-card__title { font-size:13px; font-weight:700; color:#174DA4; }
.bh-badge { font-size:11px; font-weight:700; padding:4px 10px; border-radius:0; }
.bh-badge--ok { background:rgba(22,140,74,.12); color:#128a4a; }
.bh-badge--warn { background:rgba(200,120,0,.14); color:#b5720a; }
.bh-metrics { display:grid; grid-template-columns:1fr 1fr 1fr 1fr; gap:8px; }
.bh-metric { text-align:center; padding:10px 4px; border-radius:2px; background:#fff; border:1px solid #e0e5ed; }
.bh-metric__val { font-size:20px; font-weight:700; line-height:1; }
.bh-metric__lbl { font-size:10px; color:#5a6472; margin-top:5px; }
.bh-metric--good .bh-metric__val { color:#128a4a; }
.bh-metric--bad .bh-metric__val { color:#c0392b; }
.bh-jobgrid { display:grid; grid-template-columns:repeat(5,1fr); gap:8px; }
.bh-field { background:#f5f7fa; border:1px solid #e0e5ed; border-radius:2px; padding:8px 10px; }
.bh-field__k { display:block; font-size:10px; color:#5a6472; text-transform:uppercase; letter-spacing:.3px; }
.bh-field__v { display:block; font-size:13px; font-weight:600; color:#1a1a2e; margin-top:3px; }
.bh-jobmsg { margin-top:10px; font-size:12px; color:#33415c; background:#f5f7fa; border-left:3px solid #174DA4; padding:8px 12px; }
.bh-muted { font-size:12px; color:#8a94a6; }
.bh-err { font-size:12px; color:#c0392b; }
.bh-note { font-size:11.5px; color:#5a6472; margin-top:4px; }
.bh-toast { background:#05275C; color:#fff; font-size:12px; padding:10px 14px; border-radius:2px; margin-bottom:12px; }
@media (max-width:820px){ .bh-cards{grid-template-columns:1fr;} .bh-jobgrid{grid-template-columns:repeat(2,1fr);} .bh-metrics{grid-template-columns:1fr 1fr;} }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="bh-wrap">

    <div class="bh-head">
        <div>
            <h1>Billing Health</h1>
            <p>Live consistency check of enrolment billing &mdash; won't miss a bill, won't double-bill. Current year: <b><asp:Literal ID="litYear" runat="server" /></b></p>
        </div>
        <div class="bh-actions">
            <asp:Button ID="btnRerun" runat="server" CssClass="bh-btn bh-btn--ghost" Text="Re-run Audit" OnClick="btnRerun_Click" />
            <asp:Button ID="btnRunNow" runat="server" CssClass="bh-btn" Text="Run Reconcile Now" OnClick="btnRunNow_Click"
                OnClientClick="return confirm('Run the billing reconciliation sweep now? It will register + bill any enrolled student that is missing a bill (idempotent, capped).');" />
        </div>
    </div>

    <asp:Literal ID="litToast" runat="server" />

    <!-- Consistency audit -->
    <div class="bh-section">
        <div class="bh-section__h">Consistency Audit</div>
        <div class="bh-cards bh-cards--single">
            <asp:Literal ID="litAuditYear" runat="server" />
        </div>
        <div class="bh-note">
            <b>Double bills</b> = &gt;1 bill for the same student/semester/item (real fee items only) &middot;
            <b>Registered &middot; unbilled</b> = an enrolled row with no tuition bill &middot;
            <b>Cache mismatches</b> = balance cache out of step (auto-heals) &middot;
            <b>Orphan bills</b> = a bill for a semester the student is now UNREGISTERED for.
        </div>
    </div>

    <!-- Reconcile job -->
    <div class="bh-section">
        <div class="bh-section__h">Auto-Reconcile Engine</div>
        <asp:Literal ID="litJob" runat="server" />
        <div class="bh-note">Runs every N hours across all three semesters, billing any enrolled (has-courses) student that lacks a bill. Fully idempotent and capped against runaways.</div>
    </div>

</div>
</asp:Content>
