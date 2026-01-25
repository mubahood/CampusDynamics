<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewDashboard.aspx.cs" Inherits="COOPERP_NewScreens_NewDashboard" Title="Dashboard - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        /* =============================================
           DASHBOARD STYLES - Compact & Clean
           ============================================= */
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            margin-bottom: 16px;
        }
        @media (max-width: 1200px) { .dashboard-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 600px) { .dashboard-grid { grid-template-columns: 1fr; } }
        
        /* Stat Cards */
        .stat-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            padding: 12px 14px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .stat-card__icon {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8f5fc;
            color: #174DA4;
            flex-shrink: 0;
        }
        .stat-card__icon svg { width: 20px; height: 20px; }
        .stat-card__content { flex: 1; min-width: 0; }
        .stat-card__value {
            font-size: 20px;
            font-weight: 700;
            color: #174DA4;
            line-height: 1.1;
        }
        .stat-card__label {
            font-size: 10px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            margin-top: 2px;
        }
        .stat-card__change {
            font-size: 9px;
            padding: 2px 5px;
            background: #e8f5e9;
            color: #2e7d32;
            margin-top: 4px;
            display: inline-block;
        }
        .stat-card__change--down {
            background: #ffebee;
            color: #c62828;
        }
        
        /* Section Cards */
        .section-row {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 12px;
            margin-bottom: 16px;
        }
        @media (max-width: 992px) { .section-row { grid-template-columns: 1fr; } }
        
        .section-card {
            background: #fff;
            border: 1px solid #e0e0e0;
        }
        .section-card__header {
            padding: 10px 14px;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #fafafa;
        }
        .section-card__title {
            font-size: 11px;
            font-weight: 600;
            color: #333;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .section-card__title svg { width: 14px; height: 14px; color: #174DA4; }
        .section-card__action {
            font-size: 10px;
            color: #174DA4;
            text-decoration: none;
            padding: 3px 8px;
            border: 1px solid #174DA4;
            background: transparent;
        }
        .section-card__action:hover {
            background: #174DA4;
            color: #fff;
        }
        .section-card__body {
            padding: 12px 14px;
        }
        
        /* Quick Stats Table */
        .quick-stats-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }
        .quick-stats-table td {
            padding: 8px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        .quick-stats-table tr:last-child td { border-bottom: none; }
        .quick-stats-table td:last-child {
            text-align: right;
            font-weight: 600;
            color: #174DA4;
        }
        
        /* Progress Items */
        .progress-item {
            margin-bottom: 10px;
        }
        .progress-item:last-child { margin-bottom: 0; }
        .progress-item__header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 4px;
            font-size: 10px;
        }
        .progress-item__label { color: #666; }
        .progress-item__value { font-weight: 600; color: #333; }
        .progress-item__bar {
            height: 4px;
            background: #f0f0f0;
            overflow: hidden;
        }
        .progress-item__fill {
            height: 100%;
            background: #174DA4;
            transition: width 0.3s ease;
        }
        
        /* Activity List */
        .activity-list { list-style: none; padding: 0; margin: 0; }
        .activity-item {
            display: flex;
            gap: 10px;
            padding: 8px 0;
            border-bottom: 1px solid #f0f0f0;
            font-size: 11px;
        }
        .activity-item:last-child { border-bottom: none; }
        .activity-item__icon {
            width: 26px;
            height: 26px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8f5fc;
            color: #174DA4;
            flex-shrink: 0;
        }
        .activity-item__icon svg { width: 12px; height: 12px; }
        .activity-item__content { flex: 1; }
        .activity-item__text { color: #333; }
        .activity-item__time { color: #999; font-size: 9px; margin-top: 2px; }
        
        /* Quick Links */
        .quick-links {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 8px;
        }
        .quick-link {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px;
            background: #fafafa;
            border: 1px solid #e0e0e0;
            text-decoration: none;
            color: #333;
            font-size: 11px;
            transition: all 0.2s ease;
        }
        .quick-link:hover {
            background: #174DA4;
            color: #fff;
            border-color: #174DA4;
        }
        .quick-link svg { width: 16px; height: 16px; flex-shrink: 0; }
        
        /* Welcome Banner */
        .welcome-banner {
            background: linear-gradient(135deg, #174DA4 0%, #5a3a8f 100%);
            color: #fff;
            padding: 16px 20px;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .welcome-banner__content h2 {
            margin: 0 0 4px 0;
            font-size: 16px;
            font-weight: 600;
        }
        .welcome-banner__content p {
            margin: 0;
            font-size: 11px;
            opacity: 0.85;
        }
        .welcome-banner__date {
            text-align: right;
            font-size: 11px;
            opacity: 0.9;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <!-- Welcome Banner -->
    <div class="welcome-banner">
        <div class="welcome-banner__content">
            <h2>Campus Dynamics Admin Portal</h2>
            <p>Academic Management System - New Interface</p>
        </div>
        <div class="welcome-banner__date">
            <asp:Label ID="lblDate" runat="server"></asp:Label>
        </div>
    </div>
    
    <!-- Stats Grid -->
    <div class="dashboard-grid">
        <!-- Stat Card 1 -->
        <div class="stat-card">
            <div class="stat-card__icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
            </div>
            <div class="stat-card__content">
                <div class="stat-card__value"><asp:Label ID="lblFaculties" runat="server" Text="0"></asp:Label></div>
                <div class="stat-card__label">Faculties</div>
            </div>
        </div>
        
        <!-- Stat Card 2 -->
        <div class="stat-card">
            <div class="stat-card__icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
            </div>
            <div class="stat-card__content">
                <div class="stat-card__value"><asp:Label ID="lblProgrammes" runat="server" Text="0"></asp:Label></div>
                <div class="stat-card__label">Programmes</div>
            </div>
        </div>
        
        <!-- Stat Card 3 -->
        <div class="stat-card">
            <div class="stat-card__icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
            </div>
            <div class="stat-card__content">
                <div class="stat-card__value"><asp:Label ID="lblSpecialisations" runat="server" Text="0"></asp:Label></div>
                <div class="stat-card__label">Specialisations</div>
            </div>
        </div>
        
        <!-- Stat Card 4 -->
        <div class="stat-card">
            <div class="stat-card__icon">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
            </div>
            <div class="stat-card__content">
                <div class="stat-card__value"><asp:Label ID="lblCourses" runat="server" Text="0"></asp:Label></div>
                <div class="stat-card__label">Courses</div>
            </div>
        </div>
    </div>
    
    <!-- Section Row -->
    <div class="section-row">
        <!-- Configuration Progress -->
        <div class="section-card">
            <div class="section-card__header">
                <span class="section-card__title">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    Configuration Progress
                </span>
            </div>
            <div class="section-card__body">
                <div class="progress-item">
                    <div class="progress-item__header">
                        <span class="progress-item__label">Programmes Fully Configured</span>
                        <span class="progress-item__value"><asp:Label ID="lblProgConfigured" runat="server" Text="0"></asp:Label>%</span>
                    </div>
                    <div class="progress-item__bar">
                        <div class="progress-item__fill" id="progBar" runat="server" style="width: 0%;"></div>
                    </div>
                </div>
                <div class="progress-item">
                    <div class="progress-item__header">
                        <span class="progress-item__label">Specialisations Fully Configured</span>
                        <span class="progress-item__value"><asp:Label ID="lblSpecConfigured" runat="server" Text="0"></asp:Label>%</span>
                    </div>
                    <div class="progress-item__bar">
                        <div class="progress-item__fill" id="specBar" runat="server" style="width: 0%;"></div>
                    </div>
                </div>
                <div class="progress-item">
                    <div class="progress-item__header">
                        <span class="progress-item__label">Programmes with Courses</span>
                        <span class="progress-item__value"><asp:Label ID="lblProgWithCourses" runat="server" Text="0"></asp:Label>%</span>
                    </div>
                    <div class="progress-item__bar">
                        <div class="progress-item__fill" id="coursesBar" runat="server" style="width: 0%;"></div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Quick Stats -->
        <div class="section-card">
            <div class="section-card__header">
                <span class="section-card__title">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
                    Quick Stats
                </span>
            </div>
            <div class="section-card__body">
                <table class="quick-stats-table">
                    <tr>
                        <td>Total Programme Courses</td>
                        <td><asp:Label ID="lblTotalProgrammeCourses" runat="server" Text="0"></asp:Label></td>
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
                        <td>Default Specialisations</td>
                        <td><asp:Label ID="lblDefaultSpecs" runat="server" Text="0"></asp:Label></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
    
    <!-- Quick Links Section -->
    <div class="section-card">
        <div class="section-card__header">
            <span class="section-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>
                Quick Access
            </span>
        </div>
        <div class="section-card__body">
            <div class="quick-links">
                <a href="NewFaculties.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                    <span>Manage Faculties</span>
                </a>
                <a href="NewFacultyProgrammes.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                    <span>Manage Programmes</span>
                </a>
                <a href="NewSpecialisations.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
                    <span>Manage Specialisations</span>
                </a>
                <a href="NewProgrammeCourses.aspx" class="quick-link">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    <span>Programme Courses</span>
                </a>
            </div>
        </div>
    </div>
</asp:Content>
