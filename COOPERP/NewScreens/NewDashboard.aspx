<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewDashboard.aspx.cs" Inherits="COOPERP_NewScreens_NewDashboard" Title="Dashboard - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        /* =============================================
           DASHBOARD STYLES - Executive Summary View
           ============================================= */
        
        /* Main Layout - Stats left, Quick Access right */
        .dashboard-layout {
            display: grid;
            grid-template-columns: 1fr 220px;
            gap: 16px;
        }
        @media (max-width: 1100px) { 
            .dashboard-layout { grid-template-columns: 1fr; }
            .quick-access-panel { order: -1; }
        }
        
        .main-content { min-width: 0; }
        
        /* Stats Grid - 4 columns */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 14px;
        }
        @media (max-width: 1200px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 600px) { .stats-grid { grid-template-columns: 1fr; } }
        
        /* Stat Cards - Compact */
        .stat-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            padding: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .stat-card__icon {
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .stat-card__icon svg { width: 18px; height: 18px; }
        .stat-card__icon--blue { background: #e3f2fd; color: #1976d2; }
        .stat-card__icon--green { background: #e8f5e9; color: #388e3c; }
        .stat-card__icon--orange { background: #fff3e0; color: #f57c00; }
        .stat-card__icon--purple { background: #f3e5f5; color: #7b1fa2; }
        .stat-card__icon--teal { background: #e0f2f1; color: #00897b; }
        .stat-card__icon--red { background: #ffebee; color: #d32f2f; }
        .stat-card__icon--indigo { background: #e8eaf6; color: #3949ab; }
        .stat-card__icon--cyan { background: #e0f7fa; color: #0097a7; }
        .stat-card__content { flex: 1; min-width: 0; }
        .stat-card__value {
            font-size: 18px;
            font-weight: 700;
            color: #333;
            line-height: 1.1;
        }
        .stat-card__label {
            font-size: 9px;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            margin-top: 2px;
        }
        .stat-card__sub {
            font-size: 9px;
            color: #666;
            margin-top: 3px;
        }
        .stat-card__sub span { font-weight: 600; }
        
        /* Charts Row */
        .charts-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 14px;
        }
        @media (max-width: 900px) { .charts-row { grid-template-columns: 1fr; } }
        
        /* Section Card */
        .section-card {
            background: #fff;
            border: 1px solid #e0e0e0;
        }
        .section-card__header {
            padding: 8px 12px;
            border-bottom: 1px solid #e0e0e0;
            background: #fafafa;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .section-card__title {
            font-size: 10px;
            font-weight: 600;
            color: #333;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .section-card__title svg { width: 13px; height: 13px; color: #174DA4; }
        .section-card__body { padding: 12px; }
        
        /* Chart Container */
        .chart-container {
            position: relative;
            height: 180px;
        }
        
        /* Summary Tables Row */
        .summary-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
            margin-bottom: 14px;
        }
        @media (max-width: 1000px) { .summary-row { grid-template-columns: 1fr 1fr; } }
        @media (max-width: 700px) { .summary-row { grid-template-columns: 1fr; } }
        
        /* Mini Table */
        .mini-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 10px;
        }
        .mini-table th {
            text-align: left;
            padding: 6px 8px;
            background: #f5f5f5;
            font-weight: 600;
            color: #555;
            border-bottom: 1px solid #e0e0e0;
        }
        .mini-table td {
            padding: 6px 8px;
            border-bottom: 1px solid #f0f0f0;
            color: #333;
        }
        .mini-table tr:last-child td { border-bottom: none; }
        .mini-table td:last-child { text-align: right; font-weight: 600; color: #174DA4; }
        
        /* Progress Bar */
        .progress-mini {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 8px;
        }
        .progress-mini:last-child { margin-bottom: 0; }
        .progress-mini__label {
            font-size: 9px;
            color: #666;
            width: 100px;
            flex-shrink: 0;
        }
        .progress-mini__bar {
            flex: 1;
            height: 6px;
            background: #f0f0f0;
            overflow: hidden;
        }
        .progress-mini__fill {
            height: 100%;
            background: #174DA4;
        }
        .progress-mini__value {
            font-size: 9px;
            font-weight: 600;
            color: #333;
            width: 35px;
            text-align: right;
        }
        
        /* Quick Access Panel */
        .quick-access-panel {
            background: #fff;
            border: 1px solid #e0e0e0;
            height: fit-content;
            position: sticky;
            top: 56px;
        }
        .quick-access-panel .section-card__body { padding: 8px; }
        
        .quick-link {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 10px;
            text-decoration: none;
            color: #333;
            font-size: 10px;
            border-bottom: 1px solid #f0f0f0;
            transition: all 0.15s ease;
        }
        .quick-link:last-child { border-bottom: none; }
        .quick-link:hover {
            background: #174DA4;
            color: #fff;
        }
        .quick-link svg { width: 14px; height: 14px; flex-shrink: 0; }
        
        /* Metric Highlight */
        .metric-highlight {
            text-align: center;
            padding: 12px 8px;
            border-bottom: 1px solid #f0f0f0;
        }
        .metric-highlight:last-child { border-bottom: none; }
        .metric-highlight__value {
            font-size: 20px;
            font-weight: 700;
            color: #174DA4;
        }
        .metric-highlight__label {
            font-size: 9px;
            color: #888;
            text-transform: uppercase;
            margin-top: 2px;
        }
        
        /* Alert Item */
        .alert-item {
            display: flex;
            gap: 8px;
            padding: 8px;
            background: #fff8e1;
            border-left: 3px solid #ffc107;
            margin-bottom: 8px;
            font-size: 10px;
        }
        .alert-item:last-child { margin-bottom: 0; }
        .alert-item--info { background: #e3f2fd; border-left-color: #2196f3; }
        .alert-item--success { background: #e8f5e9; border-left-color: #4caf50; }
        .alert-item svg { width: 14px; height: 14px; flex-shrink: 0; color: #f57c00; }
        .alert-item--info svg { color: #2196f3; }
        .alert-item--success svg { color: #4caf50; }

        /* ── Role-aware additions ───────────────────────────────────────── */
        .dash-welcome{background:#fff;border:1px solid #e0e5ed;border-radius:6px;padding:16px 20px;margin-bottom:16px;display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;}
        .dash-welcome__hi{font-size:17px;font-weight:700;color:#05275C;margin:0;}
        .dash-welcome__sub{font-size:12px;color:#64748b;margin-top:3px;}
        .dash-welcome__roles{display:flex;gap:6px;flex-wrap:wrap;align-items:center;}
        .dash-roles-label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#94a3b8;margin-right:2px;}
        .dash-rolechip{display:inline-flex;align-items:center;gap:6px;padding:4px 12px;border-radius:20px;color:#fff;font-size:11px;font-weight:600;white-space:nowrap;}
        .dash-rolechip__dot{width:8px;height:8px;border-radius:50%;background:rgba(255,255,255,.7);}
        .dash-rolechip--none{background:#fff;color:#92400e;border:1px solid #fde68a;}
        .dash-section{display:flex;align-items:baseline;gap:10px;margin:20px 0 10px;}
        .dash-section__title{font-size:14px;font-weight:700;color:#1a1a2e;margin:0;display:flex;align-items:center;gap:8px;}
        .dash-section__title svg{width:16px;height:16px;color:#174DA4;}
        .dash-section__hint{font-size:11px;color:#94a3b8;}
        .dash-noaccess{background:#fff;border:1px solid #e0e5ed;border-radius:6px;padding:52px 24px;text-align:center;color:#64748b;}
        .dash-noaccess svg{width:46px;height:46px;color:#cbd5e1;margin-bottom:12px;}
        .dash-noaccess h2{font-size:16px;color:#05275C;margin:0 0 6px;}
        .dash-noaccess p{font-size:13px;margin:0;line-height:1.6;}
        .stat-card__icon--money{background:#e8f5e9;color:#16a34a;}
        .stat-card__icon--amber{background:#fff7ed;color:#ea580c;}
        .stat-card__icon--slate{background:#eef2ff;color:#475569;}
        /* Your Faculty card */
        .myfac-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:14px;}
        .myfac-card{background:linear-gradient(135deg,#05275C,#174DA4);color:#fff;border-radius:8px;padding:18px 20px;box-shadow:0 4px 16px rgba(5,39,92,.25);}
        .myfac-card--dept{background:linear-gradient(135deg,#0d9488,#0f766e);box-shadow:0 4px 16px rgba(13,148,136,.25);}
        .myfac-card__top{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
        .myfac-card__abbr{font-size:11px;font-weight:700;letter-spacing:.5px;background:rgba(255,255,255,.18);padding:3px 10px;border-radius:20px;}
        .myfac-card__role{font-size:11px;color:rgba(255,255,255,.85);}
        .myfac-card__name{font-size:15px;font-weight:700;line-height:1.35;margin-bottom:14px;}
        .myfac-card__stats{display:flex;gap:26px;margin-bottom:14px;}
        .myfac-card__stats b{display:block;font-size:22px;font-weight:800;line-height:1;}
        .myfac-card__stats span{font-size:11px;color:rgba(255,255,255,.8);}
        .myfac-card__link{display:inline-block;font-size:12px;font-weight:600;color:#fff;text-decoration:none;border-bottom:1px solid rgba(255,255,255,.5);padding-bottom:1px;}
        .myfac-card__link:hover{border-bottom-color:#fff;}
        /* Faculty Overview (square, tight, graph-driven) */
        .fo-kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(148px,1fr));gap:8px;margin:0 0 8px;}
        .fo-kpi{background:#fff;border:1px solid #e0e5ed;border-left:3px solid #174DA4;border-radius:0;padding:10px 12px;}
        .fo-kpi__v{font-size:22px;font-weight:800;color:#05275C;line-height:1;}
        .fo-kpi__l{font-size:11px;color:#64748b;margin-top:4px;}
        .fo-kpi__s{font-size:10px;color:#94a3b8;margin-top:3px;}
        .fo-charts{display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;margin:0 0 8px;}
        @media(max-width:900px){.fo-charts{grid-template-columns:1fr;}}
        .fo-chart{background:#fff;border:1px solid #e0e5ed;border-radius:0;padding:10px 12px;}
        .fo-chart__t{font-size:11px;font-weight:700;color:#05275C;margin-bottom:8px;}
        .fo-chart__c{position:relative;height:185px;}
        .fo-table-card{background:#fff;border:1px solid #e0e5ed;border-radius:0;margin-bottom:8px;}
        .fo-table-card__t{font-size:11px;font-weight:700;color:#05275C;padding:9px 12px;border-bottom:1px solid #e0e5ed;}
        .fo-table-wrap{overflow-x:auto;}
        .fo-table{width:100%;border-collapse:collapse;font-size:12px;}
        .fo-table th{background:#f5f7fa;color:#374151;font-weight:600;font-size:10px;text-transform:uppercase;letter-spacing:.4px;text-align:left;padding:7px 12px;border-bottom:1px solid #e0e5ed;}
        .fo-table td{padding:7px 12px;border-bottom:1px solid #f1f5f9;color:#374151;}
        .fo-table tr:hover td{background:#f8fafc;}
        .fo-code{font-family:monospace;font-size:10px;color:#174DA4;background:#f5f7fa;border:1px solid #e0e5ed;padding:1px 6px;}
        .fo-badge{display:inline-block;font-size:9px;font-weight:700;border-radius:0;padding:2px 7px;text-transform:uppercase;}
        .fo-badge--ok{background:#e8f5e9;color:#166534;border:1px solid #bbf7d0;}
        .fo-badge--warn{background:#fff7ed;color:#b45309;border:1px solid #fde68a;}
        .fo-empty{text-align:center;color:#94a3b8;padding:18px;}
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <!-- Personalised welcome header -->
    <div class="dash-welcome">
        <div>
            <h1 class="dash-welcome__hi"><asp:Literal ID="litGreeting" runat="server" Text="Welcome" /></h1>
            <div class="dash-welcome__sub"><asp:Literal ID="litWelcomeSub" runat="server" /></div>
        </div>
        <div class="dash-welcome__roles">
            <span class="dash-roles-label">Your roles</span>
            <asp:Literal ID="litRoleChips" runat="server" />
        </div>
    </div>

    <!-- Your Faculty (shown when the user is a faculty dean) -->
    <asp:Panel ID="pnlMyFaculty" runat="server" Visible="false">
        <div class="dash-section">
            <span class="dash-section__title"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>Your Faculty</span>
            <span class="dash-section__hint">The faculty you head as Dean</span>
        </div>
        <div class="myfac-grid"><asp:Literal ID="litMyFaculty" runat="server" /></div>
    </asp:Panel>

    <!-- Your Department (shown when the user is a Head of Department) -->
    <asp:Panel ID="pnlMyDept" runat="server" Visible="false">
        <div class="dash-section">
            <span class="dash-section__title"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>Your Department</span>
            <span class="dash-section__hint">The department you head (HOD)</span>
        </div>
        <div class="myfac-grid"><asp:Literal ID="litMyDept" runat="server" /></div>
    </asp:Panel>

    <!-- Scoped Overview (Dean=faculty, HOD=department — dynamic, reusable widget) -->
    <asp:Panel ID="pnlFacultyOverview" runat="server" Visible="false">
        <div class="dash-section">
            <span class="dash-section__title"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg><asp:Literal ID="litFoTitle" runat="server" Text="Overview" /></span>
            <span class="dash-section__hint"><asp:Literal ID="litFoHint" runat="server" /></span>
        </div>

        <div class="fo-kpis">
            <div class="fo-kpi"><div class="fo-kpi__v"><asp:Label ID="lblFoProgrammes" runat="server" Text="—" /></div><div class="fo-kpi__l">Programmes</div></div>
            <div class="fo-kpi"><div class="fo-kpi__v"><asp:Label ID="lblFoStudents" runat="server" Text="—" /></div><div class="fo-kpi__l">Students</div><div class="fo-kpi__s">Total enrolled</div></div>
            <div class="fo-kpi"><div class="fo-kpi__v"><asp:Label ID="lblFoActive" runat="server" Text="—" /></div><div class="fo-kpi__l">Registered</div><div class="fo-kpi__s"><asp:Label ID="lblFoActiveSub" runat="server" /></div></div>
            <div class="fo-kpi"><div class="fo-kpi__v"><asp:Label ID="lblFoLecturers" runat="server" Text="—" /></div><div class="fo-kpi__l">Lecturers</div></div>
            <div class="fo-kpi"><div class="fo-kpi__v"><asp:Label ID="lblFoPassRate" runat="server" Text="—" /></div><div class="fo-kpi__l">Pass rate</div><div class="fo-kpi__s"><asp:Label ID="lblFoPassSub" runat="server" /></div></div>
        </div>

        <div class="fo-charts">
            <div class="fo-chart"><div class="fo-chart__t">Students by gender</div><div class="fo-chart__c"><canvas id="foGenderChart"></canvas></div></div>
            <div class="fo-chart"><div class="fo-chart__t">Top programmes by enrolment</div><div class="fo-chart__c"><canvas id="foProgChart"></canvas></div></div>
            <div class="fo-chart"><div class="fo-chart__t">Enrolment trend</div><div class="fo-chart__c"><canvas id="foEnrollChart"></canvas></div></div>
        </div>

        <div class="fo-table-card">
            <div class="fo-table-card__t"><asp:Literal ID="litFoTableTitle" runat="server" Text="Programmes" /></div>
            <div class="fo-table-wrap">
                <table class="fo-table">
                    <thead><tr><th style="width:90px;">Code</th><th>Programme</th><th style="width:90px;text-align:right;">Students</th><th style="width:120px;">Status</th></tr></thead>
                    <tbody><asp:Literal ID="litFoProgrammes" runat="server" /></tbody>
                </table>
            </div>
        </div>

        <asp:HiddenField ID="hfFoGender" runat="server" />
        <asp:HiddenField ID="hfFoProgrammes" runat="server" />
        <asp:HiddenField ID="hfFoEnroll" runat="server" />
    </asp:Panel>

    <!-- No-access state (user has no role yet) -->
    <asp:Panel ID="pnlNoAccess" runat="server" Visible="false">
        <div class="dash-noaccess">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
            <h2>Your access is being set up</h2>
            <p>You don't have a role assigned yet, so there are no modules to show here.<br>Please contact your system administrator to be granted access.</p>
        </div>
    </asp:Panel>

    <!-- FEES & BURSARY -->
    <asp:Panel ID="pnlFees" runat="server" Visible="false">
        <div class="dash-section">
            <span class="dash-section__title"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>Fees &amp; Bursary</span>
            <span class="dash-section__hint">Student fees collection &amp; billing</span>
        </div>
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--green"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblFeesMonth" runat="server" Text="—" /></div><div class="stat-card__label">Collected this month</div><div class="stat-card__sub"><asp:Label ID="lblFeesMonthName" runat="server" /></div></div></div>
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--blue"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblFeesYearCollected" runat="server" Text="—" /></div><div class="stat-card__label">Collected this year</div><div class="stat-card__sub">Jan–today</div></div></div>
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--teal"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblFeesYearBilled" runat="server" Text="—" /></div><div class="stat-card__label">Billed this year</div><div class="stat-card__sub">Total invoices</div></div></div>
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--amber"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblFeesOutstanding" runat="server" Text="—" /></div><div class="stat-card__label">Outstanding this year</div><div class="stat-card__sub">Billed − collected</div></div></div>
        </div>
    </asp:Panel>

    <!-- FINANCE & ACCOUNTS -->
    <asp:Panel ID="pnlAccounts" runat="server" Visible="false">
        <div class="dash-section">
            <span class="dash-section__title"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>Finance &amp; Accounts</span>
            <span class="dash-section__hint">General ledger &amp; expenditure</span>
        </div>
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--blue"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblAcctTxMonth" runat="server" Text="—" /></div><div class="stat-card__label">Transactions this month</div><div class="stat-card__sub">Ledger postings</div></div></div>
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--slate"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 3v18h18"></path><rect x="7" y="9" width="3" height="9"></rect><rect x="14" y="5" width="3" height="13"></rect></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblAcctAccounts" runat="server" Text="—" /></div><div class="stat-card__label">Active accounts</div><div class="stat-card__sub">In the ledger</div></div></div>
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--amber"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblAcctPendingFin" runat="server" Text="—" /></div><div class="stat-card__label">Requisitions awaiting finance</div><div class="stat-card__sub">Pending payment</div></div></div>
        </div>
    </asp:Panel>

    <!-- REQUISITIONS -->
    <asp:Panel ID="pnlReq" runat="server" Visible="false">
        <div class="dash-section">
            <span class="dash-section__title"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 11l3 3L22 4"></path><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>Requisitions</span>
            <span class="dash-section__hint">Procurement &amp; approvals</span>
        </div>
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--amber"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblReqPending" runat="server" Text="—" /></div><div class="stat-card__label">Pending requisitions</div><div class="stat-card__sub">Awaiting action</div></div></div>
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--money"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblReqValue" runat="server" Text="—" /></div><div class="stat-card__label">Pending value</div><div class="stat-card__sub">Total amount</div></div></div>
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--indigo"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblReqTotal" runat="server" Text="—" /></div><div class="stat-card__label">Total requisitions</div><div class="stat-card__sub">All time</div></div></div>
        </div>
    </asp:Panel>

    <!-- HUMAN RESOURCE -->
    <asp:Panel ID="pnlHr" runat="server" Visible="false">
        <div class="dash-section">
            <span class="dash-section__title"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>Human Resource</span>
            <span class="dash-section__hint">Staff, contracts &amp; leave</span>
        </div>
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--blue"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblHrEmployees" runat="server" Text="—" /></div><div class="stat-card__label">Employees</div><div class="stat-card__sub">On record</div></div></div>
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--teal"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblHrContracts" runat="server" Text="—" /></div><div class="stat-card__label">Employee contracts</div><div class="stat-card__sub">Recorded</div></div></div>
            <div class="stat-card"><div class="stat-card__icon stat-card__icon--amber"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line></svg></div>
                <div class="stat-card__content"><div class="stat-card__value"><asp:Label ID="lblHrPendingLeave" runat="server" Text="—" /></div><div class="stat-card__label">Pending leave requests</div><div class="stat-card__sub">Awaiting approval</div></div></div>
        </div>
    </asp:Panel>

    <!-- ACADEMICS (existing dashboard) -->
    <asp:Panel ID="pnlAcademics" runat="server">
    <div class="dashboard-layout">
        <!-- Main Content Area -->
        <div class="main-content">
            <!-- Row 1: Key Student Metrics -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--blue">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblTotalStudents" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Total Students</div>
                        <div class="stat-card__sub">M: <span><asp:Label ID="lblMaleStudents" runat="server" Text="0"></asp:Label></span> | F: <span><asp:Label ID="lblFemaleStudents" runat="server" Text="0"></asp:Label></span></div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--green">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><polyline points="17 11 19 13 23 9"></polyline></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblCurrentEnrollments" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Current Enrollments</div>
                        <div class="stat-card__sub"><asp:Label ID="lblCurrentYear" runat="server" Text="2025/2026"></asp:Label></div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--orange">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblApplications" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Applications</div>
                        <div class="stat-card__sub">All time records</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--purple">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"></path><path d="M6 12v5c3 3 9 3 12 0v-5"></path></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblExamResults" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Exam Results</div>
                        <div class="stat-card__sub">Total records</div>
                    </div>
                </div>
            </div>
            
            <!-- Row 2: Academic Structure Metrics -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--teal">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblFaculties" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Faculties</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--indigo">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblProgrammes" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Programmes</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--cyan">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblSpecialisations" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Specialisations</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--red">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblCourses" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Courses</div>
                    </div>
                </div>
            </div>
            
            <!-- Charts Row -->
            <div class="charts-row">
                <!-- Enrollment Trend Chart -->
                <div class="section-card">
                    <div class="section-card__header">
                        <span class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
                            Enrollment Trend (5 Years)
                        </span>
                    </div>
                    <div class="section-card__body">
                        <div class="chart-container">
                            <canvas id="enrollmentChart"></canvas>
                        </div>
                    </div>
                </div>
                
                <!-- Gender Distribution Chart -->
                <div class="section-card">
                    <div class="section-card__header">
                        <span class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.21 15.89A10 10 0 1 1 8 2.83"></path><path d="M22 12A10 10 0 0 0 12 2v10z"></path></svg>
                            Student Gender Distribution
                        </span>
                    </div>
                    <div class="section-card__body">
                        <div class="chart-container">
                            <canvas id="genderChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Summary Tables Row -->
            <div class="summary-row">
                <!-- Configuration Status -->
                <div class="section-card">
                    <div class="section-card__header">
                        <span class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                            Configuration Status
                        </span>
                    </div>
                    <div class="section-card__body">
                        <div class="progress-mini">
                            <span class="progress-mini__label">Programmes</span>
                            <div class="progress-mini__bar"><div class="progress-mini__fill" id="progBar" runat="server" style="width: 0%;"></div></div>
                            <span class="progress-mini__value"><asp:Label ID="lblProgConfigured" runat="server" Text="0"></asp:Label>%</span>
                        </div>
                        <div class="progress-mini">
                            <span class="progress-mini__label">Specialisations</span>
                            <div class="progress-mini__bar"><div class="progress-mini__fill" id="specBar" runat="server" style="width: 0%;"></div></div>
                            <span class="progress-mini__value"><asp:Label ID="lblSpecConfigured" runat="server" Text="0"></asp:Label>%</span>
                        </div>
                        <div class="progress-mini">
                            <span class="progress-mini__label">With Courses</span>
                            <div class="progress-mini__bar"><div class="progress-mini__fill" id="coursesBar" runat="server" style="width: 0%;"></div></div>
                            <span class="progress-mini__value"><asp:Label ID="lblProgWithCourses" runat="server" Text="0"></asp:Label>%</span>
                        </div>
                    </div>
                </div>
                
                <!-- Programme Courses Summary -->
                <div class="section-card">
                    <div class="section-card__header">
                        <span class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                            Course Statistics
                        </span>
                    </div>
                    <div class="section-card__body">
                        <table class="mini-table">
                            <tr><td>Programme Courses</td><td><asp:Label ID="lblTotalProgrammeCourses" runat="server" Text="0"></asp:Label></td></tr>
                            <tr><td>Core Courses</td><td><asp:Label ID="lblCoreCourses" runat="server" Text="0"></asp:Label></td></tr>
                            <tr><td>Elective Courses</td><td><asp:Label ID="lblElectiveCourses" runat="server" Text="0"></asp:Label></td></tr>
                            <tr><td>Default Specs</td><td><asp:Label ID="lblDefaultSpecs" runat="server" Text="0"></asp:Label></td></tr>
                        </table>
                    </div>
                </div>
                
                <!-- Recent Enrollments -->
                <div class="section-card">
                    <div class="section-card__header">
                        <span class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                            Enrollments by Year
                        </span>
                    </div>
                    <div class="section-card__body">
                        <table class="mini-table">
                            <asp:Repeater ID="rptEnrollmentsByYear" runat="server">
                                <ItemTemplate>
                                    <tr><td><%# Eval("acad_year") %></td><td><%# String.Format("{0:N0}", Eval("count")) %></td></tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Alerts / Notifications Row -->
            <div class="section-card" style="margin-bottom: 14px;">
                <div class="section-card__header">
                    <span class="section-card__title">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
                        System Alerts
                    </span>
                </div>
                <div class="section-card__body">
                    <asp:Panel ID="pnlAlerts" runat="server">
                        <div class="alert-item alert-item--info">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                            <span><asp:Label ID="lblUnConfiguredProgs" runat="server" Text="0"></asp:Label> programmes not fully configured</span>
                        </div>
                        <div class="alert-item">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                            <span><asp:Label ID="lblUnConfiguredSpecs" runat="server" Text="0"></asp:Label> specialisations not fully configured</span>
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>
        
        <!-- Quick Access Panel (Right Side) -->
        <div class="quick-access-panel">
            <div class="section-card__header">
                <span class="section-card__title">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>
                    Quick Access
                </span>
            </div>
            <div class="section-card__body">
                <a href="NewFaculties.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                    <span>Manage Faculties</span>
                </a>
                <a href="NewFacultyProgrammes.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                    <span>Programmes</span>
                </a>
                <a href="NewSpecialisations.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
                    <span>Specialisations</span>
                </a>
                <a href="NewProgrammeCourses.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    <span>Programme Courses</span>
                </a>
            </div>
            
            <!-- Key Metrics in Panel -->
            <div class="section-card__header" style="border-top: 1px solid #e0e0e0;">
                <span class="section-card__title">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
                    Key Metrics
                </span>
            </div>
            <div class="metric-highlight">
                <div class="metric-highlight__value"><asp:Label ID="lblTotalRegistrations" runat="server" Text="0"></asp:Label></div>
                <div class="metric-highlight__label">Total Registrations</div>
            </div>
            <div class="metric-highlight">
                <div class="metric-highlight__value"><asp:Label ID="lblGenderRatio" runat="server" Text="0:0"></asp:Label></div>
                <div class="metric-highlight__label">M:F Ratio</div>
            </div>
        </div>
    </div>
    </asp:Panel>
    <!-- /ACADEMICS -->

    <!-- Chart.js Initialization -->
    <asp:HiddenField ID="hfEnrollmentData" runat="server" />
    <asp:HiddenField ID="hfMaleCount" runat="server" />
    <asp:HiddenField ID="hfFemaleCount" runat="server" />
    
    <script type="text/javascript">
        document.addEventListener('DOMContentLoaded', function() {
            // Charts only exist when the Academics panel is shown for this role.
            var _enrollEl = document.getElementById('enrollmentChart');
            var _genderEl = document.getElementById('genderChart');
            if (!_enrollEl && !_genderEl) return;          // role without academics → nothing to draw
            if (typeof Chart === 'undefined') return;       // chart lib not loaded → bail safely

            // Enrollment Trend Chart
            if (_enrollEl) {
            var _hf = document.getElementById('<%= hfEnrollmentData.ClientID %>');
            var enrollmentDataStr = _hf ? _hf.value : '';
            var enrollmentData = enrollmentDataStr ? JSON.parse(enrollmentDataStr) : [];

            var enrollmentCtx = _enrollEl.getContext('2d');
            new Chart(enrollmentCtx, {
                type: 'bar',
                data: {
                    labels: enrollmentData.map(function(d) { return d.year; }),
                    datasets: [{
                        label: 'Enrollments',
                        data: enrollmentData.map(function(d) { return d.count; }),
                        backgroundColor: '#174DA4',
                        borderColor: '#174DA4',
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: { font: { size: 9 } },
                            grid: { color: '#f0f0f0' }
                        },
                        x: {
                            ticks: { font: { size: 9 } },
                            grid: { display: false }
                        }
                    }
                }
            });
            } // end enrollment chart

            // Gender Distribution Chart
            if (_genderEl) {
            var maleCount = parseInt((document.getElementById('<%= hfMaleCount.ClientID %>') || {value:0}).value) || 0;
            var femaleCount = parseInt((document.getElementById('<%= hfFemaleCount.ClientID %>') || {value:0}).value) || 0;

            var genderCtx = _genderEl.getContext('2d');
            new Chart(genderCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Male', 'Female'],
                    datasets: [{
                        data: [maleCount, femaleCount],
                        backgroundColor: ['#1976d2', '#e91e63'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'right',
                            labels: { font: { size: 10 }, boxWidth: 12 }
                        }
                    },
                    cutout: '60%'
                }
            });
            } // end gender chart
        });
    </script>

    <!-- Faculty Overview charts (Dean) — only run when those canvases exist -->
    <script type="text/javascript">
        document.addEventListener('DOMContentLoaded', function () {
            if (typeof Chart === 'undefined') return;
            function _foPairs(id){ var el=document.getElementById(id); if(!el) return []; try { return JSON.parse(el.value||'[]'); } catch(e){ return []; } }

            var gEl = document.getElementById('foGenderChart');
            if (gEl) {
                var gd = _foPairs('<%= hfFoGender.ClientID %>');
                if (gd.length) new Chart(gEl.getContext('2d'), {
                    type:'doughnut',
                    data:{ labels:gd.map(function(x){return x.k;}),
                           datasets:[{ data:gd.map(function(x){return x.v;}), backgroundColor:['#174DA4','#e91e63','#94a3b8','#16a34a'], borderWidth:0 }] },
                    options:{ responsive:true, maintainAspectRatio:false, plugins:{ legend:{ position:'right', labels:{ font:{size:10}, boxWidth:12 } } }, cutout:'58%' }
                });
            }

            var pEl = document.getElementById('foProgChart');
            if (pEl) {
                var pd = _foPairs('<%= hfFoProgrammes.ClientID %>');
                if (pd.length) new Chart(pEl.getContext('2d'), {
                    type:'bar',
                    data:{ labels:pd.map(function(x){return x.k;}),
                           datasets:[{ data:pd.map(function(x){return x.v;}), backgroundColor:'#174DA4', borderWidth:0 }] },
                    options:{ responsive:true, maintainAspectRatio:false, plugins:{ legend:{ display:false } },
                              scales:{ y:{ beginAtZero:true, ticks:{ font:{size:9} }, grid:{ color:'#f0f0f0' } }, x:{ ticks:{ font:{size:9} }, grid:{ display:false } } } }
                });
            }

            var eEl = document.getElementById('foEnrollChart');
            if (eEl) {
                var ed = _foPairs('<%= hfFoEnroll.ClientID %>');
                if (ed.length) new Chart(eEl.getContext('2d'), {
                    type:'bar',
                    data:{ labels:ed.map(function(x){return x.k;}),
                           datasets:[{ data:ed.map(function(x){return x.v;}), backgroundColor:'#05275C', borderWidth:0 }] },
                    options:{ responsive:true, maintainAspectRatio:false, plugins:{ legend:{ display:false } },
                              scales:{ y:{ beginAtZero:true, ticks:{ font:{size:9} }, grid:{ color:'#f0f0f0' } }, x:{ ticks:{ font:{size:9} }, grid:{ display:false } } } }
                });
            }
        });
    </script>
</asp:Content>
