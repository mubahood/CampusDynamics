<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="StudentResultsView.aspx.cs" Inherits="COOPERP_NewScreens_StudentResultsView" Title="Student Results View - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* ===============================================
           STUDENT RESULTS VIEW - STYLES
           Prefix: srv- (Student Results View)
        =============================================== */
        
        .srv-container { padding: 0; font-size: 11px; }
        
        /* Page Header */
        .cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
        .cd-page-header__left { display:flex; align-items:center; gap:12px; }
        .cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
        .cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
        .cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
        .cd-page-header__right { display:flex; gap:8px; align-items:center; }
        
        /* Search Bar */
        .srv-search-bar {
            display: flex;
            gap: 12px;
            align-items: center;
            padding: 15px;
            background: #f5f7fa;
            border-radius: 4px;
            margin-bottom: 15px;
        }
        .srv-search-input {
            flex: 1;
            padding: 10px 15px;
            font-size: 12px;
            border: 2px solid #ced4da;
            border-radius: 0;
            transition: border-color 0.15s ease;
        }
        .srv-search-input:focus { border-color: #174DA4; outline: none; }
        .srv-search-input::placeholder { color: #adb5bd; }
        
        /* Buttons */
        .srv-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 8px 16px;
            font-size: 11px;
            font-weight: 500;
            border: 1px solid transparent;
            border-radius: 0;
            cursor: pointer;
            transition: all 0.15s ease;
            text-decoration: none;
        }
        .srv-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
        .srv-btn--primary:hover { background: #0d3a7d; }
        .srv-btn--outline { background: #fff; color: #495057; border-color: #ced4da; }
        .srv-btn--outline:hover { background: #f8f9fa; }
        .srv-btn--success { background: #28a745; color: #fff; }
        .srv-btn--success:hover { background: #218838; }
        
        /* Layout */
        .srv-layout {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 15px;
        }
        @media (max-width: 992px) { .srv-layout { grid-template-columns: 1fr; } }
        
        /* Student Profile Card */
        .srv-profile-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            overflow: hidden;
        }
        .srv-profile-card__header {
            background: #05275C;
            padding: 20px;
            color: #fff;
            text-align: center;
        }
        .srv-profile-card__photo {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            border: 3px solid rgba(255,255,255,0.3);
            margin-bottom: 12px;
            background: #fff;
            object-fit: cover;
        }
        .srv-profile-card__name { font-size: 14px; font-weight: 700; margin-bottom: 4px; }
        .srv-profile-card__regno { font-size: 11px; opacity: 0.9; }
        .srv-profile-card__body { padding: 0; }
        
        .srv-profile-info {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .srv-profile-info__item {
            display: flex;
            justify-content: space-between;
            padding: 10px 16px;
            border-bottom: 1px solid #e9ecef;
            font-size: 11px;
        }
        .srv-profile-info__item:last-child { border-bottom: none; }
        .srv-profile-info__label { color: #6c757d; }
        .srv-profile-info__value { font-weight: 600; color: #1a1a2e; }
        
        .srv-profile-stats {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0;
        }
        .srv-profile-stat {
            padding: 16px;
            text-align: center;
            background: #f5f7fa;
        }
        .srv-profile-stat:first-child { border-right: 1px solid #e0e0e0; }
        .srv-profile-stat__value { font-size: 22px; font-weight: 700; color: #174DA4; line-height: 1; }
        .srv-profile-stat__label { font-size: 9px; color: #6c757d; margin-top: 4px; text-transform: uppercase; }
        
        /* Results Panel */
        .srv-results-panel {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            overflow: hidden;
        }
        .srv-results-panel__header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 16px;
            background: #f5f7fa;
            border-bottom: 1px solid #e0e0e0;
        }
        .srv-results-panel__title { font-size: 13px; font-weight: 600; color: #1a1a2e; }
        .srv-results-panel__actions { display: flex; gap: 8px; }
        .srv-results-panel__body { padding: 0; }
        
        /* Semester Tabs */
        .srv-semester-tabs {
            display: flex;
            border-bottom: 2px solid #e9ecef;
            overflow-x: auto;
        }
        .srv-semester-tab {
            padding: 12px 20px;
            font-size: 11px;
            font-weight: 500;
            color: #6c757d;
            background: transparent;
            border: none;
            border-bottom: 2px solid transparent;
            margin-bottom: -2px;
            cursor: pointer;
            white-space: nowrap;
            transition: all 0.15s ease;
        }
        .srv-semester-tab:hover { color: #174DA4; background: #f8f9fa; }
        .srv-semester-tab--active {
            color: #174DA4;
            border-bottom-color: #174DA4;
            background: #fff;
        }
        
        /* Results Table */
        .srv-results-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }
        .srv-results-table th {
            text-align: left;
            padding: 10px 12px;
            background: #f5f7fa;
            border-bottom: 2px solid #174DA4;
            font-weight: 600;
            color: #495057;
            font-size: 10px;
            text-transform: uppercase;
        }
        .srv-results-table td {
            padding: 12px;
            border-bottom: 1px solid #e9ecef;
            vertical-align: middle;
        }
        .srv-results-table tr:hover td { background: #f8f9fa; }
        .srv-results-table tr:last-child td { border-bottom: none; }
        
        /* Grade Badge */
        .srv-grade {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
        }
        .srv-grade--a { background: #22c55e; color: #fff; }
        .srv-grade--b { background: #84cc16; color: #fff; }
        .srv-grade--c { background: #eab308; color: #5d4a00; }
        .srv-grade--d { background: #f97316; color: #fff; }
        .srv-grade--f { background: #ef4444; color: #fff; }
        
        /* Mark Progress */
        .srv-mark-bar {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .srv-mark-bar__track {
            width: 80px;
            height: 8px;
            background: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
        }
        .srv-mark-bar__fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.3s ease;
        }
        .srv-mark-bar__fill--high { background: #28a745; }
        .srv-mark-bar__fill--medium { background: #ffc107; }
        .srv-mark-bar__fill--low { background: #dc3545; }
        .srv-mark-bar__value { font-weight: 600; min-width: 35px; }
        
        /* Status Badge */
        .srv-status {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            font-size: 10px;
            font-weight: 500;
            border-radius: 12px;
        }
        .srv-status--released { background: #d4edda; color: #155724; }
        .srv-status--pending { background: #fff3cd; color: #856404; }
        .srv-status--held { background: #f8d7da; color: #721c24; }
        
        /* Summary Footer */
        .srv-summary {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px;
            background: #05275C;
            color: #fff;
        }
        .srv-summary__item {
            text-align: center;
        }
        .srv-summary__value { font-size: 18px; font-weight: 700; }
        .srv-summary__label { font-size: 10px; opacity: 0.8; }
        
        /* No Student Message */
        .srv-no-student {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        .srv-no-student__icon { font-size: 48px; opacity: 0.5; margin-bottom: 15px; }
        .srv-no-student__title { font-size: 14px; font-weight: 600; color: #495057; margin-bottom: 8px; }
        .srv-no-student__text { font-size: 11px; }
        
        /* Actions dropdown */
        .srv-action-menu {
            position: relative;
            display: inline-block;
        }
        .srv-action-btn {
            padding: 6px 12px;
            font-size: 10px;
            background: #f8f9fa;
            border: 1px solid #ced4da;
            border-radius: 4px;
            cursor: pointer;
        }
        .srv-action-btn:hover { background: #e9ecef; }
        
        /* Print Styles */
        @media print {
            .srv-search-bar, .srv-results-panel__actions, .srv-btn { display: none !important; }
            .srv-layout { grid-template-columns: 1fr; }
            .srv-profile-card { page-break-after: avoid; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="srv-container">
        <!-- Page Header -->
        <div class="cd-page-header">
            <div class="cd-page-header__left">
                <div class="cd-page-header__icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/><line x1="12" y1="7" x2="16" y2="7"/><line x1="12" y1="11" x2="16" y2="11"/></svg>
                </div>
                <div>
                    <div class="cd-page-header__title">Student Results View</div>
                    <div class="cd-page-header__sub">View individual student academic results and transcripts</div>
                </div>
            </div>
            <div class="cd-page-header__right">
                <asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="~/COOPERP/NewScreens/ResultsRelease.aspx" CssClass="srv-btn srv-btn--outline">
                    ← Back to Results
                </asp:HyperLink>
            </div>
        </div>
        
        <!-- Search Bar -->
        <div class="srv-search-bar">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="srv-search-input" placeholder="🔍 Search by Registration Number, Student Name, or ID Number..." />
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="srv-btn srv-btn--primary" OnClick="btnSearch_Click" />
            <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="srv-btn srv-btn--outline" OnClick="btnClear_Click" />
        </div>
        
        <asp:Panel ID="pnlNoStudent" runat="server" Visible="true">
            <div class="srv-results-panel">
                <div class="srv-no-student">
                    <div class="srv-no-student__icon">🔍</div>
                    <div class="srv-no-student__title">Search for a Student</div>
                    <div class="srv-no-student__text">Enter a registration number, name, or ID to view their academic results</div>
                </div>
            </div>
        </asp:Panel>
        
        <asp:Panel ID="pnlStudent" runat="server" Visible="false">
            <div class="srv-layout">
                <!-- Student Profile Card -->
                <div class="srv-profile-card">
                    <div class="srv-profile-card__header">
                        <asp:Image ID="imgStudent" runat="server" CssClass="srv-profile-card__photo" ImageUrl="~/images/default-avatar.png" />
                        <div class="srv-profile-card__name"><asp:Literal ID="litStudentName" runat="server"></asp:Literal></div>
                        <div class="srv-profile-card__regno"><asp:Literal ID="litRegNo" runat="server"></asp:Literal></div>
                    </div>
                    
                    <ul class="srv-profile-info">
                        <li class="srv-profile-info__item">
                            <span class="srv-profile-info__label">Programme</span>
                            <span class="srv-profile-info__value"><asp:Literal ID="litProgramme" runat="server"></asp:Literal></span>
                        </li>
                        <li class="srv-profile-info__item">
                            <span class="srv-profile-info__label">Faculty</span>
                            <span class="srv-profile-info__value"><asp:Literal ID="litFaculty" runat="server"></asp:Literal></span>
                        </li>
                        <li class="srv-profile-info__item">
                            <span class="srv-profile-info__label">Year of Study</span>
                            <span class="srv-profile-info__value"><asp:Literal ID="litYear" runat="server"></asp:Literal></span>
                        </li>
                        <li class="srv-profile-info__item">
                            <span class="srv-profile-info__label">Enrollment Date</span>
                            <span class="srv-profile-info__value"><asp:Literal ID="litEnrollDate" runat="server"></asp:Literal></span>
                        </li>
                        <li class="srv-profile-info__item">
                            <span class="srv-profile-info__label">Status</span>
                            <span class="srv-profile-info__value"><asp:Literal ID="litStatus" runat="server"></asp:Literal></span>
                        </li>
                    </ul>
                    
                    <div class="srv-profile-stats">
                        <div class="srv-profile-stat">
                            <div class="srv-profile-stat__value"><asp:Literal ID="litCGPA" runat="server">0.00</asp:Literal></div>
                            <div class="srv-profile-stat__label">Cumulative GPA</div>
                        </div>
                        <div class="srv-profile-stat">
                            <div class="srv-profile-stat__value"><asp:Literal ID="litCredits" runat="server">0</asp:Literal></div>
                            <div class="srv-profile-stat__label">Credits Earned</div>
                        </div>
                    </div>
                    
                    <div style="padding: 12px;">
                        <asp:Button ID="btnPrintTranscript" runat="server" Text="🖨 Print Transcript" CssClass="srv-btn srv-btn--outline" style="width: 100%;" OnClick="btnPrintTranscript_Click" />
                    </div>
                </div>
                
                <!-- Results Panel -->
                <div class="srv-results-panel">
                    <div class="srv-results-panel__header">
                        <span class="srv-results-panel__title">📋 Academic Results</span>
                        <div class="srv-results-panel__actions">
                            <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="srv-action-btn" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged">
                            </asp:DropDownList>
                            <asp:Button ID="btnExport" runat="server" Text="📊 Export" CssClass="srv-btn srv-btn--outline" style="padding: 6px 12px; font-size: 10px;" OnClick="btnExport_Click" />
                        </div>
                    </div>
                    
                    <!-- Semester Tabs -->
                    <div class="srv-semester-tabs">
                        <asp:Repeater ID="rptSemesters" runat="server" OnItemCommand="rptSemesters_ItemCommand">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnSemTab" runat="server" 
                                    CssClass='<%# "srv-semester-tab " + (Eval("is_active").ToString() == "1" ? "srv-semester-tab--active" : "") %>'
                                    CommandName="SelectSemester" CommandArgument='<%# Eval("semester") %>'>
                                    <%# Eval("label") %>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    
                    <div class="srv-results-panel__body">
                        <dx:ASPxGridView ID="gvResults" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="id">
                            <SettingsPager PageSize="15" AlwaysShowPager="false" />
                            <Settings ShowFilterRow="false" />
                            <SettingsSearchPanel Visible="false" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="course_id" Caption="Code" VisibleIndex="0" Width="80px">
                                    <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="course_name" Caption="Course" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="credit_hours" Caption="Credits" VisibleIndex="2" Width="60px">
                                    <CellStyle HorizontalAlign="Center" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="ca_mark" Caption="CA" VisibleIndex="3" Width="60px">
                                    <CellStyle HorizontalAlign="Center" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="exam_mark" Caption="Exam" VisibleIndex="4" Width="60px">
                                    <CellStyle HorizontalAlign="Center" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="finalmark" Caption="Final" VisibleIndex="5" Width="80px">
                                    <DataItemTemplate>
                                        <div class="srv-mark-bar">
                                            <div class="srv-mark-bar__track">
                                                <div class="srv-mark-bar__fill <%# GetMarkClass(Eval("finalmark")) %>" style="width: <%# Eval("finalmark") %>%;"></div>
                                            </div>
                                            <span class="srv-mark-bar__value"><%# Eval("finalmark") %></span>
                                        </div>
                                    </DataItemTemplate>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="grade" Caption="Grade" VisibleIndex="6" Width="60px">
                                    <DataItemTemplate>
                                        <span class="srv-grade <%# GetGradeClass(Eval("grade")) %>"><%# Eval("grade") %></span>
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="status" Caption="Status" VisibleIndex="7" Width="90px">
                                    <DataItemTemplate>
                                        <%# GetStatusBadge(Eval("approved_by")) %>
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center" />
                                </dx:GridViewDataTextColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </div>
                    
                    <!-- Summary Footer -->
                    <div class="srv-summary">
                        <div class="srv-summary__item">
                            <div class="srv-summary__value"><asp:Literal ID="litSemCredits" runat="server">0</asp:Literal></div>
                            <div class="srv-summary__label">Credits This Semester</div>
                        </div>
                        <div class="srv-summary__item">
                            <div class="srv-summary__value"><asp:Literal ID="litSemGPA" runat="server">0.00</asp:Literal></div>
                            <div class="srv-summary__label">Semester GPA</div>
                        </div>
                        <div class="srv-summary__item">
                            <div class="srv-summary__value"><asp:Literal ID="litPassedCourses" runat="server">0</asp:Literal></div>
                            <div class="srv-summary__label">Courses Passed</div>
                        </div>
                        <div class="srv-summary__item">
                            <div class="srv-summary__value"><asp:Literal ID="litFailedCourses" runat="server">0</asp:Literal></div>
                            <div class="srv-summary__label">Courses Failed</div>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>
        
        <!-- Search Results Panel -->
        <asp:Panel ID="pnlSearchResults" runat="server" Visible="false">
            <div class="srv-results-panel" style="margin-top: 15px;">
                <div class="srv-results-panel__header">
                    <span class="srv-results-panel__title">🔎 Search Results</span>
                </div>
                <div class="srv-results-panel__body">
                    <dx:ASPxGridView ID="gvSearchResults" runat="server" Width="100%" AutoGenerateColumns="False" KeyFieldName="regno"
                        OnRowCommand="gvSearchResults_RowCommand">
                        <SettingsPager PageSize="10" />
                        <Columns>
                            <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" VisibleIndex="0" Width="120px">
                                <CellStyle Font-Bold="true" ForeColor="#174DA4" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="fullname" Caption="Student Name" VisibleIndex="1">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="progname" Caption="Programme" VisibleIndex="2">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="yearofstudy" Caption="Year" VisibleIndex="3" Width="60px">
                                <CellStyle HorizontalAlign="Center" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="status" Caption="Status" VisibleIndex="4" Width="100px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataColumn Caption="Action" VisibleIndex="5" Width="100px">
                                <DataItemTemplate>
                                    <asp:LinkButton ID="btnView" runat="server" CssClass="srv-btn srv-btn--primary" style="padding: 4px 10px; font-size: 10px;"
                                        CommandName="ViewStudent" CommandArgument='<%# Eval("regno") %>'>
                                        View Results
                                    </asp:LinkButton>
                                </DataItemTemplate>
                            </dx:GridViewDataColumn>
                        </Columns>
                    </dx:ASPxGridView>
                </div>
            </div>
        </asp:Panel>
    </div>
    
    <dx:ASPxGridViewExporter ID="gvExporter" runat="server" GridViewID="gvResults" />
</asp:Content>
