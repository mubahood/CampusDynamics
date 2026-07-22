<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TranscriptPrint.aspx.cs" Inherits="COOPERP_NewScreens_TranscriptPrint" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Academic Transcript</title>
<style>
/* ===== Page geometry ===== */
:root { --pad-v: 6px; --lh: 1.30; --sem-gap: 11px; }
@page { size: A4 portrait; margin: 14mm 14mm; }
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; background: #6b7280; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body { font-family: Georgia, "Times New Roman", "Liberation Serif", serif; color: #14161a; }

/* ===== Screen chrome ===== */
.print-bar { position: sticky; top: 0; z-index: 50; display: flex; gap: 8px; align-items: center;
  background: #05275C; color: #fff; padding: 9px 16px; font-family: -apple-system, "Segoe UI", sans-serif; box-shadow: 0 2px 10px rgba(0,0,0,.25); }
.print-bar__t { font-weight: 700; font-size: 13px; margin-right: auto; letter-spacing: .3px; }
.pb-btn { font: inherit; font-size: 12px; font-weight: 600; padding: 7px 16px; border: 1px solid rgba(255,255,255,.35);
  background: rgba(255,255,255,.08); color: #fff; cursor: pointer; border-radius: 2px; }
.pb-btn--go { background: #fff; color: #05275C; border-color: #fff; }
.pb-btn:hover { background: rgba(255,255,255,.2); }
.pb-btn--go:hover { background: #e8eefc; }

/* ===== Sheet ===== */
.sheet { width: 210mm; margin: 18px auto; }
.tx { position: relative; background: #fff; width: 100%; padding: 14mm 14mm; box-shadow: 0 6px 30px rgba(0,0,0,.35); }

/* Student photo — full image, never cropped (object-fit: contain), in a small fixed box */
.tx-photo { position: absolute; top: 14mm; right: 14mm; width: 27mm; height: 34mm;
  border: 1px solid #c9ced8; background: #f3f4f6; padding: 1px; overflow: hidden; z-index: 3; }
.tx-photo img { width: 100%; height: 100%; object-fit: contain; object-position: center; display: block; }

/* ===== Running identity header — REPEATS at the top of EVERY printed page ===== */
/* The whole document flows inside one table so the <thead> repeats on each page
   (display:table-header-group). This guarantees the student's identity appears at
   the top of pages 2, 3, ... — not only page 1. */
table.tx-page { width: 100%; border-collapse: collapse; }
table.tx-page > thead { display: table-header-group; }
table.tx-page > thead > tr > td,
table.tx-page > tbody > tr > td { padding: 0; border: 0; }
.tx-runhead { border-bottom: 1.5px solid #05275C; padding: 1px 40mm 5px 0; margin-bottom: 9px; }
.tx-runhead__l { font-size: 8pt; font-weight: 700; letter-spacing: .9px; text-transform: uppercase;
  color: #05275C; line-height: 1.25; }
.tx-runhead__r { font-size: 9.5pt; color: #14161a; line-height: 1.3; margin-top: 1px;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.tx-runhead__r b { color: #05275C; font-weight: 700; }
.tx-runhead .sep { color: #9aa3b2; margin: 0 6px; }
/* Fail-safe: the strip is shown by default (so multi-page is always covered); the layout
   engine hides it only once it has confirmed the transcript fits a single page. */
html.tx-singlepage .tx-runhead { display: none; }

/* ===== Letterhead ===== */
.tx-head { text-align: center; border-bottom: 2px solid #05275C; padding: 0 30mm 8px; margin-bottom: 10px; }
.tx-head__uni { font-size: 19pt; font-weight: 700; letter-spacing: .5px; color: #05275C; line-height: 1.1; }
.tx-head__office { font-size: 11.5pt; font-weight: 700; letter-spacing: 1.5px; margin-top: 2px; color: #2a2f3a; }
.tx-head__addr { font-size: 8.5pt; color: #555; margin-top: 3px; }
.tx-head__title { font-size: 15pt; font-weight: 700; letter-spacing: 4px; margin-top: 7px; padding: 3px 0;
  border-top: 1px solid #c9ced8; border-bottom: 1px solid #c9ced8; display: inline-block; padding-left: 22px; padding-right: 22px; color: #05275C; }

/* ===== Bio ===== */
.tx-bio { display: grid; grid-template-columns: 1fr 1fr; gap: 2px 26px; margin: 10px 0 6px; }
.tx-bio__cell { display: flex; align-items: baseline; gap: 8px; padding: 2.5px 0; border-bottom: 1px dotted #d7dbe2; }
.tx-bio__l { font-size: 8.5pt; font-weight: 700; letter-spacing: .6px; color: #6b7280; text-transform: uppercase; min-width: 116px; }
.tx-bio__v { font-size: 10.5pt; font-weight: 700; color: #14161a; }

/* ===== Award strip ===== */
.tx-strip { display: flex; gap: 8px; margin: 8px 0 12px; }
.tx-strip__c { flex: 1; border: 1px solid #d7dbe2; background: #f6f8fc; padding: 6px 10px; text-align: center; }
.tx-strip__v { font-size: 12pt; font-weight: 700; color: #05275C; line-height: 1.1; }
.tx-strip__l { font-size: 7.5pt; font-weight: 700; letter-spacing: .5px; color: #6b7280; text-transform: uppercase; margin-top: 2px; }

/* ===== Semester blocks ===== */
.sem { margin-bottom: var(--sem-gap); break-inside: avoid; }
.sem-head { display: flex; justify-content: space-between; align-items: baseline;
  background: #eef2f9; border-left: 3px solid #05275C; padding: 4px 9px; font-size: 11pt; font-weight: 700; color: #1f2733; }
.sem-head .sem-gpa { font-size: 9.5pt; font-weight: 700; color: #05275C; font-family: "Trebuchet MS", Georgia, serif; }

table.ct { width: 100%; border-collapse: collapse; table-layout: fixed; }
table.ct th { font-size: 9.5pt; font-weight: 700; letter-spacing: .4px; text-transform: uppercase;
  background: #fbfcfe; color: #54607a; border-bottom: 1.5px solid #c9ced8; padding: 3px 8px; text-align: left; }
table.ct td { padding: var(--pad-v) 8px; border-bottom: 1px solid #eef0f4; vertical-align: top; line-height: var(--lh); }
table.ct tr:last-child td { border-bottom: 1px solid #c9ced8; }
.c-code  { width: 16%; }
.c-course{ width: 62%; }
.c-cu    { width: 8%;  text-align: center; }
.c-grade { width: 14%; text-align: center; }
th.c-cu, th.c-grade, td.c-cu, td.c-grade { text-align: center; }
td.c-code { font-size: 10.5pt; font-weight: 700; color: #05275C; white-space: nowrap; letter-spacing: .3px; }
td.c-cu   { font-size: 10.5pt; font-variant-numeric: tabular-nums; }
td.c-grade{ font-size: 10.5pt; font-weight: 700; }
td.c-course { font-size: 11pt; }
.c-fit { display: inline-block; line-height: 1.2; max-width: 100%; }
/* 5 deterministic levels by course-name length (set server-side; longer name -> smaller).
   Pronounced 14pt -> 9pt spread so short vs long names differ visibly. */
.c-fit.c-len1 { font-size: 14pt;   line-height: 1.25; }   /* <=22 chars */
.c-fit.c-len2 { font-size: 12pt;   line-height: 1.20; }   /* 23-34 */
.c-fit.c-len3 { font-size: 10.5pt; line-height: 1.16; }   /* 35-46 */
.c-fit.c-len4 { font-size: 9.5pt;  line-height: 1.12; }   /* 47-58 */
.c-fit.c-len5 { font-size: 9pt;    line-height: 1.08; }   /* 59+   */

/* ===== Footer grid (key + classification) ===== */
.tx-foot-grid { display: grid; grid-template-columns: 1.15fr 1fr; gap: 16px; margin-top: 12px; break-inside: avoid; }
.tx-key__t { font-size: 9pt; font-weight: 700; letter-spacing: .6px; text-transform: uppercase; color: #54607a; margin-bottom: 3px; }
table.kt { width: 100%; border-collapse: collapse; }
table.kt th { font-size: 8pt; text-transform: uppercase; letter-spacing: .3px; color: #6b7280; text-align: left;
  border-bottom: 1px solid #c9ced8; padding: 2px 6px; }
table.kt td { font-size: 9pt; padding: 1.5px 6px; border-bottom: 1px solid #f0f2f5; }
.tx-class table.kt td:last-child { text-align: right; font-variant-numeric: tabular-nums; color: #444; }

/* ===== Verification / signature ===== */
.tx-verify { display: flex; justify-content: space-between; align-items: flex-end; margin-top: 16px; gap: 24px; break-inside: avoid; }
.tx-nb { font-size: 8pt; color: #555; max-width: 60%; line-height: 1.4; }
.tx-sign { text-align: center; min-width: 210px; }
.tx-sign__line { border-top: 1px solid #14161a; margin-bottom: 3px; }
.tx-sign__name { font-size: 10pt; font-weight: 700; }
.tx-sign__title { font-size: 8pt; letter-spacing: .6px; color: #6b7280; text-transform: uppercase; }

.tx-err { padding: 40px; font-family: -apple-system, "Segoe UI", sans-serif; font-size: 15px; color: #b91c1c; text-align: center; }

/* ===== Density tiers (page-fit compression) ===== */
.d1 { --pad-v: 5px; --lh: 1.22; --sem-gap: 9px; }
.d2 { --pad-v: 4px; --lh: 1.15; --sem-gap: 7px; }
.d3 { --pad-v: 3px; --lh: 1.10; --sem-gap: 5px; }
.d2 .sem-head { padding: 3px 9px; }
.d3 .sem-head { padding: 2px 9px; }
.d3 table.ct th { padding: 2px 8px; }

/* ===== Print ===== */
@media print {
  html, body { background: #fff; }
  .print-bar { display: none !important; }
  .sheet { width: auto; margin: 0; }
  .tx { box-shadow: none; padding: 0; width: auto; }
  thead { display: table-header-group; }
  .sem, .tx-foot-grid, .tx-verify { break-inside: avoid; }
}
</style>
</head>
<body>
<div class="print-bar">
  <span class="print-bar__t">Academic Transcript</span>
  <button type="button" class="pb-btn" onclick="window.close()">Close</button>
  <button type="button" class="pb-btn pb-btn--go" onclick="window.print()">&#128424;&nbsp; Print / Save PDF</button>
</div>

<div class="sheet">
  <%= Body %>
</div>

<script type="text/javascript">
(function () {
  var ROMAN = /^(I{1,3}|IV|V|VI{0,3}|IX|X{1,3})$/i;
  var CONNECT = { "AND":1, "OF":1, "FOR":1, "IN":1, "TO":1, "THE":1, "WITH":1, "&":1 };

  function setFont(span, pt, lh) { span.style.fontSize = pt + "pt"; span.style.lineHeight = lh; }

  // Tier by character count: [maxChars, pt, lineHeight]
  var TIERS = [[28,12,1.25],[42,11,1.20],[58,10,1.15],[100000,9,1.10]];

  function startTier(len) { for (var i=0;i<TIERS.length;i++) if (len<=TIERS[i][0]) return i; return TIERS.length-1; }

  function isRoman(w){ return ROMAN.test(w.replace(/[().,&]/g,"")); }
  function isNumberish(w){ return /\d/.test(w); }

  // Decide if breaking AFTER word index i is acceptable (1-based content already split into words)
  function breakOk(words, i, depth) {
    if (depth > 0) return false;                    // never break inside parentheses
    var next = words[i+1] || "";
    if (next.charAt(0) === ")") return false;        // don't strand a closing paren
    if (isRoman(next) || isNumberish(next)) return false; // keep numbers/roman with their phrase
    if (next.length <= 2 && next !== "(" ) return false;  // don't strand tiny tokens (II handled above)
    return true;
  }
  // Semantic preference: prefer breaking BEFORE "(" and AFTER a connective word
  function semBonus(words, i) {
    var cur = (words[i]||"").toUpperCase(), next = (words[i+1]||"");
    var b = 0;
    if (next.charAt(0) === "(") b += 14;
    if (CONNECT[cur.replace(/[^A-Z&]/g,"")]) b += 10;
    if (/[):]$/.test(words[i])) b += 6;
    return b;
  }

  function semanticWrap(span, text) {
    var words = text.split(/\s+/).filter(Boolean);
    if (words.length < 2) { span.textContent = text; return; }
    var total = text.length, half = total / 2, acc = 0, depth = 0, best = -1, bestScore = 1e9;
    for (var i = 0; i < words.length - 1; i++) {
      acc += words[i].length + 1;
      var w = words[i];
      depth += (w.split("(").length - 1) - (w.split(")").length - 1);
      if (depth < 0) depth = 0;
      if (!breakOk(words, i, depth)) continue;
      var score = Math.abs(acc - half) - semBonus(words, i);
      if (score < bestScore) { bestScore = score; best = i; }
    }
    if (best < 0) best = Math.max(0, Math.floor(words.length / 2) - 1);
    var nbsp = " ";
    var l1 = words.slice(0, best + 1).join(nbsp);
    var l2 = words.slice(best + 1).join(nbsp);
    var d = document.createElement("span");
    d.textContent = l1; var h1 = d.innerHTML;
    d.textContent = l2; var h2 = d.innerHTML;
    span.innerHTML = h1 + "<br>" + h2;
  }

  function fitCourse(span) {
    // The base size is already chosen DETERMINISTICALLY by course-name length via the
    // server-set class (.c-len1/2/3). Here we only refine: if a (usually long) name still
    // overflows one line, nudge it down to a floor, then fall back to a 2-line semantic wrap.
    var td = span.parentNode;
    var text = (span.textContent || "").replace(/\s+/g, " ").trim();
    span.textContent = text;
    var avail = td.clientWidth - 4;
    span.style.whiteSpace = "nowrap";
    var guard = 0;
    while (span.scrollWidth > avail && guard++ < 16) {
      var px = parseFloat(window.getComputedStyle(span).fontSize);
      if (px <= 10.6) break;                          // ~8pt floor (8pt ≈ 10.6px @96dpi)
      span.style.fontSize = (px - 0.5) + "px";
    }
    if (span.scrollWidth > avail) {                   // still overflowing -> semantic 2-line wrap
      span.style.whiteSpace = "normal";
      semanticWrap(span, text);
    }
  }

  function pageUsablePx() {
    // A4 height 297mm minus 14mm top+bottom margins, converted to px via a probe.
    var probe = document.createElement("div");
    probe.style.cssText = "position:absolute;visibility:hidden;height:269mm;";
    document.body.appendChild(probe);
    var px = probe.offsetHeight; document.body.removeChild(probe);
    return px || 1000;
  }

  function layout() {
    var tx = document.getElementById("tx");
    if (!tx) return;
    // 1. Fit every course name to one line (or graceful 2-line wrap)
    var cells = tx.querySelectorAll(".c-course .c-fit");
    for (var i = 0; i < cells.length; i++) fitCourse(cells[i]);

    // 2. Page-fit compression: tighten density to minimise page count without crowding
    var page = pageUsablePx();
    var densities = ["", "d1", "d2", "d3"];
    var bestClass = "";
    for (var k = 0; k < densities.length; k++) {
      tx.classList.remove("d1", "d2", "d3");
      if (densities[k]) tx.classList.add(densities[k]);
      var pagesNow = Math.ceil(tx.scrollHeight / page);
      bestClass = densities[k];
      if (pagesNow <= 1) break;                       // fits a single page — stop tightening
    }
    // Repeating identity strip: hide it ONLY when the transcript confirmably fits one page.
    // (Default-visible, so a multi-page transcript — or any timing/JS hiccup — always keeps it.)
    document.documentElement.classList.toggle("tx-singlepage", Math.ceil(tx.scrollHeight / page) <= 1);
    // Re-fit course cells once more (column width unchanged, but safe after density change)
    for (var j = 0; j < cells.length; j++) fitCourse(cells[j]);
  }

  function run() {
    layout();
    // Re-run once after fonts settle (web-safe fonts are sync, but guard reflow timing)
    setTimeout(layout, 60);
    <% if (AutoPrint) { %> setTimeout(function(){ window.print(); }, 350); <% } %>
  }

  if (document.readyState === "complete" || document.readyState === "interactive") setTimeout(run, 0);
  else document.addEventListener("DOMContentLoaded", run);
  window.addEventListener("beforeprint", layout);
})();
</script>
</body>
</html>
