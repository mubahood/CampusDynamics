<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ProgrammesDashboard.aspx.cs" Inherits="COOPERP_NewScreens_ProgrammesDashboard" Title="Programmes Dashboard - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.pgd-hero {
    background: linear-gradient(135deg, #05275C 0%, #174DA4 100%);
    color: #fff;
    padding: 18px 20px;
    margin-bottom: 16px;
    border-bottom: 3px solid #041d45;
}
.pgd-hero__top { display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; }
.pgd-hero__title { font-size: 18px; font-weight: 800; margin: 0 0 4px; }
.pgd-hero__sub { font-size: 12px; opacity: .82; margin: 0; }
.pgd-hero__period {
    background: rgba(255,255,255,.12);
    padding: 10px 14px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .4px;
}

.pgd-stats {
    display: grid;
    grid-template-columns: repeat(6, minmax(0, 1fr));
    gap: 12px;
    margin-bottom: 16px;
}
.pgd-stat {
    background: #fff;
    border: 1px solid #e0e5ed;
    padding: 14px;
}
.pgd-stat__label { font-size: 10px; color: #6b7280; text-transform: uppercase; letter-spacing: .45px; font-weight: 700; }
.pgd-stat__value { font-size: 24px; color: #05275C; font-weight: 800; line-height: 1.1; margin-top: 8px; }
.pgd-stat__sub { font-size: 11px; color: #6b7280; margin-top: 5px; }
.pgd-stat__sub strong { color: #05275C; }

.pgd-grid {
    display: grid;
    grid-template-columns: 1.1fr .9fr;
    gap: 16px;
}
.pgd-panel {
    background: #fff;
    border: 1px solid #e0e5ed;
    margin-bottom: 16px;
}
.pgd-panel__head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    padding: 12px 14px;
    border-bottom: 2px solid #e0e5ed;
    background: #f8fafc;
}
.pgd-panel__title { font-size: 12px; font-weight: 800; color: #05275C; text-transform: uppercase; letter-spacing: .45px; }
.pgd-panel__body { padding: 14px; }

.pgd-bars { display: flex; flex-direction: column; gap: 12px; }
.pgd-bar__row { display: grid; grid-template-columns: 180px 1fr auto; gap: 10px; align-items: center; }
.pgd-bar__label { font-size: 12px; font-weight: 600; color: #1f2937; }
.pgd-bar__track { height: 10px; background: #eef2f7; overflow: hidden; }
.pgd-bar__fill { height: 100%; background: linear-gradient(90deg, #174DA4 0%, #2c74d8 100%); }
.pgd-bar__value { font-size: 11px; color: #4b5563; font-weight: 700; }

.pgd-list { display: flex; flex-direction: column; gap: 10px; }
.pgd-list__item { padding: 10px 12px; border: 1px solid #e7ebf1; background: #fbfcfe; }
.pgd-list__top { display: flex; align-items: center; justify-content: space-between; gap: 10px; }
.pgd-list__name { font-size: 12px; font-weight: 700; color: #1f2937; }
.pgd-list__meta { font-size: 11px; color: #6b7280; margin-top: 4px; }
.pgd-badge { display: inline-block; padding: 3px 8px; font-size: 10px; font-weight: 800; text-transform: uppercase; letter-spacing: .35px; }
.pgd-badge--primary { background: #e8f0fc; color: #174DA4; }
.pgd-badge--success { background: #e7f8ec; color: #15803d; }
.pgd-badge--warn { background: #fff7e6; color: #b45309; }

.pgd-yearmix { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px; }
.pgd-yearmix__card { border: 1px solid #e7ebf1; background: #fbfcfe; padding: 12px; }
.pgd-yearmix__title { font-size: 11px; font-weight: 700; color: #4b5563; text-transform: uppercase; }
.pgd-yearmix__value { font-size: 20px; font-weight: 800; color: #05275C; margin-top: 8px; }
.pgd-yearmix__sub { font-size: 11px; color: #6b7280; margin-top: 4px; }

.pgd-links { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; }
.pgd-link {
    display: block;
    border: 1px solid #dbe4ef;
    background: #fff;
    padding: 12px 14px;
    text-decoration: none;
    color: #1f2937;
}
.pgd-link:hover { border-color: #174DA4; background: #f7faff; text-decoration: none; }
.pgd-link__title { font-size: 12px; font-weight: 700; color: #05275C; }
.pgd-link__sub { font-size: 11px; color: #6b7280; margin-top: 4px; }

.pgd-tasklist { display:flex; flex-direction:column; gap:10px; }
.pgd-task {
    display:block;
    border:1px solid #dbe4ef;
    background:#fff;
    padding:12px 14px;
    text-decoration:none;
    color:#1f2937;
}
.pgd-task:hover { border-color:#174DA4; background:#f7faff; text-decoration:none; }
.pgd-task__top { display:flex; align-items:center; justify-content:space-between; gap:10px; }
.pgd-task__title { font-size:12px; font-weight:800; color:#05275C; }
.pgd-task__count { font-size:11px; font-weight:800; color:#174DA4; background:#e8f0fc; padding:3px 8px; }
.pgd-task__sub { font-size:11px; color:#6b7280; margin-top:5px; }

.pgd-empty { font-size: 12px; color: #6b7280; }

@media (max-width: 1200px) {
    .pgd-stats { grid-template-columns: repeat(3, minmax(0, 1fr)); }
    .pgd-grid { grid-template-columns: 1fr; }
}

@media (max-width: 700px) {
    .pgd-stats, .pgd-yearmix, .pgd-links { grid-template-columns: 1fr 1fr; }
    .pgd-bar__row { grid-template-columns: 1fr; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="pgd-hero">
    <div class="pgd-hero__top">
        <div>
            <div class="pgd-hero__title">Programmes Dashboard</div>
            <p class="pgd-hero__sub">Central overview for faculties, programmes, specialisations, courses, lecturers, and current teaching load.</p>
        </div>
        <div class="pgd-hero__period">Current Period: <asp:Literal ID="litCurrentPeriod" runat="server" /></div>
    </div>
</div>

<div class="pgd-stats">
    <div class="pgd-stat">
        <div class="pgd-stat__label">Faculties</div>
        <div class="pgd-stat__value"><asp:Literal ID="litFacultyCount" runat="server" Text="0" /></div>
        <div class="pgd-stat__sub">Academic structures</div>
    </div>
    <div class="pgd-stat">
        <div class="pgd-stat__label">Programmes</div>
        <div class="pgd-stat__value"><asp:Literal ID="litProgrammeCount" runat="server" Text="0" /></div>
        <div class="pgd-stat__sub"><asp:Literal ID="litProgrammeSub" runat="server" Text="Live programme records" /></div>
    </div>
    <div class="pgd-stat">
        <div class="pgd-stat__label">Programme Course Mappings</div>
        <div class="pgd-stat__value"><asp:Literal ID="litMappingCount" runat="server" Text="0" /></div>
        <div class="pgd-stat__sub"><asp:Literal ID="litMappingSub" runat="server" Text="Mapped courses across programmes" /></div>
    </div>
    <div class="pgd-stat">
        <div class="pgd-stat__label">Courses</div>
        <div class="pgd-stat__value"><asp:Literal ID="litCourseCount" runat="server" Text="0" /></div>
        <div class="pgd-stat__sub"><asp:Literal ID="litCourseSub" runat="server" Text="Course bank records" /></div>
    </div>
    <div class="pgd-stat">
        <div class="pgd-stat__label">Pending Load Requests</div>
        <div class="pgd-stat__value"><asp:Literal ID="litPendingRequests" runat="server" Text="0" /></div>
        <div class="pgd-stat__sub"><asp:Literal ID="litPendingRequestsSub" runat="server" Text="Awaiting admin review" /></div>
    </div>
    <div class="pgd-stat">
        <div class="pgd-stat__label">Current Teaching Loads</div>
        <div class="pgd-stat__value"><asp:Literal ID="litLoadCount" runat="server" Text="0" /></div>
        <div class="pgd-stat__sub"><asp:Literal ID="litLoadSub" runat="server" Text="This semester allocations" /></div>
    </div>
</div>

<div class="pgd-grid">
    <div>
        <div class="pgd-panel">
            <div class="pgd-panel__head">
                <div class="pgd-panel__title">Faculty Distribution</div>
                <span class="pgd-badge pgd-badge--primary">By programmes &amp; mapped courses</span>
            </div>
            <div class="pgd-panel__body">
                <div class="pgd-bars"><asp:Literal ID="litFacultyBars" runat="server" /></div>
            </div>
        </div>

        <div class="pgd-panel">
            <div class="pgd-panel__head">
                <div class="pgd-panel__title">Priority Tasks</div>
                <span class="pgd-badge pgd-badge--warn">Action queue</span>
            </div>
            <div class="pgd-panel__body">
                <div class="pgd-tasklist"><asp:Literal ID="litPriorityTasks" runat="server" /></div>
            </div>
        </div>
    </div>

    <div>
        <div class="pgd-panel">
            <div class="pgd-panel__head">
                <div class="pgd-panel__title">Programme Course Mix</div>
                <span class="pgd-badge pgd-badge--success">Year &amp; assignment coverage</span>
            </div>
            <div class="pgd-panel__body">
                <div class="pgd-yearmix"><asp:Literal ID="litYearMix" runat="server" /></div>
            </div>
        </div>

        <div class="pgd-panel">
            <div class="pgd-panel__head">
                <div class="pgd-panel__title">Operational Shortcuts</div>
                <span class="pgd-badge pgd-badge--primary">Programmes &amp; courses</span>
            </div>
            <div class="pgd-panel__body">
                <div class="pgd-links">
                    <a class="pgd-link" href="CourseRegistrationLedgerController.aspx"><div class="pgd-link__title">Programme Courses Ctrl</div><div class="pgd-link__sub">Review the mapped-course controller</div></a>
                    <a class="pgd-link" href="ProgrammeLoadRequests.aspx"><div class="pgd-link__title">Load Requests</div><div class="pgd-link__sub">Review lecturer allocation requests</div></a>
                    <a class="pgd-link" href="NewFaculties.aspx"><div class="pgd-link__title">Faculties</div><div class="pgd-link__sub">Manage faculty setup</div></a>
                    <a class="pgd-link" href="NewFacultyProgrammes.aspx"><div class="pgd-link__title">Programmes</div><div class="pgd-link__sub">Browse programme definitions</div></a>
                    <a class="pgd-link" href="NewSpecialisations.aspx"><div class="pgd-link__title">Specialisations</div><div class="pgd-link__sub">Manage specialisation paths</div></a>
                    <a class="pgd-link" href="NewCourses.aspx"><div class="pgd-link__title">Courses</div><div class="pgd-link__sub">Open course bank</div></a>
                    <a class="pgd-link" href="NewProgrammeCourses.aspx"><div class="pgd-link__title">Programme Courses</div><div class="pgd-link__sub">Maintain course mappings by year and semester</div></a>
                    <a class="pgd-link" href="ProgrammeLecturers.aspx"><div class="pgd-link__title">Lecturers</div><div class="pgd-link__sub">Read-only lecturer directory</div></a>
                    <a class="pgd-link" href="ProgrammeLecturerLoads.aspx"><div class="pgd-link__title">Lecturer Loads</div><div class="pgd-link__sub">Current semester load summary</div></a>
                </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>
