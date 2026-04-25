<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="FeeAccessChecker.aspx.cs"
    Inherits="COOPERP_NewScreens_FeeAccessChecker"
    Title="Fee Access Checker - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===============================================================
   FEE ACCESS CHECKER — fac- prefix
   Design system: primary #05275C, accent #174DA4, 0 border-radius
   =============================================================== */

/* -- Page header ----------------------------------------------- */
.fac-page-header {
    display: flex; align-items: center; justify-content: space-between;
    flex-wrap: wrap; gap: 8px;
    padding: 14px 18px; background: #fff;
    border-bottom: 2px solid #174DA4; margin-bottom: 18px;
}
.fac-page-header__left { display: flex; align-items: center; gap: 10px; }
.fac-page-header__icon {
    width: 36px; height: 36px; background: #eef2fb; border-radius: 6px;
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.fac-page-title { font-size: 16px; font-weight: 700; color: #1a1a2e; }
.fac-page-sub   { font-size: 11px; color: #666; margin-top: 1px; }

/* -- Search bar ------------------------------------------------ */
.fac-search-bar {
    display: flex; align-items: stretch; gap: 0;
    background: #fff; border: 1px solid #d0d5dd;
    max-width: 520px; margin: 0 auto 22px;
}
.fac-search-bar__input {
    flex: 1; border: none; outline: none; padding: 10px 14px;
    font-size: 14px; color: #1a1a2e; background: transparent;
}
.fac-search-bar__input::placeholder { color: #a0a0a0; }
.fac-search-bar__btn {
    background: #05275C; color: #fff; border: none; padding: 10px 22px;
    font-size: 13px; font-weight: 600; cursor: pointer;
    display: flex; align-items: center; gap: 6px;
    transition: background .15s;
}
.fac-search-bar__btn:hover { background: #174DA4; }
.fac-search-bar__btn:disabled { opacity: .55; cursor: not-allowed; }

/* -- Spinner --------------------------------------------------- */
.fac-spinner {
    display: none; text-align: center; padding: 32px 0; color: #555; font-size: 13px;
}
.fac-spinner.fac-show { display: block; }
.fac-spinner__ring {
    display: inline-block; width: 28px; height: 28px;
    border: 3px solid #ddd; border-top-color: #174DA4; border-radius: 50%;
    animation: fac-spin .7s linear infinite; margin-bottom: 6px;
}
@keyframes fac-spin { to { transform: rotate(360deg); } }

/* -- Result card ----------------------------------------------- */
.fac-result { display: none; margin: 0 auto; max-width: 680px; }
.fac-result.fac-show { display: block; }
.fac-result__card {
    background: #fff; border: 1px solid #e0e0e0; margin-bottom: 16px;
}

/* -- Verdict banner -------------------------------------------- */
.fac-verdict {
    padding: 16px 20px; display: flex; align-items: center; gap: 14px;
    border-bottom: 1px solid #e0e0e0;
}
.fac-verdict--pass { background: #f0faf3; }
.fac-verdict--fail { background: #fef4f2; }
.fac-verdict--noPolicy { background: #fefce8; }
.fac-verdict__icon {
    width: 44px; height: 44px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.fac-verdict--pass .fac-verdict__icon { background: #d1fae5; color: #047857; }
.fac-verdict--fail .fac-verdict__icon { background: #fde2d9; color: #b91c1c; }
.fac-verdict--noPolicy .fac-verdict__icon { background: #fef3c7; color: #92400e; }
.fac-verdict__title { font-size: 15px; font-weight: 700; color: #1a1a2e; }
.fac-verdict__sub { font-size: 12px; color: #555; margin-top: 2px; }

/* -- Financial summary ----------------------------------------- */
.fac-finance {
    display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
    gap: 0; border-bottom: 1px solid #e0e0e0;
}
.fac-finance__item {
    padding: 14px 18px; text-align: center;
    border-right: 1px solid #e0e0e0;
}
.fac-finance__item:last-child { border-right: none; }
.fac-finance__val { font-size: 16px; font-weight: 700; color: #1a1a2e; }
.fac-finance__label { font-size: 11px; color: #777; margin-top: 2px; }

/* -- Criteria list --------------------------------------------- */
.fac-criteria { padding: 0; }
.fac-criterion {
    display: flex; align-items: flex-start; gap: 12px;
    padding: 12px 18px; border-bottom: 1px solid #f0f0f0;
}
.fac-criterion:last-child { border-bottom: none; }
.fac-criterion__icon {
    width: 22px; height: 22px; border-radius: 50%; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    margin-top: 1px;
}
.fac-criterion--pass .fac-criterion__icon { background: #d1fae5; color: #047857; }
.fac-criterion--fail .fac-criterion__icon { background: #fde2d9; color: #b91c1c; }
.fac-criterion__body { flex: 1; }
.fac-criterion__rule { font-size: 13px; font-weight: 600; color: #1a1a2e; }
.fac-criterion__detail { font-size: 12px; color: #555; margin-top: 2px; }

/* -- Guidance -------------------------------------------------- */
.fac-guidance {
    padding: 14px 18px; background: #fef8e8; border-top: 1px solid #e0e0e0;
    font-size: 12px; color: #7c5e10;
}
.fac-guidance__title { font-weight: 700; margin-bottom: 4px; }

/* -- Policy info bar ------------------------------------------- */
.fac-policy-bar {
    display: flex; flex-wrap: wrap; gap: 16px;
    padding: 10px 18px; background: #f9fafb; border-bottom: 1px solid #e0e0e0;
    font-size: 11px; color: #555;
}
.fac-policy-bar__item strong { color: #1a1a2e; }

/* -- Error ----------------------------------------------------- */
.fac-error {
    display: none; max-width: 680px; margin: 0 auto;
    padding: 14px 18px; background: #fef4f2; border: 1px solid #fbc5bb;
    font-size: 13px; color: #b91c1c;
}
.fac-error.fac-show { display: block; }

/* -- Responsive ------------------------------------------------ */
@media (max-width: 600px) {
    .fac-search-bar { flex-direction: column; }
    .fac-finance { grid-template-columns: 1fr 1fr; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ═══ Page header ═══ -->
<div class="fac-page-header">
    <div class="fac-page-header__left">
        <div class="fac-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
            </svg>
        </div>
        <div>
            <div class="fac-page-title">Fee Access Checker</div>
            <div class="fac-page-sub">Look up any student and verify if they meet the active fee access policy rules</div>
        </div>
    </div>
</div>

<!-- ═══ Search ═══ -->
<div class="fac-search-bar" id="facSearchBar">
    <input type="text" class="fac-search-bar__input" id="facRegno"
           placeholder="Enter student registration number (e.g. 2024/BSC/1234)" autocomplete="off" />
    <button type="button" class="fac-search-bar__btn" id="facCheckBtn" onclick="facCheck()">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        Check Access
    </button>
</div>

<!-- ═══ Spinner ═══ -->
<div class="fac-spinner" id="facSpinner">
    <div class="fac-spinner__ring"></div>
    <div>Evaluating student against policy rules&hellip;</div>
</div>

<!-- ═══ Error ═══ -->
<div class="fac-error" id="facError"></div>

<!-- ═══ Result ═══ -->
<div class="fac-result" id="facResult">
    <div class="fac-result__card">
        <!-- Verdict -->
        <div class="fac-verdict" id="facVerdict">
            <div class="fac-verdict__icon" id="facVerdictIcon"></div>
            <div>
                <div class="fac-verdict__title" id="facVerdictTitle"></div>
                <div class="fac-verdict__sub" id="facVerdictSub"></div>
            </div>
        </div>

        <!-- Policy info bar -->
        <div class="fac-policy-bar" id="facPolicyBar"></div>

        <!-- Financial summary -->
        <div class="fac-finance" id="facFinance"></div>

        <!-- Criteria -->
        <div class="fac-criteria" id="facCriteria"></div>

        <!-- Guidance -->
        <div class="fac-guidance" id="facGuidance" style="display:none;">
            <div class="fac-guidance__title">&#9888; What the student needs to do:</div>
            <div id="facGuidanceText"></div>
        </div>
    </div>
</div>

<!-- Hidden field for API base URL -->
<asp:HiddenField ID="hfApiBase" runat="server" />
<asp:HiddenField ID="hfAdminToken" runat="server" />

<!-- ═══ JS ═══ -->
<script>
(function () {
    // Enter key triggers search
    var input = document.getElementById('facRegno');
    if (input) {
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') { e.preventDefault(); facCheck(); }
        });
    }
})();

function facCheck() {
    var regno = (document.getElementById('facRegno').value || '').trim();
    if (!regno) { facShowError('Please enter a student registration number.'); return; }

    // UI state
    facHide('facResult'); facHide('facError');
    document.getElementById('facSpinner').classList.add('fac-show');
    document.getElementById('facCheckBtn').disabled = true;

    var apiBase = document.getElementById('<%= hfApiBase.ClientID %>').value;
    var token   = document.getElementById('<%= hfAdminToken.ClientID %>').value;
    var url = apiBase + '?action=access_status&regno=' + encodeURIComponent(regno) + '&token=' + encodeURIComponent(token);

    fetch(url, { method: 'GET' })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        document.getElementById('facSpinner').classList.remove('fac-show');
        document.getElementById('facCheckBtn').disabled = false;

        if (!json.success) {
            facShowError(json.message || 'API returned an error.');
            return;
        }

        facRender(json.data, regno);
    })
    .catch(function (err) {
        document.getElementById('facSpinner').classList.remove('fac-show');
        document.getElementById('facCheckBtn').disabled = false;
        facShowError('Network error: ' + err.message);
    });
}

function facRender(d, regno) {
    var el = document.getElementById('facResult');
    el.classList.add('fac-show');

    // Resolve nested objects (new API structure)
    var pol = d.policy || {};
    var fin = d.finance || {};
    var bur = d.bursary || {};
    var stu = d.student || {};
    var sum = d.summary || {};

    // ── Verdict ──
    var verdict = document.getElementById('facVerdict');
    var vIcon   = document.getElementById('facVerdictIcon');
    var vTitle  = document.getElementById('facVerdictTitle');
    var vSub    = document.getElementById('facVerdictSub');

    verdict.className = 'fac-verdict';
    if (!d.has_policy) {
        verdict.classList.add('fac-verdict--pass');
        vIcon.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>';
        vTitle.textContent = 'ACCESS GRANTED';
        vSub.textContent = 'No active fee access restrictions. All students are currently granted access.';
    } else if (d.access_allowed) {
        verdict.classList.add('fac-verdict--pass');
        vIcon.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>';
        vTitle.textContent = 'ACCESS ALLOWED';
        vSub.textContent = d.verdict_reason || (regno + ' meets the fee access requirements.');
    } else {
        verdict.classList.add('fac-verdict--fail');
        vIcon.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>';
        vTitle.textContent = 'ACCESS DENIED';
        vSub.textContent = d.verdict_reason || (regno + ' does NOT meet the fee access requirements.');
    }

    // ── Student info ──
    if (stu.name) {
        vSub.textContent += ' \u2014 ' + stu.name;
        if (stu.programme) vSub.textContent += ' (' + stu.programme + ', Year ' + (stu.study_year || '?') + ')';
    }

    // ── Policy bar ──
    var bar = document.getElementById('facPolicyBar');
    bar.innerHTML = '';
    if (d.has_policy) {
        bar.innerHTML =
            '<div class="fac-policy-bar__item"><strong>Policy:</strong> ' + esc(pol.title || '') + '</div>' +
            '<div class="fac-policy-bar__item"><strong>Year:</strong> ' + esc(pol.academic_year || '') + '</div>' +
            '<div class="fac-policy-bar__item"><strong>Semester:</strong> ' + (pol.semester || '') + '</div>' +
            '<div class="fac-policy-bar__item"><strong>Logic:</strong> ' + esc(pol.combination_logic || '') +
            (pol.combination_logic_description ? ' <span style="color:#888;font-size:10px;">(' + esc(pol.combination_logic_description) + ')</span>' : '') + '</div>' +
            (bur.status && bur.status !== 'None' ? '<div class="fac-policy-bar__item"><strong>Bursary:</strong> ' + esc(bur.status) + '</div>' : '') +
            (sum.total_rules !== undefined ? '<div class="fac-policy-bar__item"><strong>Rules:</strong> ' + sum.rules_passed + ' passed, ' + sum.rules_failed + ' failed / ' + sum.total_rules + ' total</div>' : '');
        bar.style.display = '';
    } else {
        bar.style.display = 'none';
    }

    // ── Finance summary ──
    var finEl = document.getElementById('facFinance');
    if (d.has_policy && fin.total_bill !== undefined) {
        var bal = fin.balance || 0;
        var balColor = bal < 0 ? '#b91c1c' : '#047857';
        var balText = bal < 0
            ? fmt(Math.abs(bal))
            : fmt(bal) + ' CR';
        var balLabel = bal < 0 ? 'Outstanding Balance' : 'Credit Balance';
        finEl.innerHTML =
            '<div class="fac-finance__item"><div class="fac-finance__val">' + fmt(fin.total_bill) + '</div><div class="fac-finance__label">Total Billed (' + esc(fin.currency || 'UGX') + ')</div></div>' +
            '<div class="fac-finance__item"><div class="fac-finance__val">' + fmt(fin.total_paid) + '</div><div class="fac-finance__label">Total Paid</div></div>' +
            '<div class="fac-finance__item"><div class="fac-finance__val" style="color:' + balColor + '">' + balText + '</div><div class="fac-finance__label">' + balLabel + '</div></div>' +
            '<div class="fac-finance__item"><div class="fac-finance__val">' + (fin.percentage_paid || 0).toFixed(1) + '%</div><div class="fac-finance__label">Percentage Paid</div></div>';
        finEl.style.display = '';
    } else { finEl.style.display = 'none'; }

    // ── Criteria ──
    var crit = document.getElementById('facCriteria');
    crit.innerHTML = '';
    if (d.criteria && d.criteria.length) {
        for (var i = 0; i < d.criteria.length; i++) {
            var c = d.criteria[i];
            var cls = c.passed ? 'fac-criterion--pass' : 'fac-criterion--fail';
            var ico = c.passed
                ? '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>'
                : '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
            crit.innerHTML +=
                '<div class="fac-criterion ' + cls + '">' +
                '  <div class="fac-criterion__icon">' + ico + '</div>' +
                '  <div class="fac-criterion__body">' +
                '    <div class="fac-criterion__rule">' + esc(c.rule) +
                (c.threshold ? ' <span style="color:#888;font-size:10px;font-weight:400;">(' + esc(c.threshold) + ')</span>' : '') +
                '</div>' +
                '    <div class="fac-criterion__detail">' + esc(c.detail) + '</div>' +
                (c.actual_value ? '    <div style="font-size:10px;color:#666;margin-top:2px;">Actual: ' + esc(c.actual_value) + '</div>' : '') +
                '  </div>' +
                '</div>';
        }
    }

    // ── Guidance ──
    var gPanel = document.getElementById('facGuidance');
    var gText  = document.getElementById('facGuidanceText');
    if (d.guidance && d.guidance.trim()) {
        gText.textContent = d.guidance;
        gPanel.style.display = '';
    } else {
        gPanel.style.display = 'none';
    }
}

function fmt(n) {
    if (n == null) return '0';
    return Number(n).toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
}
function fmtBal(n) {
    if (n == null) return '0';
    var abs = Math.abs(n);
    var s = abs.toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
    return n < 0 ? '-' + s : s;
}
function esc(s) {
    var d = document.createElement('div');
    d.appendChild(document.createTextNode(s));
    return d.innerHTML;
}
function facShowError(msg) {
    var el = document.getElementById('facError');
    el.textContent = msg;
    el.classList.add('fac-show');
    facHide('facResult');
}
function facHide(id) {
    var el = document.getElementById(id);
    if (el) el.classList.remove('fac-show');
}
</script>
</asp:Content>
