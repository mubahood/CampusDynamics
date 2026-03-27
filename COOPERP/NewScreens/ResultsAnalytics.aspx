<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ResultsAnalytics.aspx.cs" Inherits="COOPERP_NewScreens_ResultsAnalytics" Title="Results Analytics Dashboard - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* ===============================================
           RESULTS ANALYTICS DASHBOARD - STYLES
           Prefix: rad- (Results Analytics Dashboard)
        =============================================== */
        
        .rad-container { padding: 0; font-size: 11px; }
        
        /* Page Header */
        .cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
        .cd-page-header__left { display:flex; align-items:center; gap:12px; }
        .cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
        .cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
        .cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
        .cd-page-header__right { display:flex; gap:8px; align-items:center; }
        
        /* Filter Bar */
        .rad-filter-bar {
            display: flex;
            gap: 12px;
            align-items: center;
            padding: 12px 15px;
            background: #f5f7fa;
            border-radius: 4px;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }
        .rad-filter-group {
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .rad-filter-group label {
            font-size: 10px;
            color: #6c757d;
            font-weight: 600;
        }
        .rad-filter-select {
            padding: 6px 10px;
            font-size: 11px;
            border: 1px solid #ced4da;
            border-radius: 0;
            background: #fff;
        }
        .rad-filter-select:focus { border-color: #174DA4; outline: none; }
        
        /* Buttons */
        .rad-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 14px;
            font-size: 11px;
            font-weight: 500;
            border: 1px solid transparent;
            border-radius: 0;
            cursor: pointer;
            transition: all 0.15s ease;
            text-decoration: none;
        }
        .rad-btn svg { width: 12px; height: 12px; }
        .rad-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .rad-btn--primary:hover { background: #0d3a7d; }
        .rad-btn--outline { background: #fff; color: #495057; border-color: #ced4da; }
        .rad-btn--outline:hover { background: #f8f9fa; }
        
        /* KPI Cards Row */
        .rad-kpi-row {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 12px;
            margin-bottom: 20px;
        }
        @media (max-width: 1200px) { .rad-kpi-row { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 768px) { .rad-kpi-row { grid-template-columns: repeat(2, 1fr); } }
        
        .rad-kpi-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 16px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .rad-kpi-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
        }
        .rad-kpi-card--pass::before { background: #28a745; }
        .rad-kpi-card--fail::before { background: #dc3545; }
        .rad-kpi-card--avg::before { background: #17a2b8; }
        .rad-kpi-card--students::before { background: #174DA4; }
        .rad-kpi-card--courses::before { background: #ffc107; }
        
        .rad-kpi-card__value { font-size: 28px; font-weight: 700; line-height: 1; margin-bottom: 6px; }
        .rad-kpi-card--pass .rad-kpi-card__value { color: #28a745; }
        .rad-kpi-card--fail .rad-kpi-card__value { color: #dc3545; }
        .rad-kpi-card--avg .rad-kpi-card__value { color: #17a2b8; }
        .rad-kpi-card--students .rad-kpi-card__value { color: #174DA4; }
        .rad-kpi-card--courses .rad-kpi-card__value { color: #fd7e14; }
        
        .rad-kpi-card__label { font-size: 10px; color: #6c757d; text-transform: uppercase; letter-spacing: 0.5px; }
        .rad-kpi-card__trend {
            font-size: 10px;
            margin-top: 6px;
            display: inline-flex;
            align-items: center;
            gap: 3px;
            padding: 2px 8px;
            border-radius: 10px;
        }
        .rad-kpi-card__trend--up { background: #d4edda; color: #155724; }
        .rad-kpi-card__trend--down { background: #f8d7da; color: #721c24; }
        .rad-kpi-card__trend--neutral { background: #e2e3e5; color: #383d41; }
        
        /* Charts Grid */
        .rad-charts-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }
        @media (max-width: 992px) { .rad-charts-grid { grid-template-columns: 1fr; } }
        
        .rad-chart-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            overflow: hidden;
        }
        .rad-chart-card--full { grid-column: span 2; }
        @media (max-width: 992px) { .rad-chart-card--full { grid-column: span 1; } }
        
        .rad-chart-card__header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 16px;
            background: #f5f7fa;
            border-bottom: 1px solid #e0e0e0;
        }
        .rad-chart-card__title { font-size: 12px; font-weight: 600; color: #1a1a2e; }
        .rad-chart-card__actions { display: flex; gap: 6px; }
        .rad-chart-card__body { padding: 16px; min-height: 250px; }
        
        /* Grade Distribution Bars */
        .rad-grade-dist {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .rad-grade-bar {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .rad-grade-bar__label {
            width: 80px;
            font-size: 11px;
            font-weight: 600;
            color: #495057;
        }
        .rad-grade-bar__track {
            flex: 1;
            height: 24px;
            background: #e9ecef;
            border-radius: 0;
            overflow: hidden;
            position: relative;
        }
        .rad-grade-bar__fill {
            height: 100%;
            border-radius: 0;
            display: flex;
            align-items: center;
            padding-left: 8px;
            color: #fff;
            font-size: 10px;
            font-weight: 600;
            transition: width 0.5s ease;
        }
        .rad-grade-bar__fill--first { background: linear-gradient(90deg, #28a745, #20c997); }
        .rad-grade-bar__fill--upper { background: linear-gradient(90deg, #17a2b8, #6f42c1); }
        .rad-grade-bar__fill--lower { background: linear-gradient(90deg, #ffc107, #fd7e14); }
        .rad-grade-bar__fill--pass { background: linear-gradient(90deg, #6c757d, #495057); }
        .rad-grade-bar__fill--fail { background: linear-gradient(90deg, #dc3545, #e83e8c); }
        .rad-grade-bar__value {
            width: 60px;
            text-align: right;
            font-size: 11px;
            font-weight: 600;
            color: #495057;
        }
        
        /* Programme Performance Table */
        .rad-perf-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }
        .rad-perf-table th {
            text-align: left;
            padding: 10px 8px;
            background: #f5f7fa;
            border-bottom: 2px solid #174DA4;
            font-weight: 600;
            color: #495057;
            font-size: 10px;
            text-transform: uppercase;
        }
        .rad-perf-table td {
            padding: 10px 8px;
            border-bottom: 1px solid #e9ecef;
        }
        .rad-perf-table tr:hover td { background: #f8f9fa; }
        
        /* Pass Rate Badge */
        .rad-pass-rate {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 10px;
            font-size: 10px;
            font-weight: 600;
            border-radius: 12px;
        }
        .rad-pass-rate--high { background: #d4edda; color: #155724; }
        .rad-pass-rate--medium { background: #fff3cd; color: #856404; }
        .rad-pass-rate--low { background: #f8d7da; color: #721c24; }
        
        /* Mini Progress */
        .rad-mini-progress {
            width: 100px;
            height: 6px;
            background: #e9ecef;
            border-radius: 3px;
            overflow: hidden;
        }
        .rad-mini-progress__bar {
            height: 100%;
            border-radius: 3px;
        }
        
        /* Trend Chart Area */
        .rad-trend-chart {
            height: 200px;
            background: #f8f9fa;
            border-radius: 4px;
            display: flex;
            align-items: flex-end;
            justify-content: space-around;
            padding: 15px;
        }
        .rad-trend-bar {
            width: 40px;
            background: linear-gradient(180deg, #174DA4, #0d3a7d);
            border-radius: 4px 4px 0 0;
            position: relative;
        }
        .rad-trend-bar__label {
            position: absolute;
            bottom: -20px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 9px;
            color: #6c757d;
        }
        .rad-trend-bar__value {
            position: absolute;
            top: -18px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 10px;
            font-weight: 600;
            color: #174DA4;
        }
        
        /* Top Performers Section */
        .rad-top-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .rad-top-list__item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 0;
            border-bottom: 1px solid #e9ecef;
        }
        .rad-top-list__item:last-child { border-bottom: none; }
        .rad-top-list__rank {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 700;
            flex-shrink: 0;
        }
        .rad-top-list__rank--1 { background: #ffd700; color: #5d4a00; }
        .rad-top-list__rank--2 { background: #c0c0c0; color: #404040; }
        .rad-top-list__rank--3 { background: #cd7f32; color: #fff; }
        .rad-top-list__rank--other { background: #e9ecef; color: #495057; }
        .rad-top-list__content { flex: 1; }
        .rad-top-list__name { font-weight: 600; color: #1a1a2e; }
        .rad-top-list__meta { font-size: 10px; color: #6c757d; }
        .rad-top-list__score { font-size: 16px; font-weight: 700; color: #28a745; }
        
        /* Export Panel */
        .rad-export-panel {
            background: #05275C;
            border-radius: 4px;
            padding: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 20px;
        }
        .rad-export-panel__info {
            color: #fff;
        }
        .rad-export-panel__title { font-size: 13px; font-weight: 600; margin-bottom: 3px; }
        .rad-export-panel__text { font-size: 10px; opacity: 0.8; }
        .rad-export-panel__actions { display: flex; gap: 8px; }
        .rad-export-btn {
            padding: 8px 16px;
            font-size: 11px;
            font-weight: 500;
            border-radius: 0;
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .rad-export-btn--excel { background: #28a745; color: #fff; }
        .rad-export-btn--pdf { background: #dc3545; color: #fff; }
        .rad-export-btn--print { background: #17a2b8; color: #fff; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="rad-container">
        <!-- Page Header -->
        <div class="cd-page-header">
            <div class="cd-page-header__left">
                <div class="cd-page-header__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><path d="M21.21 15.89A10 10 0 1 1 8 2.83"/><path d="M22 12A10 10 0 0 0 12 2v10z"/></svg>
                </div>
                <div>
                    <div class="cd-page-header__title">Results Analytics</div>
                    <div class="cd-page-header__sub">In-depth analysis of academic performance and grade distribution</div>
                </div>
            </div>
            <div class="cd-page-header__right">
                <asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="~/COOPERP/NewScreens/ResultsRelease.aspx" CssClass="rad-btn rad-btn--outline">
                    ← Back to Results
                </asp:HyperLink>
            </div>
        </div>
        
        <!-- Filter Bar -->
        <div class="rad-filter-bar">
            <div class="rad-filter-group">
                <label>Academic Year:</label>
                <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="rad-filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"></asp:DropDownList>
            </div>
            <div class="rad-filter-group">
                <label>Semester:</label>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="rad-filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                    <asp:ListItem Value="" Text="All Semesters"></asp:ListItem>
                    <asp:ListItem Value="1" Text="Semester 1"></asp:ListItem>
                    <asp:ListItem Value="2" Text="Semester 2"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="rad-filter-group">
                <label>Faculty:</label>
                <asp:DropDownList ID="ddlFaculty" runat="server" CssClass="rad-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFaculty_SelectedIndexChanged"></asp:DropDownList>
            </div>
            <div class="rad-filter-group">
                <label>Programme:</label>
                <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="rad-filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"></asp:DropDownList>
            </div>
            <div style="margin-left: auto;">
                <asp:Button ID="btnRefresh" runat="server" Text="↻ Refresh" CssClass="rad-btn rad-btn--primary" OnClick="btnRefresh_Click" />
            </div>
        </div>
        
        <!-- KPI Cards Row -->
        <div class="rad-kpi-row">
            <div class="rad-kpi-card rad-kpi-card--pass">
                <div class="rad-kpi-card__value"><asp:Literal ID="litPassRate" runat="server">0%</asp:Literal></div>
                <div class="rad-kpi-card__label">Overall Pass Rate</div>
                <span class="rad-kpi-card__trend rad-kpi-card__trend--up">
                    ↑ <asp:Literal ID="litPassTrend" runat="server">+2.3%</asp:Literal> vs last sem
                </span>
            </div>
            <div class="rad-kpi-card rad-kpi-card--fail">
                <div class="rad-kpi-card__value"><asp:Literal ID="litFailRate" runat="server">0%</asp:Literal></div>
                <div class="rad-kpi-card__label">Fail Rate</div>
                <span class="rad-kpi-card__trend rad-kpi-card__trend--down">
                    ↓ <asp:Literal ID="litFailTrend" runat="server">-1.2%</asp:Literal> vs last sem
                </span>
            </div>
            <div class="rad-kpi-card rad-kpi-card--avg">
                <div class="rad-kpi-card__value"><asp:Literal ID="litAvgMark" runat="server">0</asp:Literal></div>
                <div class="rad-kpi-card__label">Average Mark</div>
                <span class="rad-kpi-card__trend rad-kpi-card__trend--neutral">
                    → <asp:Literal ID="litAvgTrend" runat="server">Same</asp:Literal>
                </span>
            </div>
            <div class="rad-kpi-card rad-kpi-card--students">
                <div class="rad-kpi-card__value"><asp:Literal ID="litTotalStudents" runat="server">0</asp:Literal></div>
                <div class="rad-kpi-card__label">Students Examined</div>
            </div>
            <div class="rad-kpi-card rad-kpi-card--courses">
                <div class="rad-kpi-card__value"><asp:Literal ID="litTotalCourses" runat="server">0</asp:Literal></div>
                <div class="rad-kpi-card__label">Courses</div>
            </div>
        </div>
        
        <!-- Charts Grid -->
        <div class="rad-charts-grid">
            <!-- Grade Distribution Chart -->
            <div class="rad-chart-card">
                <div class="rad-chart-card__header">
                    <span class="rad-chart-card__title">📈 Grade Distribution</span>
                </div>
                <div class="rad-chart-card__body">
                    <div class="rad-grade-dist">
                        <div class="rad-grade-bar">
                            <span class="rad-grade-bar__label">First Class</span>
                            <div class="rad-grade-bar__track">
                                <div class="rad-grade-bar__fill rad-grade-bar__fill--first" style="width: <%=FirstClassPct%>%;">
                                    <%=FirstClassPct%>%
                                </div>
                            </div>
                            <span class="rad-grade-bar__value"><asp:Literal ID="litFirstClass" runat="server">0</asp:Literal></span>
                        </div>
                        <div class="rad-grade-bar">
                            <span class="rad-grade-bar__label">2nd Upper</span>
                            <div class="rad-grade-bar__track">
                                <div class="rad-grade-bar__fill rad-grade-bar__fill--upper" style="width: <%=UpperSecondPct%>%;">
                                    <%=UpperSecondPct%>%
                                </div>
                            </div>
                            <span class="rad-grade-bar__value"><asp:Literal ID="litUpperSecond" runat="server">0</asp:Literal></span>
                        </div>
                        <div class="rad-grade-bar">
                            <span class="rad-grade-bar__label">2nd Lower</span>
                            <div class="rad-grade-bar__track">
                                <div class="rad-grade-bar__fill rad-grade-bar__fill--lower" style="width: <%=LowerSecondPct%>%;">
                                    <%=LowerSecondPct%>%
                                </div>
                            </div>
                            <span class="rad-grade-bar__value"><asp:Literal ID="litLowerSecond" runat="server">0</asp:Literal></span>
                        </div>
                        <div class="rad-grade-bar">
                            <span class="rad-grade-bar__label">Pass</span>
                            <div class="rad-grade-bar__track">
                                <div class="rad-grade-bar__fill rad-grade-bar__fill--pass" style="width: <%=PassPct%>%;">
                                    <%=PassPct%>%
                                </div>
                            </div>
                            <span class="rad-grade-bar__value"><asp:Literal ID="litPass" runat="server">0</asp:Literal></span>
                        </div>
                        <div class="rad-grade-bar">
                            <span class="rad-grade-bar__label">Fail</span>
                            <div class="rad-grade-bar__track">
                                <div class="rad-grade-bar__fill rad-grade-bar__fill--fail" style="width: <%=FailPct%>%;">
                                    <%=FailPct%>%
                                </div>
                            </div>
                            <span class="rad-grade-bar__value"><asp:Literal ID="litFail" runat="server">0</asp:Literal></span>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Top Performing Students -->
            <div class="rad-chart-card">
                <div class="rad-chart-card__header">
                    <span class="rad-chart-card__title">🏆 Top Performing Students</span>
                    <asp:HyperLink ID="lnkViewAll" runat="server" NavigateUrl="#" CssClass="rad-btn rad-btn--outline" style="padding: 4px 10px; font-size: 10px;">View All</asp:HyperLink>
                </div>
                <div class="rad-chart-card__body">
                    <ul class="rad-top-list">
                        <asp:Repeater ID="rptTopStudents" runat="server">
                            <ItemTemplate>
                                <li class="rad-top-list__item">
                                    <span class="rad-top-list__rank rad-top-list__rank--<%# Container.ItemIndex < 3 ? (Container.ItemIndex + 1).ToString() : "other" %>"><%# Container.ItemIndex + 1 %></span>
                                    <div class="rad-top-list__content">
                                        <div class="rad-top-list__name"><%# Eval("student_name") %></div>
                                        <div class="rad-top-list__meta"><%# Eval("regno") %> • <%# Eval("programme") %></div>
                                    </div>
                                    <div class="rad-top-list__score"><%# Eval("gpa", "{0:F2}") %></div>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ul>
                </div>
            </div>
            
            <!-- Programme Performance Table (Full Width) -->
            <div class="rad-chart-card rad-chart-card--full">
                <div class="rad-chart-card__header">
                    <span class="rad-chart-card__title">📋 Programme Performance Summary</span>
                    <asp:Button ID="btnExportProgrammes" runat="server" Text="📊 Export" CssClass="rad-btn rad-btn--outline" style="padding: 4px 10px; font-size: 10px;" OnClick="btnExportProgrammes_Click" />
                </div>
                <div class="rad-chart-card__body" style="padding: 0;">
                    <dx:ASPxGridView ID="gvProgrammePerformance" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="progcode" CssClass="rad-perf-table">
                        <SettingsPager PageSize="10" AlwaysShowPager="true" />
                        <Settings ShowFilterRow="false" />
                        <Columns>
                            <dx:GridViewDataTextColumn FieldName="progname" Caption="Programme" VisibleIndex="0" Width="200px">
                                <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="total_students" Caption="Students" VisibleIndex="1" Width="80px">
                                <CellStyle HorizontalAlign="Center" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="pass_count" Caption="Passed" VisibleIndex="2" Width="70px">
                                <CellStyle HorizontalAlign="Center" ForeColor="#28a745" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="fail_count" Caption="Failed" VisibleIndex="3" Width="70px">
                                <CellStyle HorizontalAlign="Center" ForeColor="#dc3545" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="pass_rate" Caption="Pass Rate" VisibleIndex="4" Width="100px">
                                <DataItemTemplate>
                                    <%# GetPassRateBadge(Eval("pass_rate")) %>
                                </DataItemTemplate>
                                <CellStyle HorizontalAlign="Center" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="avg_mark" Caption="Avg Mark" VisibleIndex="5" Width="80px">
                                <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="first_class" Caption="1st Class" VisibleIndex="6" Width="70px">
                                <CellStyle HorizontalAlign="Center" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="upper_second" Caption="2nd Upper" VisibleIndex="7" Width="80px">
                                <CellStyle HorizontalAlign="Center" />
                            </dx:GridViewDataTextColumn>
                        </Columns>
                    </dx:ASPxGridView>
                </div>
            </div>
            
            <!-- Semester Trend Chart -->
            <div class="rad-chart-card">
                <div class="rad-chart-card__header">
                    <span class="rad-chart-card__title">📊 Pass Rate Trend (Last 4 Semesters)</span>
                </div>
                <div class="rad-chart-card__body">
                    <div class="rad-trend-chart">
                        <asp:Repeater ID="rptTrend" runat="server">
                            <ItemTemplate>
                                <div class="rad-trend-bar" style="height: <%# Eval("height") %>%;">
                                    <span class="rad-trend-bar__value"><%# Eval("pass_rate") %>%</span>
                                    <span class="rad-trend-bar__label"><%# Eval("semester_label") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
            
            <!-- Courses with Highest Fail Rate -->
            <div class="rad-chart-card">
                <div class="rad-chart-card__header">
                    <span class="rad-chart-card__title">⚠️ Courses Requiring Attention</span>
                </div>
                <div class="rad-chart-card__body" style="padding: 0;">
                    <dx:ASPxGridView ID="gvProblematicCourses" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="course_id" CssClass="rad-perf-table">
                        <SettingsPager PageSize="5" />
                        <Columns>
                            <dx:GridViewDataTextColumn FieldName="course_id" Caption="Code" VisibleIndex="0" Width="80px">
                                <CellStyle Font-Bold="true" ForeColor="#dc3545" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="course_name" Caption="Course" VisibleIndex="1">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="fail_rate" Caption="Fail Rate" VisibleIndex="2" Width="80px">
                                <CellStyle HorizontalAlign="Center" Font-Bold="true" ForeColor="#dc3545" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="total" Caption="Students" VisibleIndex="3" Width="70px">
                                <CellStyle HorizontalAlign="Center" />
                            </dx:GridViewDataTextColumn>
                        </Columns>
                    </dx:ASPxGridView>
                </div>
            </div>
        </div>
        
        <!-- Export Panel -->
        <div class="rad-export-panel">
            <div class="rad-export-panel__info">
                <div class="rad-export-panel__title">Export Analytics Report</div>
                <div class="rad-export-panel__text">Generate comprehensive reports for academic review and board presentations</div>
            </div>
            <div class="rad-export-panel__actions">
                <asp:Button ID="btnExportExcel" runat="server" Text="📊 Excel Report" CssClass="rad-export-btn rad-export-btn--excel" OnClick="btnExportExcel_Click" />
                <asp:Button ID="btnExportPDF" runat="server" Text="📄 PDF Report" CssClass="rad-export-btn rad-export-btn--pdf" OnClick="btnExportPDF_Click" />
                <button type="button" class="rad-export-btn rad-export-btn--print" onclick="window.print();">🖨 Print</button>
            </div>
        </div>
    </div>
    
    <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvProgrammePerformance" />
</asp:Content>
