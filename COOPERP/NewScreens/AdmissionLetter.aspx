<%@ Page Language="C#" AutoEventWireup="true"
    CodeFile="AdmissionLetter.aspx.cs"
    Inherits="COOPERP_NewScreens_AdmissionLetter" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<asp:Literal ID="litPageTitle" runat="server" />
<style>
/* ══════════════════════════════════════════════════════
   ADMISSION LETTER — screen + print styles
   ══════════════════════════════════════════════════════ */

@page {
    size: A4 portrait;
    margin: 18mm 18mm 22mm 22mm;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
html { font-size: 11.5pt; }
body {
    font-family: 'Times New Roman', Times, serif;
    font-size: 11.5pt;
    line-height: 1.55;
    color: #000;
    background: #b8b8b8;
}

/* ── Toolbar (screen only) ─────────────────────────── */
.al-toolbar {
    position: sticky; top: 0; z-index: 500;
    background: #05275C; color: #fff;
    padding: 8px 20px;
    display: flex; align-items: center; gap: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,.4);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
}
.al-toolbar-title {
    flex: 1; font-size: 13px; font-weight: 700;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.al-tbtn {
    padding: 6px 15px; font-size: 11px; font-weight: 600;
    border: 1px solid rgba(255,255,255,.3);
    background: rgba(255,255,255,.12);
    color: #fff; cursor: pointer; text-decoration: none;
    display: inline-flex; align-items: center; gap: 5px;
    font-family: inherit; white-space: nowrap;
}
.al-tbtn:hover { background: rgba(255,255,255,.25); color: #fff; }
.al-tbtn--print { background: #16a34a; border-color: #16a34a; }
.al-tbtn--print:hover { background: #15803d; }

/* ── Page wrapper (screen shadow + spacing) ────────── */
.al-page-wrap { padding: 24px 0 40px; }

/* ── A4 Letter container ───────────────────────────── */
.al-letter {
    width: 210mm;
    min-height: 297mm;
    margin: 0 auto;
    padding: 18mm 18mm 22mm 22mm;
    background: #fff;
    box-shadow: 0 4px 28px rgba(0,0,0,.25);
}

/* ── University header ─────────────────────────────── */
.al-header { text-align: center; margin-bottom: 6pt; }
.al-logo   { max-height: 80px; max-width: 240px; display: block; margin: 0 auto 4pt; }
.al-univ-name { font-size: 15pt; font-weight: bold; letter-spacing: .5px; line-height: 1.2; }
.al-univ-tagline { font-size: 9pt; color: #333; margin-top: 3pt; }
.al-divider { border: none; border-top: 2px solid #000; margin: 7pt 0; }

/* ── Letter title ──────────────────────────────────── */
.al-letter-title {
    text-align: center;
    font-size: 13pt;
    font-weight: bold;
    text-decoration: underline;
    letter-spacing: 1.5px;
    margin: 10pt 0 14pt;
    text-transform: uppercase;
}

/* ── Student info block ────────────────────────────── */
.al-student-info { margin-bottom: 10pt; }
.al-student-row  { display: flex; margin-bottom: 2pt; }
.al-slabel { min-width: 115pt; font-weight: normal; }
.al-sval   { font-weight: bold; }

/* ── Date ──────────────────────────────────────────── */
.al-date-row {
    text-align: right;
    margin: 10pt 0 14pt;
    font-size: 11pt;
}

/* ── Programme block ───────────────────────────────── */
.al-prog-block { margin: 4pt 0 10pt 20pt; }
.al-prog-name  { font-weight: bold; font-size: 12pt; display: block; margin-bottom: 4pt; }
.al-prog-detail { margin: 1.5pt 0; }

/* ── Body text ─────────────────────────────────────── */
p { margin: 0 0 7pt; text-align: justify; }
ol, ul { margin: 3pt 0 8pt 2pt; padding-left: 18pt; }
li { margin-bottom: 3pt; }

/* ── Section headings ──────────────────────────────── */
.al-section-head {
    font-weight: bold;
    text-decoration: underline;
    text-transform: uppercase;
    margin: 11pt 0 4pt;
    font-size: 11.5pt;
}

/* ── Fees ──────────────────────────────────────────── */
.al-fees-label { font-weight: bold; margin: 6pt 0 3pt; font-size: 11pt; }
.al-fees-table {
    border-collapse: collapse;
    margin: 4pt 0 8pt;
    font-size: 11pt;
}
.al-fees-table th {
    border: 1px solid #000;
    padding: 3pt 14pt;
    background: #f0f0f0;
    font-weight: bold;
    text-align: left;
}
.al-fees-table td {
    border: 1px solid #000;
    padding: 3pt 14pt;
    text-align: left;
}
.al-total-cell { font-weight: bold; }

/* ── Signature ─────────────────────────────────────── */
.al-sig       { margin-top: 18pt; }
.al-sig p     { text-align: left; }
.al-sig-img   { display: block; max-height: 55pt; max-width: 200pt; margin: 6pt 0 0; }
.al-sig-name  { font-weight: bold; margin-top: 4pt !important; }
.al-sig-title { font-weight: bold; }

/* ══ PRINT overrides ══════════════════════════════════ */
@media print {
    .al-toolbar  { display: none !important; }
    html, body   { background: #fff !important; }
    .al-page-wrap { padding: 0; }
    .al-letter {
        box-shadow: none !important;
        margin: 0; padding: 0;
        width: 100%; min-height: auto;
    }
}
</style>
</head>
<body>

<!-- ── Toolbar ─────────────────────────────────────────── -->
<div class="al-toolbar">
    <span class="al-toolbar-title">
        <asp:Literal ID="litToolbarTitle" runat="server" Text="Admission Letter" />
    </span>
    <a href="AdmissionLetterConfig.aspx" class="al-tbtn">
        &#9881; Config
    </a>
    <a href="javascript:history.back()" class="al-tbtn">&#8592; Back</a>
    <button type="button" class="al-tbtn al-tbtn--print" onclick="window.print()">
        &#128438;&nbsp; Print&nbsp;/&nbsp;Save&nbsp;as&nbsp;PDF
    </button>
</div>

<!-- ── Letter ──────────────────────────────────────────── -->
<div class="al-page-wrap">
    <div class="al-letter">
        <asp:Literal ID="litBody" runat="server" />
    </div>
</div>

<script>
// Auto-trigger print when ?autoprint=1
(function(){
    if (window.location.search.indexOf('autoprint=1') >= 0)
        window.onload = function(){ window.print(); };
})();
</script>
</body>
</html>
