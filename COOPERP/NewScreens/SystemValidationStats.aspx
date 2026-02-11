<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="SystemValidationStats.aspx.cs" Inherits="COOPERP_NewScreens_SystemValidationStats" Title="System Validation Stats - Campus Dynamics" EnableViewState="false" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
<%@ Register Src="~/COOPERP/NewScreens/UserControls/BatchOperations.ascx" TagName="BatchOperations" TagPrefix="uc" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        /* =============================================
           SYSTEM VALIDATION STATS DASHBOARD
           ============================================= */
        
        /* Main Layout */
        .dashboard-layout {
            display: grid;
            grid-template-columns: 1fr 240px;
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
        .stat-card__icon--yellow { background: #fffde7; color: #f9a825; }
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
        .stat-card__sub .pass { color: #388e3c; }
        .stat-card__sub .fail { color: #d32f2f; }
        
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
        .mini-table .text-danger { color: #d32f2f !important; }
        .mini-table .text-success { color: #388e3c !important; }
        .mini-table .text-warning { color: #f57c00 !important; }
        
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
            width: 130px;
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
        .progress-mini__fill--green { background: #388e3c; }
        .progress-mini__fill--red { background: #d32f2f; }
        .progress-mini__fill--orange { background: #f57c00; }
        .progress-mini__value {
            font-size: 9px;
            font-weight: 600;
            color: #333;
            width: 40px;
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
        .metric-highlight__value--green { color: #388e3c; }
        .metric-highlight__value--red { color: #d32f2f; }
        .metric-highlight__value--orange { color: #f57c00; }
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
        .alert-item--danger { background: #ffebee; border-left-color: #f44336; }
        .alert-item svg { width: 14px; height: 14px; flex-shrink: 0; color: #f57c00; }
        .alert-item--info svg { color: #2196f3; }
        .alert-item--success svg { color: #4caf50; }
        .alert-item--danger svg { color: #f44336; }
        
        /* Status Badge */
        .status-badge {
            display: inline-block;
            padding: 2px 6px;
            font-size: 8px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-badge--pass { background: #e8f5e9; color: #388e3c; }
        .status-badge--fail { background: #ffebee; color: #d32f2f; }
        .status-badge--pending { background: #fff3e0; color: #f57c00; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:HiddenField ID="hfValidationChartData" runat="server" />
    <asp:HiddenField ID="hfCurriculumChartData" runat="server" />
    <asp:HiddenField ID="hfFailReasonsData" runat="server" />
    
    <!-- Page Header with Batch Operations -->
    <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; padding-bottom: 10px; border-bottom: 1px solid #e0e0e0;">
        <div>
            <h2 style="margin: 0; font-size: 16px; color: #333; font-weight: 600;">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 6px;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                System Validation Stats
            </h2>
            <span style="font-size: 10px; color: #888; margin-top: 2px; display: block;">View validation metrics and run batch operations</span>
        </div>
        <div style="display: flex; gap: 8px;">
            <asp:Button ID="btnValidateSpecializations" runat="server" Text="Validate Specializations" 
                OnClick="btnValidateSpecializations_Click" 
                CssClass="cd-btn cd-btn--primary cd-btn--sm" 
                OnClientClick="return confirm('This will validate all specializations and update their status.\n\nValidation Rules:\n- Year 1 & 2 must have 5-12 courses each\n- Year 3 must have ≤12 courses\n\nContinue?');" />
            <uc:BatchOperations ID="ucBatchOperations" runat="server" />
        </div>
    </div>
    
    <div class="dashboard-layout">
        <!-- Main Content Area -->
        <div class="main-content">
            <!-- Row 1: Academic Setup Counts -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--purple">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblTotalProgrammes" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Total Programmes</div>
                        <div class="stat-card__sub">Configured: <span class="pass"><asp:Label ID="lblConfiguredProgs" runat="server" Text="0"></asp:Label></span></div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--blue">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblTotalStudents" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Total Students</div>
                        <div class="stat-card__sub">Validated: <span class="pass"><asp:Label ID="lblValidatedStudents" runat="server" Text="0"></asp:Label></span></div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--teal">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblTotalCourses" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Total Courses</div>
                        <div class="stat-card__sub">In Bank</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--indigo">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblTotalSpecs" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Specialisations</div>
                        <div class="stat-card__sub">Fully Set: <span class="pass"><asp:Label ID="lblConfiguredSpecs" runat="server" Text="0"></asp:Label></span></div>
                    </div>
                </div>
            </div>
            
            <!-- Row 2: Validation Metrics -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--green">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblPassedStudents" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Students Passed</div>
                        <div class="stat-card__sub">Validation Status: <span class="pass">PASSED</span></div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--red">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblFailedStudents" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Students Failed</div>
                        <div class="stat-card__sub">Validation Status: <span class="fail">FAILED</span></div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--orange">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblPendingValidation" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Pending Validation</div>
                        <div class="stat-card__sub">Not yet validated</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card__icon stat-card__icon--yellow">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                    </div>
                    <div class="stat-card__content">
                        <div class="stat-card__value"><asp:Label ID="lblCurriculumNotSet" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-card__label">Curriculum Not Set</div>
                        <div class="stat-card__sub">Students with incomplete setup</div>
                    </div>
                </div>
            </div>
            
            <!-- Row 3: Charts -->
            <div class="charts-row">
                <!-- Validation Status Chart -->
                <div class="section-card">
                    <div class="section-card__header">
                        <div class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                            Student Validation Status
                        </div>
                    </div>
                    <div class="section-card__body">
                        <div class="chart-container">
                            <canvas id="validationChart"></canvas>
                        </div>
                    </div>
                </div>
                
                <!-- Curriculum Setup Chart -->
                <div class="section-card">
                    <div class="section-card__header">
                        <div class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
                            Specialisation Configuration Status
                        </div>
                    </div>
                    <div class="section-card__body">
                        <div class="chart-container">
                            <canvas id="curriculumChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Row 4: Detailed Stats Tables -->
            <div class="summary-row">
                <!-- Configuration Progress -->
                <div class="section-card">
                    <div class="section-card__header">
                        <div class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
                            Configuration Progress
                        </div>
                    </div>
                    <div class="section-card__body">
                        <div class="progress-mini">
                            <span class="progress-mini__label">Programmes Configured</span>
                            <div class="progress-mini__bar"><div class="progress-mini__fill progress-mini__fill--green" id="progBar" runat="server"></div></div>
                            <span class="progress-mini__value"><asp:Label ID="lblProgConfigPercent" runat="server" Text="0%"></asp:Label></span>
                        </div>
                        <div class="progress-mini">
                            <span class="progress-mini__label">Specialisations Configured</span>
                            <div class="progress-mini__bar"><div class="progress-mini__fill progress-mini__fill--green" id="specBar" runat="server"></div></div>
                            <span class="progress-mini__value"><asp:Label ID="lblSpecConfigPercent" runat="server" Text="0%"></asp:Label></span>
                        </div>
                        <div class="progress-mini">
                            <span class="progress-mini__label">Students Validated</span>
                            <div class="progress-mini__bar"><div class="progress-mini__fill" id="studentBar" runat="server"></div></div>
                            <span class="progress-mini__value"><asp:Label ID="lblStudentValidPercent" runat="server" Text="0%"></asp:Label></span>
                        </div>
                        <div class="progress-mini">
                            <span class="progress-mini__label">Students Passed</span>
                            <div class="progress-mini__bar"><div class="progress-mini__fill progress-mini__fill--green" id="passBar" runat="server"></div></div>
                            <span class="progress-mini__value"><asp:Label ID="lblPassPercent" runat="server" Text="0%"></asp:Label></span>
                        </div>
                    </div>
                </div>
                
                <!-- Fail Reasons Breakdown -->
                <div class="section-card">
                    <div class="section-card__header">
                        <div class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
                            Failure Reasons
                        </div>
                    </div>
                    <div class="section-card__body">
                        <table class="mini-table">
                            <tr>
                                <th>Reason</th>
                                <th>Count</th>
                            </tr>
                            <asp:Repeater ID="rptFailReasons" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("reason") %></td>
                                        <td class="text-danger"><%# Eval("count") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                    </div>
                </div>
                
                <!-- Validation by Programme -->
                <div class="section-card">
                    <div class="section-card__header">
                        <div class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
                            Top Programmes (Pass Rate)
                        </div>
                    </div>
                    <div class="section-card__body">
                        <table class="mini-table">
                            <tr>
                                <th>Programme</th>
                                <th>Rate</th>
                            </tr>
                            <asp:Repeater ID="rptTopProgrammes" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("programme") %></td>
                                        <td class="text-success"><%# Eval("passrate") %>%</td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Row 5: Additional Info -->
            <div class="summary-row">
                <!-- Unconfigured Programmes -->
                <div class="section-card">
                    <div class="section-card__header">
                        <div class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                            Unconfigured Programmes
                        </div>
                    </div>
                    <div class="section-card__body">
                        <table class="mini-table">
                            <tr>
                                <th>Code</th>
                                <th>Programme</th>
                            </tr>
                            <asp:Repeater ID="rptUnconfiguredProgs" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("code") %></td>
                                        <td><%# Eval("name") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                        <asp:Panel ID="pnlNoUnconfiguredProgs" runat="server" CssClass="alert-item alert-item--success" Visible="false">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                            All programmes are configured!
                        </asp:Panel>
                    </div>
                </div>
                
                <!-- Unconfigured Specialisations -->
                <div class="section-card">
                    <div class="section-card__header">
                        <div class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
                            Unconfigured Specialisations
                        </div>
                    </div>
                    <div class="section-card__body">
                        <table class="mini-table">
                            <tr>
                                <th>Specialisation</th>
                                <th>Programme</th>
                                <th>Courses</th>
                            </tr>
                            <asp:Repeater ID="rptUnconfiguredSpecs" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("name") %></td>
                                        <td style="font-size: 9px; color: #888;"><%# Eval("programme") %></td>
                                        <td class='<%# Convert.ToInt32(Eval("courses")) == 0 ? "text-danger" : "text-warning" %>'><%# Eval("courses") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                        <asp:Panel ID="pnlNoUnconfiguredSpecs" runat="server" CssClass="alert-item alert-item--success" Visible="false">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                            All specialisations are configured!
                        </asp:Panel>
                    </div>
                </div>
                
                <!-- Recent Failures -->
                <div class="section-card">
                    <div class="section-card__header">
                        <div class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
                            Recently Failed Students (Top 10)
                        </div>
                    </div>
                    <div class="section-card__body">
                        <table class="mini-table">
                            <tr>
                                <th>Student</th>
                                <th>Reason</th>
                            </tr>
                            <asp:Repeater ID="rptRecentFailures" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("student") %></td>
                                        <td class="text-danger"><%# Eval("reason") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                        <asp:Panel ID="pnlNoFailures" runat="server" CssClass="alert-item alert-item--success" Visible="false">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                            No failed students!
                        </asp:Panel>
                    </div>
                </div>
                
                <!-- Academic Year Stats -->
                <div class="section-card">
                    <div class="section-card__header">
                        <div class="section-card__title">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                            Course Statistics
                        </div>
                    </div>
                    <div class="section-card__body">
                        <table class="mini-table">
                            <tr>
                                <th>Metric</th>
                                <th>Value</th>
                            </tr>
                            <tr>
                                <td>Programme Courses</td>
                                <td><asp:Label ID="lblProgrammeCourses" runat="server" Text="0"></asp:Label></td>
                            </tr>
                            <tr>
                                <td>Core Courses</td>
                                <td><asp:Label ID="lblCoreCourses" runat="server" Text="0"></asp:Label></td>
                            </tr>
                            <tr>
                                <td>Elective Courses</td>
                                <td><asp:Label ID="lblElectiveCourses" runat="server" Text="0"></asp:Label></td>
                            </tr>
                            <tr>
                                <td>Exam Results</td>
                                <td><asp:Label ID="lblExamResults" runat="server" Text="0"></asp:Label></td>
                            </tr>
                            <tr>
                                <td>Avg Results/Student</td>
                                <td><asp:Label ID="lblAvgResultsPerStudent" runat="server" Text="0"></asp:Label></td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Quick Access Panel -->
        <div class="quick-access-panel section-card">
            <div class="section-card__header">
                <div class="section-card__title">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
                    Quick Stats
                </div>
            </div>
            <div class="section-card__body">
                <div class="metric-highlight">
                    <div class="metric-highlight__value metric-highlight__value--green"><asp:Label ID="lblPassRate" runat="server" Text="0%"></asp:Label></div>
                    <div class="metric-highlight__label">Pass Rate</div>
                </div>
                <div class="metric-highlight">
                    <div class="metric-highlight__value metric-highlight__value--red"><asp:Label ID="lblFailRate" runat="server" Text="0%"></asp:Label></div>
                    <div class="metric-highlight__label">Fail Rate</div>
                </div>
                <div class="metric-highlight">
                    <div class="metric-highlight__value"><asp:Label ID="lblValidationRate" runat="server" Text="0%"></asp:Label></div>
                    <div class="metric-highlight__label">Validated</div>
                </div>
            </div>
            
            <div class="section-card__header">
                <div class="section-card__title">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                    Quick Links
                </div>
            </div>
            <div class="section-card__body">
                <a href="NewStudentInfo.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
                    Student Validation
                </a>
                <a href="NewFacultyProgrammes.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                    Programmes
                </a>
                <a href="NewSpecialisations.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
                    Specialisations
                </a>
                <a href="NewProgrammeCourses.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    Programme Courses
                </a>
                <a href="NewCourses.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
                    Course Bank
                </a>
                <a href="NewDashboard.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
                    Main Dashboard
                </a>
            </div>
        </div>
    </div>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Validation Status Chart (Doughnut) - Passed vs Failed only
            var validationData = JSON.parse(document.getElementById('<%= hfValidationChartData.ClientID %>').value || '{"passed":0,"failed":0}');
            var validationTotal = validationData.passed + validationData.failed;
            var ctxValidation = document.getElementById('validationChart').getContext('2d');
            new Chart(ctxValidation, {
                type: 'doughnut',
                data: {
                    labels: [
                        'Passed (' + (validationTotal > 0 ? Math.round(validationData.passed * 100 / validationTotal) : 0) + '% - ' + validationData.passed + ')',
                        'Failed (' + (validationTotal > 0 ? Math.round(validationData.failed * 100 / validationTotal) : 0) + '% - ' + validationData.failed + ')'
                    ],
                    datasets: [{
                        data: [validationData.passed, validationData.failed],
                        backgroundColor: ['#388e3c', '#d32f2f'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { font: { size: 10 }, padding: 12 }
                        }
                    },
                    cutout: '60%'
                }
            });
            
            // Specialisation Configuration Chart (Doughnut) - Fully Set vs Not Fully Set
            var curriculumData = JSON.parse(document.getElementById('<%= hfCurriculumChartData.ClientID %>').value || '{"configured":0,"unconfigured":0}');
            var curriculumTotal = curriculumData.configured + curriculumData.unconfigured;
            var ctxCurriculum = document.getElementById('curriculumChart').getContext('2d');
            new Chart(ctxCurriculum, {
                type: 'doughnut',
                data: {
                    labels: [
                        'Fully Set (' + (curriculumTotal > 0 ? Math.round(curriculumData.configured * 100 / curriculumTotal) : 0) + '% - ' + curriculumData.configured + ')',
                        'Not Fully Set (' + (curriculumTotal > 0 ? Math.round(curriculumData.unconfigured * 100 / curriculumTotal) : 0) + '% - ' + curriculumData.unconfigured + ')'
                    ],
                    datasets: [{
                        data: [curriculumData.configured, curriculumData.unconfigured],
                        backgroundColor: ['#388e3c', '#e0e0e0'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { font: { size: 10 }, padding: 12 }
                        }
                    },
                    cutout: '60%'
                }
            });
        });
    </script>
</asp:Content>
