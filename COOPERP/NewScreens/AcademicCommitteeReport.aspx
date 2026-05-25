<%@ Page Title="Academic Committee Report" Language="C#" MasterPageFile="~/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AcademicCommitteeReport.aspx.cs" Inherits="COOPERP_NewScreens_AcademicCommitteeReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<style>
:root {
    --navy:#05275C; --blue:#174DA4; --surface:#f5f7fa;
    --border:#e0e5ed; --text:#1a1a2e; --muted:#6b7280;
    --green:#166534; --green-bg:#dcfce7; --green-border:#bbf7d0;
    --amber:#92400e; --amber-bg:#fffbeb; --amber-border:#fde68a;
    --red:#991b1b; --red-bg:#fef2f2;
}
.acr-wrap { max-width:1200px; margin:0 auto; font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif; font-size:12px; color:var(--text); }

/* Report header */
.acr-letterhead { background:#fff; border:1px solid var(--border); padding:24px 32px 16px; margin-bottom:8px; display:flex; align-items:flex-start; gap:20px; }
.acr-letterhead__logo { width:72px; height:72px; object-fit:contain; flex-shrink:0; }
.acr-letterhead__info { flex:1; }
.acr-letterhead__uni { font-size:18px; font-weight:800; color:var(--navy); letter-spacing:.3px; }
.acr-letterhead__sub { font-size:10px; color:var(--muted); margin-top:2px; }
.acr-letterhead__report { margin-top:10px; border-top:2px solid var(--navy); padding-top:8px; }
.acr-letterhead__report-title { font-size:14px; font-weight:700; color:var(--navy); }
.acr-letterhead__report-sub { font-size:10px; color:var(--muted); margin-top:2px; }
.acr-meta { display:flex; gap:24px; background:#fff; border:1px solid var(--border); border-top:none; padding:8px 32px; }
.acr-meta__item { font-size:10px; color:var(--muted); }
.acr-meta__item strong { color:var(--text); }

/* Toolbar */
.acr-toolbar { display:flex; gap:8px; margin:12px 0; }
.acr-btn { display:inline-flex; align-items:center; gap:5px; padding:6px 14px; font-size:10px; font-weight:700; border:none; border-radius:0; cursor:pointer; font-family:inherit; }
.acr-btn--primary { background:var(--navy); color:#fff; }
.acr-btn--secondary { background:#fff; color:var(--navy); border:1px solid var(--border); }
.acr-btn--print { background:var(--blue); color:#fff; }

/* Summary cards */
.acr-summary { display:grid; grid-template-columns:repeat(4,1fr); gap:10px; margin-bottom:16px; }
.acr-card { background:#fff; border:1px solid var(--border); padding:14px 16px; }
.acr-card__val { font-size:24px; font-weight:800; color:var(--navy); line-height:1; }
.acr-card__lbl { font-size:10px; color:var(--muted); margin-top:4px; }
.acr-card__sub { font-size:10px; color:var(--muted); margin-top:6px; border-top:1px solid var(--border); padding-top:5px; }

/* Sections */
.acr-section { background:#fff; border:1px solid var(--border); margin-bottom:12px; }
.acr-section__hdr { background:var(--navy); color:#fff; padding:10px 16px; display:flex; align-items:center; justify-content:space-between; }
.acr-section__hdr-title { font-size:13px; font-weight:700; }
.acr-section__hdr-sub { font-size:10px; opacity:.8; }
.acr-section__body { padding:16px; }

/* Tables */
.acr-table { width:100%; border-collapse:collapse; font-size:11px; }
.acr-table th { background:var(--navy); color:#fff; padding:7px 10px; text-align:left; font-weight:700; font-size:10px; white-space:nowrap; }
.acr-table th.right, .acr-table td.right { text-align:right; }
.acr-table td { padding:6px 10px; border-bottom:1px solid var(--border); vertical-align:top; }
.acr-table tr:hover td { background:#f8faff; }
.acr-table tr.acr-table--subtotal td { background:#f0f4ff; font-weight:700; }
.acr-table tr.acr-table--faculty td { background:#e8edf8; font-weight:700; font-size:11px; color:var(--navy); }
.acr-table tr.acr-table--grandtotal td { background:var(--navy); color:#fff; font-weight:700; }
.acr-table--compact td, .acr-table--compact th { padding:5px 8px; }
.acr-num { font-weight:700; color:var(--navy); }
.acr-num--male { color:#1d4ed8; }
.acr-num--female { color:#be185d; }

/* Year tabs */
.acr-year-tabs { display:flex; gap:0; border-bottom:2px solid var(--navy); margin-bottom:16px; }
.acr-year-tab { padding:7px 18px; font-size:11px; font-weight:700; cursor:pointer; border:1px solid var(--border); border-bottom:none; background:#f5f7fa; color:var(--muted); margin-right:2px; }
.acr-year-tab.active { background:var(--navy); color:#fff; border-color:var(--navy); }
.acr-year-panel { display:none; }
.acr-year-panel.active { display:block; }

/* Programme level badges */
.acr-level { display:inline-block; padding:2px 8px; font-size:9px; font-weight:700; border-radius:0; }
.acr-level--0 { background:#f3f4f6; color:#374151; }
.acr-level--1 { background:#dbeafe; color:#1e40af; }
.acr-level--2 { background:#e0f2fe; color:#0369a1; }
.acr-level--3 { background:#dcfce7; color:#166534; }
.acr-level--4 { background:#fef9c3; color:#713f12; }
.acr-level--5 { background:#fae8ff; color:#6b21a8; }
.acr-level--6 { background:#fce7f3; color:#9d174d; }
.acr-status--active { color:var(--green); font-weight:700; }
.acr-status--inactive { color:var(--red); }
.acr-status--pending { color:var(--amber); }
.acr-na { color:#9ca3af; font-style:italic; }

/* Notice */
.acr-notice { background:var(--amber-bg); border:1px solid var(--amber-border); padding:10px 14px; font-size:10px; color:var(--amber); margin-bottom:12px; }
.acr-notice strong { font-size:11px; }

/* Gender breakdown bar */
.acr-gender-bar { display:flex; height:6px; border-radius:0; overflow:hidden; margin-top:4px; }
.acr-gender-bar__m { background:#1d4ed8; }
.acr-gender-bar__f { background:#be185d; }

/* Footer */
.acr-footer { text-align:center; padding:16px; font-size:10px; color:var(--muted); border-top:1px solid var(--border); background:#fff; margin-top:4px; }

/* Print */
@media print {
    .acr-toolbar, .sb-sidebar, .sb-topbar, .acr-year-tabs { display:none !important; }
    .acr-year-panel { display:block !important; }
    .acr-section { page-break-inside:avoid; }
    .acr-wrap { max-width:100%; }
    .acr-table th { -webkit-print-color-adjust:exact; print-color-adjust:exact; }
}
</style>

<div class="acr-wrap">

    <!-- Letterhead -->
    <div class="acr-letterhead">
        <div class="acr-letterhead__info">
            <div class="acr-letterhead__uni">MUTESA I ROYAL UNIVERSITY</div>
            <div class="acr-letterhead__sub">P.O. Box 7614, Kampala, Uganda &nbsp;|&nbsp; www.mru.ac.ug &nbsp;|&nbsp; Accredited by NCHE</div>
            <div class="acr-letterhead__report">
                <div class="acr-letterhead__report-title">ACADEMIC &amp; QUALITY ASSURANCE COMMITTEE — FORMAL REPORT</div>
                <div class="acr-letterhead__report-sub">
                    Prepared for submission to the University Council Committee &nbsp;|&nbsp;
                    <asp:Literal ID="litReportDate" runat="server" />
                </div>
            </div>
        </div>
    </div>
    <div class="acr-meta">
        <div class="acr-meta__item"><strong>Prepared by:</strong> Office of the Registrar (EMIS)</div>
        <div class="acr-meta__item"><strong>Data source:</strong> Campus Dynamics MIS</div>
        <div class="acr-meta__item"><strong>Active student definition:</strong> new_status = ACTIVE + registered this academic year</div>
        <div class="acr-meta__item"><strong>Reference years:</strong> <asp:Literal ID="litYearsRef" runat="server" /></div>
    </div>

    <!-- Toolbar -->
    <div class="acr-toolbar">
        <button class="acr-btn acr-btn--print" onclick="window.print()">🖨 Print / Save PDF</button>
        <asp:HyperLink ID="lnkExcel" runat="server" CssClass="acr-btn acr-btn--secondary">⬇ Export Excel</asp:HyperLink>
        <button class="acr-btn acr-btn--secondary" onclick="location.reload()">↺ Refresh Data</button>
    </div>

    <!-- Executive Summary Cards -->
    <div class="acr-summary">
        <div class="acr-card">
            <div class="acr-card__val"><asp:Literal ID="litTotalActive" runat="server" /></div>
            <div class="acr-card__lbl">Total Active Students (Current Year)</div>
            <div class="acr-card__sub"><asp:Literal ID="litGenderSplit" runat="server" /></div>
        </div>
        <div class="acr-card">
            <div class="acr-card__val"><asp:Literal ID="litTotalProgrammes" runat="server" /></div>
            <div class="acr-card__lbl">Academic Programmes</div>
            <div class="acr-card__sub"><asp:Literal ID="litLevelSplit" runat="server" /></div>
        </div>
        <div class="acr-card">
            <div class="acr-card__val"><asp:Literal ID="litTotalFaculties" runat="server" /></div>
            <div class="acr-card__lbl">Faculties / Schools</div>
            <div class="acr-card__sub"><asp:Literal ID="litCurrentYear" runat="server" /></div>
        </div>
        <div class="acr-card">
            <div class="acr-card__val"><asp:Literal ID="litAlumni" runat="server" /></div>
            <div class="acr-card__lbl">Alumni (All Time)</div>
            <div class="acr-card__sub"><asp:Literal ID="litAdmitted" runat="server" /></div>
        </div>
    </div>

    <!-- ════════════════════════════════════════════════════════════════
         SECTION 1.1: STUDENT ENROLMENT STATISTICS
    ═════════════════════════════════════════════════════════════════ -->
    <div class="acr-section">
        <div class="acr-section__hdr">
            <div>
                <div class="acr-section__hdr-title">1.1 &nbsp; Student Enrolment Statistics</div>
                <div class="acr-section__hdr-sub">Per Faculty/School · Programme · Male/Female · Past Three Academic Years</div>
            </div>
        </div>
        <div class="acr-section__body">

            <!-- Year selector tabs -->
            <div class="acr-year-tabs" id="yearTabs"></div>

            <!-- Year panels (rendered server-side) -->
            <asp:Literal ID="litEnrolmentPanels" runat="server" />

            <!-- Cross-Year Summary Table -->
            <h4 style="color:var(--navy);font-size:12px;margin:20px 0 8px;">Three-Year Enrolment Summary by Faculty</h4>
            <asp:Literal ID="litCrossYearSummary" runat="server" />

        </div>
    </div>

    <!-- ════════════════════════════════════════════════════════════════
         SECTION 1.2: ACADEMIC PROGRAMMES REGISTER
    ═════════════════════════════════════════════════════════════════ -->
    <div class="acr-notice">
        <strong>Note on NCHE Fields:</strong> The following data fields were requested but are not currently captured in the University MIS:
        <em>Review Date, Date Submitted to NCHE, NCHE Comments, Accreditation Date, Next Review Date, Date Approved by Council.</em>
        These columns are shown with available system data where applicable and flagged <span class="acr-na">N/A</span> where data is pending input.
        Recommendation: These fields be added to the programme registry in Campus Dynamics for future reporting.
    </div>

    <div class="acr-section">
        <div class="acr-section__hdr">
            <div>
                <div class="acr-section__hdr-title">1.2 &nbsp; Academic Programmes Register</div>
                <div class="acr-section__hdr-sub">Certificate through PhD &nbsp;|&nbsp; Status, Faculty/School, Level, Duration, Enrolment</div>
            </div>
        </div>
        <div class="acr-section__body">
            <asp:Literal ID="litProgrammesTable" runat="server" />
        </div>
    </div>

    <div class="acr-footer">
        This report was generated automatically from the Campus Dynamics Management Information System on <asp:Literal ID="litFooterDate" runat="server" />.
        Data reflects the state of the system at the time of generation. For queries, contact the Office of the Academic Registrar.
        <br/><strong>Mutesa I Royal University</strong> &nbsp;|&nbsp; Confidential — For Committee Use Only
    </div>

</div>

<script>
(function(){
    // Build year tabs from server-rendered panels
    var panels = document.querySelectorAll('.acr-year-panel');
    var tabsEl  = document.getElementById('yearTabs');
    if (!tabsEl || !panels.length) return;
    panels.forEach(function(p, i){
        var yr = p.getAttribute('data-year') || ('Year '+(i+1));
        var tab = document.createElement('div');
        tab.className = 'acr-year-tab' + (i===0?' active':'');
        tab.textContent = yr;
        tab.onclick = function(){
            document.querySelectorAll('.acr-year-tab').forEach(function(t){t.className='acr-year-tab';});
            document.querySelectorAll('.acr-year-panel').forEach(function(pp){pp.className='acr-year-panel';});
            tab.className='acr-year-tab active';
            p.className='acr-year-panel active';
        };
        tabsEl.appendChild(tab);
        if(i===0) p.className='acr-year-panel active';
    });
})();
</script>
</asp:Content>
