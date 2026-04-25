<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AppraisalDashboard.aspx.cs" Inherits="COOPERP_NewScreens_AppraisalDashboard" Title="Appraisal Dashboard - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== APPRAISAL DASHBOARD ===== */
*,*::before,*::after{box-sizing:border-box;}
:root{--brand:#174DA4;--brand-light:#e8eef8;--brand-dark:#0f3670;--success:#28a745;--danger:#dc3545;--warning:#ffc107;--info:#17a2b8;--grey:#6c757d;--grey-light:#f4f5f7;--border:#dee2e6;--radius:6px;--shadow:0 1px 3px rgba(0,0,0,.08);}

/* ── Page header ── */
.pa-page-header{display:flex;align-items:center;gap:14px;margin-bottom:18px;flex-wrap:wrap;}
.pa-page-header__icon{width:44px;height:44px;border-radius:10px;background:var(--brand);display:flex;align-items:center;justify-content:center;color:#fff;flex-shrink:0;}
.pa-page-header__title{font-size:22px;font-weight:700;color:#1a1a1a;line-height:1.2;}
.pa-page-header__sub{font-size:12px;color:#888;margin-top:1px;}
.pa-page-header__actions{margin-left:auto;display:flex;gap:8px;align-items:center;}

/* ── Session filter ── */
.pa-session-filter{display:flex;align-items:center;gap:8px;}
.pa-session-filter label{font-size:12px;font-weight:600;color:#555;white-space:nowrap;}
.pa-session-filter select{font-size:12px;padding:6px 10px;border:1px solid var(--border);border-radius:var(--radius);background:#fff;color:#333;min-width:260px;max-width:420px;}
.pa-session-filter select:focus{outline:none;border-color:var(--brand);box-shadow:0 0 0 2px rgba(23,77,164,.15);}

/* ── KPI Grid ── */
.pa-kpi-grid{display:grid;grid-template-columns:repeat(7,1fr);gap:12px;margin-bottom:18px;}
@media(max-width:1200px){.pa-kpi-grid{grid-template-columns:repeat(4,1fr);}}
@media(max-width:800px){.pa-kpi-grid{grid-template-columns:repeat(2,1fr);}}
@media(max-width:500px){.pa-kpi-grid{grid-template-columns:1fr;}}

.pa-kpi{background:#fff;border:1px solid #e0e5ed;border-top:3px solid transparent;padding:14px 16px;display:flex;align-items:center;gap:12px;border-radius:0 0 var(--radius) var(--radius);}
.pa-kpi--blue{border-top-color:var(--brand);}
.pa-kpi--green{border-top-color:var(--success);}
.pa-kpi--amber{border-top-color:#f59e0b;}
.pa-kpi--red{border-top-color:var(--danger);}
.pa-kpi--purple{border-top-color:#7c3aed;}
.pa-kpi--teal{border-top-color:#0d9488;}
.pa-kpi--cyan{border-top-color:var(--info);}

.pa-kpi__icon{width:38px;height:38px;border-radius:4px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.pa-kpi--blue .pa-kpi__icon{background:#e8f0fe;color:var(--brand);}
.pa-kpi--green .pa-kpi__icon{background:#d4edda;color:#155724;}
.pa-kpi--amber .pa-kpi__icon{background:#fff3cd;color:#856404;}
.pa-kpi--red .pa-kpi__icon{background:#f8d7da;color:#721c24;}
.pa-kpi--purple .pa-kpi__icon{background:#ede9fe;color:#5b21b6;}
.pa-kpi--teal .pa-kpi__icon{background:#ccfbf1;color:#0d9488;}
.pa-kpi--cyan .pa-kpi__icon{background:#cff4fc;color:#055160;}

.pa-kpi__body{flex:1;min-width:0;}
.pa-kpi__val{font-size:22px;font-weight:700;color:#1a1a2e;line-height:1.15;}
.pa-kpi__label{font-size:10px;color:#888;text-transform:uppercase;letter-spacing:.3px;margin-top:2px;}

/* ── Sections ── */
.pa-section{background:#fff;border:1px solid #e0e5ed;margin-bottom:16px;border-radius:var(--radius);}
.pa-section__hdr{padding:11px 16px;border-bottom:1px solid #e0e5ed;font-size:12px;font-weight:700;color:#333;display:flex;align-items:center;gap:8px;text-transform:uppercase;letter-spacing:.3px;}
.pa-section__hdr svg{flex-shrink:0;color:#666;}
.pa-section__body{padding:14px 16px;}

/* ── Two / Three col layout ── */
.pa-two-col{display:grid;grid-template-columns:1fr 1fr;gap:16px;}
@media(max-width:900px){.pa-two-col{grid-template-columns:1fr;}}
.pa-three-col{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;}
@media(max-width:1100px){.pa-three-col{grid-template-columns:1fr 1fr;}}
@media(max-width:700px){.pa-three-col{grid-template-columns:1fr;}}

/* ── Tables ── */
.pa-table{width:100%;border-collapse:collapse;font-size:12px;}
.pa-table th{text-align:left;padding:7px 10px;border-bottom:2px solid #e0e5ed;color:#666;font-weight:600;text-transform:uppercase;font-size:10px;letter-spacing:.3px;}
.pa-table td{padding:7px 10px;border-bottom:1px solid #f5f7fa;color:#333;vertical-align:middle;}
.pa-table tr:last-child td{border-bottom:none;}
.pa-table tr:hover td{background:#f9fbff;}
.pa-num{text-align:right;font-variant-numeric:tabular-nums;}

/* ── Mini progress bar ── */
.pa-mini-prog{width:60px;height:6px;background:#eee;border-radius:3px;display:inline-block;vertical-align:middle;margin-right:6px;}
.pa-mini-prog__bar{height:100%;border-radius:3px;transition:width .3s ease;}
.pa-mini-prog__text{font-size:11px;color:#555;font-weight:600;}

/* ── Status bars ── */
.pa-status-row{display:flex;align-items:center;gap:10px;padding:6px 0;}
.pa-status-row__label{font-size:12px;min-width:160px;color:#333;}
.pa-status-row__count{font-size:12px;font-weight:700;min-width:30px;text-align:right;color:#1a1a2e;}
.pa-status-row__bar{flex:1;height:8px;background:#eee;border-radius:4px;overflow:hidden;}
.pa-status-row__fill{height:100%;border-radius:4px;transition:width .4s ease;}
.pa-status-row__pct{font-size:11px;color:#888;min-width:40px;text-align:right;}
.pa-status-empty{text-align:center;color:#999;padding:20px;font-size:13px;}

/* ── Record badge ── */
.pa-rec-badge{display:inline-block;padding:2px 8px;border-radius:3px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;}
.pa-rec-badge--pending{background:#e2e3e5;color:#383d41;}
.pa-rec-badge--emp-prog{background:#cff4fc;color:#055160;}
.pa-rec-badge--emp-done{background:#cce5ff;color:#004085;}
.pa-rec-badge--sup-prog{background:#fff3cd;color:#856404;}
.pa-rec-badge--completed{background:#d4edda;color:#155724;}
.pa-rec-badge--cancelled{background:#f8d7da;color:#721c24;}

/* ── Alerts ── */
.pa-alert-item{padding:10px 14px;border-left:3px solid transparent;margin-bottom:8px;border-radius:0 var(--radius) var(--radius) 0;background:#f8f9fa;}
.pa-alert-item--critical{border-left-color:var(--danger);background:#fff5f5;}
.pa-alert-item--high{border-left-color:#f59e0b;background:#fffbeb;}
.pa-alert-item--medium{border-left-color:var(--info);background:#f0f9ff;}
.pa-alert-item__title{font-size:13px;font-weight:600;color:#1a1a2e;margin-bottom:2px;}
.pa-alert-item__detail{font-size:11px;color:#666;}
.pa-no-alerts{display:flex;align-items:center;gap:8px;padding:16px;color:#28a745;font-size:13px;font-weight:500;}

/* ── Alert banner ── */
.pa-alert--error{padding:12px 16px;background:#f8d7da;color:#721c24;border-radius:var(--radius);margin-bottom:14px;font-size:13px;}

/* ── Quick links ── */
.pa-quicklinks{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;}
@media(max-width:700px){.pa-quicklinks{grid-template-columns:1fr;}}
.pa-quicklink{display:flex;align-items:center;gap:10px;padding:12px 16px;background:#f8f9fa;border:1px solid #e0e5ed;border-radius:var(--radius);text-decoration:none;color:#333;font-size:12px;font-weight:600;transition:all .15s ease;}
.pa-quicklink:hover{background:var(--brand-light);border-color:var(--brand);color:var(--brand);}
.pa-quicklink__icon{width:32px;height:32px;border-radius:6px;background:var(--brand-light);color:var(--brand);display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.pa-quicklink:hover .pa-quicklink__icon{background:var(--brand);color:#fff;}

/* ── Buttons ── */
.hr-btn{display:inline-flex;align-items:center;gap:6px;padding:7px 14px;font-size:12px;font-weight:600;border:none;border-radius:var(--radius);cursor:pointer;transition:all .15s ease;text-decoration:none;}
.hr-btn--primary{background:var(--brand);color:#fff;}
.hr-btn--primary:hover{background:var(--brand-dark);}
.hr-btn--outline{background:transparent;border:1px solid var(--border);color:#555;}
.hr-btn--outline:hover{border-color:var(--brand);color:var(--brand);}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ── Page Header ── -->
<div class="pa-page-header">
    <div class="pa-page-header__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="9" y1="3" x2="9" y2="21"/><line x1="15" y1="3" x2="15" y2="21"/></svg>
    </div>
    <div>
        <div class="pa-page-header__title">Appraisal Dashboard</div>
        <div class="pa-page-header__sub">Monitor performance appraisal progress across the institution</div>
    </div>
    <div class="pa-page-header__actions">
        <div class="pa-session-filter">
            <label>Session:</label>
            <select id="selSession" onchange="filterBySession(this.value)">
                <asp:Literal ID="litSessionOptions" runat="server" />
            </select>
        </div>
    </div>
</div>

<!-- ── KPI Cards ── -->
<div class="pa-kpi-grid">
    <div class="pa-kpi pa-kpi--blue">
        <div class="pa-kpi__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
        <div class="pa-kpi__body">
            <div class="pa-kpi__val"><asp:Literal ID="litKpiTotal" runat="server" Text="0" /></div>
            <div class="pa-kpi__label">Total Appraisals</div>
        </div>
    </div>
    <div class="pa-kpi pa-kpi--green">
        <div class="pa-kpi__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
        </div>
        <div class="pa-kpi__body">
            <div class="pa-kpi__val"><asp:Literal ID="litKpiCompleted" runat="server" Text="0" /></div>
            <div class="pa-kpi__label">Completed</div>
        </div>
    </div>
    <div class="pa-kpi pa-kpi--cyan">
        <div class="pa-kpi__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        </div>
        <div class="pa-kpi__body">
            <div class="pa-kpi__val"><asp:Literal ID="litKpiInProgress" runat="server" Text="0" /></div>
            <div class="pa-kpi__label">In Progress</div>
        </div>
    </div>
    <div class="pa-kpi pa-kpi--amber">
        <div class="pa-kpi__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        </div>
        <div class="pa-kpi__body">
            <div class="pa-kpi__val"><asp:Literal ID="litKpiPending" runat="server" Text="0" /></div>
            <div class="pa-kpi__label">Pending</div>
        </div>
    </div>
    <div class="pa-kpi pa-kpi--red">
        <div class="pa-kpi__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        </div>
        <div class="pa-kpi__body">
            <div class="pa-kpi__val"><asp:Literal ID="litKpiOverdue" runat="server" Text="0" /></div>
            <div class="pa-kpi__label">Overdue</div>
        </div>
    </div>
    <div class="pa-kpi pa-kpi--purple">
        <div class="pa-kpi__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div class="pa-kpi__body">
            <div class="pa-kpi__val"><asp:Literal ID="litKpiCompletion" runat="server" Text="0%" /></div>
            <div class="pa-kpi__label">Completion Rate</div>
        </div>
    </div>
    <div class="pa-kpi pa-kpi--teal">
        <div class="pa-kpi__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
        </div>
        <div class="pa-kpi__body">
            <div class="pa-kpi__val"><asp:Literal ID="litKpiAvgScore" runat="server" Text="—" /></div>
            <div class="pa-kpi__label">Avg Score</div>
        </div>
    </div>
</div>

<!-- ── Main Content: Two-Column Layout ── -->
<div class="pa-two-col">

    <!-- LEFT: Category + Department Breakdown -->
    <div>
        <!-- Category Breakdown -->
        <div class="pa-section">
            <div class="pa-section__hdr">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                By Staff Category
            </div>
            <div class="pa-section__body" style="padding:0;">
                <table class="pa-table">
                    <thead>
                        <tr>
                            <th>Category</th>
                            <th style="text-align:right;">Total</th>
                            <th style="text-align:right;">Done</th>
                            <th style="text-align:right;">In Prog</th>
                            <th style="text-align:right;">Pending</th>
                            <th>Progress</th>
                            <th style="text-align:right;">Avg</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Literal ID="litCategoryRows" runat="server" />
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Department Breakdown -->
        <div class="pa-section">
            <div class="pa-section__hdr">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                By Department
            </div>
            <div class="pa-section__body" style="padding:0;">
                <table class="pa-table">
                    <thead>
                        <tr>
                            <th>Department</th>
                            <th style="text-align:right;">Total</th>
                            <th style="text-align:right;">Done</th>
                            <th>Progress</th>
                            <th style="text-align:right;">Avg Score</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Literal ID="litDeptRows" runat="server" />
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- RIGHT: Status Chart + Alerts -->
    <div>
        <!-- Status Distribution -->
        <div class="pa-section">
            <div class="pa-section__hdr">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                Status Distribution
            </div>
            <div class="pa-section__body">
                <asp:Literal ID="litStatusBars" runat="server" />
            </div>
        </div>

        <!-- Overdue Alerts -->
        <div class="pa-section">
            <div class="pa-section__hdr">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                Overdue Alerts
            </div>
            <div class="pa-section__body">
                <asp:Literal ID="litAlerts" runat="server" />
            </div>
        </div>

        <!-- Quick Links -->
        <div class="pa-section">
            <div class="pa-section__hdr">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                Quick Links
            </div>
            <div class="pa-section__body">
                <div class="pa-quicklinks">
                    <a href="AppraisalSessions.aspx" class="pa-quicklink">
                        <div class="pa-quicklink__icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        </div>
                        Manage Sessions
                    </a>
                    <a href="AppraisalView.aspx" class="pa-quicklink">
                        <div class="pa-quicklink__icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                        </div>
                        View Appraisals
                    </a>
                    <a href="HREmployees.aspx" class="pa-quicklink">
                        <div class="pa-quicklink__icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                        Employee Profiles
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ── Recent Activity (Full Width) ── -->
<div class="pa-section">
    <div class="pa-section__hdr">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        Recent Activity
    </div>
    <div class="pa-section__body" style="padding:0;">
        <table class="pa-table">
            <thead>
                <tr>
                    <th>Employee</th>
                    <th>Session</th>
                    <th>Status</th>
                    <th style="text-align:right;">Score</th>
                    <th>Updated</th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litRecentRows" runat="server" />
            </tbody>
        </table>
    </div>
</div>

<script type="text/javascript">
function filterBySession(sid) {
    var url = 'AppraisalDashboard.aspx';
    if (sid && sid !== '0') url += '?sid=' + sid;
    window.location.href = url;
}
</script>

</asp:Content>
