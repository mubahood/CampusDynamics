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
            <div class="api-header__sub">RESTful API for Student &amp; Staff Mobile Applications &amp; ODEL/Moodle Integration</div>
            <div class="api-header__version">VERSION 2.3 — ADMISSIONS · RESIDENCE · APPRAISAL · SUPPORT · KNOWLEDGEBASE · CHART OF ACCOUNTS</div>
        </div>
    </div>
    <div class="api-layout">
        <aside class="api-sidebar">
            <nav class="api-sidebar__nav">
                <div class="api-sidebar__heading">Getting Started</div>
                <a href="#overview" class="api-sidebar__link api-sidebar__link--active">Overview</a>
                <a href="#authentication" class="api-sidebar__link">Authentication</a>
                <a href="#rate-limiting" class="api-sidebar__link">Rate Limiting</a>
                <a href="#errors" class="api-sidebar__link">Error Codes</a>
                <div class="api-sidebar__heading">Student Endpoints</div>
                <a href="#student-profile" class="api-sidebar__link">Profile &amp; Summary</a>
                <a href="#student-results" class="api-sidebar__link">Results &amp; GPA</a>
                <a href="#student-courses" class="api-sidebar__link">Course Registration</a>
                <a href="#student-idcard" class="api-sidebar__link">ID Card Status</a>
                <a href="#student-finance" class="api-sidebar__link">Finance / Fees</a>
                <a href="#student-timetable" class="api-sidebar__link">Timetable</a>
                <div class="api-sidebar__heading">Staff Endpoints</div>
                <a href="#staff-profile" class="api-sidebar__link">Staff Profile</a>
                <a href="#staff-classes" class="api-sidebar__link">My Classes</a>
                <a href="#staff-grading" class="api-sidebar__link">Grading</a>
                <a href="#staff-marks-workflow" class="api-sidebar__link">Marks Workflow</a>
                <div class="api-sidebar__heading">General</div>
                <a href="#notices" class="api-sidebar__link">Notices</a>
                <a href="#notices" class="api-sidebar__link api-sidebar__link--sub">↳ mark_read / notice_detail</a>
                <a href="#directory" class="api-sidebar__link">Directory</a>
                <a href="#campus" class="api-sidebar__link">Campus Info</a>
                <a href="#enrollment" class="api-sidebar__link">Enrollment</a>
                <div class="api-sidebar__heading">ODEL Integration</div>
                <a href="#odel-identity" class="api-sidebar__link">Identity &amp; Bulk Sync</a>
                <a href="#odel-academic" class="api-sidebar__link">Courses &amp; Curriculum</a>
                <a href="#odel-finance" class="api-sidebar__link">Fee Clearance</a>
                <a href="#fee-access" class="api-sidebar__link">Fee Access Policy</a>
                <a href="#odel-calendar" class="api-sidebar__link">Academic Calendar</a>
                <div class="api-sidebar__heading">v2.3 — New Modules</div>
                <a href="#support" class="api-sidebar__link">Support Tickets</a>
                <a href="#support" class="api-sidebar__link api-sidebar__link--sub">↳ list / detail / create / reply</a>
                <a href="#support" class="api-sidebar__link api-sidebar__link--sub">↳ update_status / close / stats / attachment</a>
                <a href="#knowledgebase" class="api-sidebar__link">Knowledgebase</a>
                <a href="#admissions" class="api-sidebar__link">Admissions (Staff)</a>
                <a href="#residence" class="api-sidebar__link">Residence</a>
                <a href="#appraisal" class="api-sidebar__link">Appraisal</a>
                <a href="#residence-finance" class="api-sidebar__link">Residence Finance</a>
                <a href="#chart-of-accounts" class="api-sidebar__link">Chart of Accounts</a>
                <a href="#provisional-marks" class="api-sidebar__link">Provisional Marks</a>
                <a href="#semester-deletion" class="api-sidebar__link">Semester Deletion</a>
                <a href="#hr-employees" class="api-sidebar__link">HR Employees</a>
                <a href="#onboarding" class="api-sidebar__link">Onboarding</a>
                <div class="api-sidebar__heading">v2.4 — Applications</div>
                <a href="#apply-auth" class="api-sidebar__link">Account &amp; Auth</a>
                <a href="#apply-wizard" class="api-sidebar__link">Application Wizard</a>
                <a href="#apply-documents" class="api-sidebar__link">Documents</a>
                <a href="#apply-notifications" class="api-sidebar__link">Notifications</a>
                <a href="#apply-public" class="api-sidebar__link">Public Data</a>
                <div class="api-sidebar__heading">Project</div>
                <a href="#changelog-v23" class="api-sidebar__link">Changelog v2.3</a>
                <a href="#changelog" class="api-sidebar__link">Changelog v2.2</a>
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
                    <div class="api-stat__num">v2.3</div>
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

                    <table class="api-endpoint__params" style="margin-bottom:14px;">
                        <tr><th>Item</th><th>Value</th></tr>
                        <tr><td>Base URL</td><td><code>https://eadmin.mru.ac.ug/API/v2/{endpoint}.aspx?action={action}</code></td></tr>
                        <tr><td>API Version</td><td>2.3 (returned in every response as <code>X-API-Version</code> header)</td></tr>
                        <tr><td>Format</td><td>JSON only — <code>Content-Type: application/json; charset=utf-8</code></td></tr>
                        <tr><td>Auth</td><td>Token via <code>?token=</code> query parameter (GET) or form body (POST)</td></tr>
                        <tr><td>Currency</td><td>All amounts in UGX (Ugandan Shilling) unless noted</td></tr>
                        <tr><td>Dates</td><td>ISO 8601 UTC timestamps in <code>timestamp</code> field; date fields as <code>YYYY-MM-DD</code></td></tr>
                        <tr><td>Allowed origins</td><td>eportal.mru.ac.ug, eadmin.mru.ac.ug, odel.mru.ac.ug (configured via CorsAllowedOrigins)</td></tr>
                    </table>

                    <div class="api-code"><span class="c-comm">// Success response envelope:</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"OK"</span>,
  <span class="c-key">"data"</span>: { ... },
  <span class="c-key">"timestamp"</span>: <span class="c-str">"2026-05-16T10:30:00.0000000Z"</span>
}

<span class="c-comm">// Error response envelope:</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">false</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Human-readable explanation"</span>,
  <span class="c-key">"error_code"</span>: <span class="c-str">"UPPER_SNAKE_ERROR_CODE"</span>,
  <span class="c-key">"data"</span>: <span class="c-num">null</span>,
  <span class="c-key">"timestamp"</span>: <span class="c-str">"2026-05-16T10:30:00.0000000Z"</span>
}</div>
                    <div class="api-note">All requests (except <code>login</code>, <code>ping</code>, and <code>grading_scheme</code>) require a <strong>token</strong> parameter. Obtain a token via <code>auth.aspx?action=login</code>. Pass it as <code>?token=...</code> on GET requests or in the POST body on POST requests.</div>
                </div>
            </div>

            <!-- Authentication -->
            <div class="api-section" id="authentication">
                <div class="api-section__header">
                    <div class="api-section__title">Authentication</div>
                    <div class="api-section__desc">Token-based authentication for all API access</div>
                </div>
                <div class="api-section__body">
                    <p style="font-size:13px;margin-bottom:12px;">The API uses token-based authentication. Call <code>login</code> with credentials, receive a token, then pass it on all subsequent requests as <code>?token=</code>. Tokens are long-lived (~10 years) by design — use <code>logout</code> or <code>refresh</code> to manage sessions. Up to 5 concurrent tokens are kept per user; the oldest is evicted when the limit is exceeded.</p>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/auth.aspx?action=login</div>
                        <div class="api-endpoint__info">Authenticate and receive an access token. The <code>username</code> field is resolved in this order: student registration number → student entry number → student email → staff username → staff email. Returns <code>user_type: "student"</code> or <code>"staff"</code>. Subject to stricter rate limiting (10/min per IP).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>username</td><td>string</td><td class="api-param--required">Yes</td><td>Reg number (MRU...), entry number (2024/AUG/...), email, or staff username</td></tr>
                            <tr><td>password</td><td>string</td><td class="api-param--required">Yes</td><td>Account password</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Request</span>
POST /API/v2/auth.aspx?action=login
Content-Type: application/x-www-form-urlencoded

username=MRU2025003204&amp;password=mypassword

<span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Login successful"</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"token"</span>: <span class="c-str">"a1b2c3d4e5f6..."</span>,
    <span class="c-key">"user_type"</span>: <span class="c-str">"student"</span>,
    <span class="c-key">"user_id"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"full_name"</span>: <span class="c-str">"JOHN DOE"</span>,
    <span class="c-key">"expires"</span>: <span class="c-str">"2036-05-16T10:30:00.0000000Z"</span>
  }
}</div>
                        <div class="api-note api-note--warn"><strong>Error codes:</strong> <code>AUTH_LOGIN_FAILED</code> — wrong credentials. <code>RATE_LIMITED</code> — too many attempts (HTTP 429).</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/auth.aspx?action=logout&amp;token=...</div>
                        <div class="api-endpoint__info">Immediately invalidate the supplied token. The token cannot be used again after logout.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Active token to invalidate</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/auth.aspx?action=validate&amp;token=...</div>
                        <div class="api-endpoint__info">Check whether a token is still valid without performing any other operation. Returns the user's identity fields on success.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"user_id"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"user_type"</span>: <span class="c-str">"student"</span>,
    <span class="c-key">"full_name"</span>: <span class="c-str">"JOHN DOE"</span>,
    <span class="c-key">"expires"</span>: <span class="c-str">"2036-05-16T10:30:00.0000000Z"</span>
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/auth.aspx?action=ping</div>
                        <div class="api-endpoint__info">Health check / connectivity test. No auth required. Performs a live DB check and reports <code>db_status: "ok"/"error"</code>.</div>
                        <div class="api-code"><span class="c-comm">// No authentication needed</span>
GET /API/v2/auth.aspx?action=ping

<span class="c-comm">// Response</span>
{
  <span class="c-key">"status"</span>: <span class="c-str">"success"</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"status"</span>: <span class="c-str">"ok"</span>,
    <span class="c-key">"db_status"</span>: <span class="c-str">"ok"</span>,
    <span class="c-key">"timestamp"</span>: <span class="c-str">"2026-04-08T10:30:00.0000000Z"</span>,
    <span class="c-key">"version"</span>: <span class="c-str">"2.1"</span>,
    <span class="c-key">"server"</span>: <span class="c-str">"CampusDynamics API v2"</span>
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/auth.aspx?action=refresh&amp;token=...</div>
                        <div class="api-endpoint__info">Exchange a valid token for a new one with a fresh expiry. The old token is immediately invalidated. Use this to extend sessions without re-authenticating. Returns <code>AUTH_INVALID_TOKEN</code> if the token is expired or the special system token.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"token"</span>: <span class="c-str">"new_token_here"</span>,
    <span class="c-key">"user_type"</span>: <span class="c-str">"student"</span>,
    <span class="c-key">"user_id"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"full_name"</span>: <span class="c-str">"John Doe"</span>,
    <span class="c-key">"expires"</span>: <span class="c-str">"2035-05-16T10:00:00.0000000Z"</span>
  }
}</div>
                    </div>
                </div>
            </div>

            <!-- Rate Limiting -->
            <div class="api-section" id="rate-limiting">
                <div class="api-section__header">
                    <div class="api-section__title">Rate Limiting</div>
                    <div class="api-section__desc">Sliding-window request limits per IP / token</div>
                </div>
                <div class="api-section__body">
                    <table class="api-endpoint__params" style="margin-bottom:14px;">
                        <tr><th>Endpoint Type</th><th>Limit</th><th>Window</th><th>Key</th></tr>
                        <tr><td><code>auth.aspx?action=login</code></td><td class="api-param--required">10 requests</td><td>per minute</td><td>per client IP address</td></tr>
                        <tr><td>All other endpoints</td><td>120 requests</td><td>per minute</td><td>per token (or IP if unauthenticated)</td></tr>
                    </table>
                    <p style="font-size:13px;margin-bottom:12px;">When the limit is exceeded the API returns HTTP <strong>429 Too Many Requests</strong> with <code>error_code: "RATE_LIMITED"</code> and a <code>Retry-After</code> header indicating how many seconds to wait before retrying.</p>
                    <div class="api-code"><span class="c-comm">// HTTP 429 response</span>
HTTP/1.1 429 Too Many Requests
Retry-After: 60

{
  <span class="c-key">"success"</span>: <span class="c-num">false</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Rate limit exceeded. Max 10 requests per 60 seconds."</span>,
  <span class="c-key">"error_code"</span>: <span class="c-str">"RATE_LIMITED"</span>,
  <span class="c-key">"data"</span>: <span class="c-num">null</span>
}</div>
                    <div class="api-note">Rate limiting state is held in the web server's in-process cache — it resets on IIS application pool recycle. If your integration calls multiple endpoints in rapid succession (e.g. Moodle bulk sync), consider adding a small delay between batches or using the dedicated bulk endpoints (<code>bulk_fee_check</code>, <code>bulk_enrollment</code>) to minimise individual call count.</div>
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
                        <tr><td>AUTH_INVALID_TOKEN</td><td>Token is expired, invalid, or cannot be refreshed</td></tr>
                        <tr><td>AUTH_LOGIN_FAILED</td><td>Invalid username or password</td></tr>
                        <tr><td>INVALID_ACTION</td><td>Unknown action parameter</td></tr>
                        <tr><td>INVALID_PARAM</td><td>A parameter value failed validation (e.g. bad acad_year format)</td></tr>
                        <tr><td>MISSING_PARAM</td><td>A required parameter is missing</td></tr>
                        <tr><td>NOT_FOUND</td><td>Requested record does not exist</td></tr>
                        <tr><td>ACCESS_DENIED</td><td>Token owner cannot access this resource</td></tr>
                        <tr><td>RATE_LIMITED</td><td>Too many requests — back off and retry after the Retry-After header value (seconds)</td></tr>
                        <tr><td>SEMESTER_CLOSED</td><td>The target semester is not open for registration (semester_registration action)</td></tr>
                        <tr><td>ALREADY_REGISTERED</td><td>Student is already registered for that course (register_course action)</td></tr>
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
                        <div class="api-endpoint__info">List courses available for registration in the given semester. Only returns courses with an Active status in the programme curriculum (<code>acad_programmecourses.status = 'Active'</code>).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year (e.g. 2025/2026)</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--required">Yes</td><td>Semester number</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>,
    <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
    <span class="c-key">"total"</span>: <span class="c-num">6</span>,
    <span class="c-key">"courses"</span>: [
      {
        <span class="c-key">"course_code"</span>: <span class="c-str">"CSC201"</span>,
        <span class="c-key">"course_name"</span>: <span class="c-str">"Data Structures &amp; Algorithms"</span>,
        <span class="c-key">"credit_units"</span>: <span class="c-str">"4"</span>,
        <span class="c-key">"course_type"</span>: <span class="c-str">"Core"</span>,
        <span class="c-key">"study_year"</span>: <span class="c-str">"2"</span>,
        <span class="c-key">"status"</span>: <span class="c-str">"Active"</span>
      }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=registered_courses&amp;token=...&amp;acad_year=...&amp;semester=...</div>
                        <div class="api-endpoint__info">List courses the student has already registered for in the given semester. Uses a LEFT JOIN against the course catalogue so registrations are always returned even if the course record is missing. The <code>ID</code> field is the registration record ID needed for <code>drop_course</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year (e.g. 2025/2026)</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--required">Yes</td><td>Semester number</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response — data is an array of registration objects</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: [
    {
      <span class="c-key">"ID"</span>: <span class="c-num">4821</span>,
      <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025000123"</span>,
      <span class="c-key">"courseID"</span>: <span class="c-str">"CSC201"</span>,
      <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>,
      <span class="c-key">"semester"</span>: <span class="c-num">2</span>,
      <span class="c-key">"course_status"</span>: <span class="c-str">"REGULAR"</span>,
      <span class="c-key">"prog_id"</span>: <span class="c-str">"BBAM"</span>,
      <span class="c-key">"stud_session"</span>: <span class="c-str">"DAY"</span>,
      <span class="c-key">"courseName"</span>: <span class="c-str">"Data Structures &amp; Algorithms"</span>,
      <span class="c-key">"creditUnit"</span>: <span class="c-num">4</span>
    }
  ]
}

<span class="c-comm">// Empty array [] when no registrations found for the period (not an error)</span></div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/academic.aspx?action=register_course</div>
                        <div class="api-endpoint__info">Register for a single course in the specified semester. Returns <code>ALREADY_REGISTERED</code> if the student has already registered for this course in the same semester.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>course_id</td><td>string</td><td class="api-param--required">Yes</td><td>Course code to register for</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--required">Yes</td><td>Semester number</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Success response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Course CSC201 registered successfully."</span>,
  <span class="c-key">"data"</span>: { <span class="c-key">"course_id"</span>: <span class="c-str">"CSC201"</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-num">1</span> }
}

<span class="c-comm">// Already registered error (HTTP 400)</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">false</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"You are already registered for this course."</span>,
  <span class="c-key">"error_code"</span>: <span class="c-str">"ALREADY_REGISTERED"</span>,
  <span class="c-key">"data"</span>: <span class="c-num">null</span>
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--delete">DELETE</span> /API/v2/academic.aspx?action=drop_course</div>
                        <div class="api-endpoint__info">Remove a registered course before the add/drop deadline. Use the <code>registration_id</code> from the <code>registered_courses</code> response.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>registration_id</td><td>int</td><td class="api-param--required">Yes</td><td>Course registration record ID to remove</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Course dropped successfully."</span>,
  <span class="c-key">"data"</span>: { <span class="c-key">"registration_id"</span>: <span class="c-num">4821</span> }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/academic.aspx?action=semester_registration</div>
                        <div class="api-endpoint__info">Confirm enrollment for a semester (triggers billing via <code>fin_Autobilling</code> stored procedure). The student's <code>billingID</code> is automatically resolved from their profile. Returns <code>SEMESTER_CLOSED</code> if the target semester is not open.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year to register for</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--required">Yes</td><td>Semester number (1, 2, or 3)</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Success response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Semester registration completed successfully."</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>,
    <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
    <span class="c-key">"registration_date"</span>: <span class="c-str">"2025-09-10"</span>
  }
}

<span class="c-comm">// Semester closed error (HTTP 400)</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">false</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Registration for Semester 2 is currently closed."</span>,
  <span class="c-key">"error_code"</span>: <span class="c-str">"SEMESTER_CLOSED"</span>,
  <span class="c-key">"data"</span>: <span class="c-num">null</span>
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=registration_history&amp;token=...</div>
                        <div class="api-endpoint__info">Full history of all past semester registrations. Each entry includes <code>status_label</code> (human-friendly) and <code>is_active_registration</code> (boolean) covering all statuses: REGISTERED, LATE REGISTERED, CLEARED, HALTED, DEAD YEAR, DISCONTINUED, UNREGISTERED.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"total"</span>: <span class="c-num">3</span>,
    <span class="c-key">"registrations"</span>: [
      {
        <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>,
        <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>,
        <span class="c-key">"reg_status"</span>: <span class="c-str">"REGISTERED"</span>,
        <span class="c-key">"status_label"</span>: <span class="c-str">"Registered"</span>,
        <span class="c-key">"is_active_registration"</span>: <span class="c-num">true</span>,
        <span class="c-key">"registration_date"</span>: <span class="c-str">"2025-09-10"</span>
      },
      {
        <span class="c-key">"acad_year"</span>: <span class="c-str">"2024/2025"</span>,
        <span class="c-key">"semester"</span>: <span class="c-str">"2"</span>,
        <span class="c-key">"reg_status"</span>: <span class="c-str">"CLEARED"</span>,
        <span class="c-key">"status_label"</span>: <span class="c-str">"Cleared"</span>,
        <span class="c-key">"is_active_registration"</span>: <span class="c-num">true</span>,
        <span class="c-key">"registration_date"</span>: <span class="c-str">"2025-02-14"</span>
      },
      {
        <span class="c-key">"acad_year"</span>: <span class="c-str">"2024/2025"</span>,
        <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>,
        <span class="c-key">"reg_status"</span>: <span class="c-str">"LATE REGISTERED"</span>,
        <span class="c-key">"status_label"</span>: <span class="c-str">"Late Registered"</span>,
        <span class="c-key">"is_active_registration"</span>: <span class="c-num">true</span>,
        <span class="c-key">"registration_date"</span>: <span class="c-str">"2024-10-01"</span>
      }
    ]
  }
}
<span class="c-comm">// is_active_registration: true for REGISTERED, LATE REGISTERED, CLEARED, ACTIVE
// false for HALTED, DEAD YEAR, DISCONTINUED, UNREGISTERED</span></div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/academic.aspx?action=semester_status&amp;token=...&amp;acad_year=...</div>
                        <div class="api-endpoint__info">Returns the open/closed status of each semester (1, 2, 3) for the given academic year based on <code>acad_acadyears.semester_X_is_active</code>. Omit <code>acad_year</code> to get the 5 most recent years. Use this to show or hide registration UI elements.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Specific year (e.g. 2025/2026). Omit for last 5 years.</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: [
    {
      <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>,
      <span class="c-key">"semesters"</span>: {
        <span class="c-key">"1"</span>: { <span class="c-key">"is_open"</span>: <span class="c-num">true</span>,  <span class="c-key">"label"</span>: <span class="c-str">"Open"</span>   },
        <span class="c-key">"2"</span>: { <span class="c-key">"is_open"</span>: <span class="c-num">false</span>, <span class="c-key">"label"</span>: <span class="c-str">"Closed"</span> },
        <span class="c-key">"3"</span>: { <span class="c-key">"is_open"</span>: <span class="c-num">false</span>, <span class="c-key">"label"</span>: <span class="c-str">"Closed"</span> }
      }
    }
  ]
}</div>
                        <div class="api-note"><code>is_open: true</code> means registration is active for that semester — used by the portal and mobile app to enable the registration button. The gate is enforced server-side too: <code>semester_registration</code> returns <code>SEMESTER_CLOSED</code> if <code>is_open</code> is false.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/academic.aspx?action=retake_courses&amp;token=...</div>
                        <div class="api-endpoint__info">Lists courses where the student's most recent attempt resulted in a failing grade (F or E). Identifies retakeable courses by scanning all results and tracking the latest grade per course code.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"total"</span>: <span class="c-num">2</span>,
    <span class="c-key">"retake_courses"</span>: [
      {
        <span class="c-key">"course_code"</span>: <span class="c-str">"MTH201"</span>,
        <span class="c-key">"course_name"</span>: <span class="c-str">"Advanced Calculus"</span>,
        <span class="c-key">"last_grade"</span>: <span class="c-str">"F"</span>,
        <span class="c-key">"last_acad_year"</span>: <span class="c-str">"2024/2025"</span>,
        <span class="c-key">"last_semester"</span>: <span class="c-str">"1"</span>,
        <span class="c-key">"attempts"</span>: <span class="c-num">1</span>
      },
      {
        <span class="c-key">"course_code"</span>: <span class="c-str">"CSC105"</span>,
        <span class="c-key">"course_name"</span>: <span class="c-str">"Computer Organisation"</span>,
        <span class="c-key">"last_grade"</span>: <span class="c-str">"E"</span>,
        <span class="c-key">"last_acad_year"</span>: <span class="c-str">"2024/2025"</span>,
        <span class="c-key">"last_semester"</span>: <span class="c-str">"2"</span>,
        <span class="c-key">"attempts"</span>: <span class="c-num">2</span>
      }
    ]
  }
}
<span class="c-comm">// Courses where a subsequent passing grade exists are excluded — only current-fails are returned</span></div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/academic.aspx?action=student_academic_summary&amp;token=...</div>
                        <div class="api-endpoint__info">Single-call comprehensive academic snapshot. Returns student profile, CGPA (computed via <code>AcademicEngine.ComputeGPA()</code>), latest registration state, enrollment flag, and retake course list. Replaces separate calls to <code>gpa</code> + <code>registration_history</code> + <code>retake_courses</code>. Staff can pass <code>?regno=</code>.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"student"</span>: {
      <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>, <span class="c-key">"firstname"</span>: <span class="c-str">"Jane"</span>,
      <span class="c-key">"programme"</span>: <span class="c-str">"BSc Computer Science"</span>, <span class="c-key">"entry_year"</span>: <span class="c-str">"2022"</span>
    },
    <span class="c-key">"gpa"</span>: {
      <span class="c-key">"cgpa"</span>: <span class="c-num">3.75</span>, <span class="c-key">"total_credits"</span>: <span class="c-num">120</span>,
      <span class="c-key">"classification"</span>: <span class="c-str">"Second Class Upper"</span>,
      <span class="c-key">"semesters"</span>: [
        { <span class="c-key">"acad_year"</span>: <span class="c-str">"2022/2023"</span>, <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"gpa"</span>: <span class="c-num">3.6</span>, <span class="c-key">"credits"</span>: <span class="c-num">18</span> },
        { <span class="c-key">"acad_year"</span>: <span class="c-str">"2022/2023"</span>, <span class="c-key">"semester"</span>: <span class="c-str">"2"</span>, <span class="c-key">"gpa"</span>: <span class="c-num">3.9</span>, <span class="c-key">"credits"</span>: <span class="c-num">18</span> }
      ]
    },
    <span class="c-key">"registration"</span>: {
      <span class="c-key">"is_currently_enrolled"</span>: <span class="c-num">true</span>,
      <span class="c-key">"history_count"</span>: <span class="c-num">8</span>,
      <span class="c-key">"latest"</span>: {
        <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
        <span class="c-key">"status"</span>: <span class="c-str">"REGISTERED"</span>, <span class="c-key">"status_label"</span>: <span class="c-str">"Registered"</span>,
        <span class="c-key">"is_active"</span>: <span class="c-num">true</span>, <span class="c-key">"study_year"</span>: <span class="c-str">"4"</span>
      }
    },
    <span class="c-key">"retake"</span>: { <span class="c-key">"total_retakable"</span>: <span class="c-num">0</span>, <span class="c-key">"courses"</span>: [] }
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/academic.aspx?action=academic_standing&amp;token=...</div>
                        <div class="api-endpoint__info">Evaluates whether the student is in good academic standing. Runs three server-side checks: minimum CGPA (≥ 2.0), active enrollment, and outstanding fail count. Returns a boolean verdict and a <code>checks</code> array so the client can show granular feedback. Analogous to <code>access_status</code> but for academic — not financial — standing. Staff can pass <code>?regno=</code>.</div>
                        <div class="api-code"><span class="c-comm">// Response — student in good standing</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"has_good_standing"</span>: <span class="c-num">true</span>,
    <span class="c-key">"verdict"</span>: <span class="c-str">"good_standing"</span>,
    <span class="c-key">"verdict_reason"</span>: <span class="c-str">"3/3 standing checks passed."</span>,
    <span class="c-key">"checks"</span>: [
      {
        <span class="c-key">"rule"</span>: <span class="c-str">"Minimum GPA"</span>, <span class="c-key">"passed"</span>: <span class="c-num">true</span>,
        <span class="c-key">"threshold"</span>: <span class="c-str">"CGPA ≥ 2.0"</span>, <span class="c-key">"actual_value"</span>: <span class="c-str">"3.75"</span>,
        <span class="c-key">"detail"</span>: <span class="c-str">"CGPA 3.75 meets minimum of 2.0."</span>
      },
      {
        <span class="c-key">"rule"</span>: <span class="c-str">"Active Enrollment"</span>, <span class="c-key">"passed"</span>: <span class="c-num">true</span>,
        <span class="c-key">"threshold"</span>: <span class="c-str">"At least one active registration"</span>,
        <span class="c-key">"actual_value"</span>: <span class="c-str">"Registered"</span>,
        <span class="c-key">"detail"</span>: <span class="c-str">"Active registration found (2025/2026)."</span>
      },
      {
        <span class="c-key">"rule"</span>: <span class="c-str">"Outstanding Fails"</span>, <span class="c-key">"passed"</span>: <span class="c-num">true</span>,
        <span class="c-key">"threshold"</span>: <span class="c-str">"Fewer than 3 retakable courses"</span>,
        <span class="c-key">"actual_value"</span>: <span class="c-str">"0 course(s)"</span>,
        <span class="c-key">"detail"</span>: <span class="c-str">"0 retakable course(s) — within acceptable range."</span>
      }
    ],
    <span class="c-key">"gpa"</span>: { <span class="c-key">"cgpa"</span>: <span class="c-num">3.75</span>, <span class="c-key">"classification"</span>: <span class="c-str">"Second Class Upper"</span>, <span class="c-key">"total_credits"</span>: <span class="c-num">120</span> },
    <span class="c-key">"retake_summary"</span>: { <span class="c-key">"total_retakable"</span>: <span class="c-num">0</span>, <span class="c-key">"courses"</span>: [] },
    <span class="c-key">"evaluated_at"</span>: <span class="c-str">"2026-05-16T09:00:00Z"</span>
  }
}

<span class="c-comm">// Response — student on academic probation</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"has_good_standing"</span>: <span class="c-num">false</span>,
    <span class="c-key">"verdict"</span>: <span class="c-str">"academic_probation"</span>,
    <span class="c-key">"verdict_reason"</span>: <span class="c-str">"1/3 standing checks passed."</span>,
    <span class="c-key">"checks"</span>: [
      { <span class="c-key">"rule"</span>: <span class="c-str">"Minimum GPA"</span>, <span class="c-key">"passed"</span>: <span class="c-num">false</span>, <span class="c-key">"actual_value"</span>: <span class="c-str">"1.85"</span>,
        <span class="c-key">"detail"</span>: <span class="c-str">"CGPA 1.85 is below the required minimum of 2.0."</span> },
      { <span class="c-key">"rule"</span>: <span class="c-str">"Active Enrollment"</span>, <span class="c-key">"passed"</span>: <span class="c-num">false</span>,
        <span class="c-key">"detail"</span>: <span class="c-str">"No active registration. Last status: Halted."</span> },
      { <span class="c-key">"rule"</span>: <span class="c-str">"Outstanding Fails"</span>, <span class="c-key">"passed"</span>: <span class="c-num">true</span>, <span class="c-key">"actual_value"</span>: <span class="c-str">"2 course(s)"</span>,
        <span class="c-key">"detail"</span>: <span class="c-str">"2 retakable course(s) — within acceptable range."</span> }
    ]
  }
}</div>
                        <div class="api-note">Good standing requires both <strong>minimum GPA</strong> AND <strong>active enrollment</strong> to pass. The outstanding-fails check is informational — it adds a warning flag when ≥ 3 retakable courses exist but does not by itself revoke good standing.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/student.aspx?action=bulk_enrollment&amp;token=...&amp;regnos=MRU001,MRU002</div>
                        <div class="api-endpoint__info"><strong>Staff only.</strong> Batch enrollment status lookup — up to 500 students per call. Returns profile, programme, most-recent registration, and <code>is_enrolled</code> flag per student. Lists unrecognised regnos in a <code>not_found</code> array. Designed for Moodle bulk sync. Can also POST raw comma-separated regnos in the request body.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token (staff only)</td></tr>
                            <tr><td>regnos</td><td>string</td><td class="api-param--required">Yes</td><td>Comma-separated registration numbers (max 500)</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// GET ?regnos=MRU2025003204,MRU2025003205,INVALID999</span>
GET /API/v2/student.aspx?action=bulk_enrollment&amp;token=...&amp;regnos=MRU2025003204,MRU2025003205,INVALID999

<span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total_requested"</span>: <span class="c-num">3</span>,
    <span class="c-key">"total_found"</span>: <span class="c-num">2</span>,
    <span class="c-key">"not_found"</span>: [<span class="c-str">"INVALID999"</span>],
    <span class="c-key">"students"</span>: [
      {
        <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
        <span class="c-key">"firstname"</span>: <span class="c-str">"JOHN"</span>,
        <span class="c-key">"surname"</span>: <span class="c-str">"DOE"</span>,
        <span class="c-key">"programme"</span>: <span class="c-str">"BACHELOR OF SCIENCE IN COMPUTER SCIENCE"</span>,
        <span class="c-key">"progcode"</span>: <span class="c-str">"BSC-CS"</span>,
        <span class="c-key">"last_reg_year"</span>: <span class="c-str">"2025/2026"</span>,
        <span class="c-key">"last_reg_semester"</span>: <span class="c-str">"1"</span>,
        <span class="c-key">"last_reg_status"</span>: <span class="c-str">"REGISTERED"</span>,
        <span class="c-key">"enrollment_status_label"</span>: <span class="c-str">"Registered"</span>,
        <span class="c-key">"is_enrolled"</span>: <span class="c-num">true</span>
      },
      {
        <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003205"</span>,
        <span class="c-key">"firstname"</span>: <span class="c-str">"JANE"</span>,
        <span class="c-key">"surname"</span>: <span class="c-str">"SMITH"</span>,
        <span class="c-key">"programme"</span>: <span class="c-str">"BACHELOR OF ARTS IN ECONOMICS"</span>,
        <span class="c-key">"progcode"</span>: <span class="c-str">"BAE"</span>,
        <span class="c-key">"last_reg_year"</span>: <span class="c-str">"2024/2025"</span>,
        <span class="c-key">"last_reg_semester"</span>: <span class="c-str">"2"</span>,
        <span class="c-key">"last_reg_status"</span>: <span class="c-str">"DISCONTINUED"</span>,
        <span class="c-key">"enrollment_status_label"</span>: <span class="c-str">"Discontinued"</span>,
        <span class="c-key">"is_enrolled"</span>: <span class="c-num">false</span>
      }
    ]
  }
}
<span class="c-comm">// POST alternative: send raw CSV in request body (Content-Type: text/plain)</span>
<span class="c-comm">// MRU2025003204,MRU2025003205</span></div>
                        <div class="api-note"><strong>Rate limiting:</strong> This endpoint counts as one request against the 120/min limit regardless of how many regnos are in the batch — use it instead of looping <code>enrollment_status</code> calls.</div>
                    </div>
                </div>
            </div>

            <!-- ID Card -->
            <div class="api-section" id="student-idcard">
                <div class="api-section__header">
                    <div class="api-section__title">ID Card Printing Status</div>
                    <div class="api-section__desc">OmniPass integration — live or cached card printing status — <code>student.aspx?action=id_card</code></div>
                </div>
                <div class="api-section__body">
                    <div class="api-note" style="margin-bottom:16px;">
                        Status is cached for <strong>6 hours</strong> in <code>acad_student.id_card_status</code>.
                        Pass <code>&amp;refresh=1</code> to bypass the cache and call OmniPass live.
                        Students always see their own card; staff pass <code>&amp;regno=</code> to query any student.
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> student.aspx?action=<strong>id_card</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Returns card printing status from OmniPass. Optional param: <code>refresh=1</code> (force live API call).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>regno</td><td>string</td><td class="api-param--optional">Staff only</td><td>Student reg number. Students always get their own card.</td></tr>
                            <tr><td>refresh</td><td>0/1</td><td class="api-param--optional">No</td><td>Pass <code>1</code> to bypass 6-hour cache and call OmniPass live.</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// status values: PRINTED | NOT_PRINTED | NOT_FOUND | ERROR | UNKNOWN</span>
{
  <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
  <span class="c-key">"status"</span>: <span class="c-str">"PRINTED"</span>,
  <span class="c-key">"status_label"</span>: <span class="c-str">"Printed"</span>,
  <span class="c-key">"card_printed"</span>: <span class="c-key">true</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"ID card has been printed and is ready for collection."</span>,
  <span class="c-key">"collection_note"</span>: <span class="c-str">"Your ID card is ready. Please visit the Student Services office..."</span>,
  <span class="c-key">"checked_at"</span>: <span class="c-str">"2026-05-24 08:15"</span>,
  <span class="c-key">"from_cache"</span>: <span class="c-key">true</span>,
  <span class="c-key">"card_record"</span>: {
    <span class="c-key">"card_id"</span>: <span class="c-num">412</span>,
    <span class="c-key">"card_type"</span>: <span class="c-str">"STUDENT"</span>,
    <span class="c-key">"print_status"</span>: <span class="c-str">"PRINTED"</span>,
    <span class="c-key">"expiry_date"</span>: <span class="c-str">"2027-08-31"</span>,
    <span class="c-key">"acadyear"</span>: <span class="c-str">"2026/2027"</span>
  }
}</div>
                        <div class="api-note">
                            <code>card_record</code> is <code>null</code> if no <code>acad_student_cards</code> row exists.
                            <code>collection_note</code> is a ready-to-display string for the student UI.
                        </div>
                    </div>
                </div>
            </div>

            <!-- Finance -->
            <div class="api-section" id="student-finance">
                <div class="api-section__header">
                    <div class="api-section__title">Finance / Fees</div>
                    <div class="api-section__desc">Fees ledger, balances, payment history, billing breakdown, and waivers — all sourced from the dual General Ledger (fin_ledger + fin_studentfeestracking)</div>
                </div>
                <div class="api-section__body">
                    <div class="api-note"><strong>Dual-source ledger:</strong> All balance and ledger data is computed from both <code>fin_ledger</code> (GL) and <code>fin_studentfeestracking</code> (audit trail) using a UNION ALL with deduplication. Only <code>post_status = 'Posted'</code> entries are included — pending/unconfirmed transactions are excluded. Balance sign convention: <strong>positive = student owes money</strong>.</div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=ledger&amp;token=...</div>
                        <div class="api-endpoint__info">Full student fees ledger with running balance per row. Paginated — defaults to page 1, 50 entries. Staff can query any student with <code>?regno=</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>regno</td><td>string</td><td class="api-param--optional">Staff only</td><td>Student reg number</td></tr>
                            <tr><td>page</td><td>int</td><td class="api-param--optional">No</td><td>Page number (default 1)</td></tr>
                            <tr><td>limit</td><td>int</td><td class="api-param--optional">No</td><td>Entries per page (default 50, max 200)</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"balance"</span>: <span class="c-num">1250000</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"total_entries"</span>: <span class="c-num">12</span>,
    <span class="c-key">"page"</span>: <span class="c-num">1</span>,
    <span class="c-key">"total_pages"</span>: <span class="c-num">1</span>,
    <span class="c-key">"limit"</span>: <span class="c-num">50</span>,
    <span class="c-key">"entries"</span>: [
      {
        <span class="c-key">"date"</span>: <span class="c-str">"2025-09-01"</span>,
        <span class="c-key">"description"</span>: <span class="c-str">"Tuition - Semester 1 2025/2026"</span>,
        <span class="c-key">"debit"</span>: <span class="c-num">2500000</span>,
        <span class="c-key">"credit"</span>: <span class="c-num">0</span>,
        <span class="c-key">"running_balance"</span>: <span class="c-num">2500000</span>
      },
      {
        <span class="c-key">"date"</span>: <span class="c-str">"2025-09-15"</span>,
        <span class="c-key">"description"</span>: <span class="c-str">"Payment - Bank Deposit"</span>,
        <span class="c-key">"debit"</span>: <span class="c-num">0</span>,
        <span class="c-key">"credit"</span>: <span class="c-num">1250000</span>,
        <span class="c-key">"running_balance"</span>: <span class="c-num">1250000</span>
      }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=balance&amp;token=...</div>
                        <div class="api-endpoint__info">Quick single-value balance check. Returns current outstanding balance, total billed, total paid, last payment date, and currency.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"balance"</span>: <span class="c-num">1250000</span>,
    <span class="c-key">"total_billed"</span>: <span class="c-num">2500000</span>,
    <span class="c-key">"total_paid"</span>: <span class="c-num">1250000</span>,
    <span class="c-key">"last_payment_date"</span>: <span class="c-str">"2025-09-15"</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=fees_structure&amp;token=...</div>
                        <div class="api-endpoint__info">Returns the student's fees for all registered periods. Two-source lookup: (1) <strong>billed</strong> — actual charges from <code>fin_studentfeestracking</code> joined with <code>academicbillingitems</code> for item names, grouped by acad_year/semester/item; (2) <strong>programme_fees</strong> — fallback when not yet billed, reads <code>fin_programme_fees</code> wide-format columns for the student's study year. <code>fees_source</code> tells which path was used. No parameters required beyond token.</div>
                        <div class="api-code"><span class="c-comm">// Response — fees_source: "billed" when fin_Autobilling has already run</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"programme_code"</span>: <span class="c-str">"BBAM"</span>,
    <span class="c-key">"study_year"</span>: <span class="c-num">1</span>,
    <span class="c-key">"fee_category"</span>: <span class="c-str">"Ugandan"</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"total_fees"</span>: <span class="c-num">2150000</span>,
    <span class="c-key">"fees_source"</span>: <span class="c-str">"billed"</span>,
    <span class="c-key">"items"</span>: [
      { <span class="c-key">"item"</span>: <span class="c-str">"1"</span>,  <span class="c-key">"item_name"</span>: <span class="c-str">"Tuition"</span>,          <span class="c-key">"amount"</span>: <span class="c-num">1800000</span>, <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span> },
      { <span class="c-key">"item"</span>: <span class="c-str">"52"</span>, <span class="c-key">"item_name"</span>: <span class="c-str">"Functional Fees"</span>, <span class="c-key">"amount"</span>: <span class="c-num">300000</span>,  <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span> },
      { <span class="c-key">"item"</span>: <span class="c-str">"3"</span>,  <span class="c-key">"item_name"</span>: <span class="c-str">"Medical Fee"</span>,      <span class="c-key">"amount"</span>: <span class="c-num">50000</span>,   <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span> }
    ]
  }
}

<span class="c-comm">// fees_source: "programme_fees" — not yet billed; tuition+functional from fin_programme_fees</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"programme_code"</span>: <span class="c-str">"BBAM"</span>,
    <span class="c-key">"study_year"</span>: <span class="c-num">1</span>,
    <span class="c-key">"fee_category"</span>: <span class="c-str">"Ugandan"</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"total_fees"</span>: <span class="c-num">4100000</span>,
    <span class="c-key">"fees_source"</span>: <span class="c-str">"programme_fees"</span>,
    <span class="c-key">"items"</span>: [
      { <span class="c-key">"item"</span>: <span class="c-str">"TUITION_S1"</span>,    <span class="c-key">"item_name"</span>: <span class="c-str">"Tuition Fees"</span>,    <span class="c-key">"amount"</span>: <span class="c-num">1800000</span>, <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">""</span> },
      { <span class="c-key">"item"</span>: <span class="c-str">"FUNCTIONAL_S1"</span>, <span class="c-key">"item_name"</span>: <span class="c-str">"Functional Fees"</span>, <span class="c-key">"amount"</span>: <span class="c-num">250000</span>,  <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">""</span> },
      { <span class="c-key">"item"</span>: <span class="c-str">"TUITION_S2"</span>,    <span class="c-key">"item_name"</span>: <span class="c-str">"Tuition Fees"</span>,    <span class="c-key">"amount"</span>: <span class="c-num">1800000</span>, <span class="c-key">"semester"</span>: <span class="c-str">"2"</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">""</span> },
      { <span class="c-key">"item"</span>: <span class="c-str">"FUNCTIONAL_S2"</span>, <span class="c-key">"item_name"</span>: <span class="c-str">"Functional Fees"</span>, <span class="c-key">"amount"</span>: <span class="c-num">250000</span>,  <span class="c-key">"semester"</span>: <span class="c-str">"2"</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">""</span> }
    ]
  }
}

<span class="c-comm">// fees_source: "not_found" — programme has no fees configured and student has no billing records</span></div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=payment_history&amp;token=...</div>
                        <div class="api-endpoint__info">Payment receipts only — filters the dual ledger to credit (payment) entries. Returns <code>total_paid</code>, payment count, and each payment with date, amount, and description.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total_paid"</span>: <span class="c-num">1250000</span>,
    <span class="c-key">"payment_count"</span>: <span class="c-num">2</span>,
    <span class="c-key">"last_payment"</span>: <span class="c-str">"2025-09-15"</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"payments"</span>: [
      { <span class="c-key">"date"</span>: <span class="c-str">"2025-09-01"</span>, <span class="c-key">"amount"</span>: <span class="c-num">750000</span>, <span class="c-key">"description"</span>: <span class="c-str">"Bank Deposit - Centenary Bank"</span> },
      { <span class="c-key">"date"</span>: <span class="c-str">"2025-09-15"</span>, <span class="c-key">"amount"</span>: <span class="c-num">500000</span>, <span class="c-key">"description"</span>: <span class="c-str">"Mobile Money Payment"</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=billing_summary&amp;token=...</div>
                        <div class="api-endpoint__info">Billing summary grouped by academic year and semester period — total charges vs payments per period, plus cumulative balance.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"overall_balance"</span>: <span class="c-num">1000000</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"periods"</span>: [
      { <span class="c-key">"period"</span>: <span class="c-str">"2024/2025_S1"</span>, <span class="c-key">"charges"</span>: <span class="c-num">1750000</span>, <span class="c-key">"payments"</span>: <span class="c-num">1500000</span>, <span class="c-key">"balance"</span>: <span class="c-num">250000</span> },
      { <span class="c-key">"period"</span>: <span class="c-str">"2024/2025_S2"</span>, <span class="c-key">"charges"</span>: <span class="c-num">1750000</span>, <span class="c-key">"payments"</span>: <span class="c-num">1000000</span>, <span class="c-key">"balance"</span>: <span class="c-num">750000</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/finance.aspx?action=billing_breakdown&amp;token=...</div>
                        <div class="api-endpoint__info">Full billing breakdown per semester including waivers. Goes deeper than <code>billing_summary</code> — merges waiver amounts from <code>fin_bill_waiver_items</code> per period. Best used for detailed statements and reconciliation.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"grand_total_billed"</span>: <span class="c-num">3500000</span>,
    <span class="c-key">"grand_total_paid"</span>: <span class="c-num">2500000</span>,
    <span class="c-key">"grand_total_waived"</span>: <span class="c-num">400000</span>,
    <span class="c-key">"grand_net_balance"</span>: <span class="c-num">600000</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"breakdown"</span>: [
      {
        <span class="c-key">"period"</span>: <span class="c-str">"2025/2026_S1"</span>,
        <span class="c-key">"total_billed"</span>: <span class="c-num">2500000</span>,
        <span class="c-key">"total_paid"</span>: <span class="c-num">1800000</span>,
        <span class="c-key">"total_waived"</span>: <span class="c-num">200000</span>,
        <span class="c-key">"net_balance"</span>: <span class="c-num">500000</span>
      }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/finance.aspx?action=waivers&amp;token=...</div>
                        <div class="api-endpoint__info">All approved fee waivers for the student with their line items. Queries <code>fin_bill_waivers</code> (header) and <code>fin_bill_waiver_items</code> (line items). Returns <code>total_waived</code> as a summary figure.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total_waived"</span>: <span class="c-num">450000</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"waivers"</span>: [
      {
        <span class="c-key">"waiver_id"</span>: <span class="c-num">12</span>,
        <span class="c-key">"category"</span>: <span class="c-str">"Bursary Waiver"</span>,
        <span class="c-key">"status"</span>: <span class="c-str">"Active"</span>,
        <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>,
        <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
        <span class="c-key">"created_at"</span>: <span class="c-str">"2025-09-10"</span>,
        <span class="c-key">"total_amount"</span>: <span class="c-num">450000</span>,
        <span class="c-key">"items"</span>: [
          { <span class="c-key">"item_code"</span>: <span class="c-num">1</span>, <span class="c-key">"item_name"</span>: <span class="c-str">"Tuition"</span>, <span class="c-key">"amount"</span>: <span class="c-num">400000</span> },
          { <span class="c-key">"item_code"</span>: <span class="c-num">52</span>, <span class="c-key">"item_name"</span>: <span class="c-str">"Functional Fees"</span>, <span class="c-key">"amount"</span>: <span class="c-num">50000</span> }
        ]
      }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/finance.aspx?action=accommodation_status&amp;token=...</div>
                        <div class="api-endpoint__info">Returns whether the student is a resident, their hostel/room assignment from <code>acad_student</code>, and whether accommodation fees have been posted for the current semester. Staff can pass <code>?regno=</code>.</div>
                        <div class="api-code"><span class="c-comm">// Response — resident student</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"is_resident"</span>: <span class="c-num">true</span>,
    <span class="c-key">"accommodation_type"</span>: <span class="c-str">"On-Campus"</span>,
    <span class="c-key">"hostel"</span>: <span class="c-str">"Block A"</span>,
    <span class="c-key">"room_no"</span>: <span class="c-str">"A-12"</span>,
    <span class="c-key">"billed_amount"</span>: <span class="c-num">300000</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>
  }
}

<span class="c-comm">// Response — non-resident</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"is_resident"</span>: <span class="c-num">false</span>,
    <span class="c-key">"accommodation_type"</span>: <span class="c-str">"Off-Campus"</span>,
    <span class="c-key">"hostel"</span>: <span class="c-num">null</span>,
    <span class="c-key">"room_no"</span>: <span class="c-num">null</span>,
    <span class="c-key">"billed_amount"</span>: <span class="c-num">0</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">NEW</span> /API/v2/finance.aspx?action=student_financial_summary&amp;token=...</div>
                        <div class="api-endpoint__info">Single-call comprehensive financial snapshot. Returns all-time balance, clearance status, waiver totals, financial lock flag, and optionally a period-specific sub-balance — all computed server-side via <code>FinanceEngine</code> from the canonical dual-source ledger. Replaces the need to call <code>balance</code> + <code>waivers</code> + <code>fee_status</code> separately. Staff can pass <code>?regno=</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>YYYY/YYYY — when provided, a period-specific balance is included in the <code>period</code> field</td></tr>
                            <tr><td>semester</td><td>string</td><td class="api-param--optional">No</td><td>1, 2, or 3 — used with <code>acad_year</code> to narrow the period balance</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// GET ?acad_year=2025/2026&amp;semester=1</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total_charges"</span>:     <span class="c-num">5200000</span>,
    <span class="c-key">"total_payments"</span>:    <span class="c-num">3800000</span>,
    <span class="c-key">"balance"</span>:           <span class="c-num">1400000</span>,
    <span class="c-key">"amount_owing"</span>:      <span class="c-num">1400000</span>,
    <span class="c-key">"credit_balance"</span>:    <span class="c-num">0</span>,
    <span class="c-key">"clearance_status"</span>:  <span class="c-str">"partial"</span>,
    <span class="c-key">"percentage_paid"</span>:   <span class="c-num">73.1</span>,
    <span class="c-key">"last_payment_date"</span>: <span class="c-str">"2026-02-14"</span>,
    <span class="c-key">"currency"</span>:          <span class="c-str">"UGX"</span>,
    <span class="c-key">"regno"</span>:             <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"has_financial_lock"</span>:<span class="c-num">false</span>,
    <span class="c-key">"waiver_total"</span>:      <span class="c-num">450000</span>,
    <span class="c-key">"waiver_count"</span>:      <span class="c-num">1</span>,
    <span class="c-key">"effective_balance"</span>: <span class="c-num">950000</span>,
    <span class="c-key">"credit_after_waivers"</span>: <span class="c-num">0</span>,
    <span class="c-key">"period"</span>: {
      <span class="c-key">"acad_year"</span>:        <span class="c-str">"2025/2026"</span>,
      <span class="c-key">"semester"</span>:         <span class="c-str">"1"</span>,
      <span class="c-key">"total_charges"</span>:    <span class="c-num">1300000</span>,
      <span class="c-key">"total_payments"</span>:   <span class="c-num">900000</span>,
      <span class="c-key">"balance"</span>:          <span class="c-num">400000</span>,
      <span class="c-key">"clearance_status"</span>: <span class="c-str">"partial"</span>,
      <span class="c-key">"percentage_paid"</span>:  <span class="c-num">69.2</span>
    }
  }
}</div>
                        <div class="api-note"><code>effective_balance</code> = <code>balance</code> minus active waivers — the real amount the student still owes after approved waivers are considered. <code>clearance_status</code> values: <code>"cleared"</code>, <code>"partial"</code>, <code>"not_cleared"</code>, <code>"no_bill"</code>.</div>
                    </div>

                    <!-- ── Residence Finance ── -->
                    <div id="residence-finance" style="margin:20px 0 12px;padding:8px 12px;background:#f0f4f8;border-left:3px solid #05275C;font-weight:700;font-size:13px;color:#05275C;text-transform:uppercase;letter-spacing:.5px;">Residence Finance &amp; Hall Allocation — <code>finance.aspx</code></div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=residence_info&amp;token=...</div>
                        <div class="api-endpoint__info">Returns the student's current hall allocation (hall name, room, allocation ID) and registration residence status for the requested period. Staff can pass <code>?regno=</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Defaults to student's most recent registration year</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Default 1</td></tr>
                        </table>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>:            <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"full_name"</span>:        <span class="c-str">"Jane Nakato"</span>,
    <span class="c-key">"residence_status"</span>: <span class="c-str">"RESIDENT"</span>,
    <span class="c-key">"is_resident"</span>:      <span class="c-num">true</span>,
    <span class="c-key">"is_allocated"</span>:     <span class="c-num">true</span>,
    <span class="c-key">"acad_year"</span>:        <span class="c-str">"2025/2026"</span>,
    <span class="c-key">"semester"</span>:         <span class="c-num">1</span>,
    <span class="c-key">"hall_name"</span>:        <span class="c-str">"Mary Stuart Hall"</span>,
    <span class="c-key">"room_id"</span>:          <span class="c-str">"B-04"</span>,
    <span class="c-key">"allocation_id"</span>:    <span class="c-num">218</span>
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=halls&amp;token=...</div>
                        <div class="api-endpoint__info">List all halls with capacity and current occupancy for a period. Available to any authenticated user.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Defaults to current calendar year</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Default 1</td></tr>
                        </table>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
    <span class="c-key">"halls"</span>: [
      { <span class="c-key">"hall_id"</span>: <span class="c-num">1</span>, <span class="c-key">"hall_name"</span>: <span class="c-str">"Africa Hall"</span>, <span class="c-key">"capacity"</span>: <span class="c-num">200</span>, <span class="c-key">"occupied"</span>: <span class="c-num">187</span>, <span class="c-key">"available"</span>: <span class="c-num">13</span> },
      { <span class="c-key">"hall_id"</span>: <span class="c-num">2</span>, <span class="c-key">"hall_name"</span>: <span class="c-str">"Mary Stuart Hall"</span>, <span class="c-key">"capacity"</span>: <span class="c-num">120</span>, <span class="c-key">"occupied"</span>: <span class="c-num">98</span>, <span class="c-key">"available"</span>: <span class="c-num">22</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/finance.aspx?action=allocate_residence&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Assign or update a student's hall/room for a period. Upserts — creates if no allocation exists, updates hall/room if one already exists.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>regno</td><td>string</td><td class="api-param--required">Yes</td><td>Student registration number</td></tr>
                            <tr><td>hall_id</td><td>int</td><td class="api-param--required">Yes</td><td>Hall ID from <code>acad_halls</code></td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>YYYY/YYYY</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Default 1</td></tr>
                            <tr><td>room_id</td><td>string</td><td class="api-param--optional">No</td><td>Room identifier (e.g. "B-04")</td></tr>
                        </table>
                        <div class="api-code">{ <span class="c-key">"success"</span>: <span class="c-num">true</span>, <span class="c-key">"message"</span>: <span class="c-str">"Residence allocated"</span>, <span class="c-key">"data"</span>: { <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>, <span class="c-key">"hall_id"</span>: <span class="c-num">2</span>, <span class="c-key">"room_id"</span>: <span class="c-str">"B-04"</span>, <span class="c-key">"action"</span>: <span class="c-str">"created"</span> } }</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/finance.aspx?action=remove_residence&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Remove a student's hall allocation for a period. Returns <code>NOT_FOUND</code> if no allocation exists.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>regno</td><td>string</td><td class="api-param--required">Yes</td><td>Student registration number</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>YYYY/YYYY</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Default 1</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=unallocated_residents&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Returns all students registered with <code>residence_status = 'RESIDENT'</code> who have no hall assignment for the given period. Used for allocation pending list.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>YYYY/YYYY</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Default 1</td></tr>
                        </table>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
    <span class="c-key">"count"</span>: <span class="c-num">14</span>,
    <span class="c-key">"students"</span>: [
      { <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025004001"</span>, <span class="c-key">"full_name"</span>: <span class="c-str">"Peter Olweny"</span>, <span class="c-key">"progid"</span>: <span class="c-str">"BBAM"</span>, <span class="c-key">"studyyear"</span>: <span class="c-num">1</span>, <span class="c-key">"regstatus"</span>: <span class="c-str">"Registered"</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=hall_utilization&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Per-hall occupancy statistics for a period — capacity, occupied, available, and occupancy %. Includes overall totals.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>YYYY/YYYY</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Default 1</td></tr>
                        </table>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
    <span class="c-key">"total_capacity"</span>: <span class="c-num">850</span>, <span class="c-key">"total_occupied"</span>: <span class="c-num">743</span>, <span class="c-key">"total_available"</span>: <span class="c-num">107</span>, <span class="c-key">"overall_pct"</span>: <span class="c-num">87.4</span>,
    <span class="c-key">"halls"</span>: [
      { <span class="c-key">"hall_id"</span>: <span class="c-num">1</span>, <span class="c-key">"hall_name"</span>: <span class="c-str">"Africa Hall"</span>, <span class="c-key">"capacity"</span>: <span class="c-num">200</span>, <span class="c-key">"occupied"</span>: <span class="c-num">187</span>, <span class="c-key">"available"</span>: <span class="c-num">13</span>, <span class="c-key">"occupancy_pct"</span>: <span class="c-num">93.5</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=residence_fees&amp;token=...</div>
                        <div class="api-endpoint__info">Returns accommodation billing entries from <code>fin_studentfeestracking</code> matched by keyword (accommodation, residence, hostel, hall). Optionally filter by <code>acad_year</code> and <code>semester</code>. Staff can pass <code>?regno=</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Filter to a specific year</td></tr>
                            <tr><td>semester</td><td>string</td><td class="api-param--optional">No</td><td>1, 2, or 3</td></tr>
                        </table>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"total_billed"</span>: <span class="c-num">600000</span>, <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"items"</span>: [
      { <span class="c-key">"item_code"</span>: <span class="c-str">"ACC01"</span>, <span class="c-key">"item_name"</span>: <span class="c-str">"Accommodation Fees"</span>, <span class="c-key">"amount"</span>: <span class="c-num">300000</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"trans_date"</span>: <span class="c-str">"2025-09-01"</span> },
      { <span class="c-key">"item_code"</span>: <span class="c-str">"ACC01"</span>, <span class="c-key">"item_name"</span>: <span class="c-str">"Accommodation Fees"</span>, <span class="c-key">"amount"</span>: <span class="c-num">300000</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-str">"2"</span>, <span class="c-key">"trans_date"</span>: <span class="c-str">"2026-01-15"</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=residence_ledger&amp;token=...</div>
                        <div class="api-endpoint__info">Full accommodation-related ledger — both bills (<code>trans_type=Bill</code>) and payments (<code>trans_type=Pay</code>) — with running balance. Staff can pass <code>?regno=</code>.</div>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
    <span class="c-key">"total_billed"</span>: <span class="c-num">600000</span>, <span class="c-key">"total_paid"</span>: <span class="c-num">300000</span>, <span class="c-key">"balance"</span>: <span class="c-num">300000</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"entries"</span>: [
      { <span class="c-key">"trans_type"</span>: <span class="c-str">"Bill"</span>, <span class="c-key">"description"</span>: <span class="c-str">"Accommodation Fees"</span>, <span class="c-key">"amount"</span>: <span class="c-num">300000</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"trans_date"</span>: <span class="c-str">"2025-09-01"</span> },
      { <span class="c-key">"trans_type"</span>: <span class="c-str">"Pay"</span>,  <span class="c-key">"description"</span>: <span class="c-str">"Cash Payment"</span>,         <span class="c-key">"amount"</span>: <span class="c-num">300000</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"trans_date"</span>: <span class="c-str">"2025-09-20"</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=residence_report&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Paginated per-student allocation report for a period. Shows hall name, room, programme, study year, and registration status. Filter by <code>hall_id</code> to narrow to one hall.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>YYYY/YYYY</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Default 1</td></tr>
                            <tr><td>hall_id</td><td>int</td><td class="api-param--optional">No</td><td>Filter to a specific hall</td></tr>
                            <tr><td>page</td><td>int</td><td class="api-param--optional">No</td><td>Page number (default 1)</td></tr>
                            <tr><td>size</td><td>int</td><td class="api-param--optional">No</td><td>Results per page (max 200, default 50)</td></tr>
                        </table>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
    <span class="c-key">"total"</span>: <span class="c-num">743</span>, <span class="c-key">"page"</span>: <span class="c-num">1</span>, <span class="c-key">"pages"</span>: <span class="c-num">15</span>, <span class="c-key">"size"</span>: <span class="c-num">50</span>,
    <span class="c-key">"allocations"</span>: [
      { <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>, <span class="c-key">"full_name"</span>: <span class="c-str">"Jane Nakato"</span>, <span class="c-key">"hall_name"</span>: <span class="c-str">"Mary Stuart Hall"</span>, <span class="c-key">"room_id"</span>: <span class="c-str">"B-04"</span>, <span class="c-key">"progid"</span>: <span class="c-str">"BBAM"</span>, <span class="c-key">"studyyear"</span>: <span class="c-num">2</span>, <span class="c-key">"regstatus"</span>: <span class="c-str">"Registered"</span> }
    ]
  }
}</div>
                    </div>

                    <!-- ── Chart of Accounts ── -->
                    <div id="chart-of-accounts" style="margin:20px 0 12px;padding:8px 12px;background:#f0f4f8;border-left:3px solid #05275C;font-weight:700;font-size:13px;color:#05275C;text-transform:uppercase;letter-spacing:.5px;">Chart of Accounts — <code>finance.aspx</code> (staff only)</div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=chart_of_accounts&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Paginated list of all accounts from <code>fin_mainaccounts</code>. Filter by keyword <code>q</code> (matches account code or name) and/or <code>category</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>q</td><td>string</td><td class="api-param--optional">No</td><td>Search in code or name</td></tr>
                            <tr><td>category</td><td>string</td><td class="api-param--optional">No</td><td>Exact category match</td></tr>
                            <tr><td>page</td><td>int</td><td class="api-param--optional">No</td><td>Default 1</td></tr>
                            <tr><td>size</td><td>int</td><td class="api-param--optional">No</td><td>Max 200, default 50</td></tr>
                        </table>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total"</span>: <span class="c-num">320</span>, <span class="c-key">"page"</span>: <span class="c-num">1</span>, <span class="c-key">"size"</span>: <span class="c-num">50</span>, <span class="c-key">"pages"</span>: <span class="c-num">7</span>,
    <span class="c-key">"accounts"</span>: [
      { <span class="c-key">"account_id"</span>: <span class="c-num">1</span>, <span class="c-key">"account_code"</span>: <span class="c-str">"1000"</span>, <span class="c-key">"account_name"</span>: <span class="c-str">"Cash and Bank"</span>, <span class="c-key">"category"</span>: <span class="c-str">"Assets"</span>, <span class="c-key">"sub_category"</span>: <span class="c-str">"Current Assets"</span>, <span class="c-key">"account_type"</span>: <span class="c-str">"Debit"</span>, <span class="c-key">"is_active"</span>: <span class="c-num">1</span>, <span class="c-key">"opening_balance"</span>: <span class="c-num">0</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=account&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Get a single account by <code>account_id</code> (int) or <code>account_code</code> (string). Returns <code>NOT_FOUND</code> if missing.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/finance.aspx?action=create_account&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Create a new account in the chart of accounts. Calls the <code>MainAccountEditor</code> SP if available, otherwise direct INSERT.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>account_code</td><td>string</td><td class="api-param--required">Yes</td><td>Unique account code (e.g. "2100")</td></tr>
                            <tr><td>account_name</td><td>string</td><td class="api-param--required">Yes</td><td>Descriptive name</td></tr>
                            <tr><td>category</td><td>string</td><td class="api-param--optional">No</td><td>e.g. Assets, Liabilities, Income, Expense</td></tr>
                            <tr><td>sub_category</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>account_type</td><td>string</td><td class="api-param--optional">No</td><td>Debit / Credit</td></tr>
                            <tr><td>description</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>opening_balance</td><td>decimal</td><td class="api-param--optional">No</td><td>Default 0</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/finance.aspx?action=update_account&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Update one or more fields on an existing account. Only supplied fields are changed (dynamic SET). Requires <code>account_id</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>account_id</td><td>int</td><td class="api-param--required">Yes</td><td>Account row ID</td></tr>
                            <tr><td>account_name</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>category</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>sub_category</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>account_type</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>description</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>is_active</td><td>int</td><td class="api-param--optional">No</td><td>1 = active, 0 = inactive</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--delete">DELETE</span> /API/v2/finance.aspx?action=delete_account&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Delete an account by <code>account_id</code>. Calls <code>DeleteMainAccount</code> SP if available, otherwise direct DELETE.</div>
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
                        <div class="api-endpoint__info">Get existing coursework and exam marks for all students in a course. Returns the marks array, the number of students with missing marks, and the configured <code>max_coursework</code> / <code>max_exam</code> limits from the mark sheet definition.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>course_id</td><td>string</td><td class="api-param--required">Yes</td><td>Course code</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--required">Yes</td><td>Semester number</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"course_id"</span>: <span class="c-str">"CSC201"</span>,
    <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>,
    <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
    <span class="c-key">"max_coursework"</span>: <span class="c-num">50</span>,
    <span class="c-key">"max_exam"</span>: <span class="c-num">60</span>,
    <span class="c-key">"total_students"</span>: <span class="c-num">42</span>,
    <span class="c-key">"marks_missing"</span>: <span class="c-num">5</span>,
    <span class="c-key">"marks"</span>: [
      { <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>, <span class="c-key">"full_name"</span>: <span class="c-str">"JOHN DOE"</span>, <span class="c-key">"coursework"</span>: <span class="c-num">42</span>, <span class="c-key">"exam"</span>: <span class="c-num">55</span> },
      { <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003205"</span>, <span class="c-key">"full_name"</span>: <span class="c-str">"JANE SMITH"</span>, <span class="c-key">"coursework"</span>: <span class="c-num">null</span>, <span class="c-key">"exam"</span>: <span class="c-num">null</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=submit_marks</div>
                        <div class="api-endpoint__info">Submit or update marks for a batch of students. Validates each score against the configured mark-sheet maximums (from <code>acad_mark_sheets</code>; defaults: 50 coursework, 60 exam). Per-student validation errors are reported without halting the whole batch.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token (staff only)</td></tr>
                            <tr><td>course_id</td><td>string</td><td class="api-param--required">Yes</td><td>Course code</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--required">Yes</td><td>Semester number</td></tr>
                            <tr><td>marks</td><td>JSON array</td><td class="api-param--required">Yes</td><td>Array of <code>{regno, coursework, exam}</code> objects. POST as <code>application/json</code> body.</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Request body</span>
POST /API/v2/staff.aspx?action=submit_marks
Content-Type: application/json

{
  <span class="c-key">"token"</span>: <span class="c-str">"a1b2c3d4..."</span>,
  <span class="c-key">"course_id"</span>: <span class="c-str">"CSC201"</span>,
  <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>,
  <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
  <span class="c-key">"marks"</span>: [
    { <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>, <span class="c-key">"coursework"</span>: <span class="c-num">42</span>, <span class="c-key">"exam"</span>: <span class="c-num">55</span> },
    { <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003205"</span>, <span class="c-key">"coursework"</span>: <span class="c-num">38</span>, <span class="c-key">"exam"</span>: <span class="c-num">48</span> },
    { <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003206"</span>, <span class="c-key">"coursework"</span>: <span class="c-num">999</span>, <span class="c-key">"exam"</span>: <span class="c-num">55</span> }
  ]
}

<span class="c-comm">// Success response (all valid)</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Marks saved for 2 student(s)."</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"saved"</span>: <span class="c-num">2</span>,
    <span class="c-key">"errors"</span>: <span class="c-num">1</span>,
    <span class="c-key">"max_coursework"</span>: <span class="c-num">50</span>,
    <span class="c-key">"max_exam"</span>: <span class="c-num">60</span>,
    <span class="c-key">"validation_errors"</span>: [
      <span class="c-str">"MRU2025003206: coursework score 999 exceeds maximum of 50"</span>
    ]
  }
}

<span class="c-comm">// Validation rules applied per student:</span>
<span class="c-comm">// • coursework and exam must be numeric</span>
<span class="c-comm">// • both must be ≥ 0</span>
<span class="c-comm">// • coursework must not exceed max_coursework</span>
<span class="c-comm">// • exam must not exceed max_exam</span>
<span class="c-comm">// Students that fail validation are skipped; valid ones are still saved</span></div>
                        <div class="api-note api-note--warn"><strong>Mark limits:</strong> Max values are read from <code>acad_mark_sheets</code> for the exact course/year/semester combination. If no record exists the defaults of <strong>50 (coursework)</strong> and <strong>60 (exam)</strong> apply. The same limits are returned by the <code>marks</code> GET endpoint so your UI can enforce them client-side before submission.</div>
                    </div>
                </div>
            </div>

            <!-- Staff Marks Workflow (NEW) -->
            <div class="api-section" id="staff-marks-workflow">
                <div class="api-section__header">
                    <div class="api-section__title">Staff — Marks Workflow</div>
                    <div class="api-section__desc">Entry-level marks, workflow submission, approvals, and deadlines</div>
                </div>
                <div class="api-section__body">
                    <div class="api-note">These endpoints integrate with the new marks management module. Marks flow through a workflow: <strong>DRAFT → SUBMITTED → DEAN_APPROVED → PUBLISHED</strong>.</div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=teaching_assignments&amp;token=...&amp;acad_year=...&amp;semester=...</div>
                        <div class="api-endpoint__info">Get courses assigned to this teacher. Uses new assignment table with legacy fallback.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=mark_sheet&amp;token=...&amp;course_id=...&amp;progid=...&amp;acad_year=...</div>
                        <div class="api-endpoint__info">Load the entry-level mark sheet with raw marks, weighted marks, ratios, grades, and workflow status.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>course_id</td><td>string</td><td class="api-param--required">Yes</td><td>Course code</td></tr>
                            <tr><td>progid</td><td>string</td><td class="api-param--required">Yes</td><td>Programme code</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Semester (default: 1)</td></tr>
                            <tr><td>study_year</td><td>int</td><td class="api-param--optional">No</td><td>Study year (default: 1)</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"status"</span>: <span class="c-str">"success"</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"ratios"</span>: { <span class="c-key">"coursework"</span>: <span class="c-num">30</span>, <span class="c-key">"test"</span>: <span class="c-num">10</span>, <span class="c-key">"exam"</span>: <span class="c-num">60</span> },
    <span class="c-key">"status"</span>: <span class="c-str">"DRAFT"</span>,
    <span class="c-key">"total_students"</span>: <span class="c-num">45</span>,
    <span class="c-key">"marks_entered"</span>: <span class="c-num">40</span>,
    <span class="c-key">"students"</span>: [
      {
        <span class="c-key">"entry_id"</span>: <span class="c-num">1023</span>,
        <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
        <span class="c-key">"cw_entered"</span>: <span class="c-num">85</span>,
        <span class="c-key">"total_mark"</span>: <span class="c-num">71.5</span>,
        <span class="c-key">"grade"</span>: <span class="c-str">"B"</span>
      }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=save_entry_marks</div>
                        <div class="api-endpoint__info">Save entry-level marks (draft). Accepts JSON array: [{"entry_id":123, "cw_entered":85, "test_entered":70, "exam_entered":65}]. Max 200 per request.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=submit_for_approval</div>
                        <div class="api-endpoint__info">Submit a mark sheet for dean approval. Only DRAFT sheets can be submitted.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>course_id</td><td>string</td><td class="api-param--required">Yes</td><td>Course code</td></tr>
                            <tr><td>progid</td><td>string</td><td class="api-param--required">Yes</td><td>Programme code</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Semester</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=sheet_status&amp;token=...&amp;course_id=...&amp;progid=...&amp;acad_year=...</div>
                        <div class="api-endpoint__info">Check workflow status of a mark sheet (DRAFT / SUBMITTED / DEAN_APPROVED / PUBLISHED).</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=deadlines&amp;token=...&amp;acad_year=...&amp;semester=...</div>
                        <div class="api-endpoint__info">Get mark submission deadlines with hours remaining and past-due indicators.</div>
                    </div>
                </div>
            </div>

            <!-- Notices -->
            <div class="api-section" id="notices">
                <div class="api-section__header">
                    <div class="api-section__title">Notices &amp; Announcements</div>
                    <div class="api-section__desc">Campus-wide and targeted announcements from <code>sys_communications</code> (portal DB). Filtered by user role (STUDENT/STAFF/BOTH).</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=notices&amp;token=...</div>
                        <div class="api-endpoint__info">List published notices for the authenticated user. Returns preview (300 chars), <code>is_read</code> flag, <code>unread_count</code>, and pagination.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>page</td><td>int</td><td class="api-param--optional">No</td><td>Page number (default 1)</td></tr>
                            <tr><td>limit</td><td>int</td><td class="api-param--optional">No</td><td>Items per page (default 20, max 50)</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=notice_detail&amp;token=...&amp;notice_id=...</div>
                        <div class="api-endpoint__info">Full notice content with attachment list. Auto-marks the notice as read for the current user.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>notice_id</td><td>int</td><td class="api-param--required">Yes</td><td>ID of the notice (sys_communications.ID)</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/campus.aspx?action=mark_read&amp;token=...&amp;notice_id=...</div>
                        <div class="api-endpoint__info">Mark a notice as read for the current user. Idempotent — safe to call multiple times. Returns <code>{"marked_read": true}</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>notice_id</td><td>int</td><td class="api-param--required">Yes</td><td>ID of the notice to mark as read</td></tr>
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
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=programmes&amp;faculty_code=...&amp;level=...</div>
                        <div class="api-endpoint__info"><strong>Enhanced for ODEL.</strong> List all programmes with faculty, department, level, duration, and study mode. Optional filters: <code>faculty_code</code>, <code>level</code>. No auth required.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>faculty_code</td><td>string</td><td class="api-param--optional">No</td><td>Filter by faculty code</td></tr>
                            <tr><td>level</td><td>string</td><td class="api-param--optional">No</td><td>Filter by level (e.g. Undergraduate)</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=campuses</div>
                        <div class="api-endpoint__info">List all campus locations. No auth required.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=faculties</div>
                        <div class="api-endpoint__info"><strong>Enhanced for ODEL.</strong> List all faculties with nested departments array. No auth required.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/campus.aspx?action=departments&amp;faculty_code=...</div>
                        <div class="api-endpoint__info">List all departments, optionally filtered by faculty. No auth required.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>faculty_code</td><td>string</td><td class="api-param--optional">No</td><td>Filter by faculty code (e.g. FBMSE)</td></tr>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Enrollment Verification (NEW) -->
            <div class="api-section" id="enrollment">
                <div class="api-section__header">
                    <div class="api-section__title">Enrollment Verification</div>
                    <div class="api-section__desc">Verify student enrollment status for third parties</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=enrollment_status&amp;token=...</div>
                        <div class="api-endpoint__info">Returns enrollment verification: student biodata, registration status, programme info. Filter by acad_year and semester.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Filter by academic year</td></tr>
                            <tr><td>semester</td><td>int</td><td class="api-param--optional">No</td><td>Filter by semester</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"student"</span>: {
      <span class="c-key">"regno"</span>: <span class="c-str">"MRU2025003204"</span>,
      <span class="c-key">"firstname"</span>: <span class="c-str">"RITAH"</span>,
      <span class="c-key">"surname"</span>: <span class="c-str">"NAKAMYA"</span>,
      <span class="c-key">"programme"</span>: <span class="c-str">"BACHELOR OF SCIENCE IN COMPUTER SCIENCE"</span>,
      <span class="c-key">"progcode"</span>: <span class="c-str">"BSC-CS"</span>,
      <span class="c-key">"study_year"</span>: <span class="c-num">2</span>,
      <span class="c-key">"campus"</span>: <span class="c-str">"Main Campus"</span>
    },
    <span class="c-key">"is_enrolled"</span>: <span class="c-num">true</span>,
    <span class="c-key">"is_active"</span>: <span class="c-num">true</span>,
    <span class="c-key">"total_semesters_registered"</span>: <span class="c-num">3</span>,
    <span class="c-key">"registrations"</span>: [
      {
        <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>,
        <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>,
        <span class="c-key">"reg_status"</span>: <span class="c-str">"REGISTERED"</span>,
        <span class="c-key">"status_label"</span>: <span class="c-str">"Registered"</span>,
        <span class="c-key">"is_active_registration"</span>: <span class="c-num">true</span>
      },
      {
        <span class="c-key">"acad_year"</span>: <span class="c-str">"2024/2025"</span>,
        <span class="c-key">"semester"</span>: <span class="c-str">"2"</span>,
        <span class="c-key">"reg_status"</span>: <span class="c-str">"CLEARED"</span>,
        <span class="c-key">"status_label"</span>: <span class="c-str">"Cleared"</span>,
        <span class="c-key">"is_active_registration"</span>: <span class="c-num">true</span>
      }
    ]
  }
}
<span class="c-comm">// is_enrolled = true when the most recent registration is an active status</span>
<span class="c-comm">// is_active = true when student's main account status is Active</span></div>
                    </div>
                </div>
            </div>

            <!-- ODEL: Identity & Lookup -->
            <div class="api-section" id="odel-identity">
                <div class="api-section__header">
                    <div class="api-section__title">ODEL — Identity &amp; Lookup</div>
                    <div class="api-section__desc">Endpoints for Moodle user identification, verification, and bulk sync</div>
                </div>
                <div class="api-section__body">
                    <div class="api-note">These endpoints are designed for the ODEL/Moodle integration plugin to verify users, sync rosters, and map roles. All require a valid token (use a system staff account for Moodle).</div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/student.aspx?action=lookup&amp;token=...&amp;email=...</div>
                        <div class="api-endpoint__info">Find a person (student or staff) by email. Returns <code>person_type</code> of "student" or "staff" with full profile data. Primary endpoint for Moodle registration identity matching.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>email</td><td>string</td><td class="api-param--required">Yes</td><td>Email address to look up</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response — Student found</span>
{
  <span class="c-key">"status"</span>: <span class="c-str">"success"</span>,
  <span class="c-key">"message"</span>: <span class="c-str">"Person found as student"</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"found"</span>: <span class="c-num">true</span>,
    <span class="c-key">"person_type"</span>: <span class="c-str">"student"</span>,
    <span class="c-key">"mru_id"</span>: <span class="c-str">"2024/BSC/001"</span>,
    <span class="c-key">"data"</span>: {
      <span class="c-key">"regno"</span>: <span class="c-str">"2024/BSC/001"</span>,
      <span class="c-key">"firstname"</span>: <span class="c-str">"John"</span>,
      <span class="c-key">"othername"</span>: <span class="c-str">"Doe"</span>,
      <span class="c-key">"programme"</span>: <span class="c-str">"Bachelor of Science in IT"</span>,
      <span class="c-key">"email"</span>: <span class="c-str">"john@example.com"</span>,
      <span class="c-key">"status"</span>: <span class="c-str">"Active"</span>
    }
  }
}

<span class="c-comm">// Response — Not found</span>
{
  <span class="c-key">"data"</span>: { <span class="c-key">"found"</span>: <span class="c-num">false</span>, <span class="c-key">"person_type"</span>: <span class="c-num">null</span>, <span class="c-key">"mru_id"</span>: <span class="c-num">null</span> }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/student.aspx?action=verify&amp;token=...&amp;id=...</div>
                        <div class="api-endpoint__info">Quick student verification by reg number or entry number. Returns <code>verified: true/false</code>, name, programme, and status.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>id</td><td>string</td><td class="api-param--required">Yes</td><td>Student reg no or entry no</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"verified"</span>: <span class="c-num">true</span>,
    <span class="c-key">"mru_id"</span>: <span class="c-str">"2024/BSC/001"</span>,
    <span class="c-key">"full_name"</span>: <span class="c-str">"John Doe"</span>,
    <span class="c-key">"status"</span>: <span class="c-str">"Active"</span>,
    <span class="c-key">"programme_code"</span>: <span class="c-str">"BSC-IT"</span>
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/student.aspx?action=search&amp;token=...&amp;q=...&amp;type=...</div>
                        <div class="api-endpoint__info"><strong>Staff only.</strong> Search students by name, email, or student number. Supports <code>type</code>=name|email|student_no|any and <code>limit</code> (max 200).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>q</td><td>string</td><td class="api-param--required">Yes</td><td>Search query</td></tr>
                            <tr><td>type</td><td>string</td><td class="api-param--optional">No</td><td>name, email, student_no, or any (default)</td></tr>
                            <tr><td>limit</td><td>int</td><td class="api-param--optional">No</td><td>Max results (default 50, max 200)</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/student.aspx?action=by_programme&amp;token=...&amp;progcode=...</div>
                        <div class="api-endpoint__info"><strong>Staff only.</strong> Bulk student list by programme with pagination. Used for Moodle cohort sync. Filters: <code>status</code>, <code>acad_year</code>, <code>page</code>, <code>per_page</code> (max 500).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>progcode</td><td>string</td><td class="api-param--required">Yes</td><td>Programme code</td></tr>
                            <tr><td>status</td><td>string</td><td class="api-param--optional">No</td><td>Filter: Active, Graduated, etc.</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Filter by academic year</td></tr>
                            <tr><td>page</td><td>int</td><td class="api-param--optional">No</td><td>Page number (default 1)</td></tr>
                            <tr><td>per_page</td><td>int</td><td class="api-param--optional">No</td><td>Per page (default 100, max 500)</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response — paginated</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"programme_code"</span>: <span class="c-str">"BSC-IT"</span>,
    <span class="c-key">"total"</span>: <span class="c-num">125</span>,
    <span class="c-key">"page"</span>: <span class="c-num">1</span>,
    <span class="c-key">"per_page"</span>: <span class="c-num">50</span>,
    <span class="c-key">"total_pages"</span>: <span class="c-num">3</span>,
    <span class="c-key">"students"</span>: [ ... ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/staff.aspx?action=lookup&amp;token=...&amp;email=...</div>
                        <div class="api-endpoint__info">Find a staff member by email. Returns profile with department, faculty, qualifications, and photo URL.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>email</td><td>string</td><td class="api-param--required">Yes</td><td>Staff email address</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/staff.aspx?action=by_department&amp;token=...&amp;department_id=...</div>
                        <div class="api-endpoint__info">List all staff in a department. Filters: <code>role</code> (e.g. academic), <code>status</code> (default Active). Returns staff list with department/faculty metadata.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>department_id</td><td>string</td><td class="api-param--required">Yes</td><td>Department ID</td></tr>
                            <tr><td>role</td><td>string</td><td class="api-param--optional">No</td><td>Filter by emp type (e.g. academic)</td></tr>
                            <tr><td>status</td><td>string</td><td class="api-param--optional">No</td><td>Contract status (default: Active)</td></tr>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ODEL: Courses & Curriculum -->
            <div class="api-section" id="odel-academic">
                <div class="api-section__header">
                    <div class="api-section__title">ODEL — Courses &amp; Curriculum</div>
                    <div class="api-section__desc">Course metadata, enrollments, curriculum structure, and grading for Moodle sync</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/academic.aspx?action=course_details&amp;token=...&amp;course_code=...</div>
                        <div class="api-endpoint__info">Get complete metadata for a single course: credit units, department, faculty, category, which programmes include it, and prerequisites.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>course_code</td><td>string</td><td class="api-param--required">Yes</td><td>Course code (e.g. CSC101)</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"course_code"</span>: <span class="c-str">"CSC101"</span>,
    <span class="c-key">"course_name"</span>: <span class="c-str">"Introduction to Computer Science"</span>,
    <span class="c-key">"credit_units"</span>: <span class="c-num">4</span>,
    <span class="c-key">"category"</span>: <span class="c-str">"Core"</span>,
    <span class="c-key">"department"</span>: <span class="c-str">"Computer Science"</span>,
    <span class="c-key">"faculty"</span>: <span class="c-str">"Faculty of Science"</span>,
    <span class="c-key">"programmes"</span>: [
      { <span class="c-key">"progcode"</span>: <span class="c-str">"BSC-IT"</span>, <span class="c-key">"study_year"</span>: <span class="c-num">1</span>, <span class="c-key">"semester"</span>: <span class="c-num">1</span> }
    ],
    <span class="c-key">"prerequisites"</span>: [ { <span class="c-key">"course_code"</span>: <span class="c-str">"MTH100"</span> } ],
    <span class="c-key">"lecturers"</span>: [
      {
        <span class="c-key">"emp_no"</span>: <span class="c-str">"EMP042"</span>,
        <span class="c-key">"full_name"</span>: <span class="c-str">"Dr. Alice Mugerwa"</span>,
        <span class="c-key">"email"</span>: <span class="c-str">"a.mugerwa@mru.ac.ug"</span>,
        <span class="c-key">"phone"</span>: <span class="c-str">"+256700123456"</span>,
        <span class="c-key">"progcode"</span>: <span class="c-str">"BSC-IT"</span>,
        <span class="c-key">"study_year"</span>: <span class="c-str">"1"</span>,
        <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>
      }
    ]
  }
}
<span class="c-comm">// lecturers: one entry per teaching allocation (acad_programmecourses row with lecturer_id set)</span>
<span class="c-comm">// Empty array [] if no lecturer has been assigned yet</span></div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/academic.aspx?action=course_enrollments&amp;token=...&amp;course_code=...&amp;acad_year=...&amp;semester=...</div>
                        <div class="api-endpoint__info"><strong>Staff only.</strong> Get all students enrolled in a course for a given semester. Used by Moodle for course roster sync.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>course_code</td><td>string</td><td class="api-param--required">Yes</td><td>Course code</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--required">Yes</td><td>Academic year (e.g. 2024/2025)</td></tr>
                            <tr><td>semester</td><td>string</td><td class="api-param--required">Yes</td><td>Semester number</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"course_code"</span>: <span class="c-str">"CSC101"</span>,
    <span class="c-key">"course_name"</span>: <span class="c-str">"Intro to CS"</span>,
    <span class="c-key">"academic_year"</span>: <span class="c-str">"2024/2025"</span>,
    <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>,
    <span class="c-key">"total_enrolled"</span>: <span class="c-num">45</span>,
    <span class="c-key">"students"</span>: [
      { <span class="c-key">"regno"</span>: <span class="c-str">"2024/BSC/001"</span>, <span class="c-key">"firstname"</span>: <span class="c-str">"John"</span>, <span class="c-key">"email"</span>: <span class="c-str">"..."</span>, <span class="c-key">"status"</span>: <span class="c-str">"Registered"</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/academic.aspx?action=programme_curriculum&amp;token=...&amp;progcode=...</div>
                        <div class="api-endpoint__info">Full programme curriculum grouped by year and semester. Includes programme metadata, total courses, total credit units. Used by Moodle to auto-create course categories.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>progcode</td><td>string</td><td class="api-param--required">Yes</td><td>Programme code</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response — curriculum grouped by year/semester</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"programme"</span>: { <span class="c-key">"progcode"</span>: <span class="c-str">"BSC-IT"</span>, <span class="c-key">"progname"</span>: <span class="c-str">"BSc IT"</span>, <span class="c-key">"level"</span>: <span class="c-str">"Undergraduate"</span> },
    <span class="c-key">"total_courses"</span>: <span class="c-num">36</span>,
    <span class="c-key">"total_credit_units"</span>: <span class="c-num">144</span>,
    <span class="c-key">"curriculum"</span>: {
      <span class="c-key">"Year 1 - Semester 1"</span>: [
        { <span class="c-key">"course_code"</span>: <span class="c-str">"CSC101"</span>, <span class="c-key">"course_name"</span>: <span class="c-str">"Intro to CS"</span>, <span class="c-key">"credit_units"</span>: <span class="c-str">"4"</span>, <span class="c-key">"course_type"</span>: <span class="c-str">"Core"</span> }
      ],
      <span class="c-key">"Year 1 - Semester 2"</span>: [ ... ]
    }
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/academic.aspx?action=grading_scheme</div>
                        <div class="api-endpoint__info"><strong>No auth required.</strong> Returns the MRU grading scale — letter grades, min/max scores, grade points, and remarks. Used by Moodle to configure grade mappings.</div>
                        <div class="api-code"><span class="c-comm">// No authentication needed</span>
GET /API/v2/academic.aspx?action=grading_scheme

<span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"institution"</span>: <span class="c-str">"Mountains of the Moon University"</span>,
    <span class="c-key">"pass_mark"</span>: <span class="c-num">50</span>,
    <span class="c-key">"max_gpa"</span>: <span class="c-num">5.0</span>,
    <span class="c-key">"scale"</span>: [
      { <span class="c-key">"letter"</span>: <span class="c-str">"A"</span>,  <span class="c-key">"min_score"</span>: <span class="c-num">90</span>, <span class="c-key">"max_score"</span>: <span class="c-num">100</span>, <span class="c-key">"grade_point"</span>: <span class="c-num">5.0</span>, <span class="c-key">"remark"</span>: <span class="c-str">"Excellent"</span> },
      { <span class="c-key">"letter"</span>: <span class="c-str">"B+"</span>, <span class="c-key">"min_score"</span>: <span class="c-num">80</span>, <span class="c-key">"max_score"</span>: <span class="c-num">89</span>,  <span class="c-key">"grade_point"</span>: <span class="c-num">4.5</span>, <span class="c-key">"remark"</span>: <span class="c-str">"Very Good"</span> },
      { <span class="c-key">"letter"</span>: <span class="c-str">"B"</span>,  <span class="c-key">"min_score"</span>: <span class="c-num">70</span>, <span class="c-key">"max_score"</span>: <span class="c-num">79</span>,  <span class="c-key">"grade_point"</span>: <span class="c-num">4.0</span>, <span class="c-key">"remark"</span>: <span class="c-str">"Good"</span> },
      { <span class="c-key">"letter"</span>: <span class="c-str">"C+"</span>, <span class="c-key">"min_score"</span>: <span class="c-num">60</span>, <span class="c-key">"max_score"</span>: <span class="c-num">69</span>,  <span class="c-key">"grade_point"</span>: <span class="c-num">3.5</span>, <span class="c-key">"remark"</span>: <span class="c-str">"Fairly Good"</span> },
      { <span class="c-key">"letter"</span>: <span class="c-str">"C"</span>,  <span class="c-key">"min_score"</span>: <span class="c-num">50</span>, <span class="c-key">"max_score"</span>: <span class="c-num">59</span>,  <span class="c-key">"grade_point"</span>: <span class="c-num">3.0</span>, <span class="c-key">"remark"</span>: <span class="c-str">"Pass"</span> },
      { <span class="c-key">"letter"</span>: <span class="c-str">"D+"</span>, <span class="c-key">"min_score"</span>: <span class="c-num">45</span>, <span class="c-key">"max_score"</span>: <span class="c-num">49</span>,  <span class="c-key">"grade_point"</span>: <span class="c-num">2.5</span>, <span class="c-key">"remark"</span>: <span class="c-str">"Marginal Pass"</span> },
      { <span class="c-key">"letter"</span>: <span class="c-str">"D"</span>,  <span class="c-key">"min_score"</span>: <span class="c-num">40</span>, <span class="c-key">"max_score"</span>: <span class="c-num">44</span>,  <span class="c-key">"grade_point"</span>: <span class="c-num">2.0</span>, <span class="c-key">"remark"</span>: <span class="c-str">"Marginal Fail"</span> },
      { <span class="c-key">"letter"</span>: <span class="c-str">"F"</span>,  <span class="c-key">"min_score"</span>: <span class="c-num">0</span>,  <span class="c-key">"max_score"</span>: <span class="c-num">39</span>,  <span class="c-key">"grade_point"</span>: <span class="c-num">0.0</span>, <span class="c-key">"remark"</span>: <span class="c-str">"Fail"</span> }
    ]
  }
}</div>
                    </div>
                </div>
            </div>

            <!-- ODEL: Fee Clearance -->
            <div class="api-section" id="odel-finance">
                <div class="api-section__header">
                    <div class="api-section__title">ODEL — Fee Clearance</div>
                    <div class="api-section__desc">Fee status checks and bulk clearance verification for Moodle access control</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/finance.aspx?action=fee_status&amp;token=...&amp;acad_year=...</div>
                        <div class="api-endpoint__info">Get fee clearance status: <code>cleared</code> / <code>partial</code> / <code>not_cleared</code>. Returns total fees, amount paid, balance, last payment date, and financial lock status. Staff can check any student via <code>?regno=</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token</td></tr>
                            <tr><td>regno</td><td>string</td><td class="api-param--optional">Staff</td><td>Student reg number (staff only)</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Filter by academic year</td></tr>
                            <tr><td>semester</td><td>string</td><td class="api-param--optional">No</td><td>Filter by semester</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"2024/BSC/001"</span>,
    <span class="c-key">"fee_status"</span>: <span class="c-str">"partial"</span>,
    <span class="c-key">"total_fees"</span>: <span class="c-num">2500000</span>,
    <span class="c-key">"amount_paid"</span>: <span class="c-num">1800000</span>,
    <span class="c-key">"balance"</span>: <span class="c-num">700000</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"last_payment_date"</span>: <span class="c-str">"2025-06-15"</span>,
    <span class="c-key">"has_financial_lock"</span>: <span class="c-num">false</span>
  }
}

<span class="c-comm">// fee_status values: "cleared" | "partial" | "not_cleared"</span></div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/finance.aspx?action=bulk_fee_check&amp;token=...</div>
                        <div class="api-endpoint__info"><strong>Staff only.</strong> Check fee status for multiple students at once (max 200). POST a JSON body with a <code>students</code> array. Used by Moodle for bulk enrollment clearance.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Auth token (staff)</td></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Filter by academic year</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Request body</span>
POST /API/v2/finance.aspx?action=bulk_fee_check&amp;token=...
Content-Type: application/json

{ <span class="c-key">"students"</span>: [<span class="c-str">"2024/BSC/001"</span>, <span class="c-str">"2024/BSC/002"</span>, <span class="c-str">"2024/BSC/003"</span>] }

<span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total_checked"</span>: <span class="c-num">3</span>,
    <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>,
    <span class="c-key">"results"</span>: [
      { <span class="c-key">"regno"</span>: <span class="c-str">"2024/BSC/001"</span>, <span class="c-key">"fee_status"</span>: <span class="c-str">"cleared"</span>, <span class="c-key">"balance"</span>: <span class="c-num">0</span> },
      { <span class="c-key">"regno"</span>: <span class="c-str">"2024/BSC/002"</span>, <span class="c-key">"fee_status"</span>: <span class="c-str">"partial"</span>, <span class="c-key">"balance"</span>: <span class="c-num">700000</span> }
    ]
  }
}</div>
                    </div>
                </div>
            </div>

            <!-- Fee Access Policy Evaluation -->
            <div class="api-section" id="fee-access">
                <div class="api-section__header">
                    <div class="api-section__title">Fee Access Policy — Evaluation</div>
                    <div class="api-section__desc">Evaluate a student against the bursar-defined fee access rules. Returns student profile, full policy configuration, financial summary, bursary status, per-rule results, verdict, and actionable guidance.</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">LIVE</span> /API/v2/finance.aspx?action=access_status&amp;token=...</div>
                        <div class="api-endpoint__info">Evaluates a student against all enabled fee-access rules and returns a comprehensive result. Students are auto-resolved from their token; staff must provide <code>?regno=</code>. The response always includes every top-level key — consumers never encounter missing fields.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>token</td><td>string</td><td class="api-param--required">Yes</td><td>Valid API token (student or staff)</td></tr>
                            <tr><td>action</td><td>string</td><td class="api-param--required">Yes</td><td>Must be <code>access_status</code></td></tr>
                            <tr><td>regno</td><td>string</td><td class="api-param--optional">Staff only</td><td>Student registration number. Students are automatically identified from their token.</td></tr>
                        </table>

                        <div class="api-note">The response is structured into nested objects: <code>student</code>, <code>policy</code>, <code>finance</code>, <code>bursary</code>, <code>criteria[]</code>, <code>summary</code>. This ensures maximum detail for any consumer (portal, mobile app, Moodle).</div>

                        <h4 style="font-size:13px;font-weight:700;margin:16px 0 6px;color:#05275C;">Response Fields (top level)</h4>
                        <table class="api-endpoint__params">
                            <tr><th>Field</th><th>Type</th><th>Description</th></tr>
                            <tr><td>access_allowed</td><td>boolean</td><td><code>true</code> if the student passes the policy (or no policy is active)</td></tr>
                            <tr><td>has_policy</td><td>boolean</td><td><code>true</code> if an active fee access policy exists</td></tr>
                            <tr><td>verdict</td><td>string</td><td><code>"granted"</code> or <code>"denied"</code></td></tr>
                            <tr><td>verdict_reason</td><td>string</td><td>Human-readable explanation (e.g. "2 of 3 rule(s) failed. Policy requires ALL rules to pass.")</td></tr>
                            <tr><td>student</td><td>object</td><td>Contains: <code>regno</code>, <code>name</code>, <code>programme</code>, <code>programme_code</code>, <code>study_year</code></td></tr>
                            <tr><td>policy</td><td>object | null</td><td>Full policy config incl. <code>rules_enabled</code> map and <code>thresholds</code>. Null when no active policy.</td></tr>
                            <tr><td>finance</td><td>object</td><td><code>total_bill</code>, <code>total_paid</code>, <code>balance</code> (negative=owing), <code>amount_owing</code>, <code>credit_balance</code>, <code>percentage_paid</code>, <code>currency</code></td></tr>
                            <tr><td>bursary</td><td>object</td><td><code>status</code>, <code>scheme_name</code>, <code>amount_offered</code>, <code>coverage_percent</code>, <code>exempt</code> (short-circuit flag)</td></tr>
                            <tr><td>criteria</td><td>array</td><td>Per-rule evaluation. Each: <code>rule</code>, <code>passed</code>, <code>enabled</code>, <code>detail</code>, <code>threshold</code>, <code>actual_value</code></td></tr>
                            <tr><td>summary</td><td>object</td><td><code>total_rules</code>, <code>rules_passed</code>, <code>rules_failed</code>, <code>enabled_rules[]</code></td></tr>
                            <tr><td>guidance</td><td>string</td><td>Actionable steps for denied students (empty if granted)</td></tr>
                            <tr><td>evaluated_at</td><td>string</td><td>ISO 8601 UTC timestamp</td></tr>
                        </table>

                        <h4 style="font-size:13px;font-weight:700;margin:16px 0 6px;color:#05275C;">Access Decision Logic</h4>
                        <div class="api-note" style="font-size:12px;line-height:1.8;">
                            <strong>1.</strong> No active policy → <code>access_allowed = true</code>, <code>has_policy = false</code><br/>
                            <strong>2.</strong> Policy active, no rules enabled → <code>access_allowed = true</code><br/>
                            <strong>3.</strong> Bursary Exemption enabled &amp; student's bursary ≥ min coverage → <code>access_allowed = true</code> (other rules skipped)<br/>
                            <strong>4.</strong> Logic = <code>ALL</code> → student must pass <strong>every</strong> enabled rule<br/>
                            <strong>5.</strong> Logic = <code>ANY</code> → student must pass <strong>at least one</strong> enabled rule
                        </div>

                        <h4 style="font-size:13px;font-weight:700;margin:16px 0 6px;color:#05275C;">Available Access Rules</h4>
                        <table class="api-endpoint__params">
                            <tr><th>Rule</th><th>Threshold</th><th>Description</th></tr>
                            <tr><td>Balance Threshold</td><td>max_balance (UGX)</td><td>Deny if outstanding balance exceeds the configured maximum</td></tr>
                            <tr><td>Payment Window</td><td>min amount + date range</td><td>Require a minimum payment within a specific date window</td></tr>
                            <tr><td>Percentage Paid</td><td>min % paid</td><td>Require at least X% of total fees to be paid</td></tr>
                            <tr><td>Bursary Exemption</td><td>min coverage %</td><td>Auto-exempt students whose approved bursary covers ≥ X% of fees (short-circuits all rules)</td></tr>
                            <tr><td>Registration</td><td>—</td><td>Require current-semester registration in <code>acad_registration</code></td></tr>
                        </table>

                        <h4 style="font-size:13px;font-weight:700;margin:16px 0 6px;color:#e74c3c;">Example — Access Denied</h4>
                        <div class="api-code"><span class="c-comm">// GET /API/v2/finance.aspx?action=access_status&amp;regno=2024/BSC/001&amp;token=...</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"access_allowed"</span>: <span class="c-num">false</span>,
    <span class="c-key">"has_policy"</span>: <span class="c-num">true</span>,
    <span class="c-key">"verdict"</span>: <span class="c-str">"denied"</span>,
    <span class="c-key">"verdict_reason"</span>: <span class="c-str">"2 of 3 rule(s) failed. Policy requires ALL rules to pass."</span>,
    <span class="c-key">"student"</span>: {
      <span class="c-key">"regno"</span>: <span class="c-str">"2024/BSC/001"</span>,
      <span class="c-key">"name"</span>: <span class="c-str">"DOE John"</span>,
      <span class="c-key">"programme"</span>: <span class="c-str">"Bachelor of Science in Computer Science"</span>,
      <span class="c-key">"programme_code"</span>: <span class="c-str">"BSC-CS"</span>,
      <span class="c-key">"study_year"</span>: <span class="c-num">2</span>
    },
    <span class="c-key">"policy"</span>: {
      <span class="c-key">"policy_id"</span>: <span class="c-num">1</span>,
      <span class="c-key">"title"</span>: <span class="c-str">"University campus access"</span>,
      <span class="c-key">"academic_year"</span>: <span class="c-str">"2025/2026"</span>,
      <span class="c-key">"semester"</span>: <span class="c-num">1</span>,
      <span class="c-key">"combination_logic"</span>: <span class="c-str">"ALL"</span>,
      <span class="c-key">"combination_logic_description"</span>: <span class="c-str">"Student must satisfy ALL enabled rules to pass"</span>,
      <span class="c-key">"rules_enabled"</span>: {
        <span class="c-key">"balance_threshold"</span>: <span class="c-num">true</span>,
        <span class="c-key">"payment_window"</span>: <span class="c-num">false</span>,
        <span class="c-key">"percentage_paid"</span>: <span class="c-num">true</span>,
        <span class="c-key">"bursary_exemption"</span>: <span class="c-num">false</span>,
        <span class="c-key">"registration"</span>: <span class="c-num">true</span>
      },
      <span class="c-key">"thresholds"</span>: {
        <span class="c-key">"max_balance"</span>: <span class="c-num">500000</span>,
        <span class="c-key">"min_percentage_paid"</span>: <span class="c-num">60</span>
      }
    },
    <span class="c-key">"finance"</span>: {
      <span class="c-key">"total_bill"</span>: <span class="c-num">2500000</span>,
      <span class="c-key">"total_paid"</span>: <span class="c-num">800000</span>,
      <span class="c-key">"balance"</span>: <span class="c-num">-1700000</span>,
      <span class="c-key">"amount_owing"</span>: <span class="c-num">1700000</span>,
      <span class="c-key">"credit_balance"</span>: <span class="c-num">0</span>,
      <span class="c-key">"percentage_paid"</span>: <span class="c-num">32.0</span>,
      <span class="c-key">"currency"</span>: <span class="c-str">"UGX"</span>
    },
    <span class="c-key">"bursary"</span>: {
      <span class="c-key">"status"</span>: <span class="c-str">"None"</span>,
      <span class="c-key">"scheme_name"</span>: <span class="c-str">""</span>,
      <span class="c-key">"amount_offered"</span>: <span class="c-num">0</span>,
      <span class="c-key">"coverage_percent"</span>: <span class="c-num">0</span>,
      <span class="c-key">"exempt"</span>: <span class="c-num">false</span>
    },
    <span class="c-key">"criteria"</span>: [
      {
        <span class="c-key">"rule"</span>: <span class="c-str">"Balance Threshold"</span>,
        <span class="c-key">"passed"</span>: <span class="c-num">false</span>,
        <span class="c-key">"enabled"</span>: <span class="c-num">true</span>,
        <span class="c-key">"detail"</span>: <span class="c-str">"Outstanding balance of 1,700,000 exceeds the allowed maximum of 500,000."</span>,
        <span class="c-key">"threshold"</span>: <span class="c-str">"Max balance: UGX 500,000"</span>,
        <span class="c-key">"actual_value"</span>: <span class="c-str">"UGX 1,700,000"</span>
      },
      {
        <span class="c-key">"rule"</span>: <span class="c-str">"Percentage Paid"</span>,
        <span class="c-key">"passed"</span>: <span class="c-num">false</span>,
        <span class="c-key">"enabled"</span>: <span class="c-num">true</span>,
        <span class="c-key">"detail"</span>: <span class="c-str">"Only 32.0% of total fees paid (required: 60%)."</span>,
        <span class="c-key">"threshold"</span>: <span class="c-str">"Min 60% paid"</span>,
        <span class="c-key">"actual_value"</span>: <span class="c-str">"32.0%"</span>
      },
      {
        <span class="c-key">"rule"</span>: <span class="c-str">"Registration"</span>,
        <span class="c-key">"passed"</span>: <span class="c-num">true</span>,
        <span class="c-key">"enabled"</span>: <span class="c-num">true</span>,
        <span class="c-key">"detail"</span>: <span class="c-str">"Student is registered for 2025/2026 Semester 1."</span>,
        <span class="c-key">"threshold"</span>: <span class="c-str">"Registered for 2025/2026 Sem 1"</span>,
        <span class="c-key">"actual_value"</span>: <span class="c-str">"Registered"</span>
      }
    ],
    <span class="c-key">"summary"</span>: {
      <span class="c-key">"total_rules"</span>: <span class="c-num">3</span>,
      <span class="c-key">"rules_passed"</span>: <span class="c-num">1</span>,
      <span class="c-key">"rules_failed"</span>: <span class="c-num">2</span>,
      <span class="c-key">"enabled_rules"</span>: [<span class="c-str">"Balance Threshold"</span>, <span class="c-str">"Percentage Paid"</span>, <span class="c-str">"Registration"</span>]
    },
    <span class="c-key">"guidance"</span>: <span class="c-str">"Pay at least UGX 1,200,000 to reduce the outstanding balance to the allowed maximum of UGX 500,000. Pay an additional UGX 700,000 to reach the required 60%."</span>,
    <span class="c-key">"evaluated_at"</span>: <span class="c-str">"2026-04-16T08:45:12Z"</span>
  }
}</div>

                        <h4 style="font-size:13px;font-weight:700;margin:16px 0 6px;color:#2ecc71;">Example — Access Granted (No Policy)</h4>
                        <div class="api-code"><span class="c-comm">// When no active policy exists in the system</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"access_allowed"</span>: <span class="c-num">true</span>,
    <span class="c-key">"has_policy"</span>: <span class="c-num">false</span>,
    <span class="c-key">"verdict"</span>: <span class="c-str">"granted"</span>,
    <span class="c-key">"verdict_reason"</span>: <span class="c-str">"No active fee access policy. All students are granted full access."</span>,
    <span class="c-key">"student"</span>: { <span class="c-key">"regno"</span>: <span class="c-str">"2024/BSC/001"</span>, <span class="c-key">"name"</span>: <span class="c-str">"DOE John"</span>, <span class="c-comm">...</span> },
    <span class="c-key">"policy"</span>: <span class="c-num">null</span>,
    <span class="c-key">"finance"</span>: { <span class="c-key">"total_bill"</span>: <span class="c-num">0</span>, <span class="c-key">"total_paid"</span>: <span class="c-num">0</span>, <span class="c-key">"balance"</span>: <span class="c-num">0</span>, <span class="c-comm">...</span> },
    <span class="c-key">"criteria"</span>: [{ <span class="c-key">"rule"</span>: <span class="c-str">"No Active Restriction"</span>, <span class="c-key">"passed"</span>: <span class="c-num">true</span> }],
    <span class="c-key">"summary"</span>: { <span class="c-key">"total_rules"</span>: <span class="c-num">0</span>, <span class="c-key">"rules_passed"</span>: <span class="c-num">0</span>, <span class="c-key">"rules_failed"</span>: <span class="c-num">0</span> },
    <span class="c-key">"guidance"</span>: <span class="c-str">"No active fee access restrictions. All students are granted access."</span>
  }
}</div>

                        <h4 style="font-size:13px;font-weight:700;margin:16px 0 6px;color:#9b59b6;">Example — Bursary Exemption (Short-Circuit)</h4>
                        <div class="api-code"><span class="c-comm">// Student has a bursary that covers ≥ minimum required → all other rules skipped</span>
{
  <span class="c-key">"success"</span>: <span class="c-num">true</span>,
  <span class="c-key">"data"</span>: {
    <span class="c-key">"access_allowed"</span>: <span class="c-num">true</span>,
    <span class="c-key">"has_policy"</span>: <span class="c-num">true</span>,
    <span class="c-key">"verdict"</span>: <span class="c-str">"granted"</span>,
    <span class="c-key">"verdict_reason"</span>: <span class="c-str">"Student is exempt via bursary/scholarship (Government Scholarship)."</span>,
    <span class="c-key">"bursary"</span>: {
      <span class="c-key">"status"</span>: <span class="c-str">"Active: Government Scholarship"</span>,
      <span class="c-key">"scheme_name"</span>: <span class="c-str">"Government Scholarship"</span>,
      <span class="c-key">"amount_offered"</span>: <span class="c-num">2200000</span>,
      <span class="c-key">"coverage_percent"</span>: <span class="c-num">88.0</span>,
      <span class="c-key">"exempt"</span>: <span class="c-num">true</span>
    },
    <span class="c-key">"criteria"</span>: [{
      <span class="c-key">"rule"</span>: <span class="c-str">"Bursary Exemption"</span>,
      <span class="c-key">"passed"</span>: <span class="c-num">true</span>,
      <span class="c-key">"detail"</span>: <span class="c-str">"Bursary/scholarship (Government Scholarship) with 88% coverage — exempt."</span>
    }],
    <span class="c-key">"guidance"</span>: <span class="c-str">""</span>
  }
}</div>

                        <div class="api-note"><strong>Integration:</strong> The student portal uses this endpoint (via <code>FeeAccessHelper</code>) to display a global restriction banner. The admin <em>Fee Access Checker</em> page also calls this endpoint. The portal caches results for 5 minutes per session.</div>
                        <div class="api-note--warn api-note"><strong>Balance sign convention:</strong> <code>finance.balance</code> is <strong>negative</strong> when the student owes money, <strong>positive</strong> when they have a credit. Use <code>finance.amount_owing</code> and <code>finance.credit_balance</code> for unsigned convenience values.</div>
                    </div>
                </div>
            </div>

            <!-- ODEL: Academic Calendar -->
            <div class="api-section" id="odel-calendar">
                <div class="api-section__header">
                    <div class="api-section__title">ODEL — Academic Calendar</div>
                    <div class="api-section__desc">Semester dates, exam periods, and registration deadlines</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> <span class="api-badge api-badge--live">ODEL</span> /API/v2/campus.aspx?action=academic_calendar&amp;acad_year=...</div>
                        <div class="api-endpoint__info"><strong>No auth required.</strong> Academic calendar with semester start/end dates, exam periods, registration deadlines, and current period indicator. Filter by <code>acad_year</code> or get all.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Filter by academic year (e.g. 2024/2025)</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// No authentication needed</span>
GET /API/v2/campus.aspx?action=academic_calendar&amp;acad_year=2024/2025

<span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"current_academic_year"</span>: <span class="c-str">"2024/2025"</span>,
    <span class="c-key">"current_semester"</span>: <span class="c-str">"2"</span>,
    <span class="c-key">"total_periods"</span>: <span class="c-num">2</span>,
    <span class="c-key">"periods"</span>: [
      {
        <span class="c-key">"acad_year"</span>: <span class="c-str">"2024/2025"</span>,
        <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>,
        <span class="c-key">"semester_start"</span>: <span class="c-str">"2024-08-15"</span>,
        <span class="c-key">"semester_end"</span>: <span class="c-str">"2024-12-15"</span>,
        <span class="c-key">"exam_start"</span>: <span class="c-str">"2024-12-01"</span>,
        <span class="c-key">"exam_end"</span>: <span class="c-str">"2024-12-15"</span>,
        <span class="c-key">"registration_deadline"</span>: <span class="c-str">"2024-09-01"</span>,
        <span class="c-key">"is_current"</span>: <span class="c-num">0</span>
      },
      {
        <span class="c-key">"acad_year"</span>: <span class="c-str">"2024/2025"</span>,
        <span class="c-key">"semester"</span>: <span class="c-str">"2"</span>,
        <span class="c-key">"semester_start"</span>: <span class="c-str">"2025-01-15"</span>,
        <span class="c-key">"semester_end"</span>: <span class="c-str">"2025-06-15"</span>,
        <span class="c-key">"exam_start"</span>: <span class="c-str">"2025-06-01"</span>,
        <span class="c-key">"exam_end"</span>: <span class="c-str">"2025-06-15"</span>,
        <span class="c-key">"registration_deadline"</span>: <span class="c-str">"2025-02-01"</span>,
        <span class="c-key">"is_current"</span>: <span class="c-num">1</span>
      }
    ]
  }
}</div>
                    </div>
                </div>
            </div>

            <!-- Changelog -->
            <div class="api-section" id="changelog">
                <div class="api-section__header">
                    <div class="api-section__title">Changelog — v2.2</div>
                    <div class="api-section__desc">What changed in API version 2.2 (May 2026)</div>
                </div>
                <div class="api-section__body">
                    <h4 style="font-size:13px;font-weight:700;margin:0 0 10px;color:#2ecc71;">New Endpoints</h4>
                    <ul class="api-task-list" style="margin-bottom:16px;">
                        <li><span class="api-status api-status--done"></span><strong>finance → student_financial_summary</strong> — Single-call comprehensive financial snapshot. Combines all-time balance, period-specific sub-balance, waiver totals, financial lock flag, and clearance status into one response. Replaces separate <code>balance + waivers + fee_status</code> calls.</li>
                        <li><span class="api-status api-status--done"></span><strong>finance → bulk_fee_check</strong> — Staff-only batch fee check. Up to 200 regnos per request; returns clearance status and balance per student plus a <code>not_found</code> list.</li>
                        <li><span class="api-status api-status--done"></span><strong>academic → student_academic_summary</strong> — Single-call comprehensive academic snapshot. Returns student profile, CGPA, per-semester GPA breakdown, latest registration state, enrollment flag, and retake course list. Replaces separate <code>gpa + registration_history + retake_courses</code> calls.</li>
                        <li><span class="api-status api-status--done"></span><strong>academic → academic_standing</strong> — Evaluates whether a student is in good academic standing. Runs three server-side checks (minimum CGPA ≥ 2.0, active enrollment, outstanding fail count) and returns a boolean verdict with a per-rule <code>checks</code> array for granular client feedback. Analogous to <code>access_status</code> but for academic — not financial — standing.</li>
                    </ul>

                    <h4 style="font-size:13px;font-weight:700;margin:0 0 10px;color:#9b59b6;">Engine Architecture</h4>
                    <ul class="api-task-list" style="margin-bottom:16px;">
                        <li><span class="api-status api-status--done"></span><strong>FinanceEngine.cs</strong> — Centralised finance computation engine. Defines the single authoritative <code>DUAL_LEDGER_SQL</code> (UNION ALL over <code>fin_ledger</code> and <code>fin_studentfeestracking</code> with NOT EXISTS deduplication). Exposes <code>GetDualLedger()</code>, <code>SummariseLedger()</code>, <code>ComputePeriodBalance()</code>, <code>GetWaiverTotal()</code>, <code>HasFinancialLock()</code>, <code>GetClearanceStatus()</code>. The <code>FinancialSummary</code> DTO owns all JSON field names.</li>
                        <li><span class="api-status api-status--done"></span><strong>AcademicEngine.cs</strong> — Centralised academic computation engine. Exposes <code>ComputeGPA()</code> (in-memory CGPA + per-semester breakdown), <code>GetClassification()</code>, <code>MapRegistrationStatus()</code>, <code>IsActiveRegistrationStatus()</code>, <code>IsSemesterOpen()</code>, and <code>GetRetakeCourses()</code>. DTOs: <code>GpaResult</code>, <code>SemesterGPA</code>, <code>RegistrationState</code>.</li>
                        <li><span class="api-status api-status--done"></span><strong>All academic &amp; finance handlers updated</strong> — Every balance computation and GPA calculation now delegates to the engines. No inline SQL duplication; field names are defined once in the engine DTOs.</li>
                    </ul>

                    <h4 style="font-size:13px;font-weight:700;margin:0 0 10px;color:#3498db;">Classification Scale</h4>
                    <ul class="api-task-list">
                        <li><span class="api-status api-status--done"></span>CGPA ≥ 4.4 → <strong>First Class</strong></li>
                        <li><span class="api-status api-status--done"></span>CGPA ≥ 3.6 → <strong>Second Class Upper</strong></li>
                        <li><span class="api-status api-status--done"></span>CGPA ≥ 2.8 → <strong>Second Class Lower</strong></li>
                        <li><span class="api-status api-status--done"></span>CGPA ≥ 2.0 → <strong>Pass</strong></li>
                        <li><span class="api-status api-status--done"></span>CGPA &lt; 2.0 → <strong>Below Pass</strong> (triggers academic probation in <code>academic_standing</code>)</li>
                    </ul>
                </div>
            </div>

            <!-- ═══════════════════════════════════════════════════════════ -->
            <!-- Support Tickets -->
            <div class="api-section" id="support">
                <div class="api-section__header">
                    <div class="api-section__title">Support Tickets</div>
                    <div class="api-section__desc">Student help-desk: submit, track, and reply to tickets. Staff can manage all tickets. DB: <code>campus_dynamics_portal</code> → <code>support_tickets</code>.</div>
                </div>
                <div class="api-section__body">

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/support.aspx?action=issue_types</div>
                        <div class="api-endpoint__info">Return canonical issue type list for the create form. <strong>No token required.</strong></div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/support.aspx?action=list&amp;token=...&amp;status=OPEN&amp;page=1&amp;size=20</div>
                        <div class="api-endpoint__info">List tickets. Students: own tickets only. Staff: all tickets with filters <code>status</code>, <code>issue_type</code>, <code>priority</code>, <code>assigned_to</code>, <code>q</code> (search).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>status</td><td>string</td><td class="api-param--optional">No</td><td>Filter: ALL (default), OPEN, IN_PROGRESS, AWAITING_REPLY, RESOLVED, CLOSED</td></tr>
                            <tr><td>page</td><td>int</td><td class="api-param--optional">No</td><td>Default 1</td></tr>
                            <tr><td>size</td><td>int</td><td class="api-param--optional">No</td><td>Default 20, max 100</td></tr>
                            <tr><td>issue_type</td><td>string</td><td class="api-param--optional">Staff only</td><td>Prefix match, e.g. "Academic"</td></tr>
                            <tr><td>priority</td><td>string</td><td class="api-param--optional">Staff only</td><td>LOW, NORMAL, HIGH, URGENT</td></tr>
                            <tr><td>assigned_to</td><td>string</td><td class="api-param--optional">Staff only</td><td>Filter by assigned staff username</td></tr>
                            <tr><td>q</td><td>string</td><td class="api-param--optional">Staff only</td><td>Search name, regno, subject</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/support.aspx?action=detail&amp;ticket_id=3&amp;token=...</div>
                        <div class="api-endpoint__info">Full ticket with messages and attachments. Internal staff notes (<code>is_internal=1</code>) never returned to students. <code>sender_role=SYSTEM</code> messages contain <code>STATUS_CHANGE:{STATUS}</code> — render as timeline events.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>ticket_id</td><td>int</td><td class="api-param--required">Yes</td><td>Ticket ID</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/support.aspx?action=create&amp;token=...</div>
                        <div class="api-endpoint__info">Submit a new ticket. Rate-limited to 5 per hour per user. Gets <code>issue_type</code> values from <code>action=issue_types</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>issue_type</td><td>string</td><td class="api-param--required">Yes</td><td>Full value e.g. "Academic — Results &amp; Marks"</td></tr>
                            <tr><td>subject</td><td>string</td><td class="api-param--required">Yes</td><td>Short title (max 250 chars)</td></tr>
                            <tr><td>message</td><td>string</td><td class="api-param--required">Yes</td><td>Initial description</td></tr>
                            <tr><td>priority</td><td>string</td><td class="api-param--optional">No</td><td>LOW, NORMAL (default), HIGH, URGENT</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/support.aspx?action=reply&amp;token=... (multipart supported)</div>
                        <div class="api-endpoint__info">Add a reply. Auto-advances status: student reply → IN_PROGRESS, admin reply → AWAITING_REPLY. Cannot reply to CLOSED/RESOLVED tickets. Attach files via multipart (max 3, 5 MB each, jpg/png/gif/pdf/doc/docx/txt).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>ticket_id</td><td>int</td><td class="api-param--required">Yes</td><td></td></tr>
                            <tr><td>message</td><td>string</td><td class="api-param--required">Yes</td><td>Reply text</td></tr>
                            <tr><td>is_internal</td><td>0/1</td><td class="api-param--optional">Staff only</td><td>1 = internal staff note, hidden from students</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/support.aspx?action=update_status&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Change status, priority, and/or assignment in one call. Status change appends a SYSTEM message for audit trail.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>ticket_id</td><td>int</td><td class="api-param--required">Yes</td><td></td></tr>
                            <tr><td>status</td><td>string</td><td class="api-param--optional">No</td><td>OPEN, IN_PROGRESS, AWAITING_REPLY, RESOLVED, CLOSED</td></tr>
                            <tr><td>priority</td><td>string</td><td class="api-param--optional">No</td><td>LOW, NORMAL, HIGH, URGENT</td></tr>
                            <tr><td>assigned_to</td><td>string</td><td class="api-param--optional">No</td><td>Staff username</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/support.aspx?action=close&amp;token=...</div>
                        <div class="api-endpoint__info">Close a ticket. Students can close their own; staff can close any. Already-CLOSED tickets return error <code>ALREADY_CLOSED</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>ticket_id</td><td>int</td><td class="api-param--required">Yes</td><td></td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/support.aspx?action=stats&amp;token=...</div>
                        <div class="api-endpoint__info">Students: counts scoped to own tickets (total, open, in_progress, awaiting_reply, resolved, closed). Staff: global counts plus <code>urgent_open</code>.</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/support.aspx?action=attachment&amp;ticket_id=3&amp;attachment_id=1&amp;token=...</div>
                        <div class="api-endpoint__info">Stream a ticket attachment. Returns raw file bytes with correct Content-Type. Use the <code>download_url</code> field from the <code>detail</code> response. Students must own the ticket.</div>
                    </div>

                </div>
            </div>

            <!-- v2.3 NEW MODULE: Knowledgebase -->
            <div class="api-section" id="knowledgebase">
                <div class="api-section__header">
                    <div class="api-section__title">Knowledgebase</div>
                    <div class="api-section__desc">Self-service help articles with categories — <code>/API/v2/knowledgebase.aspx</code></div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/knowledgebase.aspx?action=categories&amp;token=...</div>
                        <div class="api-endpoint__info">List all categories with article counts. Visibility filtered for students (EMPLOYEES-only categories hidden).</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/knowledgebase.aspx?action=articles&amp;category_id=&amp;token=...</div>
                        <div class="api-endpoint__info">List published articles. Filters: <code>category_id</code>, <code>q</code> (search), <code>page</code>, <code>size</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/knowledgebase.aspx?action=article&amp;id=&amp;token=...</div>
                        <div class="api-endpoint__info">Full article content. Increments view count (debounced 24h per user/article). Drafts restricted to staff.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/knowledgebase.aspx?action=search&amp;q=&amp;token=...</div>
                        <div class="api-endpoint__info">Full-text search across title, description, and content.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/knowledgebase.aspx?action=save_category (staff only)</div>
                        <div class="api-endpoint__info">Create or update a category. Params: <code>id</code> (0=create), <code>name</code>, <code>description</code>, <code>visibility</code> (STUDENTS/EMPLOYEES/BOTH).</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/knowledgebase.aspx?action=delete_category (staff only)</div>
                        <div class="api-endpoint__info">Delete a category. Fails if articles exist in it. Param: <code>id</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/knowledgebase.aspx?action=save_article (staff only)</div>
                        <div class="api-endpoint__info">Create or update an article. Params: <code>id</code>, <code>category_id</code>, <code>title</code>, <code>content</code>, <code>status</code> (DRAFT/PUBLISHED), <code>visibility</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/knowledgebase.aspx?action=delete_article (staff only)</div>
                        <div class="api-endpoint__info">Delete an article by id.</div>
                    </div>
                </div>
            </div>

            <!-- v2.3 NEW MODULE: Admissions (Staff) -->
            <div class="api-section" id="admissions">
                <div class="api-section__header">
                    <div class="api-section__title">Admissions — Staff Management</div>
                    <div class="api-section__desc">Pipeline review, admit/reject, and student registration — <code>/API/v2/admissions.aspx</code> — staff token required</div>
                </div>
                <div class="api-section__body">
                    <div class="api-note" style="margin-bottom:16px;">
                        <strong>Key parameter:</strong> most actions accept <code>entry_no</code> (application reference, e.g. <code>APL2026000042</code>) or <code>choice_id</code> (integer from the list endpoint).
                        <br><strong>Status flow:</strong> DRAFT → SUBMITTED → <strong>UNDER_REVIEW</strong> → ADMITTED | REJECTED | WITHDRAWN
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> admissions.aspx?action=<strong>list</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Paginated applicant list. Filters: <code>status</code> (PENDING/ADMITTED/REJECTED/WITHDRAWN), <code>prog</code>, <code>session</code>, <code>acad_year</code>, <code>q</code> (name/email/entry_no), <code>page</code>, <code>size</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> admissions.aspx?action=<strong>detail</strong>&amp;entry_no=APL2026000042&amp;token=...</div>
                        <div class="api-endpoint__info">Full applicant record: personal details, education, programme choice, documents list, and reviewer notes.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> admissions.aspx?action=<strong>review</strong> (staff only)</div>
                        <div class="api-endpoint__info">Move a SUBMITTED application to UNDER_REVIEW. Sends in-app notification to applicant. Params: <code>entry_no</code> or <code>choice_id</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> admissions.aspx?action=<strong>admit</strong> (staff only)</div>
                        <div class="api-endpoint__info">Set <code>adm_status=1</code> (ADMITTED) and <code>app_status=ADMITTED</code>. Sends congratulations notification. Params: <code>choice_id</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> admissions.aspx?action=<strong>reject</strong> (staff only)</div>
                        <div class="api-endpoint__info">Set <code>adm_status=2</code> (REJECTED). Optional rejection reason is saved as a note and sent in the notification. Params: <code>choice_id</code>, <code>reason</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> admissions.aspx?action=<strong>withdraw</strong> (staff only)</div>
                        <div class="api-endpoint__info">Set <code>adm_status=3</code> (WITHDRAWN). Params: <code>choice_id</code>, <code>reason</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> admissions.aspx?action=<strong>register</strong> (staff only)</div>
                        <div class="api-endpoint__info">Convert ADMITTED applicant to registered student via <code>acad_RegisterApplicant</code> SP. Returns student <code>regno</code>. Params: <code>choice_id</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> admissions.aspx?action=<strong>add_note</strong> (staff only)</div>
                        <div class="api-endpoint__info">Attach a private reviewer note. Params: <code>entry_no</code> or <code>choice_id</code>, <code>note</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> admissions.aspx?action=<strong>notes</strong>&amp;entry_no=APL2026000042&amp;token=...</div>
                        <div class="api-endpoint__info">List all reviewer notes for an application, newest first. Params: <code>entry_no</code> or <code>choice_id</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> admissions.aspx?action=<strong>notify</strong> (staff only)</div>
                        <div class="api-endpoint__info">Send a custom in-app notification to the applicant. Logged in audit trail. Params: <code>entry_no</code> or <code>choice_id</code>, <code>message</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> admissions.aspx?action=<strong>stats</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Pipeline counts: total, pending, admitted, rejected, withdrawn, registered. Also breakdown by programme. Filters: <code>session</code>, <code>acad_year</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> admissions.aspx?action=<strong>application_status</strong>&amp;entry_no=APL2026000042&amp;dob=2000-04-15</div>
                        <div class="api-endpoint__info"><strong>No auth required.</strong> Public self-check by entry number + date of birth. Returns status label; regno only returned if admitted.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> admissions.aspx?action=<strong>repair</strong> (staff only)</div>
                        <div class="api-endpoint__info">Diagnose and auto-fix a partially registered student (missing <code>acad_student</code> or <code>acad_registration</code> record). Param: <code>regno</code>.</div>
                    </div>
                </div>
            </div>

            <!-- v2.4 NEW MODULE: Student Application (apply.aspx) -->
            <div class="api-section" id="apply-auth">
                <div class="api-section__header">
                    <div class="api-section__title">Applications — Account &amp; Auth</div>
                    <div class="api-section__desc">Applicant account registration, login, email verification, and password reset — <code>/API/v2/apply.aspx</code> — no token needed for these</div>
                </div>
                <div class="api-section__body">
                    <div class="api-note" style="margin-bottom:16px;">
                        Applicant tokens are separate from student/staff tokens. After login, pass <code>?token=...</code> to all authenticated endpoints.
                        Login returns <code>"user_type":"applicant"</code>. OTPs are 6-digit codes sent by email, valid 30 minutes.
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>register</strong></div>
                        <div class="api-endpoint__info">Create an applicant account. Sends OTP to email for verification. Params: <code>first_name</code>, <code>last_name</code>, <code>email</code>, <code>password</code> (min 6 chars), <code>phone</code> (optional).</div>
                        <div class="api-code"><span class="c-comm">// Success response</span>
{ <span class="c-key">"status"</span>: <span class="c-str">"success"</span>, <span class="c-key">"data"</span>: { <span class="c-key">"user_id"</span>: <span class="c-num">142</span>, <span class="c-key">"email"</span>: <span class="c-str">"john@example.com"</span>, <span class="c-key">"otp_sent"</span>: <span class="c-key">true</span>, <span class="c-key">"verified"</span>: <span class="c-key">false</span> } }</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>login</strong></div>
                        <div class="api-endpoint__info">Authenticate and receive a 24-hour token. Account locks after 5 failed attempts for 15 minutes. Params: <code>email</code>, <code>password</code>.</div>
                        <div class="api-code">{ <span class="c-key">"token"</span>: <span class="c-str">"a1b2c3...64chars"</span>, <span class="c-key">"user_id"</span>: <span class="c-num">142</span>, <span class="c-key">"is_verified"</span>: <span class="c-key">true</span>, <span class="c-key">"expires_at"</span>: <span class="c-str">"2026-05-25T10:30:00Z"</span> }</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>verify_email</strong></div>
                        <div class="api-endpoint__info">Verify email address with 6-digit OTP from registration email. Params: <code>email</code>, <code>otp</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>resend_otp</strong></div>
                        <div class="api-endpoint__info">Invalidate previous OTP and send a fresh one. Param: <code>email</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>forgot_password</strong></div>
                        <div class="api-endpoint__info">Send a password reset OTP to email. Always returns success (anti-enumeration). Param: <code>email</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>reset_password</strong></div>
                        <div class="api-endpoint__info">Set new password using reset OTP. Params: <code>email</code>, <code>otp</code>, <code>new_password</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>my_profile</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Logged-in applicant profile + application summary (entry_no, app_status, programme, adm_status).</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>change_password</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Change password (requires current password). Params: <code>current_password</code>, <code>new_password</code>.</div>
                    </div>
                </div>
            </div>

            <div class="api-section" id="apply-wizard">
                <div class="api-section__header">
                    <div class="api-section__title">Applications — Wizard &amp; Submission</div>
                    <div class="api-section__desc">3-step application form, draft management, and final submission — applicant token required</div>
                </div>
                <div class="api-section__body">
                    <div class="api-note" style="margin-bottom:16px;">
                        <strong>Application flow:</strong> get_draft → save_step1 → save_step2 → save_step3 → submit → my_application<br>
                        Steps can be saved in any order and resumed at any time while status is DRAFT.
                        After SUBMITTED, fields are locked (read-only).
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>get_draft</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Load all saved data for the current draft application including documents. Returns <code>null</code> if no application started.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>save_step1</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Personal details. Creates draft automatically on first call. Required: <code>surname</code>, <code>other_names</code>, <code>gender</code> (M/F), <code>nationality</code>, <code>phone</code>, <code>dob</code> (YYYY-MM-DD). Optional: <code>religion</code>, <code>address</code>, <code>marital</code>, <code>disability</code>, <code>national_id</code>.</div>
                        <div class="api-code">{ <span class="c-key">"entry_no"</span>: <span class="c-str">"APL2026000042"</span>, <span class="c-key">"step"</span>: <span class="c-num">1</span> }</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>save_step2</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Education history. Required: <code>olevel_school</code>, <code>olevel_index</code>, <code>olevel_year</code>. Optional: <code>olevel_agg</code>, <code>alevel_school</code>, <code>alevel_index</code>, <code>alevel_year</code>, <code>alevel_points</code>, <code>other_inst</code>, <code>other_qual</code>, <code>other_year</code>, <code>other_grade</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>save_step3</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Programme selection + emergency contact. Required: <code>programme</code> (progcode), <code>session</code> (DAY/EVENING/WEEKEND), <code>campus</code>, <code>intake</code>, <code>emergency_name</code>. Optional: <code>sponsor</code>, <code>emergency_rel</code>, <code>emergency_phone</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>submit</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Final submission. Validates all required fields, locks the form, sends confirmation email + notification. Required param: <code>declaration_accepted=1</code>.</div>
                        <div class="api-code">{ <span class="c-key">"entry_no"</span>: <span class="c-str">"APL2026000042"</span>, <span class="c-key">"status"</span>: <span class="c-str">"SUBMITTED"</span> }</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>my_application</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Full application status with programme name, admission decision label, unread notification count, and document count. <code>choice_status_label</code>: PENDING | ADMITTED | REJECTED | WITHDRAWN.</div>
                    </div>
                </div>
            </div>

            <div class="api-section" id="apply-documents">
                <div class="api-section__header">
                    <div class="api-section__title">Applications — Documents</div>
                    <div class="api-section__desc">Upload, list, download, and delete application documents — applicant token required</div>
                </div>
                <div class="api-section__body">
                    <div class="api-note" style="margin-bottom:16px;">
                        <strong>doc_type values:</strong> <code>PHOTO</code> (passport photo), <code>OLEVEL</code> (O-Level cert), <code>ALEVEL</code> (A-Level cert), <code>NATID</code> (national ID), <code>OTHER</code> (any supporting doc)<br>
                        Each type (except OTHER) has one slot — uploading again replaces the previous file.
                        Max size: <strong>5 MB</strong>. Accepted formats: <strong>JPG, PNG, PDF</strong>.
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>documents</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">List all uploaded documents for the applicant's current application.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>upload_document</strong>&amp;token=... (multipart/form-data)</div>
                        <div class="api-endpoint__info">Upload a document file. Form fields: <code>doc_type</code>, <code>file</code> (the file field), <code>token</code>.</div>
                        <div class="api-code">{ <span class="c-key">"id"</span>: <span class="c-num">9</span>, <span class="c-key">"doc_type"</span>: <span class="c-str">"PHOTO"</span>, <span class="c-key">"original_filename"</span>: <span class="c-str">"photo.jpg"</span>, <span class="c-key">"file_size_bytes"</span>: <span class="c-num">87234</span> }</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>delete_document</strong>&amp;id=9&amp;token=...</div>
                        <div class="api-endpoint__info">Delete a specific document by ID. Removes file from disk and database. Param: <code>id</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>get_document</strong>&amp;id=9&amp;token=...</div>
                        <div class="api-endpoint__info"><strong>Returns raw file bytes</strong> (image/jpeg, image/png, or application/pdf). Use as src in an img tag or open in a PDF viewer. Param: <code>id</code>.</div>
                    </div>
                </div>
            </div>

            <div class="api-section" id="apply-notifications">
                <div class="api-section__header">
                    <div class="api-section__title">Applications — Notifications</div>
                    <div class="api-section__desc">In-app notification inbox for applicants — applicant token required</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>notifications</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Paginated notifications newest first. Params: <code>page</code> (default 1), <code>size</code> (default 20, max 50). Returns <code>total</code>, <code>pages</code>, <code>notifications[]</code>.</div>
                        <div class="api-code">{ <span class="c-key">"total"</span>: <span class="c-num">5</span>, <span class="c-key">"notifications"</span>: [{ <span class="c-key">"id"</span>: <span class="c-num">12</span>, <span class="c-key">"message"</span>: <span class="c-str">"Your application has been admitted."</span>, <span class="c-key">"is_read"</span>: <span class="c-num">0</span>, <span class="c-key">"created_at"</span>: <span class="c-str">"2026-05-22 14:30"</span> }] }</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> apply.aspx?action=<strong>mark_read</strong>&amp;token=...</div>
                        <div class="api-endpoint__info">Mark one or all notifications as read. Pass <code>id=12</code> for a single notification; omit <code>id</code> to mark all as read.</div>
                    </div>
                </div>
            </div>

            <div class="api-section" id="apply-public">
                <div class="api-section__header">
                    <div class="api-section__title">Applications — Public Reference Data</div>
                    <div class="api-section__desc">Programmes, faculties, campuses, intakes, and public status check — no auth required</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>programmes</strong></div>
                        <div class="api-endpoint__info">All active programmes with faculty name, duration, and award type. Optional filters: <code>faculty</code> (faculty_code), <code>q</code> (name/code search).</div>
                        <div class="api-code">{ <span class="c-key">"total"</span>: <span class="c-num">42</span>, <span class="c-key">"programmes"</span>: [{ <span class="c-key">"progcode"</span>: <span class="c-str">"BSCSE"</span>, <span class="c-key">"progname"</span>: <span class="c-str">"Bachelor of Science in Computer Science"</span>, <span class="c-key">"duration"</span>: <span class="c-str">"3 Years"</span>, <span class="c-key">"award_type"</span>: <span class="c-str">"Degree"</span> }] }</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>faculties</strong></div>
                        <div class="api-endpoint__info">All faculties: <code>faculty_code</code>, <code>faculty_name</code>. Used to populate a faculty filter for the programmes list.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>campuses</strong></div>
                        <div class="api-endpoint__info">All campuses: <code>campus_code</code>, <code>campus_name</code>. Fallback returns Main Campus if table is empty.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>intakes</strong></div>
                        <div class="api-endpoint__info">Currently open application intakes: <code>id</code>, <code>intake_year</code>, <code>intake_label</code>, <code>session_type</code>, <code>open_from</code>, <code>open_to</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> apply.aspx?action=<strong>check_status</strong>&amp;entry_no=APL2026000042&amp;dob=2000-04-15</div>
                        <div class="api-endpoint__info"><strong>Public.</strong> Check application status without logging in. Requires <code>entry_no</code> + <code>dob</code> (YYYY-MM-DD). Returns status, programme, admission decision. <code>regno</code> only returned if admitted.</div>
                        <div class="api-code">{ <span class="c-key">"stud_entry_no"</span>: <span class="c-str">"APL2026000042"</span>, <span class="c-key">"app_status"</span>: <span class="c-str">"ADMITTED"</span>, <span class="c-key">"choice_status_label"</span>: <span class="c-str">"ADMITTED"</span>, <span class="c-key">"regno"</span>: <span class="c-str">"MRU2026004512"</span> }</div>
                    </div>
                </div>
            </div>

            <!-- v2.3 NEW MODULE: Residence -->
            <div class="api-section" id="residence">
                <div class="api-section__header">
                    <div class="api-section__title">Residence / Hall Allocation</div>
                    <div class="api-section__desc">Student hall assignment management — <code>/API/v2/residence.aspx</code></div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/residence.aspx?action=halls&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">All halls with capacity, occupied count, available count, and occupancy %. Optional filters: <code>acad_year</code>, <code>semester</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/residence.aspx?action=allocations&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Paginated allocations list. Filters: <code>acad_year</code>, <code>semester</code>, <code>hall_id</code>, <code>prog</code>, <code>q</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/residence.aspx?action=allocate (staff only)</div>
                        <div class="api-endpoint__info">Assign student to a hall/room. Enforces capacity and duplicate checks. Params: <code>regno</code>, <code>hall_id</code>, <code>room_id</code>, <code>acad_year</code>, <code>semester</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/residence.aspx?action=deallocate (staff only)</div>
                        <div class="api-endpoint__info">Remove student from hall. Updates <code>residence_status</code> back to NON-RESIDENT. Params: <code>regno</code>, <code>acad_year</code>, <code>semester</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/residence.aspx?action=residence_stats&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Occupancy summary: total_capacity, total_occupied, total_available, overall_occupancy_pct, per-hall breakdown sorted by occupancy.</div>
                    </div>
                </div>
            </div>

            <!-- v2.3 NEW MODULE: Appraisal -->
            <div class="api-section" id="appraisal">
                <div class="api-section__header">
                    <div class="api-section__title">Staff Appraisal</div>
                    <div class="api-section__desc">HR performance appraisal management — <code>/API/v2/appraisal.aspx</code> — staff token required for all endpoints</div>
                </div>
                <div class="api-section__body">
                    <div class="api-note" style="margin-bottom:16px;">
                        <strong>Record status lifecycle:</strong>
                        <code>PENDING</code> → employee saves draft → <code>IN_PROGRESS</code> → employee submits → <code>SUPERVISOR_REVIEW</code> → supervisor submits → <code>COMPLETED</code> (locked).<br>
                        <strong>Score classification:</strong> ≥90% = Excellent | ≥75% = Good | ≥60% = Satisfactory | &lt;60% = Needs Improvement.<br>
                        <strong>Staff categories:</strong> <code>ACADEMIC</code> | <code>ADMINISTRATIVE</code> | <code>SUPPORT</code>
                    </div>

                    <!-- sessions -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/appraisal.aspx?action=sessions&amp;token=...</div>
                        <div class="api-endpoint__info">List appraisal sessions. Regular staff see only ACTIVE sessions they are assigned to (with their record status). Pass <code>all=1</code> to get every session with record counts (admin use).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>all</td><td>int</td><td class="api-param--optional">No</td><td><code>1</code> = admin mode: return all sessions with record counts</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Staff view (all=0, default) — only sessions the employee is assigned to</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total"</span>: <span class="c-num">1</span>,
    <span class="c-key">"sessions"</span>: [
      {
        <span class="c-key">"session_id"</span>: <span class="c-num">3</span>,
        <span class="c-key">"session_title"</span>: <span class="c-str">"2025/2026 Annual Appraisal"</span>,
        <span class="c-key">"period_start"</span>: <span class="c-str">"2025-08-01"</span>,
        <span class="c-key">"period_end"</span>: <span class="c-str">"2026-07-31"</span>,
        <span class="c-key">"deadline"</span>: <span class="c-str">"2026-06-30"</span>,
        <span class="c-key">"status"</span>: <span class="c-str">"ACTIVE"</span>,
        <span class="c-key">"record_id"</span>: <span class="c-num">47</span>,
        <span class="c-key">"record_status"</span>: <span class="c-str">"IN_PROGRESS"</span>,
        <span class="c-key">"final_percentage"</span>: <span class="c-num">null</span>,
        <span class="c-key">"classification"</span>: <span class="c-num">null</span>
      }
    ]
  }
}

<span class="c-comm">// Admin view (all=1) — all sessions with record counts</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total"</span>: <span class="c-num">3</span>,
    <span class="c-key">"sessions"</span>: [
      {
        <span class="c-key">"session_id"</span>: <span class="c-num">3</span>,
        <span class="c-key">"session_title"</span>: <span class="c-str">"2025/2026 Annual Appraisal"</span>,
        <span class="c-key">"session_description"</span>: <span class="c-str">"Annual staff performance review"</span>,
        <span class="c-key">"period_start"</span>: <span class="c-str">"2025-08-01"</span>, <span class="c-key">"period_end"</span>: <span class="c-str">"2026-07-31"</span>,
        <span class="c-key">"deadline"</span>: <span class="c-str">"2026-06-30"</span>,
        <span class="c-key">"target_categories"</span>: <span class="c-str">"ACADEMIC,ADMINISTRATIVE,SUPPORT"</span>,
        <span class="c-key">"status"</span>: <span class="c-str">"ACTIVE"</span>,
        <span class="c-key">"record_count"</span>: <span class="c-num">124</span>
      }
    ]
  }
}</div>
                    </div>

                    <!-- session -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/appraisal.aspx?action=session&amp;session_id=&amp;token=...</div>
                        <div class="api-endpoint__info">Single session detail with live completion statistics (total, pending, in_progress, submitted counts, average percentage).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>session_id</td><td>int</td><td class="api-param--required">Yes</td><td>Appraisal session ID</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"session_id"</span>: <span class="c-num">3</span>,
    <span class="c-key">"session_title"</span>: <span class="c-str">"2025/2026 Annual Appraisal"</span>,
    <span class="c-key">"session_description"</span>: <span class="c-str">"Annual staff performance review"</span>,
    <span class="c-key">"period_start"</span>: <span class="c-str">"2025-08-01"</span>, <span class="c-key">"period_end"</span>: <span class="c-str">"2026-07-31"</span>,
    <span class="c-key">"deadline"</span>: <span class="c-str">"2026-06-30"</span>,
    <span class="c-key">"target_categories"</span>: <span class="c-str">"ACADEMIC,ADMINISTRATIVE,SUPPORT"</span>,
    <span class="c-key">"status"</span>: <span class="c-str">"ACTIVE"</span>,
    <span class="c-key">"stats"</span>: {
      <span class="c-key">"total"</span>: <span class="c-num">124</span>, <span class="c-key">"pending"</span>: <span class="c-num">12</span>, <span class="c-key">"in_progress"</span>: <span class="c-num">38</span>,
      <span class="c-key">"emp_submitted"</span>: <span class="c-num">74</span>, <span class="c-key">"sup_submitted"</span>: <span class="c-num">60</span>,
      <span class="c-key">"avg_percentage"</span>: <span class="c-str">"72.40"</span>
    }
  }
}</div>
                    </div>

                    <!-- create_session -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/appraisal.aspx?action=create_session (staff only)</div>
                        <div class="api-endpoint__info">Create a new appraisal session. Sessions start as DRAFT; set <code>status=ACTIVE</code> to open them for staff.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>session_title</td><td>string</td><td class="api-param--required">Yes</td><td>Display name (e.g. "2025/2026 Annual Appraisal")</td></tr>
                            <tr><td>period_start</td><td>date</td><td class="api-param--required">Yes</td><td>Appraisal period start (YYYY-MM-DD)</td></tr>
                            <tr><td>period_end</td><td>date</td><td class="api-param--required">Yes</td><td>Appraisal period end (YYYY-MM-DD)</td></tr>
                            <tr><td>deadline</td><td>date</td><td class="api-param--required">Yes</td><td>Submission deadline (YYYY-MM-DD)</td></tr>
                            <tr><td>session_description</td><td>string</td><td class="api-param--optional">No</td><td>Optional description</td></tr>
                            <tr><td>target_categories</td><td>string</td><td class="api-param--optional">No</td><td>Comma-separated: <code>ACADEMIC,ADMINISTRATIVE,SUPPORT</code> (default)</td></tr>
                            <tr><td>status</td><td>string</td><td class="api-param--optional">No</td><td><code>DRAFT</code> (default) | <code>ACTIVE</code> | <code>CLOSED</code></td></tr>
                        </table>
                        <div class="api-code">{ <span class="c-key">"data"</span>: { <span class="c-key">"session_id"</span>: <span class="c-num">4</span>, <span class="c-key">"status"</span>: <span class="c-str">"DRAFT"</span> }, <span class="c-key">"message"</span>: <span class="c-str">"Appraisal session created"</span> }</div>
                    </div>

                    <!-- update_session -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/appraisal.aspx?action=update_session (staff only)</div>
                        <div class="api-endpoint__info">Update any session field. Only provided fields are changed (dynamic SET). Use <code>status=ACTIVE</code> to open a session, <code>status=CLOSED</code> to close it.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>session_id</td><td>int</td><td class="api-param--required">Yes</td><td>Session to update</td></tr>
                            <tr><td>session_title</td><td>string</td><td class="api-param--optional">No</td><td>New title</td></tr>
                            <tr><td>session_description</td><td>string</td><td class="api-param--optional">No</td><td>New description</td></tr>
                            <tr><td>period_start / period_end</td><td>date</td><td class="api-param--optional">No</td><td>New period dates</td></tr>
                            <tr><td>deadline</td><td>date</td><td class="api-param--optional">No</td><td>New deadline</td></tr>
                            <tr><td>target_categories</td><td>string</td><td class="api-param--optional">No</td><td>Updated category list</td></tr>
                            <tr><td>status</td><td>string</td><td class="api-param--optional">No</td><td><code>DRAFT</code> | <code>ACTIVE</code> | <code>CLOSED</code></td></tr>
                        </table>
                        <div class="api-code">{ <span class="c-key">"data"</span>: { <span class="c-key">"session_id"</span>: <span class="c-num">3</span> }, <span class="c-key">"message"</span>: <span class="c-str">"Session updated"</span> }</div>
                    </div>

                    <!-- my_appraisals -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/appraisal.aspx?action=my_appraisals&amp;token=...</div>
                        <div class="api-endpoint__info">All appraisal records assigned to the logged-in staff member, across all sessions, newest deadline first.</div>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total"</span>: <span class="c-num">2</span>,
    <span class="c-key">"records"</span>: [
      {
        <span class="c-key">"record_id"</span>: <span class="c-num">47</span>,
        <span class="c-key">"session_id"</span>: <span class="c-num">3</span>,
        <span class="c-key">"session_title"</span>: <span class="c-str">"2025/2026 Annual Appraisal"</span>,
        <span class="c-key">"deadline"</span>: <span class="c-str">"2026-06-30"</span>,
        <span class="c-key">"session_status"</span>: <span class="c-str">"ACTIVE"</span>,
        <span class="c-key">"staff_category"</span>: <span class="c-str">"ACADEMIC"</span>,
        <span class="c-key">"record_status"</span>: <span class="c-str">"IN_PROGRESS"</span>,
        <span class="c-key">"emp_submitted_at"</span>: <span class="c-num">null</span>,
        <span class="c-key">"sup_submitted_at"</span>: <span class="c-num">null</span>,
        <span class="c-key">"final_percentage"</span>: <span class="c-num">null</span>,
        <span class="c-key">"classification"</span>: <span class="c-num">null</span>
      }
    ]
  }
}</div>
                    </div>

                    <!-- appraisal_record -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/appraisal.aspx?action=appraisal_record&amp;record_id=&amp;token=...</div>
                        <div class="api-endpoint__info">Full appraisal record with all four section data arrays. Section B = competency ratings; Section C = overall assessment score; Section D = gaps &amp; action plan rows; Section E = narrative question responses.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>record_id</td><td>int</td><td class="api-param--required">Yes</td><td>Appraisal record ID (from <code>my_appraisals</code>)</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"record_id"</span>: <span class="c-num">47</span>, <span class="c-key">"session_id"</span>: <span class="c-num">3</span>,
    <span class="c-key">"session_title"</span>: <span class="c-str">"2025/2026 Annual Appraisal"</span>,
    <span class="c-key">"period_start"</span>: <span class="c-str">"2025-08-01"</span>, <span class="c-key">"period_end"</span>: <span class="c-str">"2026-07-31"</span>, <span class="c-key">"deadline"</span>: <span class="c-str">"2026-06-30"</span>,
    <span class="c-key">"employee_id"</span>: <span class="c-num">12</span>, <span class="c-key">"reviewer_id"</span>: <span class="c-num">5</span>,
    <span class="c-key">"staff_category"</span>: <span class="c-str">"ACADEMIC"</span>,
    <span class="c-key">"status"</span>: <span class="c-str">"SUPERVISOR_REVIEW"</span>,
    <span class="c-key">"emp_submitted_at"</span>: <span class="c-str">"2026-05-10 09:32"</span>, <span class="c-key">"sup_submitted_at"</span>: <span class="c-num">null</span>,
    <span class="c-key">"section_b_self_total"</span>: <span class="c-num">142</span>,
    <span class="c-key">"section_b_supervisor_total"</span>: <span class="c-num">null</span>,
    <span class="c-key">"section_c_total"</span>: <span class="c-num">null</span>,
    <span class="c-key">"final_percentage"</span>: <span class="c-num">null</span>, <span class="c-key">"classification"</span>: <span class="c-num">null</span>,
    <span class="c-key">"section_b"</span>: [
      { <span class="c-key">"id"</span>: <span class="c-num">201</span>, <span class="c-key">"competency_id"</span>: <span class="c-num">1</span>, <span class="c-key">"competency_name"</span>: <span class="c-str">"Teaching Quality"</span>,
        <span class="c-key">"competency_description"</span>: <span class="c-str">"..."</span>, <span class="c-key">"self_score"</span>: <span class="c-num">4</span>,
        <span class="c-key">"supervisor_score"</span>: <span class="c-num">null</span>, <span class="c-key">"max_score"</span>: <span class="c-num">5</span> }
    ],
    <span class="c-key">"section_c"</span>: { <span class="c-key">"record_id"</span>: <span class="c-num">47</span>, <span class="c-key">"total"</span>: <span class="c-num">null</span>, <span class="c-key">"comments"</span>: <span class="c-num">null</span> },
    <span class="c-key">"section_d"</span>: [],
    <span class="c-key">"section_e"</span>: []
  }
}</div>
                    </div>

                    <!-- save_self_appraisal -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/appraisal.aspx?action=save_self_appraisal</div>
                        <div class="api-endpoint__info">Employee saves their section B self-scores as a draft. Can be called multiple times (upsert per competency). Rejected if the employee has already formally submitted (<code>submit_appraisal role=employee</code>).</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>record_id</td><td>int</td><td class="api-param--required">Yes</td><td>Appraisal record to update</td></tr>
                            <tr><td>ratings</td><td>JSON string</td><td class="api-param--required">Yes</td><td>Array of <code>[{"competency_id": 1, "self_score": 4}, ...]</code></td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// ratings param example</span>
[{"competency_id": 1, "self_score": 4}, {"competency_id": 2, "self_score": 3}]

<span class="c-comm">// Response</span>
{ <span class="c-key">"data"</span>: { <span class="c-key">"record_id"</span>: <span class="c-num">47</span>, <span class="c-key">"ratings_saved"</span>: <span class="c-num">2</span>, <span class="c-key">"self_total"</span>: <span class="c-num">7</span> }, <span class="c-key">"message"</span>: <span class="c-str">"Self-appraisal saved"</span> }

<span class="c-comm">// Error if already submitted</span>
{ <span class="c-key">"error_code"</span>: <span class="c-str">"ALREADY_SUBMITTED"</span>, <span class="c-key">"message"</span>: <span class="c-str">"Self-appraisal already submitted and locked."</span> }</div>
                    </div>

                    <!-- save_supervisor_appraisal -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/appraisal.aspx?action=save_supervisor_appraisal</div>
                        <div class="api-endpoint__info">Supervisor saves their section B scores and/or section C assessment. Automatically recomputes <code>final_percentage</code> and <code>classification</code>. Employee must have submitted first. Rejected if supervisor already submitted.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>record_id</td><td>int</td><td class="api-param--required">Yes</td><td>Appraisal record to score</td></tr>
                            <tr><td>ratings</td><td>JSON string</td><td class="api-param--optional">No</td><td>Array of <code>[{"competency_id": 1, "supervisor_score": 4}, ...]</code></td></tr>
                            <tr><td>section_c</td><td>JSON string</td><td class="api-param--optional">No</td><td><code>{"total": 25, "comments": "..."}</code> — overall assessment score</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{ <span class="c-key">"data"</span>: { <span class="c-key">"record_id"</span>: <span class="c-num">47</span>, <span class="c-key">"supervisor_total"</span>: <span class="c-num">138</span> }, <span class="c-key">"message"</span>: <span class="c-str">"Supervisor appraisal saved"</span> }

<span class="c-comm">// Error codes: BUSINESS_ERROR (employee not submitted yet) | ALREADY_SUBMITTED</span></div>
                    </div>

                    <!-- submit_appraisal -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/appraisal.aspx?action=submit_appraisal</div>
                        <div class="api-endpoint__info">Formally lock a submission. Employee submission advances status to <code>SUPERVISOR_REVIEW</code>; supervisor submission advances to <code>COMPLETED</code> (fully locked). Both are irreversible.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>record_id</td><td>int</td><td class="api-param--required">Yes</td><td>Record to submit</td></tr>
                            <tr><td>role</td><td>string</td><td class="api-param--required">Yes</td><td><code>employee</code> or <code>supervisor</code></td></tr>
                        </table>
                        <div class="api-code">{ <span class="c-key">"data"</span>: { <span class="c-key">"record_id"</span>: <span class="c-num">47</span>, <span class="c-key">"role_submitted"</span>: <span class="c-str">"employee"</span> }, <span class="c-key">"message"</span>: <span class="c-str">"Submission locked"</span> }

<span class="c-comm">// Error codes: ALREADY_SUBMITTED | BUSINESS_ERROR (employee must submit before supervisor)</span></div>
                    </div>

                    <!-- report -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/appraisal.aspx?action=report&amp;session_id=&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Session-level aggregate report: completion counts, average score, classification distribution, and per-employee rows with department and submission status.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>session_id</td><td>int</td><td class="api-param--required">Yes</td><td>Session to report on</td></tr>
                            <tr><td>category</td><td>string</td><td class="api-param--optional">No</td><td>Filter by <code>ACADEMIC</code> | <code>ADMINISTRATIVE</code> | <code>SUPPORT</code></td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"session_id"</span>: <span class="c-num">3</span>,
    <span class="c-key">"total_records"</span>: <span class="c-num">124</span>,
    <span class="c-key">"avg_percentage"</span>: <span class="c-num">72.4</span>,
    <span class="c-key">"classification_summary"</span>: { <span class="c-key">"Excellent"</span>: <span class="c-num">18</span>, <span class="c-key">"Good"</span>: <span class="c-num">45</span>, <span class="c-key">"Satisfactory"</span>: <span class="c-num">38</span>, <span class="c-key">"Needs Improvement"</span>: <span class="c-num">8</span>, <span class="c-key">"Pending"</span>: <span class="c-num">15</span> },
    <span class="c-key">"records"</span>: [
      { <span class="c-key">"record_id"</span>: <span class="c-num">47</span>, <span class="c-key">"emp_name"</span>: <span class="c-str">"Dr. Alice Nakato"</span>, <span class="c-key">"emp_type"</span>: <span class="c-str">"ACADEMIC"</span>,
        <span class="c-key">"department"</span>: <span class="c-str">"School of Computing"</span>, <span class="c-key">"staff_category"</span>: <span class="c-str">"ACADEMIC"</span>,
        <span class="c-key">"status"</span>: <span class="c-str">"COMPLETED"</span>, <span class="c-key">"final_percentage"</span>: <span class="c-num">81.5</span>, <span class="c-key">"classification"</span>: <span class="c-str">"Good"</span>,
        <span class="c-key">"emp_submitted"</span>: <span class="c-num">1</span>, <span class="c-key">"sup_submitted"</span>: <span class="c-num">1</span> }
    ]
  }
}</div>
                    </div>

                    <!-- export_report -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/appraisal.aspx?action=export_report&amp;session_id=&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Download full session results as <code>text/csv</code>. Columns: Employee, Type, Department, Category, Status, Self_Score, Supervisor_Score, Assessment_Score, Final_Percentage, Classification. Browser will trigger a file download named <code>appraisal_session_{id}.csv</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>session_id</td><td>int</td><td class="api-param--required">Yes</td><td>Session to export</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Returns text/csv — not JSON. Use as a direct download link or fetch with blob handling.</span>
Employee,Type,Department,Category,Status,Self_Score,Supervisor_Score,Assessment_Score,Final_Percentage,Classification
Dr. Alice Nakato,ACADEMIC,School of Computing,ACADEMIC,COMPLETED,142,138,25,81.5,Good</div>
                    </div>

                    <!-- competency_templates -->
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/appraisal.aspx?action=competency_templates&amp;token=...</div>
                        <div class="api-endpoint__info">List all competency criteria from <code>appraisal_competency_templates</code>. Used to build the section B scoring form. Optionally filter by <code>staff_category</code> — items with <code>staff_category = 'BOTH'</code> are always included.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>staff_category</td><td>string</td><td class="api-param--optional">No</td><td><code>ACADEMIC</code> | <code>ADMINISTRATIVE</code> | <code>SUPPORT</code> — omit for all</td></tr>
                        </table>
                        <div class="api-code"><span class="c-comm">// Response</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"total"</span>: <span class="c-num">52</span>,
    <span class="c-key">"staff_category"</span>: <span class="c-str">"ACADEMIC"</span>,
    <span class="c-key">"templates"</span>: [
      { <span class="c-key">"id"</span>: <span class="c-num">1</span>, <span class="c-key">"competency_name"</span>: <span class="c-str">"Teaching Quality"</span>,
        <span class="c-key">"competency_description"</span>: <span class="c-str">"Quality of lectures, materials and student feedback"</span>,
        <span class="c-key">"max_score"</span>: <span class="c-num">5</span>, <span class="c-key">"staff_category"</span>: <span class="c-str">"ACADEMIC"</span>, <span class="c-key">"sort_order"</span>: <span class="c-num">1</span> }
    ]
  }
}</div>
                    </div>
                </div>
            </div>

            <!-- v2.3 EXTENSION: Chart of Accounts -->
            <div class="api-section" id="chart-of-accounts">
                <div class="api-section__header">
                    <div class="api-section__title">Chart of Accounts</div>
                    <div class="api-section__desc">Finance ledger account management — extended <code>/API/v2/finance.aspx</code> (staff only)</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=chart_of_accounts&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Paginated list from <code>fin_mainaccounts</code>. Filters: <code>q</code> (code/name), <code>category</code>, <code>page</code>, <code>size</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/finance.aspx?action=account&amp;id=&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Single account detail by id.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/finance.aspx?action=create_account (staff only)</div>
                        <div class="api-endpoint__info">Create a new account. Tries <code>CALL MainAccountEditor(...)</code> SP first, falls back to direct INSERT. Params: <code>account_code</code>, <code>account_name</code>, <code>category</code>, <code>description</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/finance.aspx?action=update_account (staff only)</div>
                        <div class="api-endpoint__info">Update account fields. Dynamic SET from provided params. Param: <code>id</code> required.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/finance.aspx?action=delete_account (staff only)</div>
                        <div class="api-endpoint__info">Delete an account. Tries <code>CALL DeleteMainAccount(@id)</code> SP first, falls back to direct DELETE. Param: <code>id</code>.</div>
                    </div>
                </div>
            </div>

            <!-- v2.3 EXTENSION: Provisional Marks -->
            <div class="api-section" id="provisional-marks">
                <div class="api-section__header">
                    <div class="api-section__title">Provisional Marks</div>
                    <div class="api-section__desc">Lecturer provisional mark entry — extended <code>/API/v2/staff.aspx</code></div>
                </div>
                <div class="api-section__body">
                    <div class="api-note" style="margin-bottom:16px;">Lecturers can only access courses assigned to them via <code>acad_programmecourses.lecturer_id</code>. Marks are locked once status is <code>published</code>. CW max: 40. Exam max: 60.</div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=provisional_marks_list&amp;token=...</div>
                        <div class="api-endpoint__info">List enrolled students with their provisional marks for the lecturer's courses. Filters: <code>acad_year</code>, <code>semester</code>, <code>prog</code>, <code>status</code> (not_entered/pending/others), <code>sq</code> (student search).</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=save_provisional_mark</div>
                        <div class="api-endpoint__info">Save/update CW and exam marks for one student. Params: <code>reg_id</code>, <code>cw</code> (0–40), <code>exam</code> (0–60).</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=save_provisional_mark_inline</div>
                        <div class="api-endpoint__info">Update a single mark field (CW or exam) without requiring both. Params: <code>reg_id</code>, <code>field</code> (cw/exam), <code>value</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=provisional_marks_summary&amp;token=...</div>
                        <div class="api-endpoint__info">Per-course aggregates: total, entered, not_entered, pending, approved, published counts.</div>
                    </div>
                </div>
            </div>

            <!-- v2.3 EXTENSION: Semester Deletion Requests -->
            <div class="api-section" id="semester-deletion">
                <div class="api-section__header">
                    <div class="api-section__title">Semester Deletion Requests</div>
                    <div class="api-section__desc">Student semester registration deletion workflow — extended <code>/API/v2/academic.aspx</code></div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/academic.aspx?action=submit_semester_deletion (student)</div>
                        <div class="api-endpoint__info">Student submits a request to delete their semester registration. Params: <code>acad_year</code>, <code>semester</code>, <code>reason</code>. Blocked if a PENDING request already exists.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=list_semester_deletion_requests&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Paginated list. Filters: <code>status</code> (PENDING/APPROVED/REJECTED), <code>acad_year</code>, <code>prog</code>, <code>q</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/academic.aspx?action=semester_deletion_detail&amp;id=&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Single request detail.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/academic.aspx?action=decide_semester_deletion (staff only)</div>
                        <div class="api-endpoint__info">Approve or reject one request. If APPROVED, deletes <code>acad_course_registration</code> rows for that semester. Params: <code>id</code>, <code>decision</code> (APPROVED/REJECTED), <code>comment</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/academic.aspx?action=batch_decide_semester_deletion (staff only)</div>
                        <div class="api-endpoint__info">Batch approve/reject up to 50 requests. Params: <code>ids</code> (comma-separated), <code>decision</code>, <code>comment</code>. Returns succeeded/failed counts.</div>
                    </div>
                </div>
            </div>

            <!-- v2.3 EXTENSION: HR Employees -->
            <div class="api-section" id="hr-employees">
                <div class="api-section__header">
                    <div class="api-section__title">HR Employee Management</div>
                    <div class="api-section__desc">Staff CRUD and contract management — extended <code>/API/v2/staff.aspx</code> (staff only)</div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=employees&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Paginated employee list with department and contract info. Filters: <code>dept</code>, <code>type</code> (academic/admin), <code>status</code>, <code>q</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=create_employee (staff only)</div>
                        <div class="api-endpoint__info">Create a new employee record. Params: <code>emp_code</code>, <code>emp_name</code>, <code>emp_email</code>, <code>emp_phone</code>, <code>emp_type</code>, <code>usernames</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=update_employee (staff only)</div>
                        <div class="api-endpoint__info">Update any combination of employee fields. Only provided params are changed. Param: <code>emp_id</code> required.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=update_contract (staff only)</div>
                        <div class="api-endpoint__info">Expire the current VALID contract and insert a new one. Params: <code>emp_id</code>, <code>department_id</code>, <code>designation</code>, <code>salary</code>, <code>start_date</code>, <code>end_date</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=departments&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">All departments with employee_count. Cached 1 hour. Optional filter: <code>faculty_code</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=mark_requests_list&amp;token=...</div>
                        <div class="api-endpoint__info">Mark amendment requests for the authenticated lecturer. Filters: <code>status</code>, <code>acad_year</code>, <code>semester</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/staff.aspx?action=create_mark_request</div>
                        <div class="api-endpoint__info">Submit a mark amendment request. Params: <code>reg_id</code>, <code>old_cw</code>, <code>new_cw</code>, <code>old_exam</code>, <code>new_exam</code>, <code>reason</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/staff.aspx?action=mark_request_detail&amp;id=&amp;token=...</div>
                        <div class="api-endpoint__info">Single mark request detail.</div>
                    </div>
                </div>
            </div>

            <!-- v2.3 EXTENSION: Onboarding -->
            <div class="api-section" id="onboarding">
                <div class="api-section__header">
                    <div class="api-section__title">Portal Onboarding</div>
                    <div class="api-section__desc">Student/staff portal account verification tracking — extended <code>/API/v2/student.aspx</code></div>
                </div>
                <div class="api-section__body">
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=onboarding_list&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Paginated list of onboarded users. Filters: <code>status</code> (verification_status), <code>user_type</code> (STUDENT/LECTURER), <code>prog</code>, <code>q</code>.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=onboarding_stats&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Counts by onboarding/verification status. Returns total_onboarded and breakdown array.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=resolve_onboarding_email&amp;regno=&amp;token=... (staff only)</div>
                        <div class="api-endpoint__info">Look up the best email for a student/staff. Checks portal verified_email → hrm_employee.emp_email → acad_student.email in priority order. Returns email and source.</div>
                    </div>
                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=application_detail&amp;token=...</div>
                        <div class="api-endpoint__info">Student's own post-admission application record. Staff can pass <code>?regno=</code> to view any. Returns admission status label, programme, and application details.</div>
                    </div>
                    <div class="api-note">The <code>profile</code> action now accepts <code>?include=next_of_kin,sponsor,onboarding</code> to embed extra data in a single call.</div>

                    <!-- ── Profile Extras ── -->
                    <div style="margin:20px 0 12px;padding:8px 12px;background:#f0f4f8;border-left:3px solid #05275C;font-weight:700;font-size:13px;color:#05275C;text-transform:uppercase;letter-spacing:.5px;">Profile Extras &amp; Self-Service</div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/student.aspx?action=update_contact&amp;token=...</div>
                        <div class="api-endpoint__info">Update student contact details. Student can update own details; staff can pass <code>?regno=</code>. Only supplied fields are changed.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>phone</td><td>string</td><td class="api-param--optional">No</td><td>Mobile phone number</td></tr>
                            <tr><td>email</td><td>string</td><td class="api-param--optional">No</td><td>Email address</td></tr>
                            <tr><td>address</td><td>string</td><td class="api-param--optional">No</td><td>Residential address</td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=guardian&amp;token=...</div>
                        <div class="api-endpoint__info">Fetch next-of-kin / guardian information from <code>acad_student</code> — name, relationship, phone, email, address, occupation. Returns empty strings gracefully if guardian columns are not configured in the DB.</div>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"guardian_name"</span>:         <span class="c-str">"Robert Kiggundu"</span>,
    <span class="c-key">"guardian_relationship"</span>: <span class="c-str">"Father"</span>,
    <span class="c-key">"guardian_phone"</span>:        <span class="c-str">"+256701234567"</span>,
    <span class="c-key">"guardian_email"</span>:        <span class="c-str">"r.kiggundu@gmail.com"</span>,
    <span class="c-key">"guardian_address"</span>:      <span class="c-str">"Kampala, Uganda"</span>,
    <span class="c-key">"guardian_occupation"</span>:   <span class="c-str">"Businessman"</span>
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--post">POST</span> /API/v2/student.aspx?action=update_guardian&amp;token=...</div>
                        <div class="api-endpoint__info">Update next-of-kin / guardian details. Student updates own; staff pass <code>?regno=</code>. Dynamic SET — only supplied fields are written.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>guardian_name</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>guardian_relationship</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>guardian_phone</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>guardian_email</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>guardian_address</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                            <tr><td>guardian_occupation</td><td>string</td><td class="api-param--optional">No</td><td></td></tr>
                        </table>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=enrollment_history&amp;token=...</div>
                        <div class="api-endpoint__info">Full registration history across all academic years and semesters — study year, status, registration date, late-reg flag, programme. Staff can pass <code>?regno=</code>.</div>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>: <span class="c-str">"MRU2024001002"</span>, <span class="c-key">"total"</span>: <span class="c-num">4</span>,
    <span class="c-key">"history"</span>: [
      { <span class="c-key">"registration_id"</span>: <span class="c-num">892</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2025/2026"</span>, <span class="c-key">"semester"</span>: <span class="c-str">"1"</span>, <span class="c-key">"study_year"</span>: <span class="c-num">2</span>, <span class="c-key">"status"</span>: <span class="c-str">"Registered"</span>, <span class="c-key">"is_active"</span>: <span class="c-num">true</span>, <span class="c-key">"is_late"</span>: <span class="c-num">false</span>, <span class="c-key">"reg_date"</span>: <span class="c-str">"2025-08-15"</span>, <span class="c-key">"programme"</span>: <span class="c-str">"Bachelor of Business Administration"</span> },
      { <span class="c-key">"registration_id"</span>: <span class="c-num">812</span>, <span class="c-key">"acad_year"</span>: <span class="c-str">"2024/2025"</span>, <span class="c-key">"semester"</span>: <span class="c-str">"2"</span>, <span class="c-key">"study_year"</span>: <span class="c-num">1</span>, <span class="c-key">"status"</span>: <span class="c-str">"Registered"</span>, <span class="c-key">"is_active"</span>: <span class="c-num">true</span>, <span class="c-key">"is_late"</span>: <span class="c-num">false</span>, <span class="c-key">"reg_date"</span>: <span class="c-str">"2025-02-01"</span>, <span class="c-key">"programme"</span>: <span class="c-str">"Bachelor of Business Administration"</span> }
    ]
  }
}</div>
                    </div>

                    <div class="api-endpoint" data-status="live">
                        <div class="api-endpoint__path"><span class="api-badge api-badge--get">GET</span> /API/v2/student.aspx?action=clearance&amp;token=...</div>
                        <div class="api-endpoint__info">Aggregated clearance check — financial balance, registration status, and financial lock. Optionally scoped to a specific period. Staff can pass <code>?regno=</code>.</div>
                        <table class="api-endpoint__params">
                            <tr><th>Parameter</th><th>Type</th><th>Required</th><th>Description</th></tr>
                            <tr><td>acad_year</td><td>string</td><td class="api-param--optional">No</td><td>Scope to this year (default: all-time)</td></tr>
                            <tr><td>semester</td><td>string</td><td class="api-param--optional">No</td><td>Scope to this semester</td></tr>
                        </table>
                        <div class="api-code">{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"regno"</span>:        <span class="c-str">"MRU2024001002"</span>,
    <span class="c-key">"overall"</span>:      <span class="c-str">"CLEARED"</span>,
    <span class="c-key">"is_cleared"</span>:   <span class="c-num">true</span>,
    <span class="c-key">"pass_count"</span>:   <span class="c-num">3</span>,
    <span class="c-key">"total_checks"</span>: <span class="c-num">3</span>,
    <span class="c-key">"checks"</span>: [
      { <span class="c-key">"check"</span>: <span class="c-str">"Financial"</span>,       <span class="c-key">"cleared"</span>: <span class="c-num">true</span>,  <span class="c-key">"detail"</span>: <span class="c-str">"No outstanding balance."</span>,          <span class="c-key">"balance"</span>: <span class="c-num">0</span> },
      { <span class="c-key">"check"</span>: <span class="c-str">"Registration"</span>,    <span class="c-key">"cleared"</span>: <span class="c-num">true</span>,  <span class="c-key">"detail"</span>: <span class="c-str">"Registered for the period."</span>,        <span class="c-key">"status"</span>: <span class="c-str">"Registered"</span> },
      { <span class="c-key">"check"</span>: <span class="c-str">"Financial Lock"</span>, <span class="c-key">"cleared"</span>: <span class="c-num">true</span>,  <span class="c-key">"detail"</span>: <span class="c-str">"No financial hold."</span> }
    ]
  }
}

<span class="c-comm">// NOT_CLEARED response example</span>
{
  <span class="c-key">"data"</span>: {
    <span class="c-key">"overall"</span>:    <span class="c-str">"NOT_CLEARED"</span>, <span class="c-key">"is_cleared"</span>: <span class="c-num">false</span>, <span class="c-key">"pass_count"</span>: <span class="c-num">1</span>, <span class="c-key">"total_checks"</span>: <span class="c-num">3</span>,
    <span class="c-key">"checks"</span>: [
      { <span class="c-key">"check"</span>: <span class="c-str">"Financial"</span>,    <span class="c-key">"cleared"</span>: <span class="c-num">false</span>, <span class="c-key">"detail"</span>: <span class="c-str">"Outstanding balance: UGX 750,000"</span>, <span class="c-key">"balance"</span>: <span class="c-num">750000</span> },
      { <span class="c-key">"check"</span>: <span class="c-str">"Registration"</span>, <span class="c-key">"cleared"</span>: <span class="c-num">true</span>,  <span class="c-key">"detail"</span>: <span class="c-str">"Registered for the period."</span> }
    ]
  }
}</div>
                    </div>
                </div>
            </div>

            <!-- Changelog v2.3 -->
            <div class="api-section" id="changelog-v23">
                <div class="api-section__header">
                    <div class="api-section__title">Changelog — v2.3</div>
                    <div class="api-section__desc">Major expansion: 75 new endpoints across 9 modules (May 2026)</div>
                </div>
                <div class="api-section__body">
                    <h4 style="font-size:13px;font-weight:700;margin:0 0 10px;color:#2ecc71;">New API Files</h4>
                    <ul class="api-task-list" style="margin-bottom:16px;">
                        <li><span class="api-status api-status--done"></span><strong>support.aspx</strong> — 7 endpoints: Student help-desk ticketing system with messages, attachments, internal notes, and admin stats.</li>
                        <li><span class="api-status api-status--done"></span><strong>knowledgebase.aspx</strong> — 8 endpoints: Self-service knowledge base with categories, articles, full-text search, view-count debounce, and staff CRUD.</li>
                        <li><span class="api-status api-status--done"></span><strong>admissions.aspx</strong> — 10 endpoints: Full admissions pipeline — list, admit/reject/withdraw decisions, student registration from application, repair tool, notes, pipeline stats, and a public application status check endpoint.</li>
                        <li><span class="api-status api-status--done"></span><strong>residence.aspx</strong> — 5 endpoints: Hall listing with occupancy, paginated allocations, allocate/deallocate with capacity enforcement, and residence stats.</li>
                        <li><span class="api-status api-status--done"></span><strong>appraisal.aspx</strong> — 12 endpoints: HR performance appraisal — session management, employee self-appraisal, supervisor scoring, two-phase submission workflow, reporting, and CSV export.</li>
                    </ul>

                    <h4 style="font-size:13px;font-weight:700;margin:0 0 10px;color:#3498db;">Extended Existing Files</h4>
                    <ul class="api-task-list" style="margin-bottom:16px;">
                        <li><span class="api-status api-status--done"></span><strong>finance.aspx +14</strong> — Chart of accounts CRUD (+5): chart_of_accounts, account, create_account, update_account, delete_account. Residence finance (+9): residence_info, halls, allocate_residence, remove_residence, unallocated_residents, hall_utilization, residence_fees, residence_ledger, residence_report.</li>
                        <li><span class="api-status api-status--done"></span><strong>staff.aspx +14</strong> — Provisional marks entry (4 endpoints) · HR employee CRUD + contracts (5 endpoints) · Mark amendment requests (3 endpoints) · Departments listing.</li>
                        <li><span class="api-status api-status--done"></span><strong>academic.aspx +5</strong> — Semester deletion request workflow: student submit, staff list/detail/decide/batch-decide with auto-deletion of course registrations on approval.</li>
                        <li><span class="api-status api-status--done"></span><strong>student.aspx +9</strong> — Portal onboarding list, onboarding stats, email resolver, application detail (post-admission). Profile extras (+5): update_contact, guardian, update_guardian, enrollment_history, clearance. Profile extended with <code>?include=next_of_kin,sponsor,onboarding</code>.</li>
                    </ul>

                    <h4 style="font-size:13px;font-weight:700;margin:0 0 10px;color:#9b59b6;">Design Patterns Introduced</h4>
                    <ul class="api-task-list">
                        <li><span class="api-status api-status--done"></span><strong>Lazy schema creation</strong> — <code>EnsureSchema()</code> / <code>EnsureMarkRequestsSchema()</code> / <code>EnsureSemesterDeletionSchema()</code> create tables on first use with <code>CREATE TABLE IF NOT EXISTS</code>.</li>
                        <li><span class="api-status api-status--done"></span><strong>ON DUPLICATE KEY UPDATE upserts</strong> — Used for appraisal section_b competency ratings so repeated saves don't create duplicates.</li>
                        <li><span class="api-status api-status--done"></span><strong>Cross-database queries</strong> — Provisional marks and semester deletion use fully-qualified <code>campus_dynamics_portal.table</code> names for cross-DB joins.</li>
                        <li><span class="api-status api-status--done"></span><strong>SP-with-fallback pattern</strong> — Chart of accounts create/delete try stored procedures first; fall back to direct SQL if SP does not exist.</li>
                        <li><span class="api-status api-status--done"></span><strong>Public no-auth endpoint</strong> — <code>admissions → application_status</code> allows applicants to self-check status without a portal account.</li>
                        <li><span class="api-status api-status--done"></span><strong>CSV export endpoint</strong> — <code>appraisal → export_report</code> streams <code>text/csv</code> directly for spreadsheet download.</li>
                    </ul>
                </div>
            </div>

            <!-- Changelog v2.1 (historical) -->
            <div class="api-section">
                <div class="api-section__header">
                    <div class="api-section__title">Changelog — v2.1</div>
                    <div class="api-section__desc">What changed in API version 2.1 (May 2026)</div>
                </div>
                <div class="api-section__body">
                    <h4 style="font-size:13px;font-weight:700;margin:0 0 10px;color:#2ecc71;">New Endpoints</h4>
                    <ul class="api-task-list" style="margin-bottom:16px;">
                        <li><span class="api-status api-status--done"></span><strong>auth → refresh</strong> — Exchange a valid token for a new one with a fresh expiry. Old token is immediately invalidated.</li>
                        <li><span class="api-status api-status--done"></span><strong>academic → semester_status</strong> — Per-semester open/closed flag for any academic year. Reads <code>semester_X_is_active</code> columns from <code>acad_acadyears</code>.</li>
                        <li><span class="api-status api-status--done"></span><strong>academic → retake_courses</strong> — Identify courses eligible for retake by scanning the student's full results history; returns courses where the most recent grade is F or E.</li>
                        <li><span class="api-status api-status--done"></span><strong>student → bulk_enrollment</strong> — Staff-only batch endpoint. Up to 500 regnos per call with enrollment status per student and a <code>not_found</code> list.</li>
                        <li><span class="api-status api-status--done"></span><strong>finance → billing_breakdown</strong> — Per-semester breakdown with waiver amounts merged from <code>fin_bill_waiver_items</code>.</li>
                        <li><span class="api-status api-status--done"></span><strong>finance → waivers</strong> — All approved fee waivers with line-item detail.</li>
                        <li><span class="api-status api-status--done"></span><strong>finance → accommodation_status</strong> — Hostel/room assignment and accommodation billing status.</li>
                    </ul>

                    <h4 style="font-size:13px;font-weight:700;margin:0 0 10px;color:#3498db;">Bug Fixes &amp; Improvements</h4>
                    <ul class="api-task-list" style="margin-bottom:16px;">
                        <li><span class="api-status api-status--done"></span><strong>FIX-03 — Semester gate enforced:</strong> <code>semester_registration</code> now returns <code>SEMESTER_CLOSED</code> when the target semester is not open. Previously it always allowed registration.</li>
                        <li><span class="api-status api-status--done"></span><strong>FIX-04 — Course status filter:</strong> <code>available_courses</code> now post-filters results to only return Active courses (<code>acad_programmecourses.status</code>). Inactive courses no longer appear in the list.</li>
                        <li><span class="api-status api-status--done"></span><strong>FIX-06 — Registration status completeness:</strong> <code>registration_history</code> and <code>enrollment_status</code> now recognise all seven statuses (REGISTERED, LATE REGISTERED, CLEARED, HALTED, DEAD YEAR, DISCONTINUED, UNREGISTERED). Previously only "active"/"registered" were handled.</li>
                        <li><span class="api-status api-status--done"></span><strong>FIX-08 — billingID resolution:</strong> <code>semester_registration</code> now fetches the student's actual <code>billingID</code> from <code>acad_student</code> and passes it to <code>fin_Autobilling</code>. Previously hardcoded to <code>"-"</code>.</li>
                        <li><span class="api-status api-status--done"></span><strong>FIX-11 — Lecturer assignment in course details:</strong> <code>course_details</code> now includes a <code>lecturers</code> array with staff linked via <code>acad_programmecourses.lecturer_id → hrm_employee</code>.</li>
                        <li><span class="api-status api-status--done"></span><strong>ROB-06 — Duplicate registration error code:</strong> <code>register_course</code> now returns <code>ALREADY_REGISTERED</code> (not a generic 500) when a duplicate key constraint is hit.</li>
                        <li><span class="api-status api-status--done"></span><strong>ROB-07 — Mark validation:</strong> <code>submit_marks</code> validates each score against <code>acad_mark_sheets</code> maxima (default 50 CW / 60 exam). Per-student validation errors are reported without halting valid rows.</li>
                        <li><span class="api-status api-status--done"></span><strong>ROB-09 — Ping live DB check:</strong> <code>ping</code> now performs an actual SELECT 1 and returns <code>db_status: "ok"/"error"</code> instead of always reporting healthy.</li>
                    </ul>

                    <h4 style="font-size:13px;font-weight:700;margin:0 0 10px;color:#9b59b6;">Infrastructure</h4>
                    <ul class="api-task-list">
                        <li><span class="api-status api-status--done"></span><strong>Rate Limiting:</strong> Sliding-window in-process cache. Login: 10/min per IP; all other endpoints: 120/min per token. Returns HTTP 429 with <code>Retry-After</code> header.</li>
                        <li><span class="api-status api-status--done"></span><strong>CORS whitelist:</strong> Allowed origins moved to <code>web.config CorsAllowedOrigins</code> key (comma-separated). Default: <code>eportal.mru.ac.ug, eadmin.mru.ac.ug, odel.mru.ac.ug</code>.</li>
                        <li><span class="api-status api-status--done"></span><strong>Dual-write GL:</strong> All finance balance/ledger computations now use UNION ALL across <code>fin_ledger</code> and <code>fin_studentfeestracking</code> with NOT EXISTS deduplication and <code>post_status = 'Posted'</code> filter.</li>
                        <li><span class="api-status api-status--done"></span><strong>fees_structure rewrite:</strong> Two-source lookup — (1) actual billed rows from <code>fin_studentfeestracking</code> + <code>academicbillingitems</code> item names, (2) fallback to <code>fin_programme_fees</code> wide-format columns (<code>y{year}_s{sem}_tuition/_functional</code>, <code>is_active='Yes'</code>). Old code queried wrong columns and wrong <code>is_active</code> type. <code>fees_source</code>: <code>"billed"</code> | <code>"programme_fees"</code> | <code>"not_found"</code>.</li>
                        <li><span class="api-status api-status--done"></span><strong>registered_courses fix:</strong> Replaced INNER JOIN (silently dropped courses missing from catalogue) with LEFT JOIN. Response is a flat array — fields: <code>ID, regno, courseID, acad_year, semester, course_status, prog_id, stud_session, courseName, creditUnit</code>.</li>
                        <li><span class="api-status api-status--done"></span><strong>Token reuse &amp; 1-year expiry:</strong> <code>TokenManager.CreateToken()</code> reuses existing valid tokens (>30 days remaining) instead of always creating new ones. Cap raised from 5 → 50. Expiry: 8760 h (1 year). Prevents eviction on repeated logins.</li>
                        <li><span class="api-status api-status--done"></span><strong>ApiHelper additions:</strong> <code>IsRateLimited()</code>, <code>SanitiseParam()</code>, <code>ValidateAcadYear()</code>, <code>ExecuteAccounts()</code>, <code>QueryAccounts()</code>, <code>HandleCors()</code>, <code>CompleteResponse()</code> — all files updated to use these.</li>
                    </ul>
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
            // v2.0 — Initial Release
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
            {name:'Staff — Marks Workflow (6 endpoints)', status:'done'},
            {name:'Finance — Payment History & Billing Summary', status:'done'},
            {name:'Academic — Enrollment Verification', status:'done'},
            {name:'Campus — Faculties & Departments', status:'done'},
            {name:'Notices & Announcements', status:'done'},
            {name:'Directory & Campus Info', status:'done'},
            {name:'API Documentation Page', status:'done'},
            {name:'End-to-End Testing & Validation', status:'done'},
            {name:'ODEL — Identity Lookup & Verification (6 endpoints)', status:'done'},
            {name:'ODEL — Course Details & Curriculum (4 endpoints)', status:'done'},
            {name:'ODEL — Fee Clearance & Bulk Check (2 endpoints)', status:'done'},
            {name:'ODEL — Academic Calendar & Enhanced Campus (3 endpoints)', status:'done'},
            {name:'ODEL — API Documentation v2.2', status:'done'},
            {name:'Fee Access Policy — Evaluation Endpoint (access_status)', status:'done'},
            {name:'Fee Access Policy — Portal Alert Integration', status:'done'},
            {name:'Fee Access Policy — Admin Checker Page', status:'done'},
            // v2.1 — May 2026
            {name:'v2.1: Rate Limiting (sliding window, 429 responses)', status:'done'},
            {name:'v2.1: CORS whitelist via web.config (CorsAllowedOrigins)', status:'done'},
            {name:'v2.1: Token Refresh endpoint (auth → refresh)', status:'done'},
            {name:'v2.1: Semester status endpoint (per-semester open/closed)', status:'done'},
            {name:'v2.1: Retake courses endpoint (failed grade detection)', status:'done'},
            {name:'v2.1: Bulk enrollment endpoint — staff, up to 500 students', status:'done'},
            {name:'v2.1: Finance billing_breakdown with waiver merge', status:'done'},
            {name:'v2.1: Finance waivers endpoint (fin_bill_waivers)', status:'done'},
            {name:'v2.1: Finance accommodation_status endpoint', status:'done'},
            {name:'v2.1: Dual-write GL (fin_ledger + fin_studentfeestracking)', status:'done'},
            {name:'v2.1: Programme fees table (fin_programme_fees)', status:'done'},
            {name:'v2.1: FIX — Semester gate (SEMESTER_CLOSED error)', status:'done'},
            {name:'v2.1: FIX — Course status filter (Active only)', status:'done'},
            {name:'v2.1: FIX — Registration status completeness (7 statuses)', status:'done'},
            {name:'v2.1: FIX — billingID resolution per student', status:'done'},
            {name:'v2.1: FIX — Lecturer array in course_details', status:'done'},
            {name:'v2.1: FIX — ALREADY_REGISTERED error code', status:'done'},
            {name:'v2.1: FIX — Mark validation against acad_mark_sheets maxima', status:'done'},
            {name:'v2.1: FIX — Ping live DB check (db_status field)', status:'done'},
            {name:'v2.1: Comprehensive API documentation update', status:'done'},
            // v2.2 — May 2026
            {name:'v2.2: FinanceEngine.cs — centralised finance computation engine', status:'done'},
            {name:'v2.2: AcademicEngine.cs — centralised academic computation engine', status:'done'},
            {name:'v2.2: finance → student_financial_summary (single-call snapshot)', status:'done'},
            {name:'v2.2: finance → bulk_fee_check (staff batch, up to 200 students)', status:'done'},
            {name:'v2.2: academic → student_academic_summary (single-call snapshot)', status:'done'},
            {name:'v2.2: academic → academic_standing (boolean verdict + per-rule checks)', status:'done'},
            {name:'v2.2: All handlers migrated to engine delegation (no inline duplicates)', status:'done'},
            {name:'v2.2: Degree classification scale locked in AcademicEngine.GetClassification()', status:'done'},
            {name:'v2.2: FinancialSummary DTO — field names defined once, used everywhere', status:'done'},
            {name:'v2.2: Documentation updated to v2.2', status:'done'},
            // v2.3 — May 2026
            {name:'v2.3: support.aspx — Student help-desk ticketing system (7 endpoints)', status:'done'},
            {name:'v2.3: knowledgebase.aspx — Self-service KB with categories & articles (8 endpoints)', status:'done'},
            {name:'v2.3: admissions.aspx — Full admissions pipeline & student registration (10 endpoints)', status:'done'},
            {name:'v2.3: residence.aspx — Hall allocation & occupancy management (5 endpoints)', status:'done'},
            {name:'v2.3: appraisal.aspx — HR performance appraisal workflow (12 endpoints)', status:'done'},
            {name:'v2.3: finance.aspx +5 — Chart of accounts CRUD with SP fallback', status:'done'},
            {name:'v2.3: staff.aspx +14 — Provisional marks · HR employee CRUD · Mark requests', status:'done'},
            {name:'v2.3: academic.aspx +5 — Semester deletion request workflow', status:'done'},
            {name:'v2.3: student.aspx +4 — Onboarding list/stats · Email resolver · Application detail', status:'done'},
            {name:'v2.3: student.aspx profile — Extended ?include=next_of_kin,sponsor,onboarding', status:'done'},
            {name:'v2.3: Documentation updated to v2.3', status:'done'}
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

    <!-- ═══════════════════════════════════════════════════════════════ -->
    <!-- EXPORT PANEL                                                    -->
    <!-- ═══════════════════════════════════════════════════════════════ -->
    <style>
        /* Export FAB */
        #exportFab { position:fixed; bottom:28px; right:28px; z-index:9999; display:flex; flex-direction:column; align-items:flex-end; gap:10px; }
        #exportBtn { background:#05275C; color:#fff; border:none; padding:13px 22px; font-size:13px; font-weight:700; cursor:pointer; display:flex; align-items:center; gap:9px; box-shadow:0 4px 20px rgba(5,39,92,0.38); letter-spacing:0.4px; font-family:inherit; transition:background 0.15s,transform 0.1s; }
        #exportBtn:hover { background:#0a3d8f; transform:translateY(-1px); }
        #exportBtn:active { transform:translateY(0); }
        #exportPanel { background:#fff; border:1px solid #e0e5ed; box-shadow:0 10px 40px rgba(5,39,92,0.20); width:300px; overflow:hidden; transform-origin:bottom right; transition:transform 0.18s cubic-bezier(.4,0,.2,1), opacity 0.18s; }
        #exportPanel.ep-hidden { transform:scale(0.9) translateY(8px); opacity:0; pointer-events:none; }
        .ep-header { padding:11px 16px; font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:1.2px; color:#8892a4; background:#f5f7fa; border-bottom:1px solid #e0e5ed; }
        .ep-option { width:100%; background:none; border:none; border-bottom:1px solid #f0f2f5; padding:13px 16px; display:flex; align-items:center; gap:13px; cursor:pointer; text-align:left; transition:background 0.1s; font-family:inherit; }
        .ep-option:last-child { border-bottom:none; }
        .ep-option:hover { background:#f0f4ff; }
        .ep-icon { font-size:22px; flex-shrink:0; width:28px; text-align:center; line-height:1; }
        .ep-title { font-size:13px; font-weight:700; color:#1a1a2e; }
        .ep-sub { font-size:11px; color:#8892a4; margin-top:2px; }
        #epToast { position:fixed; bottom:92px; right:28px; background:#1a1a2e; color:#fff; padding:10px 18px; font-size:12px; font-weight:600; z-index:10000; opacity:0; transition:opacity 0.25s; pointer-events:none; letter-spacing:0.2px; }
        #epToast.show { opacity:1; }

        /* Print stylesheet */
        @media print {
            .api-sidebar, #exportFab, #epToast, .api-stats, .api-header__version { display:none !important; }
            .api-layout { display:block !important; padding:0 !important; max-width:none !important; }
            .api-main { width:100% !important; }
            .api-section { border:1px solid #ccc !important; margin-bottom:12px !important; page-break-inside:avoid; break-inside:avoid; }
            .api-section__header { background:#f5f7fa !important; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
            .api-code { background:#f5f5f5 !important; color:#222 !important; border:1px solid #ccc; white-space:pre-wrap !important; font-size:10px !important; }
            .api-badge { -webkit-print-color-adjust:exact; print-color-adjust:exact; }
            .api-header { -webkit-print-color-adjust:exact; print-color-adjust:exact; }
            body { background:white !important; font-size:11px !important; }
            .api-endpoint { border:1px solid #e0e5ed !important; margin-bottom:8px !important; page-break-inside:avoid; }
            a { color:inherit !important; text-decoration:none !important; }
        }
    </style>

    <!-- Export FAB markup -->
    <div id="exportFab">
        <div id="exportPanel" class="ep-hidden">
            <div class="ep-header">Export Documentation</div>
            <button class="ep-option" onclick="cdExport('print')">
                <span class="ep-icon">🖨️</span>
                <div><div class="ep-title">Print / Save as PDF</div><div class="ep-sub">Browser print dialog — choose "Save as PDF"</div></div>
            </button>
            <button class="ep-option" onclick="cdExport('markdown')">
                <span class="ep-icon">📝</span>
                <div><div class="ep-title">Markdown (.md)</div><div class="ep-sub">GitHub-flavoured reference document</div></div>
            </button>
            <button class="ep-option" onclick="cdExport('openapi')">
                <span class="ep-icon">⚙️</span>
                <div><div class="ep-title">OpenAPI 3.0 JSON</div><div class="ep-sub">Import into Swagger UI, Insomnia, or Postman</div></div>
            </button>
            <button class="ep-option" onclick="cdExport('postman')">
                <span class="ep-icon">📮</span>
                <div><div class="ep-title">Postman Collection</div><div class="ep-sub">v2.1 format — File → Import in Postman</div></div>
            </button>
        </div>
        <button id="exportBtn" onclick="cdToggleExport()">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            Export Docs
        </button>
    </div>
    <div id="epToast"></div>

    <script>
    (function(){
        var _open = false;

        window.cdToggleExport = function() {
            _open = !_open;
            var panel = document.getElementById('exportPanel');
            if (_open) panel.classList.remove('ep-hidden');
            else        panel.classList.add('ep-hidden');
        };

        document.addEventListener('click', function(e) {
            if (_open && !document.getElementById('exportFab').contains(e.target)) {
                _open = false;
                document.getElementById('exportPanel').classList.add('ep-hidden');
            }
        });

        function toast(msg) {
            var t = document.getElementById('epToast');
            t.textContent = msg;
            t.classList.add('show');
            setTimeout(function(){ t.classList.remove('show'); }, 2800);
        }

        function download(filename, content, mime) {
            var blob = new Blob([content], { type: mime });
            var url  = URL.createObjectURL(blob);
            var a    = document.createElement('a');
            a.href = url; a.download = filename;
            document.body.appendChild(a); a.click();
            setTimeout(function(){ URL.revokeObjectURL(url); document.body.removeChild(a); }, 600);
        }

        /* ── Extract all endpoints from the rendered DOM ── */
        function extractEndpoints() {
            var out = [];
            document.querySelectorAll('.api-section').forEach(function(sec) {
                var titleEl = sec.querySelector('.api-section__title');
                var section = titleEl ? titleEl.textContent.trim() : 'General';
                sec.querySelectorAll('.api-endpoint').forEach(function(ep) {
                    var pathEl  = ep.querySelector('.api-endpoint__path');
                    var infoEl  = ep.querySelector('.api-endpoint__info');
                    var mBadge  = pathEl ? pathEl.querySelector('.api-badge--get,.api-badge--post,.api-badge--put,.api-badge--delete') : null;
                    var method  = mBadge ? mBadge.textContent.trim().toUpperCase() : 'GET';

                    /* strip badge spans to get clean path text */
                    var rawPath = '';
                    if (pathEl) {
                        var clone = pathEl.cloneNode(true);
                        clone.querySelectorAll('.api-badge').forEach(function(b){ b.parentNode.removeChild(b); });
                        rawPath = clone.textContent.replace(/\s+/g,' ').trim();
                    }

                    var urlM   = rawPath.match(/\/API\/v2\/([^?\s(]+\.aspx)(\?[^\s(]+)?/);
                    var file   = urlM ? urlM[1] : rawPath;
                    var qs     = urlM ? (urlM[2] || '') : '';
                    var actM   = qs.match(/action=([^&\s]+)/);
                    var action = actM ? actM[1] : '';
                    var staffOnly = /staff only/i.test(rawPath);
                    var noAuth    = /no auth/i.test(ep.textContent);

                    var params = [];
                    ep.querySelectorAll('.api-endpoint__params tr').forEach(function(row, i){
                        if (i === 0) return; /* header */
                        var cells = row.querySelectorAll('td');
                        if (cells.length >= 2 && cells[0].textContent.trim()) {
                            params.push({
                                name:        cells[0].textContent.trim(),
                                type:        cells[1] ? cells[1].textContent.trim() : 'string',
                                required:    cells[2] ? /yes/i.test(cells[2].textContent) : false,
                                description: cells[3] ? cells[3].textContent.trim() : ''
                            });
                        }
                    });

                    out.push({ section: section, method: method, file: file, action: action,
                                rawPath: rawPath, description: infoEl ? infoEl.textContent.trim() : '',
                                status: ep.getAttribute('data-status') || 'live',
                                staffOnly: staffOnly, noAuth: noAuth, params: params });
                });
            });
            return out;
        }

        window.cdExport = function(type) {
            _open = false;
            document.getElementById('exportPanel').classList.add('ep-hidden');
            if (type === 'print') { window.print(); return; }
            var eps = extractEndpoints();
            if (type === 'markdown') {
                download('campus-dynamics-api-v2.3.md', genMarkdown(eps), 'text/markdown;charset=utf-8');
                toast('✓ Markdown downloaded');
            } else if (type === 'openapi') {
                download('campus-dynamics-openapi-3.0.json', JSON.stringify(genOpenAPI(eps), null, 2), 'application/json');
                toast('✓ OpenAPI 3.0 JSON downloaded');
            } else if (type === 'postman') {
                download('campus-dynamics-api.postman_collection.json', JSON.stringify(genPostman(eps), null, 2), 'application/json');
                toast('✓ Postman Collection downloaded');
            }
        };

        /* ════════════════════════════════════════════════════
           MARKDOWN GENERATOR
        ════════════════════════════════════════════════════ */
        function genMarkdown(eps) {
            var L = [];
            L.push('# Campus Dynamics API v2.3');
            L.push('');
            L.push('> **Base URL:** `https://eadmin.mru.ac.ug/API/v2/`');
            L.push('> **Auth:** Append `?token=<token>` to every authenticated request.  ');
            L.push('> Obtain a token: `POST /API/v2/auth.aspx?action=login`');
            L.push('');
            L.push('**Response envelope**');
            L.push('```json');
            L.push('{ "success": true, "message": "OK", "data": { ... }, "timestamp": "2026-01-01T00:00:00Z" }');
            L.push('```');
            L.push('');
            L.push('---');
            L.push('');

            var sections = {}, order = [];
            eps.forEach(function(ep){
                if (!sections[ep.section]){ sections[ep.section]=[]; order.push(ep.section); }
                sections[ep.section].push(ep);
            });

            order.forEach(function(sec){
                L.push('## ' + sec);
                L.push('');
                sections[sec].forEach(function(ep){
                    var path = ep.action
                        ? '/API/v2/' + ep.file + '?action=' + ep.action
                        : '/API/v2/' + ep.file;
                    L.push('### `' + ep.method + '` ' + path);
                    L.push('');
                    var badges = [];
                    if (ep.staffOnly) badges.push('**Staff only**');
                    if (ep.noAuth)    badges.push('**No auth required**');
                    if (ep.status !== 'live') badges.push('**Pending**');
                    if (badges.length) { L.push('> ' + badges.join(' · ')); L.push(''); }
                    L.push(ep.description);
                    L.push('');
                    if (ep.params.length > 0) {
                        L.push('| Parameter | Type | Required | Description |');
                        L.push('|-----------|------|:--------:|-------------|');
                        ep.params.forEach(function(p){
                            L.push('| `' + p.name + '` | ' + (p.type||'string') + ' | ' + (p.required ? '✓' : '') + ' | ' + (p.description||'') + ' |');
                        });
                        L.push('');
                    }
                });
                L.push('---');
                L.push('');
            });

            L.push('*Generated ' + new Date().toISOString().slice(0,10) + ' from [Campus Dynamics API Docs](https://eadmin.mru.ac.ug/API/v2/docs.aspx)*');
            return L.join('\n');
        }

        /* ════════════════════════════════════════════════════
           OPENAPI 3.0 GENERATOR
        ════════════════════════════════════════════════════ */
        function genOpenAPI(eps) {
            var paths = {};
            var tagsSeen = {}, tags = [];

            eps.forEach(function(ep){
                var pathKey = '/API/v2/' + ep.file;
                if (!paths[pathKey]) paths[pathKey] = {};

                /* OpenAPI doesn't allow duplicate methods on one path; append action as operationId */
                var methodKey = ep.method.toLowerCase();
                /* if method slot taken, create a virtual path suffix */
                var tryKey = pathKey;
                var suffix = 0;
                while (paths[tryKey] && paths[tryKey][methodKey]) {
                    suffix++;
                    tryKey = pathKey + '#' + suffix;
                }
                if (!paths[tryKey]) paths[tryKey] = {};

                if (!tagsSeen[ep.section]) { tagsSeen[ep.section] = true; tags.push({ name: ep.section }); }

                var parameters = [];
                if (ep.action) {
                    parameters.push({ name: 'action', in: 'query', required: true,
                        schema: { type: 'string', 'enum': [ep.action] }, description: 'API action selector' });
                }
                if (!ep.noAuth) {
                    parameters.push({ name: 'token', in: 'query', required: !ep.staffOnly,
                        schema: { type: 'string' }, description: 'Auth token from login' });
                }
                ep.params.forEach(function(p){
                    if (p.name === 'token') return;
                    parameters.push({ name: p.name, in: 'query', required: p.required,
                        schema: { type: /int|integer|number/i.test(p.type) ? 'integer' : 'string' },
                        description: p.description });
                });

                var op = {
                    operationId: (ep.file.replace('.aspx','') + '_' + (ep.action || ep.method) + (suffix ? '_' + suffix : '')).replace(/[^a-zA-Z0-9_]/g,'_'),
                    summary: ep.action ? ep.action.replace(/_/g,' ') : ep.file.replace('.aspx',''),
                    description: ep.description + (ep.staffOnly ? '\n\n**Auth:** Staff token required.' : '') + (ep.noAuth ? '\n\n**Auth:** None — public endpoint.' : ''),
                    tags: [ep.section],
                    parameters: parameters,
                    responses: {
                        '200': { description: 'Success', content: { 'application/json': { schema: { '$ref': '#/components/schemas/ApiResponse' } } } },
                        '401': { '$ref': '#/components/responses/Unauthorized' },
                        '403': { '$ref': '#/components/responses/Forbidden' },
                        '429': { '$ref': '#/components/responses/RateLimited' }
                    }
                };
                if (!ep.noAuth) op.security = [{ tokenQuery: [] }];

                paths[tryKey][methodKey] = op;
            });

            /* clean up virtual #N suffixes — OpenAPI needs real path strings */
            var cleanPaths = {};
            Object.keys(paths).forEach(function(k){ cleanPaths[k.split('#')[0]] = paths[k]; });

            return {
                openapi: '3.0.3',
                info: {
                    title: 'Campus Dynamics API',
                    version: '2.3.0',
                    description: 'RESTful API for Campus Dynamics MRU — student records, results, finance, admissions, HR, residence, appraisal, support, and knowledgebase.',
                    contact: { name: 'Campus Dynamics Developer', email: 'mubahood360@gmail.com' }
                },
                servers: [
                    { url: 'https://eadmin.mru.ac.ug', description: 'Production' }
                ],
                tags: tags,
                components: {
                    securitySchemes: {
                        tokenQuery: { type: 'apiKey', in: 'query', name: 'token', description: 'Obtain via POST /API/v2/auth.aspx?action=login' }
                    },
                    schemas: {
                        ApiResponse: {
                            type: 'object',
                            properties: {
                                success:   { type: 'boolean', example: true },
                                message:   { type: 'string',  example: 'OK' },
                                data:      { type: 'object' },
                                timestamp: { type: 'string', format: 'date-time' }
                            }
                        }
                    },
                    responses: {
                        Unauthorized: { description: 'Missing or invalid token' },
                        Forbidden:    { description: 'Insufficient permissions (staff-only endpoint)' },
                        RateLimited:  { description: 'Too many requests — see Retry-After header' }
                    }
                },
                paths: cleanPaths,
                security: [{ tokenQuery: [] }]
            };
        }

        /* ════════════════════════════════════════════════════
           POSTMAN COLLECTION v2.1 GENERATOR
        ════════════════════════════════════════════════════ */
        function genPostman(eps) {
            var base   = '{{base_url}}';
            var folders = {}, order = [];

            eps.forEach(function(ep){
                if (!folders[ep.section]) { folders[ep.section]=[]; order.push(ep.section); }

                var queryItems = [];
                if (ep.action) queryItems.push({ key: 'action', value: ep.action });
                if (!ep.noAuth) queryItems.push({ key: 'token', value: '{{cd_token}}', description: 'Auth token' });

                /* GET params go in query; POST params go in body */
                var bodyItems = [];
                ep.params.forEach(function(p){
                    if (p.name === 'token') return;
                    var item = { key: p.name, value: '', description: p.description, type: 'text', disabled: !p.required };
                    if (ep.method === 'GET') queryItems.push({ key: p.name, value: '', description: p.description, disabled: !p.required });
                    else bodyItems.push(item);
                });

                var rawUrl = base + '/API/v2/' + ep.file + '?action=' + (ep.action||'');

                var req = {
                    method: ep.method,
                    header: [],
                    url: {
                        raw:      rawUrl,
                        host:     [base],
                        path:     ['API', 'v2', ep.file],
                        query:    queryItems
                    },
                    description: ep.description + (ep.staffOnly ? '\n\n🔒 Staff only.' : '') + (ep.noAuth ? '\n\n🌐 No auth required.' : '')
                };

                if (ep.method === 'POST' || ep.method === 'PUT') {
                    req.body = { mode: 'urlencoded', urlencoded: [{ key: 'token', value: '{{cd_token}}', type: 'text' }].concat(bodyItems) };
                }

                var label = ep.action || ep.file.replace('.aspx','');
                if (ep.staffOnly) label += ' [staff]';
                if (ep.noAuth)    label += ' [public]';

                folders[ep.section].push({ name: label, request: req, response: [] });
            });

            return {
                info: {
                    _postman_id: 'cd-api-v2-3',
                    name: 'Campus Dynamics API v2.3',
                    description: 'Full API collection for Campus Dynamics MRU.\n\nSet the {{cd_token}} variable to your token.\nGet a token: POST {{base_url}}/API/v2/auth.aspx?action=login\n\nGenerated: ' + new Date().toISOString().slice(0,10),
                    schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'
                },
                variable: [
                    { key: 'base_url', value: 'https://eadmin.mru.ac.ug', type: 'string' },
                    { key: 'cd_token', value: 'PASTE_YOUR_TOKEN_HERE',    type: 'string' }
                ],
                auth: {
                    type: 'apikey',
                    apikey: [
                        { key: 'key',   value: 'token',          type: 'string' },
                        { key: 'value', value: '{{cd_token}}',   type: 'string' },
                        { key: 'in',    value: 'query',          type: 'string' }
                    ]
                },
                item: order.map(function(sec){
                    return { name: sec, item: folders[sec] };
                })
            };
        }
    })();
    </script>
</body>
</html>
