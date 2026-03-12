<%@ Page Language="C#" AutoEventWireup="true" CodeFile="docs.aspx.cs" Inherits="API_v2_docs" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Campus Dynamics API v2 — Documentation</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, sans-serif; background:#f5f7fa; color:#1a1a2e; line-height:1.6; }
        .api-header { background: linear-gradient(135deg, #05275C 0%, #0a3d8f 100%); color:#fff; padding:32px 0; }
        .api-header__inner { max-width:1100px; margin:0 auto; padding:0 24px; }
        .api-header__title { font-size:28px; font-weight:800; letter-spacing:-0.5px; }
        .api-header__sub { font-size:14px; opacity:0.8; margin-top:4px; }
        .api-header__version { display:inline-block; background:rgba(255,255,255,0.15); padding:3px 10px; font-size:11px; font-weight:700; margin-top:8px; letter-spacing:0.5px; }
        .api-layout { max-width:1100px; margin:0 auto; padding:24px; display:flex; gap:24px; }
        .api-sidebar { width:240px; flex-shrink:0; position:sticky; top:24px; align-self:flex-start; }
        .api-sidebar__nav { background:#fff; border:1px solid #e0e5ed; padding:16px 0; }
        .api-sidebar__heading { padding:6px 16px; font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#8892a4; }
        .api-sidebar__link { display:block; padding:6px 16px; font-size:13px; color:#333; text-decoration:none; transition:background 0.15s,color 0.15s; }
        .api-sidebar__link:hover { background:#f0f4ff; color:#05275C; }
        .api-sidebar__link--active { background:#e8eeff; color:#05275C; font-weight:600; border-left:3px solid #05275C; }
        .api-main { flex:1; min-width:0; }
        .api-section { background:#fff; border:1px solid #e0e5ed; margin-bottom:20px; }
        .api-section__header { padding:16px 20px; border-bottom:1px solid #e0e5ed; }
        .api-section__title { font-size:18px; font-weight:700; }
        .api-section__desc { font-size:13px; color:#666; margin-top:4px; }
        .api-section__body { padding:20px; }
        .api-badge { display:inline-block; padding:2px 8px; font-size:11px; font-weight:700; letter-spacing:0.5px; color:#fff; margin-right:6px; vertical-align:middle; }
        .api-badge--get { background:#2ecc71; }
        .api-badge--post { background:#3498db; }
        .api-badge--put { background:#f39c12; }
        .api-badge--delete { background:#e74c3c; }
        .api-badge--auth { background:#9b59b6; }
        .api-badge--pending { background:#95a5a6; }
        .api-badge--live { background:#2ecc71; }
        .api-endpoint { margin-bottom:20px; padding:16px; border:1px solid #e8ecf1; background:#fafbfc; }
        .api-endpoint:last-child { margin-bottom:0; }
        .api-endpoint__path { font-family: 'Courier New', monospace; font-size:14px; font-weight:600; color:#1a1a2e; margin-bottom:6px; }
        .api-endpoint__info { font-size:13px; color:#555; margin-bottom:10px; }
        .api-endpoint__params { width:100%; border-collapse:collapse; font-size:12px; margin-top:8px; }
        .api-endpoint__params th { text-align:left; padding:6px 8px; background:#f0f4f8; border:1px solid #e0e5ed; font-weight:600; }
        .api-endpoint__params td { padding:6px 8px; border:1px solid #e0e5ed; }
        .api-param--required { color:#e74c3c; font-weight:600; }
        .api-param--optional { color:#95a5a6; }
        .api-code { background:#1e1e2e; color:#cdd6f4; padding:16px; overflow-x:auto; font-family:'Courier New',monospace; font-size:12px; line-height:1.7; margin-top:10px; white-space:pre; }
        .api-code .c-key { color:#89b4fa; }
        .api-code .c-str { color:#a6e3a1; }
        .api-code .c-num { color:#fab387; }
        .api-code .c-comm { color:#6c7086; }
        .api-code .c-url { color:#f9e2af; }
        .api-note { padding:12px 16px; font-size:12px; border-left:3px solid #3498db; background:#f0f7ff; margin-top:12px; }
        .api-note--warn { border-left-color:#f39c12; background:#fffbf0; }
        .api-note--danger { border-left-color:#e74c3c; background:#fff5f5; }
        .api-task-list { list-style:none; padding:0; }
        .api-task-list li { padding:10px 12px; border-bottom:1px solid #f0f2f5; font-size:13px; display:flex; align-items:center; gap:10px; }
        .api-task-list li:last-child { border-bottom:none; }
        .api-status { width:10px; height:10px; display:inline-block; flex-shrink:0; }
        .api-status--done { background:#2ecc71; border-radius:50%; }
        .api-status--pending { background:#f39c12; border-radius:50%; }
        .api-status--todo { background:#e0e5ed; border-radius:50%; }
        .api-stats { display:flex; gap:16px; margin-bottom:20px; }
        .api-stat { flex:1; padding:16px; background:#fff; border:1px solid #e0e5ed; text-align:center; }
        .api-stat__num { font-size:28px; font-weight:800; color:#05275C; }
        .api-stat__label { font-size:11px; color:#8892a4; text-transform:uppercase; letter-spacing:0.5px; margin-top:2px; }
        @media(max-width:768px) {
            .api-layout { flex-direction:column; }
            .api-sidebar { width:100%; position:static; }
        }
    </style>
</head>
<body>
    <div class="api-header">
        <div class="api-header__inner">
            <div class="api-header__title">Campus Dynamics API</div>
            <div class="api-header__sub">RESTful API for Student &amp; Staff Mobile Applications</div>
            <div class="api-header__version">VERSION 2.0</div>
        </div>
    </div>
    <div class="api-layout">
        <aside class="api-sidebar">
            <nav class="api-sidebar__nav">
                <div class="api-sidebar__heading">Getting Started</div>
                <a href="#overview" class="api-sidebar__link api-sidebar__link--active">Overview</a>
                <a href="#authentication" class="api-sidebar__link">Authentication</a>
                <a href="#errors" class="api-sidebar__link">Error Handling</a>
                <div class="api-sidebar__heading">Student Endpoints</div>
                <a href="#student-profile" class="api-sidebar__link">Profile</a>
                <a href="#student-results" class="api-sidebar__link">Results</a>
                <a href="#student-courses" class="api-sidebar__link">Course Registration</a>
                <a href="#student-finance" class="api-sidebar__link">Finance / Fees</a>
                <a href="#student-timetable" class="api-sidebar__link">Timetable</a>
                <div class="api-sidebar__heading">Staff Endpoints</div>
                <a href="#staff-profile" class="api-sidebar__link">Staff Profile</a>
                <a href="#staff-classes" class="api-sidebar__link">My Classes</a>
                <a href="#staff-grading" class="api-sidebar__link">Grading</a>
                <div class="api-sidebar__heading">General</div>
                <a href="#notices" class="api-sidebar__link">Notices</a>
                <a href="#directory" class="api-sidebar__link">Directory</a>
                <a href="#campus" class="api-sidebar__link">Campus Info</a>
                <div class="api-sidebar__heading">Project</div>
                <a href="#roadmap" class="api-sidebar__link">Roadmap</a>
            </nav>
        </aside>
        <main class="api-main">
            <!-- Stats -->
            <div class="api-stats">
                <div class="api-stat">
                    <div class="api-stat__num" id="statTotal">0</div>
                    <div class="api-stat__label">Total Endpoints</div>
                </div>
                <div class="api-stat">
                    <div class="api-stat__num" id="statLive">0</div>
                    <div class="api-stat__label">Live</div>
                </div>
                <div class="api-stat">
                    <div class="api-stat__num" id="statPending">0</div>
                    <div class="api-stat__label">Pending</div>
                </div>
                <div class="api-stat">
                    <div class="api-stat__num">v2.0</div>
                    <div class="api-stat__label">API Version</div>
                </div>
            </div>

            <!-- Overview -->
            <div class="api-section" id="overview">
                <div class="api-section__header">
                    <div class="api-section__title">Overview</div>
                    <div class="api-section__desc">Base URL, request format, and response structure</div>
                </div>
                <div class="api-section__body">
                    <p style="font-size:13px;margin-bottom:12px;">The Campus Dynamics API v2 provides programmatic access to student records, academic results, financial data, timetables, staff information, and campus services. All endpoints return JSON.</p>
                    <div class="api-code"><span class="c-comm">// Base URL</span>
<span class="c-url">https://eadmin.mru.ac.ug/API/v2/{endpoint}.aspx?action={action}</span>

<span class="c-comm">// All responses follow this structure:</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"OK"</span>,
  <span class="c-key">"data"</span>: { ... },
  <span class="c-key">"timestamp"</span>: <span class="c-str">"2026-03-12T10:30:00Z"</span>
}

<span class="c-comm">// Error response:</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">false</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Invalid token"</span>,
  <span class="c-key">"error_code"</span>: <span class="c-str">"AUTH_INVALID_TOKEN"</span>,
  <span class="c-key">"data"</span>: <span class="c-num">null</span>
}</div>
                    <div class="api-note">All requests (except login) require a <strong>token</strong> parameter. Tokens are obtained via the <code>/auth.aspx?action=login</code> endpoint.</div>
                </div>
            </div>

            <!-- Authentication -->
            <div class="api-section" id="authentication">
                <div class="api-section__header">
                    <div class="api-section__title">Authentication</div>
                    <div class="api-section__desc">Token-based authentication for all API access</div>
                </div>
                <div class="api-section__body">
                    <p style="font-size:13px;margin-bottom:12px;">The API uses simple token-based auth. Call the login endpoint with credentials, receive a token, then pass it on all subsequent requests as a query parameter <code>token=</code>.</p>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/auth.aspx?action=login</div>
                        <div class="api-endpoint__info">Authenticate a student or staff member and receive an access token.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>username</td><td>string</td><td class="api-param--required">Yes</td><td>Registration number (student) or staff ID</td></tr>
                            <tr><td>password</td><td>string</td><td class="api-param--required">Yes</td><td>Account password</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Request</span>
POST /API/v2/auth.aspx?action=login
Content-Type: application/x-www-form-urlencoded

username=MRU/2023/001&amp;password=mypassword

<span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Login successful"</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"token"</span>: <span class="c-str">"a1b2c3d4e5f6..."</span>,
    <span class="c-key">"user_type"</span>: <span class="c-str">"student"</span>,
    <span class="c-key">"user_id"</span>: <span class="c-str">"MRU/2023/001"</span>,
    <span class="c-key">"full_name"</span>: <span class="c-str">"JOHN DOE"</span>,
    <span class="c-key">"expires"</span>: <span class="c-str">"2026-03-13T10:30:00Z"</span>
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/auth.aspx?action=logout</div>
                        <div class="api-endpoint__info">Invalidate the current token.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Active token to invalidate</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/auth.aspx?action=validate&amp;token=...</div>
                        <div class="api-endpoint__info">Check if a token is still valid.</div>
                    </div>
                </div>
            </div>

            <!-- Error Handling -->
            <div class="api-section" id="errors">
                <div class="api-section__header">
                    <div class="api-section__title">Error Handling</div>
                    <div class="api-section__desc">Standard error codes returned by the API</div>
                </div>
                <div class="api-section__body">
                    <table class="api-endpoint__params">
                        <tr><th>Error Code</th><th>Description</th></tr>
                        <tr><td>AUTH_MISSING_TOKEN</td><td>No token provided in the request</td></tr>
                        <tr><td>AUTH_INVALID_TOKEN</td><td>Token is expired or invalid</td></tr>
                        <tr><td>AUTH_LOGIN_FAILED</td><td>Invalid username or password</td></tr>
                        <tr><td>INVALID_ACTION</td><td>Unknown action parameter</td></tr>
                        <tr><td>MISSING_PARAM</td><td>A required parameter is missing</td></tr>
                        <tr><td>NOT_FOUND</td><td>Requested record does not exist</td></tr>
                        <tr><td>ACCESS_DENIED</td><td>Token owner cannot access this resource</td></tr>
                        <tr><td>SERVER_ERROR</td><td>Unexpected internal server error</td></tr>
                    </table>
                </div>
            </div>

            <!-- Student Profile -->
            <div class="api-section" id="student-profile">
                <div class="api-section__header">
                    <div class="api-section__title">Student Profile</div>
                    <div class="api-section__desc">Retrieve student biographical and academic information</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=profile&amp;token=...</div>
                        <div class="api-endpoint__info">Get the full profile of the authenticated student. Returns bio data, programme, campus, study year, etc.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"MRU/2023/001"</span>,
    <span class="c-key">"surname"</span>: <span class="c-str">"DOE"</span>,
    <span class="c-key">"othername"</span>: <span class="c-str">"JOHN"</span>,
    <span class="c-key">"gender"</span>: <span class="c-str">"Male"</span>,
    <span class="c-key">"programme"</span>: <span class="c-str">"BACHELOR OF SCIENCE IN COMPUTER SCIENCE"</span>,
    <span class="c-key">"progcode"</span>: <span class="c-str">"BCS"</span>,
    <span class="c-key">"campus"</span>: <span class="c-str">"Main Campus"</span>,
    <span class="c-key">"study_year"</span>: <span class="c-num">2</span>,
    <span class="c-key">"entry_year"</span>: <span class="c-num">2023</span>,
    <span class="c-key">"intake"</span>: <span class="c-str">"AUGUST"</span>,
    <span class="c-key">"session"</span>: <span class="c-str">"Full time"</span>,
    <span class="c-key">"status"</span>: <span class="c-str">"Active"</span>,
    <span class="c-key">"nationality"</span>: <span class="c-str">"Ugandan"</span>,
    <span class="c-key">"phone"</span>: <span class="c-str">"+256700000000"</span>,
    <span class="c-key">"email"</span>: <span class="c-str">"john@example.com"</span>,
    <span class="c-key">"photo_url"</span>: <span class="c-str">"/API/student_photo.aspx?id=MRU/2023/001"</span>
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=photo&amp;token=...</div>
                        <div class="api-endpoint__info">Returns the student photo as a binary image (JPEG). Use in &lt;img&gt; tags.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=lock_status&amp;token=...</div>
                        <div class="api-endpoint__info">Check if the student account is locked (financial hold, exam hold, etc.).</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=summary&amp;token=...</div>
                        <div class="api-endpoint__info">Dashboard summary: GPA, balance, registered courses count, notices count.</div>
                    </div>
                </div>
            </div>

            <!-- Results -->
            <div class="api-section" id="student-results">
                <div class="api-section__header">
                    <div class="api-section__title">Academic Results</div>
                    <div class="api-section__desc">Access examination and coursework results</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=results&amp;token=...</div>
                        <div class="api-endpoint__info">Get all results for the authenticated student, grouped by academic year and semester.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Filter by academic year (e.g. 2025/2026). If omitted, returns all years.</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Filter by semester (1 or 2)</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=transcript&amp;token=...</div>
                        <div class="api-endpoint__info">Get a full academic transcript with cumulative GPA, credits earned, and classification.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=gpa&amp;token=...</div>
                        <div class="api-endpoint__info">Semester-by-semester GPA and cumulative GPA calculation.</div>
                    </div>
                </div>
            </div>

            <!-- Course Registration -->
            <div class="api-section" id="student-courses">
                <div class="api-section__header">
                    <div class="api-section__title">Course Registration</div>
                    <div class="api-section__desc">View available courses, register, and manage course list</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=available_courses&amp;token=...&amp;acad_year=...&amp;semester=...</div>
                        <div class="api-endpoint__info">List courses available for registration in the given semester.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year (e.g. 2025/2026)</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--required">Yes</td><td>Semester number</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=registered_courses&amp;token=...&amp;acad_year=...&amp;semester=...</div>
                        <div class="api-endpoint__info">List courses the student has registered for in the given semester.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/academic.aspx?action=register_course</div>
                        <div class="api-endpoint__info">Register for a course in the current semester.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>course_id</td><td>string</td><td class="api-param--required">Yes</td><td>Course code</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--required">Yes</td><td>Semester number</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--delete">DELETE</span> /API/v2/academic.aspx?action=drop_course</div>
                        <div class="api-endpoint__info">Remove a registered course (before deadline).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>registration_id</td><td>int</td><td class="api-param--required">Yes</td><td>Course registration ID to remove</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/academic.aspx?action=semester_registration</div>
                        <div class="api-endpoint__info">Complete semester registration (confirms enrollment, triggers billing).</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=registration_history&amp;token=...</div>
                        <div class="api-endpoint__info">View all past semester registrations with status.</div>
                    </div>
                </div>
            </div>

            <!-- Finance -->
            <div class="api-section" id="student-finance">
                <div class="api-section__header">
                    <div class="api-section__title">Finance / Fees</div>
                    <div class="api-section__desc">Fees ledger, balances, and payment history</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=ledger&amp;token=...</div>
                        <div class="api-endpoint__info">Full student fees ledger — all charges and payments.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"balance"</span>: <span class="c-num">-1250000</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"entries"</span>: [
      {
        <span class="c-key">"date"</span>: <span class="c-str">"2025-09-01"</span>,
        <span class="c-key">"description"</span>: <span class="c-str">"Tuition - Semester 1"</span>,
        <span class="c-key">"debit"</span>: <span class="c-num">2500000</span>,
        <span class="c-key">"credit"</span>: <span class="c-num">0</span>,
        <span class="c-key">"balance"</span>: <span class="c-num">2500000</span>
      },
      {
        <span class="c-key">"date"</span>: <span class="c-str">"2025-09-15"</span>,
        <span class="c-key">"description"</span>: <span class="c-str">"Payment - Bank Deposit"</span>,
        <span class="c-key">"debit"</span>: <span class="c-num">0</span>,
        <span class="c-key">"credit"</span>: <span class="c-num">1250000</span>,
        <span class="c-key">"balance"</span>: <span class="c-num">1250000</span>
      }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=balance&amp;token=...</div>
                        <div class="api-endpoint__info">Quick balance check — returns current outstanding balance only.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=fees_structure&amp;token=...</div>
                        <div class="api-endpoint__info">Get the fees structure for the student's programme and study year.</div>
                    </div>
                </div>
            </div>

            <!-- Timetable -->
            <div class="api-section" id="student-timetable">
                <div class="api-section__header">
                    <div class="api-section__title">Timetable</div>
                    <div class="api-section__desc">Lecture and examination schedules</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/timetable.aspx?action=lectures&amp;token=...</div>
                        <div class="api-endpoint__info">Get the lecture timetable for the student's registered courses.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Academic year (defaults to current)</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Semester (defaults to current)</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/timetable.aspx?action=exams&amp;token=...</div>
                        <div class="api-endpoint__info">Get the exam timetable for the student's registered courses.</div>
                    </div>
                </div>
            </div>

            <!-- Staff Profile -->
            <div class="api-section" id="staff-profile">
                <div class="api-section__header">
                    <div class="api-section__title">Staff Profile</div>
                    <div class="api-section__desc">Staff biographical and employment information</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=profile&amp;token=...</div>
                        <div class="api-endpoint__info">Get authenticated staff member's profile — name, department, title, contract details.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=photo&amp;token=...</div>
                        <div class="api-endpoint__info">Staff photo as binary image.</div>
                    </div>
                </div>
            </div>

            <!-- Staff Classes -->
            <div class="api-section" id="staff-classes">
                <div class="api-section__header">
                    <div class="api-section__title">Staff — My Classes</div>
                    <div class="api-section__desc">Teaching allocations, class lists, and attendance</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=my_courses&amp;token=...&amp;acad_year=...&amp;semester=...</div>
                        <div class="api-endpoint__info">Courses allocated to this lecturer in the given semester.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=class_list&amp;token=...&amp;course_id=...&amp;acad_year=...&amp;semester=...</div>
                        <div class="api-endpoint__info">List of students registered for a specific course.</div>
                    </div>
                </div>
            </div>

            <!-- Staff Grading -->
            <div class="api-section" id="staff-grading">
                <div class="api-section__header">
                    <div class="api-section__title">Staff — Grading</div>
                    <div class="api-section__desc">Submit and view coursework and exam marks</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=marks&amp;token=...&amp;course_id=...&amp;acad_year=...&amp;semester=...</div>
                        <div class="api-endpoint__info">Get existing coursework and exam marks for a course.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=submit_marks</div>
                        <div class="api-endpoint__info">Submit or update marks for students in a course. Accepts a JSON array of {regno, coursework, exam} objects.</div>
                    </div>
                </div>
            </div>

            <!-- Notices -->
            <div class="api-section" id="notices">
                <div class="api-section__header">
                    <div class="api-section__title">Notices &amp; Announcements</div>
                    <div class="api-section__desc">Campus-wide and targeted announcements</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=notices&amp;token=...</div>
                        <div class="api-endpoint__info">Get active notices and announcements. Supports pagination.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>page</td><td>int</td><td class="api-param--optional">No</td><td>Page number (default 1)</td></tr>
                            <tr><td>limit</td><td>int</td><td class="api-param--optional">No</td><td>Items per page (default 20, max 50)</td></tr>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Directory -->
            <div class="api-section" id="directory">
                <div class="api-section__header">
                    <div class="api-section__title">Directory</div>
                    <div class="api-section__desc">Staff and department directory</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=directory&amp;token=...&amp;category=...</div>
                        <div class="api-endpoint__info">Search the campus directory by category (department, faculty, admin, etc.).</div>
                    </div>
                </div>
            </div>

            <!-- Campus -->
            <div class="api-section" id="campus">
                <div class="api-section__header">
                    <div class="api-section__title">Campus Information</div>
                    <div class="api-section__desc">General campus data — academic years, programmes, campuses</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=academic_years</div>
                        <div class="api-endpoint__info">List all academic years. No auth required.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=current_semester</div>
                        <div class="api-endpoint__info">Current academic year and semester. No auth required.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=programmes</div>
                        <div class="api-endpoint__info">List all programmes offered. No auth required.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=campuses</div>
                        <div class="api-endpoint__info">List all campus locations. No auth required.</div>
                    </div>
                </div>
            </div>

            <!-- Roadmap -->
            <div class="api-section" id="roadmap">
                <div class="api-section__header">
                    <div class="api-section__title">Development Roadmap</div>
                    <div class="api-section__desc">Implementation progress for API v2 endpoints</div>
                </div>
                <div class="api-section__body">
                    <ul class="api-task-list" id="taskList"></ul>
                </div>
            </div>
        </main>
    </div>

    <script>
    (function(){
        // Count endpoint statuses
        var endpoints = document.querySelectorAll('.api-endpoint');
        var total = endpoints.length, live = 0, pending = 0;
        endpoints.forEach(function(el){
            var s = el.getAttribute('data-status');
            if(s === 'live') live++;
            else pending++;
        });
        document.getElementById('statTotal').textContent = total;
        document.getElementById('statLive').textContent = live;
        document.getElementById('statPending').textContent = pending;

        // Sidebar active on scroll
        var links = document.querySelectorAll('.api-sidebar__link');
        window.addEventListener('scroll', function(){
            var scrollPos = window.scrollY + 80;
            links.forEach(function(link){
                var href = link.getAttribute('href');
                if(!href || href.charAt(0) !== '#') return;
                var target = document.getElementById(href.substring(1));
                if(target && target.offsetTop <= scrollPos && (target.offsetTop + target.offsetHeight) > scrollPos){
                    links.forEach(function(l){ l.classList.remove('api-sidebar__link--active'); });
                    link.classList.add('api-sidebar__link--active');
                }
            });
        });

        // Roadmap tasks
        var tasks = [
            {name:'API Base Framework & Helper Classes', status:'done'},
            {name:'Token Manager & Database Table', status:'done'},
            {name:'Authentication (login/logout/validate)', status:'done'},
            {name:'Student Profile & Photo', status:'done'},
            {name:'Academic Results & Transcript', status:'done'},
            {name:'Course Registration (view/add/drop)', status:'done'},
            {name:'Semester Registration', status:'done'},
            {name:'Finance — Ledger & Balance', status:'done'},
            {name:'Timetable — Lectures & Exams', status:'done'},
            {name:'Staff Profile & Photo', status:'done'},
            {name:'Staff — My Courses & Class Lists', status:'done'},
            {name:'Staff — Grading (view/submit marks)', status:'done'},
            {name:'Notices & Announcements', status:'done'},
            {name:'Directory & Campus Info', status:'done'},
            {name:'API Documentation Page', status:'done'},
            {name:'End-to-End Testing & Validation', status:'done'}
        ];
        var ul = document.getElementById('taskList');
        tasks.forEach(function(t){
            var li = document.createElement('li');
            var dot = document.createElement('span');
            dot.className = 'api-status api-status--' + t.status;
            li.appendChild(dot);
            li.appendChild(document.createTextNode(t.name));
            ul.appendChild(li);
        });
    })();
    </script>
</body>
</html>
