<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="TeacherDashboard.aspx.cs" Inherits="COOPERP_NewScreens_TeacherDashboard" Title="My Marks Dashboard - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<meta name="csrf-token" content="<%= MarksAntiForgeryService.GetToken() %>" />
<style>
/* ===== TEACHER DASHBOARD (prefix: td-) ================================= */

/* Welcome Banner */
.td-welcome { background: linear-gradient(135deg, #05275C 0%, #174DA4 100%); color: #fff; padding: 18px 22px; margin-bottom: 16px; display: flex; align-items: center; justify-content: space-between; }
.td-welcome__left { display: flex; align-items: center; gap: 14px; }
.td-welcome__avatar { width: 42px; height: 42px; background: rgba(255,255,255,.15); display: flex; align-items: center; justify-content: center; border-radius: 50%; }
.td-welcome__name { font-size: 15px; font-weight: 700; }
.td-welcome__sub { font-size: 10px; opacity: .8; margin-top: 2px; }
.td-welcome__period { background: rgba(255,255,255,.12); padding: 6px 14px; font-size: 11px; font-weight: 600; }

/* Stats */
.td-stats { display: grid; grid-template-columns: repeat(6, 1fr); gap: 10px; margin-bottom: 16px; }
.td-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.td-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--tc, #ccc); }
.td-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.td-stat__val { font-size: 16px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.td-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.td-stat--courses   { --tc: #174DA4; } .td-stat--courses .td-stat__icon   { background: #e8f0fc; } .td-stat--courses .td-stat__val   { color: #174DA4; }
.td-stat--complete  { --tc: #2e7d32; } .td-stat--complete .td-stat__icon  { background: #e6f4ea; } .td-stat--complete .td-stat__val  { color: #2e7d32; }
.td-stat--pending   { --tc: #e65100; } .td-stat--pending .td-stat__icon   { background: #fff3e0; } .td-stat--pending .td-stat__val   { color: #e65100; }
.td-stat--pending-exam { --tc: #8e24aa; } .td-stat--pending-exam .td-stat__icon { background: #f3e5f5; } .td-stat--pending-exam .td-stat__val { color: #8e24aa; }
.td-stat--submitted { --tc: #1565c0; } .td-stat--submitted .td-stat__icon { background: #e3f2fd; } .td-stat--submitted .td-stat__val { color: #1565c0; }
.td-stat--deadline  { --tc: #c62828; } .td-stat--deadline .td-stat__icon  { background: #fde8e8; } .td-stat--deadline .td-stat__val  { color: #c62828; }
.td-metric-note { margin: -8px 0 14px; padding: 8px 12px; background: #f8fafc; border: 1px solid #e0e5ed; font-size: 10px; color: #6b7280; }

/* Section Container */
.td-section { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 16px; }
.td-section__head { padding: 12px 16px; border-bottom: 1px solid #e0e5ed; display: flex; align-items: center; justify-content: space-between; }
.td-section__title { font-size: 12px; font-weight: 700; color: #05275C; text-transform: uppercase; letter-spacing: .5px; }
.td-section__body { padding: 0; }

/* Course Cards */
.td-courses { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 12px; padding: 14px; }
.td-course { border: 1px solid #e0e5ed; padding: 14px; position: relative; transition: box-shadow .15s; }
.td-course:hover { box-shadow: 0 2px 8px rgba(0,0,0,.08); }
.td-course__header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 10px; }
.td-course__code { font-size: 12px; font-weight: 700; color: #05275C; }
.td-course__name { font-size: 10px; color: #666; margin-top: 2px; max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.td-course__status { padding: 2px 8px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; }
.td-course__status--DRAFT { background: #f0f0f0; color: #666; }
.td-course__status--SUBMITTED { background: #e3f2fd; color: #1565c0; }
.td-course__status--DEAN_APPROVED { background: #e6f4ea; color: #2e7d32; }
.td-course__status--PROVISIONAL_PUBLISHED { background: #fff3e0; color: #e65100; }
.td-course__status--FINAL_PUBLISHED { background: #e8f0fc; color: #174DA4; }

/* Progress Bar */
.td-progress { height: 6px; background: #eee; margin: 8px 0; position: relative; overflow: hidden; }
.td-progress__bar { height: 100%; background: #2e7d32; transition: width .3s; }
.td-progress__text { font-size: 9px; color: #888; display: flex; justify-content: space-between; }

/* Course Meta Row */
.td-course__meta { display: flex; gap: 12px; font-size: 9px; color: #888; margin: 6px 0; flex-wrap: wrap; }
.td-course__meta span { display: flex; align-items: center; gap: 3px; }

/* Deadline Warning */
.td-deadline-warn { display: flex; align-items: center; gap: 6px; padding: 6px 10px; margin-top: 8px; font-size: 10px; font-weight: 600; }
.td-deadline-warn--ok { background: #e6f4ea; color: #2e7d32; }
.td-deadline-warn--warn { background: #fff3e0; color: #e65100; }
.td-deadline-warn--critical { background: #fde8e8; color: #c62828; }

/* Course Actions */
.td-course__actions { display: flex; gap: 6px; margin-top: 10px; }

/* Buttons */
.td-btn { padding: 5px 12px; font-size: 10px; font-weight: 600; cursor: pointer; border: none; transition: background .15s; text-decoration: none; display: inline-block; text-align: center; }
.td-btn--primary { background: #174DA4; color: #fff; }
.td-btn--primary:hover { background: #0d3b82; color: #fff; }
.td-btn--success { background: #2e7d32; color: #fff; }
.td-btn--success:hover { background: #1b5e20; color: #fff; }
.td-btn--outline { background: transparent; border: 1px solid #cdd3de; color: #555; }
.td-btn--outline:hover { background: #f4f6f9; }
.td-btn--sm { padding: 3px 8px; font-size: 9px; }

/* Filters */
.td-filters { display: flex; gap: 8px; padding: 10px 16px; border-bottom: 1px solid #e0e5ed; flex-wrap: wrap; align-items: center; }
.td-filters select { padding: 5px 10px; font-size: 11px; border: 1px solid #cdd3de; background: #fff; }

/* Alert Banners */
.td-alert { display: flex; align-items: center; gap: 10px; padding: 10px 16px; margin-bottom: 12px; font-size: 11px; }
.td-alert--info { background: #e3f2fd; color: #1565c0; border-left: 3px solid #1565c0; }
.td-alert--warn { background: #fff3e0; color: #e65100; border-left: 3px solid #e65100; }
.td-alert--error { background: #fde8e8; color: #c62828; border-left: 3px solid #c62828; }

/* Toast */
.td-toast { position: fixed; bottom: 20px; right: 20px; padding: 10px 18px; font-size: 11px; font-weight: 600; color: #fff; z-index: 2000; transform: translateY(40px); opacity: 0; transition: all .25s; }
.td-toast--show { transform: translateY(0); opacity: 1; }
.td-toast--ok { background: #2e7d32; }
.td-toast--err { background: #c62828; }

/* Loading */
.td-loading { text-align: center; padding: 40px; color: #888; font-size: 12px; }

/* Grade Distribution (Batch 11) */
.td-grade-dist { display: flex; flex-wrap: wrap; gap: 4px; margin: 8px 0 4px; }
.td-grade-pill { display: inline-flex; align-items: center; gap: 3px; padding: 2px 7px; font-size: 9px; font-weight: 700; border-radius: 10px; background: #e8eaf6; color: #283593; }
.td-grade-pill em { font-style: normal; font-weight: 400; opacity: .8; }

/* Responsive */
@media (max-width: 900px) { .td-stats { grid-template-columns: repeat(3, 1fr); } }
@media (max-width: 600px) {
    .td-stats { grid-template-columns: repeat(2, 1fr); }
    .td-courses { grid-template-columns: 1fr; }
    .td-welcome { flex-direction: column; gap: 10px; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Welcome Banner -->
<div class="td-welcome">
    <div class="td-welcome__left">
        <div class="td-welcome__avatar">
            <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16"><path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM2 14s-1 0-1-1 1-4 7-4 7 3 7 4-1 1-1 1H2z"/></svg>
        </div>
        <div>
            <div class="td-welcome__name" id="td-teacher-name">Loading...</div>
            <div class="td-welcome__sub">My Marks Dashboard</div>
        </div>
    </div>
    <div class="td-welcome__period" id="td-period"></div>
</div>

<!-- Deadline Alert (shown if any deadline is near) -->
<div class="td-alert td-alert--warn" id="td-deadline-alert" style="display:none;">
    <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a7 7 0 1 0 0 14A7 7 0 0 0 8 1Zm0 3a.9.9 0 0 1 .9.9v4.2a.9.9 0 0 1-1.8 0V4.9A.9.9 0 0 1 8 4Zm0 8a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"/></svg>
    <span id="td-deadline-msg"></span>
</div>

<!-- Stats -->
<div class="td-stats">
    <div class="td-stat td-stat--courses">
        <div class="td-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M1 2.5A1.5 1.5 0 0 1 2.5 1h3A1.5 1.5 0 0 1 7 2.5v3A1.5 1.5 0 0 1 5.5 7h-3A1.5 1.5 0 0 1 1 5.5v-3Zm8 0A1.5 1.5 0 0 1 10.5 1h3A1.5 1.5 0 0 1 15 2.5v3A1.5 1.5 0 0 1 13.5 7h-3A1.5 1.5 0 0 1 9 5.5v-3Zm-8 8A1.5 1.5 0 0 1 2.5 9h3A1.5 1.5 0 0 1 7 10.5v3A1.5 1.5 0 0 1 5.5 15h-3A1.5 1.5 0 0 1 1 13.5v-3Z"/></svg></div>
        <div><div class="td-stat__val" id="stat-courses">0</div><div class="td-stat__label">Assigned Courses</div></div>
    </div>
    <div class="td-stat td-stat--complete">
        <div class="td-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M6.5 11.5 3 8l1-1 2.5 2.5L12 4l1 1-6.5 6.5Z"/></svg></div>
        <div><div class="td-stat__val" id="stat-complete">0</div><div class="td-stat__label">Marks Complete</div></div>
    </div>
    <div class="td-stat td-stat--pending" title="Counts ACTIVE students in non-published sheets where coursework is NULL.">
        <div class="td-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a7 7 0 1 0 0 14A7 7 0 0 0 8 1Zm1 4v4H5"/></svg></div>
        <div><div class="td-stat__val" id="stat-pending">0</div><div class="td-stat__label">Pending Coursework</div></div>
    </div>
    <div class="td-stat td-stat--pending-exam" title="Counts ACTIVE students in non-published sheets where exam is NULL.">
        <div class="td-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M2 2h12v10H2z"/><path d="M4 4h8v2H4z"/><path d="M4 7h2v2H4zM7 7h2v2H7zM10 7h2v2h-2zM4 10h8v1H4z"/></svg></div>
        <div><div class="td-stat__val" id="stat-pending-exam">0</div><div class="td-stat__label">Pending Exam Marks</div></div>
    </div>
    <div class="td-stat td-stat--submitted">
        <div class="td-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="m12.14 8.753-5.482 4.796c-.646.566-1.658.106-1.658-.753V3.204a1 1 0 0 1 1.659-.753l5.48 4.796a1 1 0 0 1 0 1.506z"/></svg></div>
        <div><div class="td-stat__val" id="stat-submitted">0</div><div class="td-stat__label">Submitted</div></div>
    </div>
    <div class="td-stat td-stat--deadline">
        <div class="td-stat__icon"><svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a7 7 0 1 0 0 14A7 7 0 0 0 8 1Zm0 3v5h4"/></svg></div>
        <div><div class="td-stat__val" id="stat-deadline">--</div><div class="td-stat__label">Days to Deadline</div></div>
    </div>
</div>

<div class="td-metric-note">
    Pending Coursework = ACTIVE students with <strong>coursework = NULL</strong> in non-published sheets. &nbsp;|&nbsp;
    Pending Exam Marks = ACTIVE students with <strong>exam = NULL</strong> in non-published sheets.
</div>

<!-- Courses Section -->
<div class="td-section">
    <div class="td-section__head">
        <div class="td-section__title">My Assigned Courses</div>
        <div class="td-filters">
            <select id="td-year" onchange="TD.load()"><option value="">Loading...</option></select>
            <select id="td-semester" onchange="TD.load()">
                <option value="1">Semester 1</option>
                <option value="2">Semester 2</option>
            </select>
        </div>
    </div>
    <div class="td-section__body">
        <div class="td-courses" id="td-course-list">
            <div class="td-loading">Loading your assigned courses...</div>
        </div>
    </div>
</div>

<!-- Toast -->
<div class="td-toast" id="td-toast"></div>

<script>
var TD = (function () {
    var _data = null;
    var _csrfToken = (function() { var m = document.querySelector('meta[name="csrf-token"]'); return m ? m.getAttribute('content') : ''; })();

    function init() {
        _loadInit();
    }

    /* ─── Initial Load ──────────────────────────────────────────── */
    function _loadInit() {
        fetch('TeacherDashboard.aspx?ajax=init')
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.error) { toast(d.error, true); return; }
                document.getElementById('td-teacher-name').textContent = d.teacher_name || 'Teacher';
                _fillYears(d.years || []);
                document.getElementById('td-period').textContent = (d.current_year || '') + ' Sem ' + (d.current_sem || '');
                // Set current values
                if (d.current_year) document.getElementById('td-year').value = d.current_year;
                if (d.current_sem) document.getElementById('td-semester').value = d.current_sem;
                load();
            })
            .catch(function (e) { toast('Failed to load: ' + e.message, true); });
    }

    function _fillYears(years) {
        var el = document.getElementById('td-year');
        el.innerHTML = '';
        for (var i = 0; i < years.length; i++) {
            el.innerHTML += '<option value="' + years[i].val + '">' + _esc(years[i].val) + '</option>';
        }
    }

    /* ─── Main Dashboard Load ───────────────────────────────────── */
    function load() {
        var year = document.getElementById('td-year').value;
        var sem = document.getElementById('td-semester').value;
        if (!year) return;

        document.getElementById('td-course-list').innerHTML = '<div class="td-loading">Loading courses...</div>';

        fetch('TeacherDashboard.aspx?ajax=dashboard&year=' + encodeURIComponent(year) + '&sem=' + sem)
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.error) { toast(d.error, true); return; }
                _data = d;
                _updateStats(d.stats || {});
                _renderCourses(d.courses || []);
                _checkDeadlineAlerts(d.courses || []);
                document.getElementById('td-period').textContent = year + ' Sem ' + sem;
            })
            .catch(function (e) { toast('Error: ' + e.message, true); });
    }

    /* ─── Update Stats ──────────────────────────────────────────── */
    function _updateStats(s) {
        document.getElementById('stat-courses').textContent = s.total_courses || 0;
        document.getElementById('stat-complete').textContent = s.marks_complete || 0;
        document.getElementById('stat-pending').textContent = s.pending_entry || 0;
        document.getElementById('stat-pending-exam').textContent = s.pending_exam || 0;
        document.getElementById('stat-submitted').textContent = s.submitted || 0;
        document.getElementById('stat-deadline').textContent = s.nearest_deadline !== undefined && s.nearest_deadline !== null
            ? (s.nearest_deadline < 0 ? 'Overdue' : s.nearest_deadline + 'd')
            : '--';
    }

    /* ─── Render Course Cards ───────────────────────────────────── */
    function _renderCourses(courses) {
        var container = document.getElementById('td-course-list');
        if (!courses.length) {
            container.innerHTML = '<div class="td-loading">No courses assigned for this period. Contact your administrator if this is unexpected.</div>';
            return;
        }
        var html = '';
        for (var i = 0; i < courses.length; i++) {
            var c = courses[i];
            var pct = c.expected_students > 0 ? Math.round((c.entered_count / c.expected_students) * 100) : 0;
            var dlClass = 'ok';
            var dlText = '';
            if (c.days_to_deadline !== null && c.days_to_deadline !== undefined) {
                if (c.days_to_deadline < 0) { dlClass = 'critical'; dlText = Math.abs(c.days_to_deadline) + ' days overdue'; }
                else if (c.days_to_deadline <= 3) { dlClass = 'critical'; dlText = c.days_to_deadline + ' days left'; }
                else if (c.days_to_deadline <= 7) { dlClass = 'warn'; dlText = c.days_to_deadline + ' days left'; }
                else { dlClass = 'ok'; dlText = c.days_to_deadline + ' days left'; }
            }

            html += '<div class="td-course">';
            html += '<div class="td-course__header">';
            html += '<div><div class="td-course__code">' + _esc(c.course_id) + '</div>';
            html += '<div class="td-course__name" title="' + _esc(c.course_name) + '">' + _esc(c.course_name) + '</div></div>';
            html += '<span class="td-course__status td-course__status--' + c.status + '">' + _statusLabel(c.status) + '</span>';
            html += '</div>';

            // Progress
            html += '<div class="td-progress"><div class="td-progress__bar" style="width:' + pct + '%"></div></div>';
            html += '<div class="td-progress__text"><span>' + c.entered_count + ' / ' + c.expected_students + ' students entered</span><span>' + pct + '%</span></div>';

            // Meta
            html += '<div class="td-course__meta">';
            html += '<span><svg width="10" height="10" fill="currentColor" viewBox="0 0 16 16"><path d="M4 1v14h8V1H4Z"/></svg> Year ' + c.study_year + '</span>';
            html += '<span><svg width="10" height="10" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a7 7 0 1 0 0 14A7 7 0 0 0 8 1Z"/></svg> ' + _esc(c.programme) + '</span>';
            if (c.campus_name) html += '<span>' + _esc(c.campus_name) + '</span>';
            html += '</div>';

            // Deadline warning
            if (dlText) {
                html += '<div class="td-deadline-warn td-deadline-warn--' + dlClass + '">';
                html += '<svg width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><rect x="3" y="4" width="10" height="10" rx="1"/><line x1="5" y1="2" x2="5" y2="5" stroke="currentColor" stroke-width="1.5"/><line x1="11" y1="2" x2="11" y2="5" stroke="currentColor" stroke-width="1.5"/></svg>';
                html += dlText + '</div>';
            }

            // Grade distribution pills (Batch 11)
            if (c.grade_distribution && c.grade_distribution.length > 0) {
                html += '<div class="td-grade-dist">';
                for (var gi = 0; gi < c.grade_distribution.length; gi++) {
                    var gd = c.grade_distribution[gi];
                    html += '<span class="td-grade-pill" title="' + _esc(gd.g) + ': ' + gd.n + ' students">' + _esc(gd.g) + ' <em>' + gd.n + '</em></span>';
                }
                html += '</div>';
            }

            // Actions
            html += '<div class="td-course__actions">';
            if (c.status === 'DRAFT') {
                html += '<a class="td-btn td-btn--primary td-btn--sm" href="MarkEntry.aspx?course=' + encodeURIComponent(c.course_id) + '&prog=' + encodeURIComponent(c.prog_id) + '&year=' + encodeURIComponent(c.acadyear) + '&sem=' + c.semester + '&sy=' + c.study_year + '&campus=' + c.campus_id + '&session=' + encodeURIComponent(c.session) + '">Enter Marks</a>';
                if (pct >= 100) {
                    html += '<button class="td-btn td-btn--success td-btn--sm" onclick="TD.submitSheet(\'' + _esc(c.course_id) + '\',\'' + _esc(c.prog_id) + '\',' + c.study_year + ',' + c.campus_id + ',\'' + _esc(c.session) + '\')">Submit for Approval</button>';
                }
            } else if (c.status === 'SUBMITTED') {
                html += '<span class="td-btn td-btn--outline td-btn--sm" style="cursor:default;">Awaiting Dean Review</span>';
            } else if (c.status === 'DEAN_APPROVED') {
                html += '<span class="td-btn td-btn--outline td-btn--sm" style="cursor:default;">Approved — Awaiting Publication</span>';
            } else {
                html += '<a class="td-btn td-btn--outline td-btn--sm" href="MarkEntry.aspx?course=' + encodeURIComponent(c.course_id) + '&prog=' + encodeURIComponent(c.prog_id) + '&year=' + encodeURIComponent(c.acadyear) + '&sem=' + c.semester + '&sy=' + c.study_year + '&campus=' + c.campus_id + '&session=' + encodeURIComponent(c.session) + '">View Marks</a>';
            }
            html += '</div>';

            // Reject reason
            if (c.reject_reason) {
                html += '<div class="td-alert td-alert--error" style="margin-top:8px;padding:6px 10px;font-size:10px;">';
                html += '<strong>Rejection Note:</strong> ' + _esc(c.reject_reason);
                html += '</div>';
            }

            html += '</div>';
        }
        container.innerHTML = html;
    }

    /* ─── Deadline Alerts ───────────────────────────────────────── */
    function _checkDeadlineAlerts(courses) {
        var nearest = null;
        for (var i = 0; i < courses.length; i++) {
            var d = courses[i].days_to_deadline;
            if (d !== null && d !== undefined && (nearest === null || d < nearest)) nearest = d;
        }
        var alert = document.getElementById('td-deadline-alert');
        if (nearest !== null && nearest <= 7) {
            document.getElementById('td-deadline-msg').textContent = nearest < 0
                ? 'One or more coursework deadlines have passed. Contact your Dean for an unlock request.'
                : 'Coursework deadline in ' + nearest + ' day(s). Complete and submit your marks before the deadline.';
            alert.className = 'td-alert ' + (nearest <= 3 ? 'td-alert--error' : 'td-alert--warn');
            alert.style.display = '';
        } else {
            alert.style.display = 'none';
        }
    }

    /* ─── Submit Sheet ──────────────────────────────────────────── */
    function submitSheet(courseId, progId, studyYear, campusId, session) {
        if (!confirm('Submit marks for ' + courseId + ' for Dean approval? You will not be able to edit until the Dean reviews.')) return;

        fetch('TeacherDashboard.aspx?ajax=submit', {
            method: 'POST', headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': _csrfToken },
            body: JSON.stringify({
                course_id: courseId, prog_id: progId,
                study_year: studyYear, campus_id: campusId, session: session
            })
        })
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d.ok) { toast('Marks submitted for Dean approval.'); load(); }
                else { toast(d.error || 'Submit failed.', true); }
            })
            .catch(function (e) { toast('Error: ' + e.message, true); });
    }

    /* ─── Helpers ───────────────────────────────────────────────── */
    function _statusLabel(s) {
        if (s === 'DRAFT') return 'Draft';
        if (s === 'SUBMITTED') return 'Submitted';
        if (s === 'DEAN_APPROVED') return 'Approved';
        if (s === 'PROVISIONAL_PUBLISHED') return 'Provisional';
        if (s === 'FINAL_PUBLISHED') return 'Published';
        return s || 'Draft';
    }

    function toast(msg, isErr) {
        var el = document.getElementById('td-toast');
        el.textContent = msg;
        el.className = 'td-toast td-toast--show ' + (isErr ? 'td-toast--err' : 'td-toast--ok');
        setTimeout(function () { el.className = 'td-toast'; }, 3000);
    }

    function _esc(s) { var d = document.createElement('div'); d.textContent = s || ''; return d.innerHTML; }

    document.addEventListener('DOMContentLoaded', init);

    return { load: load, submitSheet: submitSheet };
})();
</script>

</asp:Content>
