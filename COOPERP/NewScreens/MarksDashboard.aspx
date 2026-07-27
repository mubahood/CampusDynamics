<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MarksDashboard.aspx.cs" Inherits="COOPERP_NewScreens_MarksDashboard" Title="Marks Dashboard - Admin" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box;}
.md-wrap{max-width:1320px;margin:0 auto;padding:8px 10px 12px;}

/* ── filter card ── */
.md-filter-card{background:#fff;border:1px solid #e0e5ed;border-radius:4px;margin-bottom:8px;overflow:hidden;}
.md-filter-hdr{padding:8px 10px 6px;border-bottom:1px solid #e0e5ed;display:flex;justify-content:space-between;align-items:flex-start;gap:8px;}
.md-filter-title{font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.md-filter-sub{font-size:9px;color:#94a3b8;margin-top:2px;}
.md-badge-active{display:inline-flex;align-items:center;padding:2px 9px;background:#e6f4ea;border:1px solid #a7d9b2;border-radius:10px;font-size:9px;font-weight:800;color:#2e7d32;letter-spacing:.2px;white-space:nowrap;flex-shrink:0;}
.md-filters{padding:8px 10px;display:flex;flex-wrap:wrap;gap:8px;align-items:flex-end;}
.md-fg{display:flex;flex-direction:column;gap:2px;min-width:0;flex:1 1 150px;}
.md-fg--act{flex:0 0 auto;}
.md-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:700;}
.md-select{height:30px;border:1px solid #cdd8e6;padding:4px 8px;font-size:11px;background:#fff;border-radius:6px;color:#1a1a2e;font-family:inherit;width:100%;box-sizing:border-box;}
/* searchable programme combobox */
.md-combo{position:relative;}
.md-combo__input{cursor:text;}
.md-combo__list{display:none;position:absolute;top:calc(100% + 2px);left:0;right:0;z-index:50;background:#fff;border:1px solid #cdd8e6;border-radius:6px;box-shadow:0 8px 24px rgba(5,39,92,.16);max-height:260px;overflow-y:auto;}
.md-combo.open .md-combo__list{display:block;}
.md-combo__opt{padding:6px 9px;font-size:11px;color:#1a1a2e;cursor:pointer;border-bottom:1px solid #f0f3f8;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.md-combo__opt:last-child{border-bottom:none;}
.md-combo__opt:hover,.md-combo__opt.active{background:#eef4ff;color:#05275C;}
.md-combo__opt--all{font-weight:700;color:#05275C;}
.md-combo__opt small{color:#94a3b8;font-weight:400;}
.md-combo__none{padding:8px 9px;font-size:11px;color:#94a3b8;font-style:italic;}
.md-select:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 2px rgba(23,77,164,.12);}
.md-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;padding:5px 10px;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;border-radius:6px;min-height:30px;}
.md-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff;}
.md-btn--primary{background:#05275C;color:#fff;border-color:#05275C;}
.md-btn--primary:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.md-scope-bar{padding:5px 10px;background:#f8fafc;border-top:1px solid #e0e5ed;font-size:9px;color:#64748b;display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;}
.md-scope-bar strong{color:#334155;}

/* ── pipeline stats (same design language as ProvisionalMarksController) ── */
.md-stats-wrap{background:#fff;border:1px solid #e0e5ed;border-radius:4px;padding:8px 10px 10px;margin-bottom:8px;}
.md-stats-hdr{display:flex;align-items:flex-start;justify-content:space-between;gap:8px;margin-bottom:7px;}
.md-stats-hdr__lbl{font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#1a1a2e;}
.md-stats-hdr__sub{font-size:9px;color:#94a3b8;margin-top:2px;font-weight:400;}
.md-stats-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(135px,1fr));gap:5px;}
.md-stat{padding:8px 9px;border-radius:4px;border:1px solid #e0e5ed;border-left:3px solid #e0e5ed;background:#fff;min-height:84px;display:flex;flex-direction:column;justify-content:flex-start;gap:0;}
.md-stat:hover{background:#f7f9fc;}
.md-stat__meta{display:flex;align-items:flex-start;justify-content:space-between;gap:4px;margin-bottom:3px;}
.md-stat__val{font-size:22px;line-height:1;font-weight:800;color:#05275C;letter-spacing:-.02em;}
.md-stat__pct{font-size:10px;font-weight:800;color:#94a3b8;background:#f1f5f9;border-radius:3px;padding:2px 5px;white-space:nowrap;flex-shrink:0;line-height:1.2;margin-top:3px;}
.md-stat__lbl{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:700;line-height:1.2;}
.md-stat__cap{font-size:9px;color:#9ca3af;line-height:1.35;margin-top:2px;}
.md-stat--pending{border-left-color:#f59e0b;}.md-stat--pending .md-stat__val{color:#b45309;}
.md-stat--rejected{border-left-color:#ef4444;}.md-stat--rejected .md-stat__val{color:#b42318;}
.md-stat--approved{border-left-color:#22c55e;}.md-stat--approved .md-stat__val{color:#2e7d32;}
.md-stat--published{border-left-color:#3b82f6;}.md-stat--published .md-stat__val{color:#174DA4;}
.md-stat--nomarks{border-left-color:#d1d5db;}.md-stat--nomarks .md-stat__val{color:#6b7280;}
.md-stat--ready{border-left-color:#10b981;cursor:pointer;}.md-stat--ready .md-stat__val{color:#059669;}

/* ── insights bar ── */
.md-insights-bar{display:flex;gap:10px;flex-wrap:wrap;margin-top:8px;padding:6px 0 0;border-top:1px solid #eef2f6;font-size:9px;font-weight:600;color:#64748b;}
.md-pib-item{display:inline-flex;align-items:center;gap:2px;}
.md-pib-pub strong{color:#174DA4;}.md-pib-ready strong{color:#059669;}.md-pib-pend strong{color:#b45309;}.md-pib-miss strong{color:#9ca3af;}.md-pib-sep{color:#e0e5ed;}

/* ── context summary cards ── */
.md-ctx-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:5px;margin-bottom:8px;}
.md-ctx-card{background:#fff;border:1px solid #e0e5ed;border-radius:4px;padding:8px 10px;display:flex;flex-direction:column;gap:2px;}
.md-ctx-card__val{font-size:20px;font-weight:800;color:#05275C;line-height:1;letter-spacing:-.02em;}
.md-ctx-card__lbl{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:700;}
.md-ctx-card__cap{font-size:9px;color:#9ca3af;line-height:1.3;}
.md-ctx-card--warn .md-ctx-card__val{color:#b45309;}
.md-ctx-card--err  .md-ctx-card__val{color:#b42318;}

/* ── general cards ── */
.md-card{background:#fff;border:1px solid #e0e5ed;border-radius:4px;overflow:hidden;margin-bottom:8px;}
.md-card__head{padding:8px 10px;border-bottom:1px solid #e0e5ed;background:#f8fafc;}
.md-card__title{font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.md-card__sub{font-size:9px;color:#94a3b8;margin-top:2px;}

/* ── tables ── */
.md-table-wrap{overflow:auto;scrollbar-color:#b6c5db #f5f8fc;scrollbar-width:thin;}
.md-table{width:100%;min-width:480px;border-collapse:collapse;}
.md-table th{background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:700;padding:6px 8px;text-align:left;white-space:nowrap;}
.md-table td{border-bottom:1px solid #eef2f6;font-size:10px;color:#1f2937;padding:6px 8px;vertical-align:middle;}
.md-table tbody tr:last-child td{border-bottom:none;}
.md-table tbody tr:hover td{background:#fafcff;}
.md-pill{display:inline-block;padding:2px 7px;font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;border-radius:3px;}
.md-pill--pending{background:#fff3cd;color:#92400e;}
.md-pill--approved{background:#e6f4ea;color:#2e7d32;}
.md-pill--published{background:#e8f0fc;color:#174DA4;}
.md-pill--rejected{background:#fde8e8;color:#b42318;}
.md-pill--missing{background:#fef2f2;color:#b42318;}
.md-pill--nomarks{background:#f3f4f6;color:#6b7280;}
.md-pill--ready{background:#ecfdf5;color:#059669;}
.md-bar-bg{background:#f1f5f9;border-radius:2px;height:5px;width:100%;max-width:100px;overflow:hidden;display:inline-block;vertical-align:middle;}
.md-bar-fill{height:100%;border-radius:2px;background:#ef4444;}

/* ── error / loading ── */
.md-err{display:none;margin:0 0 8px;padding:8px 10px;background:#fef2f2;border:1px solid #fecaca;color:#b91c1c;border-radius:4px;font-size:11px;}
.md-err.show{display:block;}
.md-loading{opacity:.6;pointer-events:none;}
/* clear JS loader */
.md-loader{position:fixed;inset:0;background:rgba(245,247,250,.78);z-index:9998;display:none;align-items:center;justify-content:center;}
.md-loader.show{display:flex;}
.md-loader__box{display:flex;flex-direction:column;align-items:center;gap:13px;background:#fff;border:1px solid #e0e5ed;border-radius:10px;padding:24px 34px;box-shadow:0 14px 44px rgba(5,39,92,.18);}
.md-spinner{width:44px;height:44px;border:4px solid #e6ebf2;border-top-color:#05275C;border-radius:50%;animation:mdspin .75s linear infinite;}
.md-spinner--sm{width:16px;height:16px;border-width:2px;border-color:rgba(255,255,255,.28);border-top-color:#8fd0ff;}
@keyframes mdspin{to{transform:rotate(360deg);}}
.md-loader__txt{font-size:12px;font-weight:800;color:#05275C;letter-spacing:.02em;}
.md-loader__sub{font-size:10px;color:#94a3b8;margin-top:-6px;}

@media(max-width:1100px){.md-filters{grid-template-columns:repeat(3,minmax(0,1fr));}}
@media(max-width:720px){.md-filters{grid-template-columns:1fr 1fr;}.md-stats-grid{grid-template-columns:repeat(2,minmax(0,1fr));}.md-ctx-grid{grid-template-columns:repeat(2,minmax(0,1fr));}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="md-wrap">
<div class="md-loader" id="mdLoader"><div class="md-loader__box"><div class="md-spinner"></div><div class="md-loader__txt">Loading dashboard…</div><div class="md-loader__sub">Crunching the marks pipeline</div></div></div>
<div id="mdError" class="md-err"></div>

<!-- ── Filter Card ── -->
<div class="md-filter-card" id="mdFilterCard">
    <div class="md-filter-hdr">
        <div>
            <div class="md-filter-title">Provisional Marks Dashboard</div>
            <div class="md-filter-sub" id="mdScopeBanner">Muteesa I Royal University &middot; resolving your access scope&hellip;</div>
        </div>
        <span class="md-badge-active" id="mdRoleChip">&#10003; Active Students Only</span>
    </div>
    <div class="md-filters">
        <div class="md-fg"><label>Academic Year</label><select id="mdYear" class="md-select"></select></div>
        <div class="md-fg">
            <label>Semester</label>
            <select id="mdSemester" class="md-select">
                <option value="">All Semesters</option>
                <option value="1">Semester 1</option>
                <option value="2">Semester 2</option>
                <option value="3">Semester 3</option>
            </select>
        </div>
        <div class="md-fg"><label>Faculty</label><select id="mdFaculty" class="md-select"></select></div>
        <div class="md-fg"><label>Department</label><select id="mdDepartment" class="md-select"></select></div>
        <div class="md-fg" style="flex:1 1 200px;">
            <label>Programme</label>
            <div class="md-combo" id="mdProgCombo">
                <input type="text" id="mdProgInput" class="md-select md-combo__input" placeholder="All programmes" autocomplete="off" spellcheck="false" />
                <input type="hidden" id="mdProgramme" value="" />
                <div class="md-combo__list" id="mdProgList"></div>
            </div>
        </div>
        <div class="md-fg md-fg--act"><label>&nbsp;</label><button type="button" id="mdApply" class="md-btn md-btn--primary">Apply Filters</button></div>
        <div class="md-fg md-fg--act"><label>&nbsp;</label><button type="button" id="mdReset" class="md-btn">Reset</button></div>
    </div>
    <div class="md-scope-bar">
        <span>Viewing: <strong id="mdScopeText">All years &nbsp;&middot;&nbsp; All semesters &nbsp;&middot;&nbsp; All programmes</strong></span>
        <span>All figures restricted to active students</span>
    </div>
</div>

<!-- ── Pipeline Stats ── -->
<div class="md-stats-wrap">
    <div class="md-stats-hdr">
        <div>
            <div class="md-stats-hdr__lbl">Provisional Marks Pipeline</div>
            <div class="md-stats-hdr__sub">All statistics restricted to active student registrations in the selected scope</div>
        </div>
        <span class="md-badge-active">&#10003; Active Students Only</span>
    </div>
    <div class="md-stats-grid">
        <div class="md-stat">
            <div class="md-stat__meta"><div class="md-stat__val" id="kMarksRows">—</div><div class="md-stat__pct" id="kMarksRowsPct">100%</div></div>
            <div class="md-stat__lbl">Total Marks Records</div>
            <div class="md-stat__cap">All active student–course enrolments in scope</div>
        </div>
        <div class="md-stat md-stat--nomarks">
            <div class="md-stat__meta"><div class="md-stat__val" id="kNoMarks">—</div><div class="md-stat__pct" id="kNoMarksPct">—</div></div>
            <div class="md-stat__lbl">No Marks Yet</div>
            <div class="md-stat__cap">Missing both CW &amp; Exam — lecturer has not entered marks</div>
        </div>
        <div class="md-stat md-stat--pending">
            <div class="md-stat__meta"><div class="md-stat__val" id="kPending">—</div><div class="md-stat__pct" id="kPendingPct">—</div></div>
            <div class="md-stat__lbl">Pending Review</div>
            <div class="md-stat__cap">Marks entered by lecturer, awaiting admin review</div>
        </div>
        <div class="md-stat md-stat--ready" id="kReadyCard" title="Click to view Ready records in Provisional Marks Queue">
            <div class="md-stat__meta"><div class="md-stat__val" id="kReady">—</div><div class="md-stat__pct" id="kReadyPct">—</div></div>
            <div class="md-stat__lbl">Ready to Publish</div>
            <div class="md-stat__cap">Both CW &amp; Exam complete &middot; click to open queue</div>
        </div>
        <div class="md-stat md-stat--published">
            <div class="md-stat__meta"><div class="md-stat__val" id="kPublished">—</div><div class="md-stat__pct" id="kPublishedPct">—</div></div>
            <div class="md-stat__lbl">Published to Results</div>
            <div class="md-stat__cap">Marks finalised in academic records &mdash; counted as final regardless of mark presence</div>
        </div>
    </div>
    <div class="md-insights-bar">
        <span class="md-pib-item md-pib-pub"><strong id="iPublishedPct">—</strong> published</span>
        <span class="md-pib-sep">&nbsp;&middot;&nbsp;</span>
        <span class="md-pib-item md-pib-ready"><strong id="iReadyPct">—</strong> ready to publish</span>
        <span class="md-pib-sep">&nbsp;&middot;&nbsp;</span>
        <span class="md-pib-item md-pib-pend"><strong id="iPendingPct">—</strong> pending review</span>
        <span class="md-pib-sep">&nbsp;&middot;&nbsp;</span>
        <span class="md-pib-item md-pib-miss"><strong id="iNoMarksPct">—</strong> no marks entered</span>
    </div>
</div>

<!-- ── Context Summary Cards ── -->
<div class="md-ctx-grid">
    <div class="md-ctx-card">
        <div class="md-ctx-card__val" id="kActiveStudents">—</div>
        <div class="md-ctx-card__lbl">Active Students</div>
        <div class="md-ctx-card__cap">Distinct students with registrations in scope</div>
    </div>
    <div class="md-ctx-card">
        <div class="md-ctx-card__val" id="kCourses">—</div>
        <div class="md-ctx-card__lbl">Distinct Courses</div>
        <div class="md-ctx-card__cap">Unique courses represented in scope</div>
    </div>
    <div class="md-ctx-card">
        <div class="md-ctx-card__val" id="kProgs">—</div>
        <div class="md-ctx-card__lbl">Programmes</div>
        <div class="md-ctx-card__cap">Distinct programmes in scope</div>
    </div>
    <div class="md-ctx-card md-ctx-card--warn">
        <div class="md-ctx-card__val" id="kMissingCw">—</div>
        <div class="md-ctx-card__lbl">Missing Coursework</div>
        <div class="md-ctx-card__cap">CW not entered &amp; not yet published</div>
    </div>
    <div class="md-ctx-card md-ctx-card--err">
        <div class="md-ctx-card__val" id="kMissingExam">—</div>
        <div class="md-ctx-card__lbl">Missing Exam Marks</div>
        <div class="md-ctx-card__cap">Exam not entered &amp; not yet published</div>
    </div>
</div>

<!-- ── Status Breakdown Table ── -->
<div class="md-card">
    <div class="md-card__head">
        <div class="md-card__title">Status Breakdown</div>
        <div class="md-card__sub">All counts for active students in scope &middot; published rows counted as final regardless of mark presence</div>
    </div>
    <div class="md-table-wrap">
        <table class="md-table">
            <thead>
                <tr>
                    <th style="width:170px;">Status</th>
                    <th style="width:80px;">Count</th>
                    <th style="width:65px;">% of Total</th>
                    <th>Description</th>
                    <th style="width:110px;">Distribution</th>
                </tr>
            </thead>
            <tbody id="mdStatusTable">
                <tr><td colspan="5" style="text-align:center;color:#6b7280;padding:20px 8px;">Loading&hellip;</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- ── Top 25 Courses with Missing Marks ── -->
<div class="md-card">
    <div class="md-card__head">
        <div class="md-card__title">Top 25 Courses with Missing Marks</div>
        <div class="md-card__sub">Active students only &middot; excludes published records &middot; missing = CW or Exam not entered</div>
    </div>
    <div class="md-table-wrap">
        <table class="md-table">
            <thead>
                <tr>
                    <th style="width:90px;">Code</th>
                    <th>Course Name</th>
                    <th style="width:100px;">Missing Entries</th>
                    <th style="width:130px;">Students Affected</th>
                    <th style="width:130px;">vs All Registrations</th>
                </tr>
            </thead>
            <tbody id="topCoursesBody">
                <tr><td colspan="5" style="text-align:center;color:#6b7280;padding:20px 8px;">Loading&hellip;</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- ── Marks Progress by Programme ── -->
<div class="md-card">
    <div class="md-card__head">
        <div>
            <div class="md-card__title">Marks Progress by Programme</div>
            <div class="md-card__sub">Active students in scope &middot; published = finalised regardless of CW/Exam presence &middot; sorted by total registrations</div>
        </div>
        <span id="progCount" style="font-size:9px;color:#94a3b8;font-weight:600;white-space:nowrap;"></span>
    </div>
    <div class="md-table-wrap">
        <table class="md-table">
            <thead>
                <tr>
                    <th style="width:78px;">Code</th>
                    <th>Programme</th>
                    <th style="width:68px;text-align:right;">Students</th>
                    <th style="width:75px;text-align:right;">Total Regs</th>
                    <th style="width:78px;text-align:right;">Published</th>
                    <th style="width:72px;text-align:right;">No Marks</th>
                    <th style="width:68px;text-align:right;">Missing</th>
                    <th style="width:62px;text-align:right;">Done %</th>
                    <th style="width:120px;">Progress</th>
                </tr>
            </thead>
            <tbody id="progStatsBody">
                <tr><td colspan="9" style="text-align:center;color:#6b7280;padding:20px 8px;">Loading&hellip;</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- ── Marks Progress by Faculty ── -->
<div class="md-card">
    <div class="md-card__head">
        <div class="md-card__title">Marks Progress by Faculty</div>
        <div class="md-card__sub">Active students in scope &middot; published = finalised &middot; sorted by completion (lowest first)</div>
    </div>
    <div class="md-table-wrap">
        <table class="md-table">
            <thead>
                <tr>
                    <th>Faculty</th>
                    <th style="width:68px;text-align:right;">Students</th>
                    <th style="width:75px;text-align:right;">Total Regs</th>
                    <th style="width:78px;text-align:right;">Published</th>
                    <th style="width:72px;text-align:right;">No Marks</th>
                    <th style="width:68px;text-align:right;">Missing</th>
                    <th style="width:62px;text-align:right;">Done %</th>
                    <th style="width:120px;">Progress</th>
                </tr>
            </thead>
            <tbody id="facStatsBody">
                <tr><td colspan="8" style="text-align:center;color:#6b7280;padding:20px 8px;">Loading&hellip;</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- ── Marks Progress by Department ── -->
<div class="md-card">
    <div class="md-card__head">
        <div class="md-card__title">Marks Progress by Department</div>
        <div class="md-card__sub">Active students in scope &middot; based on each programme's department &middot; sorted by completion (lowest first)</div>
    </div>
    <div class="md-table-wrap">
        <table class="md-table">
            <thead>
                <tr>
                    <th>Department</th>
                    <th style="width:68px;text-align:right;">Students</th>
                    <th style="width:75px;text-align:right;">Total Regs</th>
                    <th style="width:78px;text-align:right;">Published</th>
                    <th style="width:72px;text-align:right;">No Marks</th>
                    <th style="width:68px;text-align:right;">Missing</th>
                    <th style="width:62px;text-align:right;">Done %</th>
                    <th style="width:120px;">Progress</th>
                </tr>
            </thead>
            <tbody id="deptStatsBody">
                <tr><td colspan="8" style="text-align:center;color:#6b7280;padding:20px 8px;">Loading&hellip;</td></tr>
            </tbody>
        </table>
    </div>
</div>

<style>
.mca{background:#fff;border:1px solid #e0e5ed;border-radius:4px;padding:16px;margin-top:14px;}
.mca__hd{display:flex;align-items:flex-start;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:12px;}
.mca__title{font-size:13px;font-weight:800;color:#05275C;}
.mca__sub{font-size:11px;color:#64748b;margin-top:3px;}
.mca__sub a{color:#174DA4;font-weight:600;text-decoration:none;}
.mca__win{display:flex;align-items:center;gap:6px;font-size:11px;color:#475569;white-space:nowrap;}
.mca__kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:10px;margin-bottom:12px;}
.mca-kpi{border:1px solid #e0e5ed;background:#f8fafc;padding:10px 12px;border-radius:2px;}
.mca-kpi .v{font-size:20px;font-weight:800;color:#05275C;}
.mca-kpi .l{font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;margin-top:2px;}
.mca-kpi--warn .v{color:#b42318;}
.mca__toolbar{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:10px;}
.mca__search{flex:1 1 220px;min-width:160px;}
.mca__tablewrap{overflow-x:auto;max-height:460px;overflow-y:auto;border:1px solid #e0e5ed;}
.mca__table{width:100%;border-collapse:collapse;}
.mca__table th{position:sticky;top:0;background:#05275C;color:#fff;text-align:left;padding:7px 10px;font-size:10px;font-weight:700;white-space:nowrap;text-transform:uppercase;letter-spacing:.3px;}
.mca__table td{padding:6px 10px;border-bottom:1px solid #eef2f7;font-size:11px;vertical-align:middle;}
.mca__table tbody tr:nth-child(even){background:#f6f8fb;}
.mca-row{cursor:pointer;}
.mca-row:hover{background:#e8f0fd !important;}
.mca-b{display:inline-block;padding:1px 7px;font-size:10px;font-weight:700;border-radius:2px;background:#eef1f6;color:#64748b;}
.mca-b--UPDATE{background:#fef6e7;color:#b45309;}
.mca-b--INSERT{background:#e7f6ec;color:#15803d;}
.mca-b--DELETE{background:#fdeaea;color:#b91c1c;}
.mca-b--APPROVE{background:#eaf1fc;color:#174DA4;}
.mca-b--MIGRATE{background:#eef1f6;color:#64748b;}
.mca-chg .o{color:#b42318;text-decoration:line-through;}
.mca-chg .n{color:#15803d;font-weight:700;}
.mca-ovl{display:none;position:fixed;inset:0;background:rgba(10,20,40,.5);z-index:10000;align-items:center;justify-content:center;padding:20px;}
.mca-ovl.open{display:flex;}
.mca-modal{background:#fff;width:520px;max-width:96vw;max-height:88vh;display:flex;flex-direction:column;border-radius:2px;box-shadow:0 16px 48px rgba(0,0,0,.28);}
.mca-modal__hd{display:flex;align-items:center;justify-content:space-between;padding:12px 16px;border-bottom:1px solid #e0e5ed;}
.mca-modal__hd h3{margin:0;font-size:14px;color:#05275C;}
.mca-modal__x{background:none;border:none;font-size:22px;line-height:1;color:#888;cursor:pointer;}
.mca-modal__bd{padding:14px 16px;overflow-y:auto;}
.mca-kv{display:grid;grid-template-columns:120px 1fr;gap:5px 10px;font-size:12px;}
.mca-kv .k{color:#64748b;}
.mca-kv .v{color:#1a1a2e;font-weight:500;word-break:break-word;}
.mca-lnk{font-size:11px;font-weight:600;color:#174DA4;text-decoration:none;}
</style>

<!-- ================= MARK CHANGES & AUDIT ================= -->
<div class="mca">
    <div class="mca__hd">
        <div>
            <div class="mca__title">Mark Changes &amp; Audit &mdash; who changed what</div>
            <div class="mca__sub">Every change to a final result is tracked (scoped to your access). Full historical trail: <a href="MarksAuditTrail.aspx">Marks Audit Trail &#8599;</a></div>
        </div>
        <div class="mca__win"><label>Window</label>
            <select id="mcaDays" class="md-select">
                <option value="7">Last 7 days</option>
                <option value="30" selected="selected">Last 30 days</option>
                <option value="90">Last 90 days</option>
                <option value="365">Last year</option>
            </select>
        </div>
    </div>
    <div class="mca__kpis">
        <div class="mca-kpi"><div class="v" id="mcaKChanges">&mdash;</div><div class="l">Changes in window</div></div>
        <div class="mca-kpi"><div class="v" id="mcaKEditors">&mdash;</div><div class="l">Distinct editors</div></div>
        <div class="mca-kpi mca-kpi--warn"><div class="v" id="mcaKDeletes">&mdash;</div><div class="l">Deletions</div></div>
        <div class="mca-kpi"><div class="v" id="mcaKTotal">&mdash;</div><div class="l">Total tracked</div></div>
    </div>
    <div class="mca__toolbar">
        <input type="text" id="mcaQ" class="md-select mca__search" placeholder="Search reg no, name, course or editor&hellip;" />
        <select id="mcaAction" class="md-select">
            <option value="ALL">All actions</option>
            <option value="CHANGES">Changes only</option>
            <option value="UPDATE">Updated</option>
            <option value="INSERT">Inserted</option>
            <option value="DELETE">Deleted</option>
            <option value="MIGRATE">Imported history</option>
        </select>
        <select id="mcaLimit" class="md-select">
            <option value="50">50 rows</option>
            <option value="100" selected="selected">100 rows</option>
            <option value="200">200 rows</option>
        </select>
        <button type="button" id="mcaRefresh" class="md-btn">Refresh</button>
    </div>
    <div class="mca__tablewrap">
        <table class="mca__table">
            <thead><tr><th>When</th><th>Action</th><th>Student</th><th>Course</th><th>Before &rarr; After</th><th>Changed by</th><th>Source</th></tr></thead>
            <tbody id="mcaBody"><tr><td colspan="7" style="text-align:center;color:#6b7280;padding:18px;">Loading&hellip;</td></tr></tbody>
        </table>
    </div>
</div>

<div class="mca-ovl" id="mcaOvl">
    <div class="mca-modal">
        <div class="mca-modal__hd"><h3 id="mcaMTitle">Mark change</h3><button type="button" class="mca-modal__x" id="mcaMClose">&times;</button></div>
        <div class="mca-modal__bd" id="mcaMBody"></div>
    </div>
</div>

</div><!-- /.md-wrap -->

<script type="text/javascript">
(function(){
'use strict';
var _total = 0;
function qs(id){ return document.getElementById(id); }
function toNum(v){ var n=parseInt(v,10); return isNaN(n)?0:n; }
function fmt(v){ return toNum(v).toLocaleString('en-US'); }
function pct(v,tot){ if(!tot||tot===0) return '—'; var p=Math.round(v*1000/tot)/10; return (p%1===0?p:p.toFixed(1))+'%'; }
function esc(s){ return s?String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'):''; }
function showError(msg){ var el=qs('mdError'); if(!el)return; el.textContent=msg||'Unable to load dashboard data.'; el.className='md-err show'; }
function hideError(){ var el=qs('mdError'); if(el) el.className='md-err'; }
function callAJAX(method,params,cb){
    var xhr=new XMLHttpRequest();
    xhr.open('POST','MarksDashboard.aspx/'+method,true);
    xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
    xhr.onload=function(){ try{ var o=JSON.parse(xhr.responseText); cb(typeof o.d==='string'?JSON.parse(o.d):o.d); } catch(e){ cb({success:false,message:'Parse error.'}); } };
    xhr.onerror=function(){ cb({success:false,message:'Network error.'}); };
    xhr.send(JSON.stringify(params||{}));
}
function setLoading(on){
    var ld=qs('mdLoader'); if(ld) ld.className='md-loader'+(on?' show':'');
    var c=qs('mdFilterCard'); if(c) c.className='md-filter-card'+(on?' md-loading':'');
    var s=document.querySelector('.md-stats-wrap'); if(s) s.style.opacity=on?'.6':'1';
}
function fillSelect(id,items,allText){
    var el=qs(id); if(!el)return;
    var h='<option value="">'+allText+'</option>';
    (items||[]).forEach(function(it){ h+='<option value="'+esc(it.value||'')+'">'+esc(it.text||it.value||'')+'</option>'; });
    el.innerHTML=h;
}
function selText(id,all){ var e=qs(id); return (e&&e.value)?e.options[e.selectedIndex].text:all; }
function setScopeText(){
    var parts=[selText('mdYear','All years'),selText('mdSemester','All semesters')];
    if(qs('mdFaculty').value) parts.push(selText('mdFaculty','All faculties'));
    if(qs('mdDepartment').value) parts.push(selText('mdDepartment','All departments'));
    parts.push(qs('mdProgramme').value ? (qs('mdProgInput').value||'Programme') : 'All programmes');
    var el=qs('mdScopeText'); if(el) el.innerHTML=parts.map(esc).join('&nbsp;&middot;&nbsp;');
}
function setV(id,v){ var el=qs(id); if(el) el.textContent=fmt(v); }
function setP(id,v,tot){ var el=qs(id); if(el) el.textContent=pct(v,tot); }

function applyStats(d){
    _total=toNum(d.marksRecords);
    var t=_total;
    // Pipeline cards
    setV('kMarksRows',d.marksRecords);   if(qs('kMarksRowsPct')) qs('kMarksRowsPct').textContent=t>0?'100%':'—';
    setV('kNoMarks',d.noMarksCount);     setP('kNoMarksPct',d.noMarksCount,t);
    setV('kPending',d.pendingCount);     setP('kPendingPct',d.pendingCount,t);
    setV('kReady',d.readyCount);         setP('kReadyPct',d.readyCount,t);
    setV('kPublished',d.publishedCount); setP('kPublishedPct',d.publishedCount,t);
    // Insights bar
    if(qs('iPublishedPct')) qs('iPublishedPct').textContent=pct(d.publishedCount,t);
    if(qs('iReadyPct'))     qs('iReadyPct').textContent=pct(d.readyCount,t);
    if(qs('iPendingPct'))   qs('iPendingPct').textContent=pct(d.pendingCount,t);
    if(qs('iNoMarksPct'))   qs('iNoMarksPct').textContent=pct(d.noMarksCount,t);
    // Context cards
    setV('kActiveStudents',d.activeStudents);
    setV('kCourses',d.courseCount);
    setV('kProgs',d.progCount);
    setV('kMissingCw',d.missingCourseworkCount);
    setV('kMissingExam',d.missingExamCount);
    // Tables
    buildStatusTable(d,t);
    bindTopCourses(d.topMissingCourses||[],t);
    bindProgStats(d.programmeStats||[]);
    bindGroupStats(d.facultyStats||[],'facStatsBody',8);
    bindGroupStats(d.departmentStats||[],'deptStatsBody',8);
}

function applyScope(sc, showNotice){
    if(!sc) return;
    var banner=qs('mdScopeBanner'), chip=qs('mdRoleChip');
    if(banner) banner.innerHTML='Muteesa I Royal University &middot; <strong>'+esc(sc.label||'')+'</strong>';
    if(chip){
        if(sc.isAdmin){ chip.textContent='Administrator · Full access'; chip.style.background='#e8f0fc'; chip.style.borderColor='#9bbdf0'; chip.style.color='#174DA4'; }
        else if(sc.hasAccess){ chip.textContent=(sc.role||'Scoped access'); chip.style.background='#e6f4ea'; chip.style.borderColor='#a7d9b2'; chip.style.color='#2e7d32'; }
        else { chip.textContent='No data access'; chip.style.background='#fde8e8'; chip.style.borderColor='#f5b5b5'; chip.style.color='#b42318'; }
    }
    if(showNotice && !sc.isAdmin && !sc.hasAccess){
        showError('Your account is not linked to any faculty or department, so no marks data is shown. Contact the administrator if this is unexpected.');
    }
}

function bindGroupStats(rows, tbodyId, cols){
    var tbody=qs(tbodyId); if(!tbody) return;
    if(!rows||rows.length===0){
        tbody.innerHTML='<tr><td colspan="'+cols+'" style="text-align:center;color:#6b7280;padding:20px;">No data available.</td></tr>';
        return;
    }
    var html='';
    rows.forEach(function(g,i){
        var pubPct=g.total>0?Math.round(g.published*100/g.total):0;
        var barColor=pubPct>=80?'#22c55e':pubPct>=50?'#f59e0b':'#ef4444';
        var pctColor=pubPct>=80?'#2e7d32':pubPct>=50?'#b45309':'#b42318';
        var rowBg=i%2===0?'':'background:#fafcff;';
        html+='<tr style="'+rowBg+'">';
        html+='<td style="font-size:10px;color:#1f2937;max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="'+esc(g.name)+'">'+esc(g.name)+'</td>';
        html+='<td style="text-align:right;font-weight:700;color:#05275C;">'+fmt(g.students)+'</td>';
        html+='<td style="text-align:right;color:#475569;">'+fmt(g.total)+'</td>';
        html+='<td style="text-align:right;font-weight:700;color:#174DA4;">'+fmt(g.published)+'</td>';
        html+='<td style="text-align:right;color:#6b7280;">'+fmt(g.noMarks)+'</td>';
        html+='<td style="text-align:right;color:#b42318;font-weight:700;">'+fmt(g.missing)+'</td>';
        html+='<td style="text-align:right;font-weight:800;color:'+pctColor+';">'+pubPct+'%</td>';
        html+='<td><div style="display:flex;align-items:center;gap:5px;"><div style="flex:1;background:#f1f5f9;border-radius:2px;height:6px;overflow:hidden;"><div style="width:'+pubPct+'%;height:100%;background:'+barColor+';border-radius:2px;"></div></div></div></td>';
        html+='</tr>';
    });
    tbody.innerHTML=html;
}

var STATUS_ROWS=[
    {lbl:'Published to Results', pill:'published', key:'publishedCount', color:'#3b82f6', desc:'Marks finalised in acad_results &mdash; counted as final regardless of CW or Exam presence'},
    {lbl:'Ready to Publish',     pill:'ready',     key:'readyCount',     color:'#10b981', desc:'Both CW &amp; Exam complete, not yet published or rejected &mdash; a subset of Pending Review'},
    {lbl:'Pending Review',       pill:'pending',   key:'pendingCount',   color:'#f59e0b', desc:'At least one mark entered by lecturer, awaiting admin review (includes Ready to Publish records)'},
    {lbl:'Rejected / Returned',  pill:'rejected',  key:'rejectedCount',  color:'#ef4444', desc:'Sent back to lecturer for correction &mdash; must be re-submitted before it can be published'},
    {lbl:'No Marks Yet',         pill:'nomarks',   key:'noMarksCount',   color:'#d1d5db', desc:'Both CW &amp; Exam are missing and record is not published &mdash; lecturer has not entered marks'}
];

function buildStatusTable(d,total){
    var tbody=qs('mdStatusTable'); if(!tbody) return;
    var html='';
    STATUS_ROWS.forEach(function(r){
        var cnt=toNum(d[r.key]||0);
        var p=pct(cnt,total);
        var barW=total>0?Math.round(cnt*100/total):0;
        html+='<tr>';
        html+='<td><span class="md-pill md-pill--'+r.pill+'">'+r.lbl+'</span></td>';
        html+='<td style="font-weight:800;color:#05275C;">'+fmt(cnt)+'</td>';
        html+='<td style="font-weight:700;color:#64748b;">'+p+'</td>';
        html+='<td style="color:#6b7280;font-size:10px;">'+r.desc+'</td>';
        html+='<td><div class="md-bar-bg"><div class="md-bar-fill" style="width:'+barW+'%;background:'+r.color+';"></div></div></td>';
        html+='</tr>';
    });
    tbody.innerHTML=html||'<tr><td colspan="5" style="text-align:center;color:#6b7280;padding:16px;">No data available</td></tr>';
}

function bindTopCourses(courses,total){
    var tbody=qs('topCoursesBody'); if(!tbody) return;
    if(!courses||courses.length===0){
        tbody.innerHTML='<tr><td colspan="5" style="text-align:center;color:#6b7280;padding:20px;">No missing marks found &mdash; all courses complete.</td></tr>';
        return;
    }
    var maxM=courses.reduce(function(m,c){ return Math.max(m,toNum(c.missingCount)); },0);
    var html='';
    courses.forEach(function(c,i){
        var cnt=toNum(c.missingCount), sa=toNum(c.studentsAffected);
        var barW=maxM>0?Math.round(cnt*100/maxM):0;
        var p=pct(cnt,total);
        var name=c.courseName&&c.courseName!==c.course?c.courseName:'—';
        html+='<tr>';
        html+='<td><span style="font-family:Consolas,monospace;font-size:10px;font-weight:700;color:#174DA4;">'+esc(c.course)+'</span></td>';
        html+='<td style="font-size:10px;color:#374151;max-width:220px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="'+esc(name)+'">'+esc(name)+'</td>';
        html+='<td style="font-weight:800;color:#b42318;">'+fmt(cnt)+'</td>';
        html+='<td style="color:#64748b;">'+fmt(sa)+' student'+(sa===1?'':'s')+'</td>';
        html+='<td style="white-space:nowrap;"><div class="md-bar-bg" style="max-width:80px;"><div class="md-bar-fill" style="width:'+barW+'%;"></div></div> <span style="font-size:9px;color:#94a3b8;vertical-align:middle;">'+p+'</span></td>';
        html+='</tr>';
    });
    tbody.innerHTML=html;
}

function bindProgStats(progs){
    var tbody=qs('progStatsBody'); if(!tbody) return;
    var countEl=qs('progCount');
    if(countEl) countEl.textContent=fmt(progs.length)+' programme'+(progs.length===1?'':'s');
    if(!progs||progs.length===0){
        tbody.innerHTML='<tr><td colspan="9" style="text-align:center;color:#6b7280;padding:20px;">No programme data available.</td></tr>';
        return;
    }
    var html='';
    progs.forEach(function(p,i){
        var pubPct=p.total>0?Math.round(p.published*100/p.total):0;
        var pctTxt=pubPct+'%';
        var barColor=pubPct>=80?'#22c55e':pubPct>=50?'#f59e0b':'#ef4444';
        var pctColor=pubPct>=80?'#2e7d32':pubPct>=50?'#b45309':'#b42318';
        var rowBg=i%2===0?'':'background:#fafcff;';
        html+='<tr style="'+rowBg+'">';
        html+='<td><span style="font-family:Consolas,monospace;font-size:10px;font-weight:700;color:#174DA4;">'+esc(p.progCode)+'</span></td>';
        html+='<td style="font-size:10px;color:#1f2937;max-width:240px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="'+esc(p.progName)+'">'+esc(p.progName)+'</td>';
        html+='<td style="text-align:right;font-weight:700;color:#05275C;">'+fmt(p.students)+'</td>';
        html+='<td style="text-align:right;color:#475569;">'+fmt(p.total)+'</td>';
        html+='<td style="text-align:right;font-weight:700;color:#174DA4;">'+fmt(p.published)+'</td>';
        html+='<td style="text-align:right;color:#6b7280;">'+fmt(p.noMarks)+'</td>';
        html+='<td style="text-align:right;color:#b42318;font-weight:700;">'+fmt(p.missing)+'</td>';
        html+='<td style="text-align:right;font-weight:800;color:'+pctColor+';">'+pctTxt+'</td>';
        html+='<td><div style="display:flex;align-items:center;gap:5px;">';
        html+='<div style="flex:1;background:#f1f5f9;border-radius:2px;height:6px;overflow:hidden;">';
        html+='<div style="width:'+pubPct+'%;height:100%;background:'+barColor+';border-radius:2px;transition:width .3s;"></div></div>';
        html+='</div></td>';
        html+='</tr>';
    });
    tbody.innerHTML=html;
}

function loadStats(){
    hideError();
    setLoading(true);
    callAJAX('GetDashboardStats',{
        year:qs('mdYear').value,
        semester:qs('mdSemester').value,
        faculty:qs('mdFaculty').value,
        department:qs('mdDepartment').value,
        programme:qs('mdProgramme').value
    },function(d){
        setLoading(false);
        if(!d||!d.success){ showError((d&&d.message)||'Failed to load stats.'); return; }
        setScopeText();
        if(d.scope) applyScope(d.scope,false);
        applyStats(d.stats||{});
    });
}

/* ===== Mark Changes & Audit panel ===== */
var _mcaRows=[];
function setTxt(id,v){ var el=qs(id); if(el) el.textContent=v; }
function mcaChangeCell(r){
    var ot=(r.old_total==null?'':r.old_total), nt=(r.new_total==null?'':r.new_total);
    var og=r.old_grade||'', ng=r.new_grade||'';
    var oldS=(ot!==''?String(ot):'')+(og?(' '+og):''); var newS=(nt!==''?String(nt):'')+(ng?(' '+ng):'');
    if(!oldS && !newS) return '<span style="color:#94a3b8;">&mdash;</span>';
    if(!oldS) return '<span class="n">'+esc(newS)+'</span>';
    if(!newS) return '<span class="o">'+esc(oldS)+'</span> removed';
    return '<span class="o">'+esc(oldS)+'</span> &rarr; <span class="n">'+esc(newS)+'</span>';
}
function mcaFeed(){
    var body=qs('mcaBody'); if(!body) return;
    callAJAX('GetMarkAuditFeed',{days:qs('mcaDays').value,action:qs('mcaAction').value,q:qs('mcaQ').value,regno:'',course:'',limit:qs('mcaLimit').value},function(d){
        if(!d||!d.success){ body.innerHTML='<tr><td colspan="7" style="text-align:center;color:#b42318;padding:16px;">Failed to load changes.</td></tr>'; return; }
        _mcaRows=d.rows||[];
        if(!_mcaRows.length){ body.innerHTML='<tr><td colspan="7" style="text-align:center;color:#6b7280;padding:18px;">No changes match your filters.</td></tr>'; return; }
        var h='';
        _mcaRows.forEach(function(r,i){
            h+='<tr class="mca-row" data-i="'+i+'">'
              +'<td style="white-space:nowrap;color:#475569;">'+esc(r.ts)+'</td>'
              +'<td><span class="mca-b mca-b--'+esc(r.action)+'">'+esc(r.action)+'</span></td>'
              +'<td><div style="font-weight:600;color:#05275C;">'+esc(r.student||r.regno)+'</div><div style="font-size:9px;color:#94a3b8;">'+esc(r.regno)+'</div></td>'
              +'<td><span style="font-family:Consolas,monospace;font-size:10px;color:#174DA4;font-weight:700;">'+esc(r.course)+'</span></td>'
              +'<td class="mca-chg">'+mcaChangeCell(r)+'</td>'
              +'<td>'+esc(r.actor)+'</td>'
              +'<td style="font-size:9px;color:#94a3b8;">'+esc(r.source)+'</td>'
              +'</tr>';
        });
        body.innerHTML=h;
        var trs=body.querySelectorAll('.mca-row');
        for(var j=0;j<trs.length;j++) trs[j].onclick=function(){ mcaDetail(_mcaRows[parseInt(this.getAttribute('data-i'),10)]); };
    });
}
function mcaStats(){
    callAJAX('GetMarkAuditStats',{days:qs('mcaDays').value},function(d){
        if(!d||!d.success||!d.stats) return; var s=d.stats;
        setTxt('mcaKChanges',fmt(s.window)); setTxt('mcaKEditors',fmt(s.editors));
        setTxt('mcaKDeletes',fmt(s.deletes)); setTxt('mcaKTotal',fmt(s.total));
    });
}
function mcaLoad(){ mcaStats(); mcaFeed(); }
function mcaDetail(r){
    if(!r) return;
    setTxt('mcaMTitle', r.action+'  ·  '+(r.course||''));
    function kv(k,v){ return '<div class="k">'+esc(k)+'</div><div class="v">'+(v==null||v===''?'&mdash;':esc(v))+'</div>'; }
    var before=(r.old_total==null?'—':r.old_total)+(r.old_grade?(' '+r.old_grade):'');
    var after=(r.new_total==null?'—':r.new_total)+(r.new_grade?(' '+r.new_grade):'');
    var prof='StudentResultsView.aspx?regno='+encodeURIComponent(r.regno);
    var h='<div class="mca-kv">'
        +kv('When',r.ts)+kv('Action',r.action)
        +kv('Student',(r.student||'')+' ('+r.regno+')')
        +kv('Course',r.course+(r.course_name&&r.course_name!==r.course?(' — '+r.course_name):''))
        +kv('Period',(r.acad||'')+'  ·  Sem '+(r.sem||''))
        +kv('Before',before)+kv('After',after)
        +kv('Changed by',r.actor)+kv('Source',r.source)+kv('IP',r.ip)+kv('Reason / note',r.reason)
        +'</div><div style="margin-top:12px;"><a class="mca-lnk" href="'+prof+'" target="_blank" rel="noopener">Open student results &#8599;</a></div>';
    qs('mcaMBody').innerHTML=h;
    qs('mcaOvl').classList.add('open');
}

/* ── Faculty / Department / searchable Programme filters ── */
var _progs=[];   // [{value,text,faculty,department}]
function fillFilter(id,items,allText){
    var el=qs(id); if(!el) return;
    var h='<option value="">'+esc(allText)+'</option>';
    (items||[]).forEach(function(it){ h+='<option value="'+esc(it.value)+'" data-fac="'+esc(it.faculty||'')+'">'+esc(it.text||it.value)+'</option>'; });
    el.innerHTML=h;
}
function cascadeDept(){
    var fac=qs('mdFaculty').value, sel=qs('mdDepartment');
    for(var i=0;i<sel.options.length;i++){ var o=sel.options[i]; if(!o.value) continue; o.style.display=(!fac||o.getAttribute('data-fac')===fac)?'':'none'; }
    if(sel.selectedIndex>0 && sel.options[sel.selectedIndex].style.display==='none') sel.value='';
}
function progMatches(p){
    var fac=qs('mdFaculty').value, dep=qs('mdDepartment').value;
    return (!fac||p.faculty===fac) && (!dep||p.department===dep);
}
function progFilteredList(){
    var q=(qs('mdProgInput').value||'').toLowerCase().trim();
    return _progs.filter(function(p){
        if(!progMatches(p)) return false;
        if(q && p.text.toLowerCase().indexOf(q)<0 && (''+p.value).toLowerCase().indexOf(q)<0) return false;
        return true;
    });
}
function renderProgList(){
    var list=qs('mdProgList'); var items=progFilteredList();
    var h='<div class="md-combo__opt md-combo__opt--all" data-v="">All programmes</div>';
    if(!items.length) h+='<div class="md-combo__none">No programmes match</div>';
    else items.slice(0,400).forEach(function(p){ h+='<div class="md-combo__opt" data-v="'+esc(p.value)+'">'+esc(p.text)+' <small>'+esc(p.value)+'</small></div>'; });
    list.innerHTML=h;
    var opts=list.querySelectorAll('.md-combo__opt');
    for(var i=0;i<opts.length;i++) opts[i].onclick=function(){ selectProg(this.getAttribute('data-v'),true); };
}
function selectProg(v,doLoad){
    qs('mdProgramme').value=v||'';
    var m=v?_progs.filter(function(p){return p.value===v;})[0]:null;
    qs('mdProgInput').value=m?m.text:'';
    qs('mdProgCombo').classList.remove('open');
    if(doLoad) loadStats();
}
function openCombo(){ renderProgList(); qs('mdProgCombo').classList.add('open'); }
function closeCombo(){ qs('mdProgCombo').classList.remove('open'); var v=qs('mdProgramme').value; var m=v?_progs.filter(function(p){return p.value===v;})[0]:null; qs('mdProgInput').value=m?m.text:''; }
function syncProgToFilters(){ var v=qs('mdProgramme').value; if(!v) return; var m=_progs.filter(function(p){return p.value===v;})[0]; if(m && !progMatches(m)) selectProg(''); }

function init(){
    // Ready card click → open provisional marks queue filtered to ready records
    var readyCard=qs('kReadyCard');
    if(readyCard){
        readyCard.onclick=function(){
            var yr=qs('mdYear').value,sem=qs('mdSemester').value,prog=qs('mdProgramme').value;
            window.location.href='ProvisionalMarksController.aspx?pg=1&year='+encodeURIComponent(yr)+'&sem='+encodeURIComponent(sem)+'&prog='+encodeURIComponent(prog)+'&status=pending&ready=1&ps=100&q=';
        };
    }
    setLoading(true);
    callAJAX('GetDashboardInit',{},function(d){
        setLoading(false);
        if(!d||!d.success){ showError((d&&d.message)||'Failed to load filters.'); return; }
        if(d.scope) applyScope(d.scope,true);
        fillSelect('mdYear',d.years,'All Years');
        fillFilter('mdFaculty',d.faculties,'All Faculties');
        fillFilter('mdDepartment',d.departments,'All Departments');
        _progs=d.programmes||[];
        cascadeDept();
        // Faculty / Department cascade
        qs('mdFaculty').onchange=function(){ cascadeDept(); syncProgToFilters(); };
        qs('mdDepartment').onchange=function(){ syncProgToFilters(); };
        // Searchable programme combobox
        var pin=qs('mdProgInput');
        pin.onfocus=openCombo; pin.onclick=openCombo;
        pin.oninput=function(){ qs('mdProgramme').value=''; openCombo(); };
        pin.onkeydown=function(e){
            if(e.key==='Escape'){ closeCombo(); }
            else if(e.key==='Enter'){ e.preventDefault(); var l=progFilteredList(); selectProg(l.length?l[0].value:'',true); }
        };
        document.addEventListener('click',function(e){ var c=qs('mdProgCombo'); if(c && !c.contains(e.target)) closeCombo(); });
        qs('mdApply').onclick=function(){ loadStats(); };
        qs('mdReset').onclick=function(){
            qs('mdYear').value=''; qs('mdSemester').value='';
            qs('mdFaculty').value=''; qs('mdDepartment').value=''; cascadeDept();
            selectProg('');
            loadStats();
        };
        loadStats();

        // Mark Changes & Audit panel
        if(qs('mcaDays')){
            qs('mcaDays').onchange=mcaLoad;
            qs('mcaAction').onchange=mcaFeed;
            qs('mcaLimit').onchange=mcaFeed;
            qs('mcaRefresh').onclick=mcaLoad;
            qs('mcaQ').onkeydown=function(e){ if(e.key==='Enter') mcaFeed(); };
            qs('mcaMClose').onclick=function(){ qs('mcaOvl').classList.remove('open'); };
            qs('mcaOvl').onclick=function(e){ if(e.target===this) this.classList.remove('open'); };
            mcaLoad();
        }
    });
}
init();
})();
</script>
</asp:Content>
