<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Verify.aspx.cs" Inherits="Verify" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Masters Letter Verification — Mutesa I Royal University</title>
<style>
/* ─────────────────────────────────────────────────────────────────────
   Mutesa I Royal University — Masters Letter of Award Verification
   Public page, no authentication required.
   Primary: #002365 (MRU navy)   Gold accent: #c9a227
───────────────────────────────────────────────────────────────────── */

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 14px;
    background: #eef2f7;
    color: #1a1a2e;
    min-height: 100vh;
}

/* ── Page header ── */
.page-header {
    background: #002365;
    border-bottom: 5px solid #c9a227;
}
.page-header-inner {
    max-width: 700px;
    margin: 0 auto;
    padding: 18px 24px;
    display: flex;
    align-items: center;
    gap: 20px;
}
/* University logo loaded from DB */
.uni-logo-img {
    max-height: 72px;
    max-width: 360px;
    object-fit: contain;
    flex-shrink: 0;
    background: transparent;
}
/* Fallback text when logo is not available */
.uni-logo-fallback {
    display: flex;
    flex-direction: column;
    color: #fff;
}
.uni-logo-fallback .uni-abbr {
    font-size: 26px;
    font-weight: 900;
    letter-spacing: 2px;
    color: #c9a227;
    line-height: 1;
}
.uni-logo-fallback .uni-full {
    font-size: 12px;
    color: rgba(255,255,255,0.85);
    letter-spacing: 0.3px;
    line-height: 1.4;
}
.uni-logo-divider {
    width: 1px;
    height: 50px;
    background: rgba(255,255,255,0.25);
    flex-shrink: 0;
    display: none; /* shown via JS when logo loads */
}
.page-header-label {
    color: rgba(255,255,255,0.9);
    font-size: 12px;
    line-height: 1.5;
    padding-left: 4px;
    border-left: 2px solid rgba(201,162,39,0.6);
    padding-left: 14px;
}
.page-header-label strong {
    display: block;
    font-size: 14px;
    color: #fff;
    font-weight: 700;
}

/* ── Body ── */
.page-body {
    max-width: 700px;
    margin: 38px auto 70px;
    padding: 0 20px;
}

/* ── Search card ── */
.search-card {
    background: #fff;
    border-top: 4px solid #002365;
    box-shadow: 0 2px 14px rgba(0,35,101,0.10);
    padding: 32px 36px 30px;
    margin-bottom: 26px;
}
.search-card h1 {
    font-size: 20px;
    font-weight: 700;
    color: #002365;
    margin-bottom: 8px;
}
.search-card p {
    color: #555;
    font-size: 13px;
    line-height: 1.6;
    margin-bottom: 26px;
}
.form-row {
    display: flex;
    gap: 10px;
    align-items: stretch;
}
.form-row input[type="text"] {
    flex: 1;
    height: 46px;
    border: 1.5px solid #b8c7dd;
    border-radius: 0;
    padding: 0 16px;
    font-size: 14px;
    font-family: inherit;
    color: #1a1a2e;
    outline: none;
    transition: border-color 0.18s;
}
.form-row input[type="text"]:focus { border-color: #002365; }
.form-row input[type="text"]::placeholder { color: #aab; }
.btn-verify {
    height: 46px;
    padding: 0 28px;
    background: #002365;
    color: #fff;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.6px;
    border: none;
    border-radius: 0;
    cursor: pointer;
    white-space: nowrap;
    transition: background 0.18s;
}
.btn-verify:hover { background: #001845; }

/* ── Inline error ── */
.inline-error {
    background: #fef2f2;
    border-left: 4px solid #ef4444;
    padding: 10px 14px;
    color: #b91c1c;
    font-size: 13px;
    margin-top: 14px;
}

/* ── Result card ── */
.result-card {
    background: #fff;
    box-shadow: 0 2px 14px rgba(0,35,101,0.10);
    overflow: hidden;
}

/* ── Result banners ── */
.result-banner {
    padding: 20px 28px;
    display: flex;
    align-items: center;
    gap: 16px;
}
.result-banner.authentic {
    background: linear-gradient(135deg, #002365 0%, #003a99 100%);
    border-bottom: 4px solid #c9a227;
}
.result-banner.not-found {
    background: linear-gradient(135deg, #7f1d1d 0%, #b91c1c 100%);
    border-bottom: 4px solid #f87171;
}

/* SVG badge icon circles */
.badge-circle {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.authentic .badge-circle { background: #c9a227; }
.not-found .badge-circle { background: rgba(255,255,255,0.20); }

.badge-text strong {
    display: block;
    font-size: 17px;
    font-weight: 700;
    color: #fff;
    letter-spacing: 0.3px;
}
.badge-text span {
    font-size: 12px;
    color: rgba(255,255,255,0.78);
    line-height: 1.4;
    display: block;
    margin-top: 2px;
}

/* ── Authentic detail body ── */
.result-body {
    padding: 28px 32px 34px;
}
.result-body h2 {
    font-size: 14px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    color: #002365;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 2px solid #e3eaf5;
}
.detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px 32px;
}
.detail-item label {
    display: block;
    font-size: 10.5px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    color: #7a8ca5;
    margin-bottom: 4px;
}
.detail-item .val {
    font-size: 14px;
    font-weight: 600;
    color: #1a1a2e;
    line-height: 1.35;
}
.detail-item.full { grid-column: 1 / -1; }
.detail-item.name-item .val {
    font-size: 17px;
    font-weight: 700;
    color: #002365;
}

/* Gold seal strip at bottom of authentic result */
.seal-strip {
    background: #f7f3e8;
    border-top: 1px solid #e9ddb4;
    padding: 12px 32px;
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 12px;
    color: #7a6820;
}
.seal-strip svg { flex-shrink: 0; }

/* ── Not found body ── */
.not-found-body {
    padding: 30px 32px;
    text-align: center;
}
.not-found-body p {
    color: #555;
    line-height: 1.65;
    margin-bottom: 10px;
    font-size: 14px;
}

/* ── Footer ── */
.page-footer {
    text-align: center;
    font-size: 12px;
    color: #8a99b0;
    margin-top: 30px;
    line-height: 1.6;
}

/* ── Responsive ── */
@media (max-width: 540px) {
    .detail-grid { grid-template-columns: 1fr; }
    .search-card, .result-body, .not-found-body { padding: 22px 18px; }
    .result-banner { padding: 16px 18px; }
    .form-row { flex-direction: column; }
    .btn-verify { height: 44px; }
    .page-header-inner { gap: 12px; }
    .uni-logo-img { max-height: 52px; max-width: 220px; }
}
</style>
</head>
<body>

<!-- ── Page Header with university logo from DB ── -->
<div class="page-header">
    <div class="page-header-inner">

        <%-- University logo from DB (base64 data URI) — falls back to text badge --%>
        <% if (!string.IsNullOrEmpty(LogoBase64)) { %>
            <img class="uni-logo-img"
                 src="data:<%=LogoMimeType%>;base64,<%=LogoBase64%>"
                 alt="Mutesa I Royal University" />
        <% } else { %>
            <div class="uni-logo-fallback">
                <span class="uni-abbr">MRU</span>
                <span class="uni-full">Mutesa I Royal<br/>University</span>
            </div>
        <% } %>

        <div class="page-header-label">
            <strong>Letter of Award Verification</strong>
            Academic Records &mdash; Mutesa I Royal University
        </div>
    </div>
</div>

<!-- ── Main content ── -->
<div class="page-body">

    <!-- Search card -->
    <div class="search-card">
        <h1>Masters Letter of Award &mdash; Verification</h1>
        <p>
            Enter the student registration number printed on the letter,
            or scan the QR code with any smartphone camera to verify the
            authenticity of a Masters Letter of Award issued by Mutesa I Royal University.
        </p>
        <form method="get" action="Verify.aspx" autocomplete="off">
            <div class="form-row">
                <input type="text" name="reg_no"
                       placeholder="Enter registration number, e.g.  2019/M.SC.CS/001"
                       value="<%= System.Web.HttpUtility.HtmlEncode(RegNoInput) %>"
                       maxlength="50" />
                <button type="submit" class="btn-verify">
                    <!-- Search icon SVG -->
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                         stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
                         style="vertical-align:-2px; margin-right:6px;">
                        <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                    </svg>VERIFY
                </button>
            </div>
            <asp:Literal ID="litError" runat="server" />
        </form>
    </div>

    <!-- Result panel — only rendered when a query is made -->
    <asp:Panel ID="pnlResult" runat="server" Visible="false">
        <div class="result-card">

            <%-- ── AUTHENTIC ── --%>
            <asp:Panel ID="pnlAuthentic" runat="server" Visible="false">
                <div class="result-banner authentic">
                    <div class="badge-circle">
                        <!-- Checkmark SVG — white on gold circle -->
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none"
                             stroke="#fff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="20 6 9 17 4 12"/>
                        </svg>
                    </div>
                    <div class="badge-text">
                        <strong>AUTHENTIC &mdash; VERIFIED</strong>
                        <span>This Masters Letter of Award is on record at Mutesa I Royal University</span>
                    </div>
                </div>

                <div class="result-body">
                    <h2>Student &amp; Award Details</h2>
                    <div class="detail-grid">

                        <div class="detail-item full name-item">
                            <label>Full Name</label>
                            <div class="val"><asp:Literal ID="litName" runat="server" /></div>
                        </div>

                        <div class="detail-item">
                            <label>Registration Number</label>
                            <div class="val"><asp:Literal ID="litRegNo" runat="server" /></div>
                        </div>

                        <div class="detail-item">
                            <label>CGPA</label>
                            <div class="val"><asp:Literal ID="litCgpa" runat="server" /></div>
                        </div>

                        <div class="detail-item full">
                            <label>Programme of Study</label>
                            <div class="val"><asp:Literal ID="litProg" runat="server" /></div>
                        </div>

                        <div class="detail-item full">
                            <label>Degree Awarded</label>
                            <div class="val"><asp:Literal ID="litDeg" runat="server" /></div>
                        </div>

                        <div class="detail-item">
                            <label>Graduation Date</label>
                            <div class="val"><asp:Literal ID="litGradDate" runat="server" /></div>
                        </div>

                        <div class="detail-item">
                            <label>Senate Approval Date</label>
                            <div class="val"><asp:Literal ID="litCompDate" runat="server" /></div>
                        </div>

                    </div>
                </div>

                <!-- Gold seal strip -->
                <div class="seal-strip">
                    <!-- Shield / seal SVG -->
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="#c9a227">
                        <path d="M12 2L3 7v5c0 5.25 3.75 10.15 9 11.25C17.25 22.15 21 17.25 21 12V7L12 2z"/>
                    </svg>
                    This record has been verified against the Academic Registry of Mutesa I Royal University.
                    For further enquiries contact the Academic Registrar&rsquo;s Office.
                </div>
            </asp:Panel>

            <%-- ── NOT FOUND ── --%>
            <asp:Panel ID="pnlNotFound" runat="server" Visible="false">
                <div class="result-banner not-found">
                    <div class="badge-circle">
                        <!-- X / cross SVG — white on translucent circle -->
                        <svg width="26" height="26" viewBox="0 0 24 24" fill="none"
                             stroke="#fff" stroke-width="2.8" stroke-linecap="round">
                            <line x1="18" y1="6" x2="6" y2="18"/>
                            <line x1="6" y1="6" x2="18" y2="18"/>
                        </svg>
                    </div>
                    <div class="badge-text">
                        <strong>NOT FOUND &mdash; CANNOT VERIFY</strong>
                        <span>No Masters award record was found for the supplied registration number</span>
                    </div>
                </div>
                <div class="not-found-body">
                    <p>
                        The registration number
                        <strong><asp:Literal ID="litNotFoundReg" runat="server" /></strong>
                        does not match any Master&rsquo;s degree award record in our Academic Registry.
                    </p>
                    <p>
                        If you believe this is an error, or if you received this letter from a third party,
                        please contact the <strong>Academic Registrar&rsquo;s Office</strong> at
                        Mutesa I Royal University for further verification.
                    </p>
                </div>
            </asp:Panel>

        </div><!-- /result-card -->
    </asp:Panel>

    <div class="page-footer">
        &copy; <%= DateTime.Now.Year %> Mutesa I Royal University &mdash; Academic Records Office<br/>
        This portal is operated solely for letter authenticity verification purposes.
        Unauthorised use is prohibited.
    </div>

</div><!-- /page-body -->

</body>
</html>
