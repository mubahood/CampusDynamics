<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ElectionResults.aspx.cs" Inherits="COOPERP_NewScreens_ElectionResults" Title="Election Results - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ELECTION RESULTS — LIVE DASHBOARD ===== */

/* -- Page Header --------------------------------------- */
.el-page-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 12px 0 10px; margin-bottom: 14px;
    border-bottom: 2px solid #174DA4; flex-wrap: wrap; gap: 8px;
}
.el-page-header__left { display: flex; align-items: center; gap: 10px; min-width: 0; }
.el-page-header__icon {
    width: 36px; height: 36px; background: #174DA4;
    display: flex; align-items: center; justify-content: center;
    border-radius: 6px; flex-shrink: 0;
}
.el-page-header__title { font-size: 16px; font-weight: 700; color: #1a1a2e; margin: 0; line-height: 1.2; }
.el-page-header__sub   { font-size: 11px; color: #888; margin-top: 1px; }
.el-page-header__actions { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }

/* -- Live Indicator ------------------------------------ */
.el-live-badge {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px; border-radius: 16px; font-size: 10px; font-weight: 700;
    text-transform: uppercase; letter-spacing: .5px;
}
.el-live-badge--active { background: #fdecea; color: #dc3545; border: 1px solid #f5c6cb; }
.el-live-badge--closed { background: #e6f4ea; color: #28a745; border: 1px solid #a5d6a7; }
.el-live-badge--off    { background: #f5f5f5; color: #999; border: 1px solid #ddd; }
.el-live-dot {
    width: 6px; height: 6px; border-radius: 50%; background: #dc3545;
    animation: elPulse 1.5s infinite;
}
@keyframes elPulse { 0%,100% { opacity: 1; } 50% { opacity: .3; } }

/* -- Turnout Hero -------------------------------------- */
.el-hero-turnout {
    background: linear-gradient(135deg, #174DA4 0%, #0f3576 100%);
    border-radius: 8px; padding: 16px 20px; margin-bottom: 14px;
    color: #fff; display: flex; align-items: center; justify-content: space-between;
    flex-wrap: wrap; gap: 12px;
}
.el-hero-turnout__left  { min-width: 0; }
.el-hero-turnout__title { font-size: 11px; text-transform: uppercase; letter-spacing: .5px; opacity: .8; }
.el-hero-turnout__big   { font-size: 32px; font-weight: 800; line-height: 1.1; }
.el-hero-turnout__sub   { font-size: 11px; opacity: .7; margin-top: 2px; }
.el-hero-turnout__right { flex: 1; min-width: 200px; max-width: 400px; }
.el-hero-turnout__bar  {
    height: 12px; background: rgba(255,255,255,.2); border-radius: 8px; overflow: hidden;
}
.el-hero-turnout__fill {
    height: 100%; background: rgba(255,255,255,.85); border-radius: 8px;
    transition: width .6s ease;
}

/* -- Post Card ----------------------------------------- */
.el-post-card {
    background: #fff; border: 1px solid #e4e8f0; border-radius: 8px;
    margin-bottom: 14px; overflow: hidden;
}
.el-post-card__header {
    padding: 10px 16px; border-bottom: 1px solid #e4e8f0; background: #fafbfc;
    display: flex; align-items: center; justify-content: space-between;
}
.el-post-card__title { font-size: 14px; font-weight: 700; color: #1a1a2e; display: flex; align-items: center; gap: 8px; }
.el-post-card__badge { font-size: 10px; color: #888; font-weight: 400; }
.el-post-card__body  { padding: 12px 16px; }

/* -- Candidate Result Row ------------------------------ */
.el-result-row {
    display: flex; align-items: center; gap: 12px; padding: 8px 0;
    border-bottom: 1px solid #f5f5f5;
}
.el-result-row:last-child { border-bottom: none; }
.el-result-row--winner { background: #f0f9f2; margin: 0 -16px; padding: 8px 16px; border-radius: 6px; }

.el-result__rank {
    width: 28px; height: 28px; display: flex; align-items: center; justify-content: center;
    border-radius: 50%; font-size: 12px; font-weight: 700; flex-shrink: 0;
}
.el-result__rank--1 { background: #ffd700; color: #7a6400; }
.el-result__rank--2 { background: #e0e0e0; color: #555; }
.el-result__rank--3 { background: #e8c494; color: #7a5c2d; }
.el-result__rank--other { background: #f5f5f5; color: #999; }

.el-result__photo {
    width: 36px; height: 36px; border-radius: 50%; border: 2px solid #e4e8f0;
    object-fit: cover; flex-shrink: 0;
}
.el-result__photo--placeholder {
    width: 36px; height: 36px; border-radius: 50%; border: 2px solid #e4e8f0;
    background: #e8f0fc; display: flex; align-items: center; justify-content: center;
    font-size: 14px; font-weight: 700; color: #174DA4; flex-shrink: 0;
    text-transform: uppercase;
}

.el-result__info { flex: 1; min-width: 0; }
.el-result__name { font-size: 13px; font-weight: 600; color: #1a1a2e; }
.el-result__meta { font-size: 10px; color: #888; margin-top: 1px; }

.el-result__bar-wrap { flex: 1; min-width: 100px; max-width: 260px; }
.el-result__bar {
    height: 20px; background: #f0f2f5; border-radius: 10px; overflow: hidden; position: relative;
}
.el-result__bar-fill {
    height: 100%; border-radius: 10px; transition: width .6s ease;
    display: flex; align-items: center; padding-left: 6px; min-width: 0;
}
.el-result__bar-fill--lead { background: linear-gradient(90deg, #174DA4, #2563eb); }
.el-result__bar-fill--other { background: #d0d8e8; }
.el-result__bar-text { font-size: 9px; color: #fff; font-weight: 700; white-space: nowrap; }

.el-result__votes { text-align: right; min-width: 70px; }
.el-result__votes-num { font-size: 16px; font-weight: 700; color: #1a1a2e; }
.el-result__votes-pct { font-size: 10px; color: #888; }

.el-result__winner-badge {
    display: inline-flex; align-items: center; gap: 3px;
    background: #28a745; color: #fff; padding: 2px 8px; border-radius: 10px;
    font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px;
}
.el-result__tie-badge {
    display: inline-flex; align-items: center; gap: 3px;
    background: #e67e00; color: #fff; padding: 2px 8px; border-radius: 10px;
    font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px;
}

/* -- Buttons ------------------------------------------- */
.el-btn {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 5px 12px; border-radius: 6px; font-size: 11px; font-weight: 600;
    cursor: pointer; transition: all .15s; text-decoration: none; border: none;
}
.el-btn--primary { background: #174DA4; color: #fff; }
.el-btn--primary:hover { background: #0f3576; }
.el-btn--success { background: #28a745; color: #fff; }
.el-btn--success:hover { background: #1e8537; }
.el-btn--outline {
    background: transparent; border: 1px solid #ddd; color: #555;
}
.el-btn--outline:hover { background: #f5f7fa; border-color: #bbb; }

/* -- Flash Alert --------------------------------------- */
.el-flash { padding: 8px 14px; border-radius: 6px; font-size: 12px; display: flex; align-items: center; gap: 8px; margin-bottom: 12px; }
.el-flash--ok  { background: #e6f4ea; color: #1a7c35; border: 1px solid #a5d6a7; }
.el-flash--err { background: #fdecea; color: #b71c1c; border: 1px solid #ef9a9a; }

/* -- No Data Placeholder ------------------------------- */
.el-empty { text-align: center; padding: 40px 10px; color: #aaa; }
.el-empty svg { margin: 0 auto 8px; opacity: .5; display: block; }
.el-empty__title { font-size: 14px; font-weight: 600; color: #888; }
.el-empty__sub   { font-size: 11px; color: #aaa; margin-top: 3px; max-width: 320px; margin-left: auto; margin-right: auto; }

/* -- Auto-refresh indicator ---------------------------- */
.el-refresh-info {
    font-size: 10px; color: #aaa; display: flex; align-items: center; gap: 4px;
}

/* -- Filter Select ------------------------------------- */
.el-filter-select {
    border: 1px solid #ddd; border-radius: 6px;
    padding: 5px 8px; font-size: 11px; background: #fff; color: #333;
    cursor: pointer; min-width: 250px;
}
.el-filter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }

/* -- Responsive ---------------------------------------- */
@media(max-width:768px){
    .el-hero-turnout { flex-direction: column; text-align: center; }
    .el-hero-turnout__right { max-width: 100%; }
    .el-result-row { flex-wrap: wrap; }
    .el-result__bar-wrap { max-width: 100%; min-width: 0; order: 10; width: 100%; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Flash -->
<asp:Literal ID="litFlash" runat="server" />

<!-- Page Header -->
<div class="el-page-header">
    <div class="el-page-header__left">
        <div class="el-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
        </div>
        <div>
            <div class="el-page-header__title">Election Results</div>
            <div class="el-page-header__sub">Live vote tallies &amp; final results</div>
        </div>
    </div>
    <div class="el-page-header__actions">
        <asp:Literal ID="litLiveBadge" runat="server" />
        <span class="el-refresh-info" id="refreshInfo"></span>
    </div>
</div>

<!-- Election Selector -->
<div style="margin-bottom: 14px; display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
    <asp:DropDownList ID="ddlElection" runat="server" CssClass="el-filter-select" AutoPostBack="true"
        OnSelectedIndexChanged="ddlElection_Changed" />
    <asp:Button ID="btnCompute" runat="server" CssClass="el-btn el-btn--primary"
        Text="Compute Final Results" OnClick="btnCompute_Click"
        OnClientClick="return confirm('Compute and store final results for this election?');"
        Visible="false" />
</div>

<!-- No-election state -->
<asp:Panel ID="pnlNoElection" runat="server" Visible="true">
    <div style="padding:40px; text-align:center;">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="1.5" style="margin:0 auto 8px; display:block;"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
        <div style="font-size:14px; font-weight:600; color:#888;">Select an election above</div>
        <div style="font-size:11px; color:#aaa; margin-top:3px;">Choose an election to view its results.</div>
    </div>
</asp:Panel>

<!-- Results Content -->
<asp:Panel ID="pnlContent" runat="server" Visible="false">

    <!-- Turnout Hero -->
    <div class="el-hero-turnout" id="turnoutHero">
        <div class="el-hero-turnout__left">
            <div class="el-hero-turnout__title">Voter Turnout</div>
            <div class="el-hero-turnout__big" id="turnoutPctBig"><asp:Literal ID="litTurnoutPct" runat="server" Text="0" />%</div>
            <div class="el-hero-turnout__sub" id="turnoutSubText">
                <asp:Literal ID="litTurnoutDetail" runat="server" />
            </div>
        </div>
        <div class="el-hero-turnout__right">
            <div class="el-hero-turnout__bar">
                <div class="el-hero-turnout__fill" id="turnoutFill" style="width:<%= TurnoutPct %>%;"></div>
            </div>
        </div>
    </div>

    <!-- Results by Post -->
    <asp:Literal ID="litResultsBody" runat="server" />

</asp:Panel>

<asp:HiddenField ID="hdnElectionId" runat="server" Value="0" />
<asp:HiddenField ID="hdnIsLive" runat="server" Value="0" />

<script type="text/javascript">
// ─── Live Auto-Refresh ───────────────────────────────────────────────────
var _refreshTimer = null;
var _refreshInterval = 10000; // 10 seconds
var _lastRefresh = new Date();

function startAutoRefresh() {
    var isLive = document.getElementById('<%= hdnIsLive.ClientID %>').value === '1';
    if (!isLive) {
        var info = document.getElementById('refreshInfo');
        if (info) info.textContent = '';
        return;
    }

    updateRefreshInfo();
    _refreshTimer = setInterval(function() { fetchLiveResults(); }, _refreshInterval);
}

function fetchLiveResults() {
    var eid = document.getElementById('<%= hdnElectionId.ClientID %>').value;
    if (!eid || eid === '0') return;

    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'ElectionResults.aspx?ajax=liveresults&eid=' + eid + '&_=' + Date.now(), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                if (data.ok) {
                    updateTurnout(data.turnout);
                    updateCandidateVotes(data.posts);
                    _lastRefresh = new Date();
                    updateRefreshInfo();
                }
            } catch(e) { /* silently fail */ }
        }
    };
    xhr.send();
}

function updateTurnout(t) {
    var pctEl = document.getElementById('turnoutPctBig');
    if (pctEl) pctEl.textContent = t.pct + '%';
    var fill = document.getElementById('turnoutFill');
    if (fill) fill.style.width = t.pct + '%';
    var sub = document.getElementById('turnoutSubText');
    if (sub) sub.textContent = t.voted + ' of ' + t.total + ' voters';
}

function updateCandidateVotes(posts) {
    if (!posts) return;
    for (var p = 0; p < posts.length; p++) {
        var post = posts[p];
        // Calculate total for this post
        var totalVotes = 0;
        for (var c = 0; c < post.candidates.length; c++) {
            totalVotes += post.candidates[c].votes;
        }
        // Find max votes for leading
        var maxVotes = 0;
        for (var c = 0; c < post.candidates.length; c++) {
            if (post.candidates[c].votes > maxVotes) maxVotes = post.candidates[c].votes;
        }
        // Update each candidate
        for (var c = 0; c < post.candidates.length; c++) {
            var cand = post.candidates[c];
            var pct = totalVotes > 0 ? Math.round(cand.votes / totalVotes * 1000) / 10 : 0;
            var barEl = document.getElementById('bar_' + cand.id);
            if (barEl) barEl.style.width = pct + '%';
            var votesEl = document.getElementById('votes_' + cand.id);
            if (votesEl) votesEl.textContent = cand.votes;
            var pctEl = document.getElementById('pct_' + cand.id);
            if (pctEl) pctEl.textContent = pct + '%';
        }
    }
}

function updateRefreshInfo() {
    var info = document.getElementById('refreshInfo');
    if (info) {
        var now = new Date();
        var sec = Math.round((now - _lastRefresh) / 1000);
        info.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg> Auto-refreshing every ' + (_refreshInterval/1000) + 's';
    }
}

// Start on page load
if (window.addEventListener) {
    window.addEventListener('load', startAutoRefresh);
} else {
    window.attachEvent('onload', startAutoRefresh);
}
</script>
</asp:Content>
