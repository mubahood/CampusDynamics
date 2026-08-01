<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="GeneralDashboard.aspx.cs" Inherits="COOPERP_NewScreens_GeneralDashboard" Title="General Dashboard - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
<style type="text/css">
    .gd-wrap { padding: 12px; color: #1a1a2e; }
    .gd-head { display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap; margin-bottom:10px; }
    .gd-head__t { font-size:16px; font-weight:700; color:#05275C; margin:0; }
    .gd-head__s { font-size:10px; color:#6b7280; margin-top:2px; }
    .gd-head__meta { font-size:10px; color:#6b7280; text-align:right; }
    .gd-refresh { border:1px solid #05275C; background:#05275C; color:#fff; font-size:11px; padding:6px 12px; cursor:pointer; border-radius:0; }
    .gd-refresh:hover { background:#0a3a7d; }

    /* Filter bar */
    .gd-filter { background:#fff; border:1px solid #e0e5ed; padding:10px; margin-bottom:12px; }
    .gd-filter__row { display:flex; flex-wrap:wrap; gap:8px; align-items:flex-end; }
    .gd-fld { display:flex; flex-direction:column; gap:2px; }
    .gd-fld label { font-size:9px; text-transform:uppercase; letter-spacing:.3px; color:#6b7280; font-weight:600; }
    .gd-fld select, .gd-fld input { font-size:11px; padding:5px 6px; border:1px solid #d0d7e2; border-radius:0; background:#fff; min-width:110px; font-family:inherit; }
    .gd-fld input[type=date] { min-width:130px; }
    .gd-presets { display:flex; gap:4px; }
    .gd-presets button { font-size:9px; padding:4px 7px; border:1px solid #d0d7e2; background:#f5f7fa; cursor:pointer; border-radius:0; color:#374151; }
    .gd-presets button:hover, .gd-presets button.on { background:#05275C; color:#fff; border-color:#05275C; }
    .gd-fbtns { display:flex; gap:6px; margin-left:auto; }
    .gd-apply { border:1px solid #05275C; background:#05275C; color:#fff; font-size:11px; padding:6px 16px; cursor:pointer; border-radius:0; font-weight:600; }
    .gd-apply:hover { background:#0a3a7d; }
    .gd-reset { border:1px solid #d0d7e2; background:#fff; color:#374151; font-size:11px; padding:6px 12px; cursor:pointer; border-radius:0; }
    .gd-chips { display:flex; flex-wrap:wrap; gap:5px; margin-top:8px; }
    .gd-chip { background:#eef3fb; border:1px solid #cfe0f7; color:#174DA4; font-size:9px; padding:2px 7px; border-radius:10px; display:inline-flex; align-items:center; gap:4px; }
    .gd-chip b { font-weight:700; }

    /* Sections */
    .gd-sec { background:#fff; border:1px solid #e0e5ed; margin-bottom:12px; }
    .gd-sec__hd { padding:8px 12px; border-bottom:1px solid #e0e5ed; background:#fafbfd; display:flex; align-items:center; gap:8px; }
    .gd-sec__hd h3 { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.4px; color:#05275C; margin:0; }
    .gd-sec__hd .gd-badge { font-size:9px; color:#6b7280; font-weight:500; text-transform:none; letter-spacing:0; }
    .gd-sec__bd { padding:12px; }

    /* KPI cards */
    .gd-kpis { display:grid; gap:8px; }
    .gd-kpis.c4 { grid-template-columns:repeat(4,1fr); }
    .gd-kpis.c5 { grid-template-columns:repeat(5,1fr); }
    .gd-kpi { background:#fff; border:1px solid #e6ebf2; padding:10px; border-left:3px solid #174DA4; }
    .gd-kpi--nav { border-left-color:#05275C; }
    .gd-kpi--green { border-left-color:#28A745; }
    .gd-kpi--amber { border-left-color:#FF9800; }
    .gd-kpi--red { border-left-color:#DC3545; }
    .gd-kpi--teal { border-left-color:#17A2B8; }
    .gd-kpi__v { font-size:19px; font-weight:700; color:#1a1a2e; line-height:1.05; }
    .gd-kpi__l { font-size:9px; text-transform:uppercase; letter-spacing:.3px; color:#6b7280; margin-top:3px; }
    .gd-kpi__s { font-size:9px; color:#9098a5; margin-top:2px; }

    /* Chart grids */
    .gd-grid { display:grid; gap:12px; margin-top:12px; }
    .gd-grid.g2 { grid-template-columns:2fr 1fr; }
    .gd-grid.g2e { grid-template-columns:1fr 1fr; }
    .gd-grid.g3 { grid-template-columns:1fr 1fr 1fr; }
    .gd-card { border:1px solid #eceff4; }
    .gd-card__hd { font-size:10px; font-weight:600; color:#374151; padding:7px 10px; border-bottom:1px solid #eceff4; background:#fbfcfe; }
    .gd-card__hd small { color:#9098a5; font-weight:400; }
    .gd-card__bd { padding:10px; }
    .gd-chartbox { position:relative; height:220px; }
    .gd-chartbox.sm { height:180px; }

    /* Tables */
    .gd-tbl { width:100%; border-collapse:collapse; font-size:10px; }
    .gd-tbl th { text-align:left; padding:5px 8px; background:#f5f7fa; color:#556; font-weight:600; border-bottom:1px solid #e0e5ed; }
    .gd-tbl td { padding:5px 8px; border-bottom:1px solid #f0f2f6; }
    .gd-tbl td:last-child { text-align:right; font-weight:600; color:#174DA4; }

    /* Conversion funnel */
    .gd-funnel { display:flex; gap:6px; flex-wrap:wrap; }
    .gd-fstep { flex:1 1 0; min-width:120px; background:#f7f9fc; border:1px solid #e6ebf2; padding:10px; position:relative; }
    .gd-fstep__n { font-size:20px; font-weight:700; color:#05275C; line-height:1; }
    .gd-fstep__l { font-size:9px; text-transform:uppercase; letter-spacing:.3px; color:#6b7280; margin-top:4px; }
    .gd-fstep__p { font-size:9px; color:#28A745; margin-top:3px; font-weight:600; }
    .gd-fstep__drop { font-size:9px; color:#DC3545; margin-top:1px; }
    .gd-fbar { height:5px; background:#e6ebf2; margin-top:6px; }
    .gd-fbar > span { display:block; height:100%; background:#174DA4; }

    .gd-err { display:none; background:#fde8e8; border:1px solid #f5b5b5; color:#b42318; font-size:11px; padding:8px 12px; margin-bottom:10px; }
    .gd-err.show { display:block; }
    .gd-note { font-size:9px; color:#9098a5; margin-top:6px; font-style:italic; }

    /* Loader (reused pattern) */
    .md-loader { position:fixed; inset:0; background:rgba(245,247,250,.8); z-index:9998; display:none; align-items:center; justify-content:center; }
    .md-loader.show { display:flex; }
    .md-loader__box { text-align:center; }
    .md-spinner { width:44px; height:44px; border:4px solid #e6ebf2; border-top-color:#05275C; border-radius:50%; animation:gdspin .75s linear infinite; margin:0 auto; }
    .md-loader__txt { font-size:12px; color:#05275C; font-weight:600; margin-top:12px; }
    .md-loader__sub { font-size:10px; color:#6b7280; margin-top:2px; }
    @keyframes gdspin { to { transform:rotate(360deg); } }

    @media (max-width:1100px){ .gd-kpis.c4,.gd-kpis.c5{grid-template-columns:repeat(2,1fr);} .gd-grid.g2,.gd-grid.g2e,.gd-grid.g3{grid-template-columns:1fr;} }
</style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="gd-wrap">

    <div class="gd-head">
        <div>
            <h2 class="gd-head__t">General Dashboard</h2>
            <div class="gd-head__s">Muteesa I Royal University &middot; institution-wide overview</div>
        </div>
        <div>
            <div class="gd-head__meta" id="gdMeta">&nbsp;</div>
            <div style="text-align:right;margin-top:4px;"><button class="gd-refresh" id="gdRefresh" type="button">Refresh</button></div>
        </div>
    </div>

    <div class="gd-err" id="gdError"></div>

    <!-- FILTER BAR -->
    <div class="gd-filter" id="gdFilter">
        <div class="gd-filter__row">
            <div class="gd-fld"><label>From</label><input type="date" id="fDateFrom" /></div>
            <div class="gd-fld"><label>To</label><input type="date" id="fDateTo" /></div>
            <div class="gd-fld"><label>&nbsp;</label>
                <div class="gd-presets">
                    <button type="button" data-preset="30">30d</button>
                    <button type="button" data-preset="90">90d</button>
                    <button type="button" data-preset="365">12m</button>
                    <button type="button" data-preset="ytd">YTD</button>
                </div>
            </div>
            <div class="gd-fld"><label>Academic Year</label><select id="fYear"></select></div>
            <div class="gd-fld"><label>Semester</label><select id="fSem"><option value="">All</option><option value="1">Sem 1</option><option value="2">Sem 2</option><option value="3">Sem 3</option></select></div>
            <div class="gd-fld"><label>Faculty</label><select id="fFaculty"></select></div>
            <div class="gd-fld"><label>Programme</label><select id="fProg"></select></div>
        </div>
        <div class="gd-filter__row" style="margin-top:8px;">
            <div class="gd-fld"><label>Intake</label><select id="fIntake"></select></div>
            <div class="gd-fld"><label>Session</label><select id="fSession"></select></div>
            <div class="gd-fld"><label>Gender</label><select id="fGender"></select></div>
            <div class="gd-fld"><label>Status</label><select id="fStatus"></select></div>
            <div class="gd-fld"><label>Campus</label><select id="fCampus"></select></div>
            <div class="gd-fbtns">
                <button class="gd-reset" id="gdReset" type="button">Reset</button>
                <button class="gd-apply" id="gdApply" type="button">Apply Filters</button>
            </div>
        </div>
        <div class="gd-chips" id="gdChips"></div>
    </div>

    <!-- CONVERSION FUNNEL -->
    <div class="gd-sec">
        <div class="gd-sec__hd"><h3>Student Journey Funnel</h3><span class="gd-badge">Applied &rarr; Admitted &rarr; Active account &rarr; Registered &rarr; Cleared</span></div>
        <div class="gd-sec__bd">
            <div class="gd-funnel" id="gdFunnel"></div>
            <div class="gd-note">Applied/Admitted are lifetime onboarding totals; Registered/Cleared reflect the selected (or current) academic year. Percentages are relative to Applied.</div>
        </div>
    </div>

    <!-- SECTION A: STUDENT BODY -->
    <div class="gd-sec">
        <div class="gd-sec__hd"><h3>Student Body</h3><span class="gd-badge">Snapshot &middot; respects student filters</span></div>
        <div class="gd-sec__bd">
            <div class="gd-kpis c5">
                <div class="gd-kpi gd-kpi--nav"><div class="gd-kpi__v" id="kStudTotal">&ndash;</div><div class="gd-kpi__l">Total Students</div><div class="gd-kpi__s" id="kStudSub">&nbsp;</div></div>
                <div class="gd-kpi gd-kpi--green"><div class="gd-kpi__v" id="kStudActive">&ndash;</div><div class="gd-kpi__l">Active</div><div class="gd-kpi__s">Current students</div></div>
                <div class="gd-kpi gd-kpi--amber"><div class="gd-kpi__v" id="kStudAdmitted">&ndash;</div><div class="gd-kpi__l">Admitted</div><div class="gd-kpi__s">Not yet active</div></div>
                <div class="gd-kpi gd-kpi--teal"><div class="gd-kpi__v" id="kStudAlumni">&ndash;</div><div class="gd-kpi__l">Alumni</div><div class="gd-kpi__s">Completed</div></div>
                <div class="gd-kpi"><div class="gd-kpi__v" id="kStudGender">&ndash;</div><div class="gd-kpi__l">Gender (M / F)</div><div class="gd-kpi__s" id="kStudScope">&nbsp;</div></div>
            </div>
            <div class="gd-grid g2">
                <div class="gd-card"><div class="gd-card__hd">Students by Faculty</div><div class="gd-card__bd"><div class="gd-chartbox"><canvas id="chFaculty"></canvas></div></div></div>
                <div class="gd-card"><div class="gd-card__hd">Gender</div><div class="gd-card__bd"><div class="gd-chartbox"><canvas id="chGender"></canvas></div></div></div>
            </div>
            <div class="gd-grid g3">
                <div class="gd-card"><div class="gd-card__hd">Study Session</div><div class="gd-card__bd"><div class="gd-chartbox sm"><canvas id="chSession"></canvas></div></div></div>
                <div class="gd-card"><div class="gd-card__hd">Enrolment by Entry Year</div><div class="gd-card__bd"><div class="gd-chartbox sm"><canvas id="chEntryYear"></canvas></div></div></div>
                <div class="gd-card"><div class="gd-card__hd">Top Programmes <small>by headcount</small></div><div class="gd-card__bd" style="max-height:200px;overflow:auto;"><table class="gd-tbl" id="tblTopProg"><tbody></tbody></table></div></div>
            </div>
        </div>
    </div>

    <!-- SECTION C: REGISTRATIONS -->
    <div class="gd-sec">
        <div class="gd-sec__hd"><h3>Semester Registrations</h3><span class="gd-badge" id="gdRegScope">&nbsp;</span></div>
        <div class="gd-sec__bd">
            <div class="gd-kpis c4">
                <div class="gd-kpi gd-kpi--green"><div class="gd-kpi__v" id="kRegReg">&ndash;</div><div class="gd-kpi__l">Registered</div><div class="gd-kpi__s">Incl. late</div></div>
                <div class="gd-kpi gd-kpi--red"><div class="gd-kpi__v" id="kRegUnreg">&ndash;</div><div class="gd-kpi__l">Unregistered</div><div class="gd-kpi__s">Revenue at risk</div></div>
                <div class="gd-kpi gd-kpi--teal"><div class="gd-kpi__v" id="kRegCleared">&ndash;</div><div class="gd-kpi__l">Cleared</div><div class="gd-kpi__s">Fully cleared</div></div>
                <div class="gd-kpi gd-kpi--nav"><div class="gd-kpi__v" id="kRegRate">&ndash;</div><div class="gd-kpi__l">Registration Rate</div><div class="gd-kpi__s" id="kRegTotal">&nbsp;</div></div>
            </div>
            <div class="gd-grid g2">
                <div class="gd-card"><div class="gd-card__hd">Registrations by Year &amp; Semester <small>(all years)</small></div><div class="gd-card__bd"><div class="gd-chartbox"><canvas id="chYearSem"></canvas></div></div></div>
                <div class="gd-card"><div class="gd-card__hd">Status Breakdown</div><div class="gd-card__bd"><div class="gd-chartbox"><canvas id="chRegStatus"></canvas></div></div></div>
            </div>
            <div class="gd-grid">
                <div class="gd-card"><div class="gd-card__hd">Registered vs Unregistered by Faculty</div><div class="gd-card__bd"><div class="gd-chartbox sm"><canvas id="chRegFaculty"></canvas></div></div></div>
            </div>
        </div>
    </div>

    <!-- SECTION B: ONBOARDING -->
    <div class="gd-sec">
        <div class="gd-sec__hd"><h3>Onboarding &amp; Applications</h3><span class="gd-badge">Online apply cohort (timestamps 2026+)</span></div>
        <div class="gd-sec__bd">
            <div class="gd-kpis c5">
                <div class="gd-kpi gd-kpi--nav"><div class="gd-kpi__v" id="kAppTotal">&ndash;</div><div class="gd-kpi__l">Applications</div><div class="gd-kpi__s">All time</div></div>
                <div class="gd-kpi gd-kpi--green"><div class="gd-kpi__v" id="kAppAdmitted">&ndash;</div><div class="gd-kpi__l">Admitted</div><div class="gd-kpi__s">&nbsp;</div></div>
                <div class="gd-kpi gd-kpi--amber"><div class="gd-kpi__v" id="kAppDraft">&ndash;</div><div class="gd-kpi__l">Draft</div><div class="gd-kpi__s">Incomplete</div></div>
                <div class="gd-kpi gd-kpi--teal"><div class="gd-kpi__v" id="kAppSubmitted">&ndash;</div><div class="gd-kpi__l">Submitted</div><div class="gd-kpi__s">Awaiting decision</div></div>
                <div class="gd-kpi"><div class="gd-kpi__v" id="kAppRate">&ndash;</div><div class="gd-kpi__l">Admission Rate</div><div class="gd-kpi__s">Of all choices</div></div>
            </div>
            <div class="gd-grid g2">
                <div class="gd-card"><div class="gd-card__hd">Online Applications Over Time <small>(2026+)</small></div><div class="gd-card__bd"><div class="gd-chartbox"><canvas id="chAppTime"></canvas></div></div></div>
                <div class="gd-card"><div class="gd-card__hd">Application Status</div><div class="gd-card__bd"><div class="gd-chartbox"><canvas id="chAppStatus"></canvas></div></div></div>
            </div>
            <div class="gd-grid">
                <div class="gd-card"><div class="gd-card__hd">Programme Demand <small>(first choice)</small></div><div class="gd-card__bd"><div class="gd-chartbox sm"><canvas id="chDemand"></canvas></div></div></div>
            </div>
        </div>
    </div>

    <!-- SECTION D: FEES -->
    <div class="gd-sec">
        <div class="gd-sec__hd"><h3>Fees &amp; Collections</h3><span class="gd-badge" id="gdFeeWin">&nbsp;</span></div>
        <div class="gd-sec__bd">
            <div class="gd-kpis c5">
                <div class="gd-kpi gd-kpi--green"><div class="gd-kpi__v" id="kFeeColl">&ndash;</div><div class="gd-kpi__l">Collected</div><div class="gd-kpi__s">In date range</div></div>
                <div class="gd-kpi gd-kpi--nav"><div class="gd-kpi__v" id="kFeePmts">&ndash;</div><div class="gd-kpi__l">Payments</div><div class="gd-kpi__s"># receipts</div></div>
                <div class="gd-kpi gd-kpi--teal"><div class="gd-kpi__v" id="kFeeAvg">&ndash;</div><div class="gd-kpi__l">Avg Payment</div><div class="gd-kpi__s">&nbsp;</div></div>
                <div class="gd-kpi gd-kpi--amber"><div class="gd-kpi__v" id="kFeeBilled">&ndash;</div><div class="gd-kpi__l">Billed</div><div class="gd-kpi__s">Charges raised</div></div>
                <div class="gd-kpi gd-kpi--red"><div class="gd-kpi__v" id="kFeeRate">&ndash;</div><div class="gd-kpi__l">Collection Rate</div><div class="gd-kpi__s">Collected / billed</div></div>
            </div>
            <div class="gd-grid g2">
                <div class="gd-card"><div class="gd-card__hd">Collections vs Billing Trend</div><div class="gd-card__bd"><div class="gd-chartbox"><canvas id="chFeeTrend"></canvas></div></div></div>
                <div class="gd-card"><div class="gd-card__hd">By GL Source</div><div class="gd-card__bd"><div class="gd-chartbox"><canvas id="chFeeSource"></canvas></div></div></div>
            </div>
            <div class="gd-grid g2e">
                <div class="gd-card"><div class="gd-card__hd">SchoolPay Channels <small>(mobile money subset)</small></div><div class="gd-card__bd"><div class="gd-chartbox sm"><canvas id="chFeeChannel"></canvas></div></div></div>
                <div class="gd-card"><div class="gd-card__hd">Top Collecting Faculties</div><div class="gd-card__bd" style="max-height:200px;overflow:auto;"><table class="gd-tbl" id="tblFeeFac"><tbody></tbody></table></div></div>
            </div>
            <div class="gd-note">Collections are counted once from the general ledger (money received), excluding opening balances, journal vouchers and reversals. The SchoolPay panel is a channel view of mobile-money receipts only and does not sum to the ledger total.</div>
        </div>
    </div>

</div>

<div class="md-loader" id="gdLoader">
    <div class="md-loader__box">
        <div class="md-spinner"></div>
        <div class="md-loader__txt">Loading dashboard&hellip;</div>
        <div class="md-loader__sub">Crunching students, registrations, onboarding &amp; payments</div>
    </div>
</div>

<script type="text/javascript">
(function(){
'use strict';
var charts = {};
var opts = null;

function qs(id){ return document.getElementById(id); }
function esc(s){ return s==null?'':String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function nfmt(v){ v=Number(v)||0; return v.toLocaleString('en-US'); }
function money(v){
    v=Number(v)||0;
    if(Math.abs(v)>=1e9) return (v/1e9).toFixed(2)+'B';
    if(Math.abs(v)>=1e6) return (v/1e6).toFixed(1)+'M';
    if(Math.abs(v)>=1e3) return (v/1e3).toFixed(0)+'K';
    return nfmt(v);
}
function moneyFull(v){ return 'UGX ' + nfmt(Math.round(Number(v)||0)); }
function pct(a,b){ b=Number(b)||0; if(!b) return '0%'; return (Math.round((Number(a)||0)*1000/b)/10)+'%'; }
function setTxt(id,v){ var e=qs(id); if(e) e.textContent=v; }
function setLoading(on){ var l=qs('gdLoader'); if(l) l.className='md-loader'+(on?' show':''); }
function showErr(m){ var e=qs('gdError'); if(!e)return; e.textContent=m; e.className='gd-err show'; }
function hideErr(){ var e=qs('gdError'); if(e) e.className='gd-err'; }

function ajax(method,params,cb){
    var xhr=new XMLHttpRequest();
    xhr.open('POST','GeneralDashboard.aspx/'+method,true);
    xhr.setRequestHeader('Content-Type','application/json; charset=utf-8');
    xhr.timeout=60000;
    xhr.onload=function(){ try{ var o=JSON.parse(xhr.responseText); cb(typeof o.d==='string'?JSON.parse(o.d):o.d); }catch(e){ cb({success:false,message:'Server did not return valid data (the page may still be warming up — please retry).'}); } };
    xhr.onerror=function(){ cb({success:false,message:'Network error — could not reach the server.'}); };
    xhr.ontimeout=function(){ cb({success:false,message:'The request took too long. Try a narrower date range or filter, then retry.'}); };
    xhr.send(JSON.stringify(params||{}));
}

var PALETTE=['#174DA4','#28A745','#FF9800','#17A2B8','#8E44AD','#E91E63','#795548','#607D8B','#05275C','#4CAF50'];
function chart(id,cfg){
    var el=qs(id); if(!el) return;
    if(charts[id]){ charts[id].destroy(); }
    charts[id]=new Chart(el.getContext('2d'),cfg);
}
function baseOpts(extra){
    var o={ responsive:true, maintainAspectRatio:false,
        plugins:{ legend:{ labels:{ font:{size:10}, boxWidth:12 } } },
        scales:{ y:{ beginAtZero:true, ticks:{ font:{size:9} }, grid:{color:'#f0f2f6'} }, x:{ ticks:{ font:{size:9} }, grid:{display:false} } } };
    if(extra) for(var k in extra) o[k]=extra[k];
    return o;
}
function noScale(){ return { responsive:true, maintainAspectRatio:false, plugins:{ legend:{ position:'right', labels:{ font:{size:10}, boxWidth:12 } } } }; }

// ---------- filter helpers ----------
function fill(id,items,allLabel,valKey,txtKey){
    var el=qs(id); if(!el)return;
    var h = allLabel!=null ? '<option value="">'+esc(allLabel)+'</option>' : '';
    (items||[]).forEach(function(it){ h+='<option value="'+esc(it[valKey])+'">'+esc(it[txtKey])+'</option>'; });
    el.innerHTML=h;
}
function pad2(n){ n=''+n; return n.length<2?'0'+n:n; }
function fmtDate(d){ return d.getFullYear()+'-'+pad2(d.getMonth()+1)+'-'+pad2(d.getDate()); }
function setPreset(days){
    var to=new Date(), from=new Date();
    if(days==='ytd'){ from=new Date(to.getFullYear(),0,1); }
    else { from.setDate(to.getDate()-Number(days)); }
    qs('fDateFrom').value=fmtDate(from); qs('fDateTo').value=fmtDate(to);
}
function collect(){
    return {
        dateFrom:qs('fDateFrom').value, dateTo:qs('fDateTo').value,
        acadYear:qs('fYear').value, semester:qs('fSem').value,
        faculty:qs('fFaculty').value, programme:qs('fProg').value,
        intake:qs('fIntake').value, session:qs('fSession').value,
        gender:qs('fGender').value, status:qs('fStatus').value, campus:qs('fCampus').value
    };
}
function label(sel){ var e=qs(sel); return e&&e.selectedIndex>=0?e.options[e.selectedIndex].text:''; }
function chips(f){
    var c=[];
    if(f.dateFrom||f.dateTo) c.push(['Dates',(f.dateFrom||'…')+' → '+(f.dateTo||'…')]);
    if(f.acadYear) c.push(['Year',f.acadYear]);
    if(f.semester) c.push(['Semester',label('fSem')]);
    if(f.faculty) c.push(['Faculty',label('fFaculty')]);
    if(f.programme) c.push(['Programme',label('fProg')]);
    if(f.intake) c.push(['Intake',f.intake]);
    if(f.session) c.push(['Session',label('fSession')]);
    if(f.gender) c.push(['Gender',label('fGender')]);
    if(f.status) c.push(['Status',label('fStatus')]);
    if(f.campus) c.push(['Campus',label('fCampus')]);
    var box=qs('gdChips');
    box.innerHTML=c.map(function(x){ return '<span class="gd-chip"><b>'+esc(x[0])+':</b> '+esc(x[1])+'</span>'; }).join('');
}

// ---------- rendering ----------
function names(a){ return (a||[]).map(function(x){ return x.name; }); }
function counts(a){ return (a||[]).map(function(x){ return Number(x.count)||0; }); }

function renderFunnel(fn){
    if(!fn){ qs('gdFunnel').innerHTML=''; return; }
    var steps=[['Applied',fn.applied],['Admitted',fn.admitted],['Active account',fn.active],['Registered',fn.registered],['Cleared',fn.cleared]];
    var base=Number(fn.applied)||0, prev=null, h='';
    steps.forEach(function(s){
        var n=Number(s[1])||0;
        var p = base>0 ? Math.round(n*100/base) : 0;
        var drop = prev!=null && prev>0 ? Math.round((prev-n)*100/prev) : null;
        h+='<div class="gd-fstep"><div class="gd-fstep__n">'+nfmt(n)+'</div><div class="gd-fstep__l">'+esc(s[0])+'</div>'+
           '<div class="gd-fstep__p">'+p+'% of applied</div>'+
           (drop!=null&&drop>0?'<div class="gd-fstep__drop">▼ '+drop+'% drop-off</div>':'<div class="gd-fstep__drop">&nbsp;</div>')+
           '<div class="gd-fbar"><span style="width:'+Math.max(3,p)+'%"></span></div></div>';
        prev=n;
    });
    qs('gdFunnel').innerHTML=h;
}

function renderStudents(s){
    if(!s||s.error){ return; }
    setTxt('kStudTotal',nfmt(s.total));
    setTxt('kStudSub',nfmt(s.faculties)+' faculties · '+nfmt(s.programmes)+' programmes');
    setTxt('kStudActive',nfmt(s.active));
    setTxt('kStudAdmitted',nfmt(s.admitted));
    setTxt('kStudAlumni',nfmt(s.alumni));
    setTxt('kStudGender',nfmt(s.male)+' / '+nfmt(s.female));
    setTxt('kStudScope',pct(s.female,(Number(s.male)+Number(s.female)))+' female');

    chart('chFaculty',{ type:'bar', data:{ labels:names(s.byFaculty), datasets:[{ label:'Students', data:counts(s.byFaculty), backgroundColor:'#174DA4' }] },
        options:baseOpts({ indexAxis:'y', plugins:{legend:{display:false}} }) });
    chart('chGender',{ type:'doughnut', data:{ labels:names(s.byGender), datasets:[{ data:counts(s.byGender), backgroundColor:['#174DA4','#E91E63','#9098a5'] }] }, options:noScale() });
    chart('chSession',{ type:'doughnut', data:{ labels:names(s.bySession), datasets:[{ data:counts(s.bySession), backgroundColor:PALETTE }] }, options:noScale() });
    chart('chEntryYear',{ type:'bar', data:{ labels:names(s.byEntryYear), datasets:[{ label:'Enrolled', data:counts(s.byEntryYear), backgroundColor:'#28A745' }] }, options:baseOpts({plugins:{legend:{display:false}}}) });

    var tb=qs('tblTopProg').getElementsByTagName('tbody')[0];
    tb.innerHTML=(s.topProgrammes||[]).map(function(x){ return '<tr><td>'+esc(x.name)+'</td><td>'+nfmt(x.count)+'</td></tr>'; }).join('') || '<tr><td colspan="2" style="color:#9098a5">No data</td></tr>';
}

function renderReg(r){
    if(!r||r.error){ return; }
    setTxt('kRegReg',nfmt(r.registered));
    setTxt('kRegUnreg',nfmt(r.unregistered));
    setTxt('kRegCleared',nfmt(r.cleared));
    var denom=Number(r.total)||0;
    setTxt('kRegRate',pct((Number(r.registered)+Number(r.cleared)),denom));
    setTxt('kRegTotal',nfmt(denom)+' registration rows');

    var ys=r.byYearSem||[];
    chart('chYearSem',{ type:'bar', data:{ labels:ys.map(function(x){ return x.year+' S'+x.semester; }), datasets:[{ label:'Registrations', data:ys.map(function(x){ return Number(x.count)||0; }), backgroundColor:'#174DA4' }] }, options:baseOpts({plugins:{legend:{display:false}}}) });
    chart('chRegStatus',{ type:'doughnut', data:{ labels:names(r.byStatus), datasets:[{ data:counts(r.byStatus), backgroundColor:PALETTE }] }, options:noScale() });

    var fac=r.byFaculty||[];
    chart('chRegFaculty',{ type:'bar', data:{ labels:fac.map(function(x){return x.name;}), datasets:[
        { label:'Registered', data:fac.map(function(x){return Number(x.registered)||0;}), backgroundColor:'#28A745' },
        { label:'Unregistered', data:fac.map(function(x){return Number(x.unregistered)||0;}), backgroundColor:'#DC3545' }
    ] }, options:baseOpts({ scales:{ x:{stacked:true,grid:{display:false},ticks:{font:{size:9}}}, y:{stacked:true,beginAtZero:true,grid:{color:'#f0f2f6'},ticks:{font:{size:9}}} } }) });
}

function renderOnboard(o){
    if(!o||o.error){ return; }
    setTxt('kAppTotal',nfmt(o.total));
    setTxt('kAppAdmitted',nfmt(o.admitted));
    setTxt('kAppDraft',nfmt(o.draft));
    setTxt('kAppSubmitted',nfmt(o.submitted));
    setTxt('kAppRate',(Math.round((Number(o.admissionRate)||0)*10)/10)+'%');

    var ot=o.overTime||[];
    chart('chAppTime',{ type:'line', data:{ labels:ot.map(function(x){return x.label;}), datasets:[{ label:'Applications', data:ot.map(function(x){return Number(x.count)||0;}), borderColor:'#174DA4', backgroundColor:'rgba(23,77,164,.1)', fill:true, tension:.3, pointRadius:2 }] }, options:baseOpts({plugins:{legend:{display:false}}}) });
    chart('chAppStatus',{ type:'bar', data:{ labels:names(o.byStatus), datasets:[{ label:'Applications', data:counts(o.byStatus), backgroundColor:PALETTE }] }, options:baseOpts({plugins:{legend:{display:false}}}) });

    var dm=o.demand||[];
    chart('chDemand',{ type:'bar', data:{ labels:dm.map(function(x){return x.name;}), datasets:[{ label:'First choice', data:dm.map(function(x){return Number(x.count)||0;}), backgroundColor:'#17A2B8' }] }, options:baseOpts({ indexAxis:'y', plugins:{legend:{display:false}} }) });
}

function renderFees(fe){
    if(!fe||fe.error){ return; }
    setTxt('kFeeColl',money(fe.collected));
    setTxt('kFeePmts',nfmt(fe.numPayments));
    setTxt('kFeeAvg',money(fe.avgPayment));
    setTxt('kFeeBilled',money(fe.billed));
    setTxt('kFeeRate',(Math.round((Number(fe.collectionRate)||0)*10)/10)+'%');
    setTxt('gdFeeWin',(fe.windowStart||'')+' → '+(fe.windowEnd||'')+' · by '+(fe.granularity||'month'));

    var tr=fe.trend||[];
    chart('chFeeTrend',{ type:'line', data:{ labels:tr.map(function(x){return x.label;}), datasets:[
        { label:'Collected', data:tr.map(function(x){return Number(x.collected)||0;}), borderColor:'#28A745', backgroundColor:'rgba(40,167,69,.08)', fill:true, tension:.3, pointRadius:2 },
        { label:'Billed', data:tr.map(function(x){return Number(x.billed)||0;}), borderColor:'#FF9800', backgroundColor:'rgba(255,152,0,.06)', fill:true, tension:.3, pointRadius:2 }
    ] }, options:baseOpts({ plugins:{ legend:{labels:{font:{size:10},boxWidth:12}}, tooltip:{callbacks:{label:function(c){return c.dataset.label+': '+moneyFull(c.parsed.y);}} } }, scales:{ y:{beginAtZero:true,grid:{color:'#f0f2f6'},ticks:{font:{size:9},callback:function(v){return money(v);}}}, x:{grid:{display:false},ticks:{font:{size:9}}} } }) });

    chart('chFeeSource',{ type:'doughnut', data:{ labels:(fe.bySource||[]).map(function(x){return x.name;}), datasets:[{ data:(fe.bySource||[]).map(function(x){return Number(x.amount)||0;}), backgroundColor:PALETTE }] }, options:(function(){var o=noScale(); o.plugins.tooltip={callbacks:{label:function(c){return c.label+': '+moneyFull(c.parsed);}}}; return o;})() });

    var ch=fe.byChannel||[];
    chart('chFeeChannel',{ type:'bar', data:{ labels:ch.map(function(x){return x.name;}), datasets:[{ label:'Amount', data:ch.map(function(x){return Number(x.amount)||0;}), backgroundColor:'#8E44AD' }] }, options:baseOpts({ plugins:{legend:{display:false}, tooltip:{callbacks:{label:function(c){return moneyFull(c.parsed.y);}}}}, scales:{ y:{beginAtZero:true,grid:{color:'#f0f2f6'},ticks:{font:{size:9},callback:function(v){return money(v);}}}, x:{grid:{display:false},ticks:{font:{size:9}}} } }) });

    var tb=qs('tblFeeFac').getElementsByTagName('tbody')[0];
    tb.innerHTML=(fe.topFaculties||[]).map(function(x){ return '<tr><td>'+esc(x.name)+'</td><td>'+money(x.amount)+'</td></tr>'; }).join('') || '<tr><td colspan="2" style="color:#9098a5">No data</td></tr>';
}

function loadDashboard(){
    hideErr(); setLoading(true);
    var f=collect(); chips(f);
    ajax('GetDashboard',{ filtersJson: JSON.stringify(f) }, function(d){
        setLoading(false);
        if(!d||!d.success){ showErr((d&&d.message)||'Unable to load dashboard.'); return; }
        setTxt('gdMeta','Generated '+esc(d.generatedAt||''));
        renderFunnel(d.funnel);
        renderStudents(d.students);
        renderReg(d.registrations);
        renderOnboard(d.onboarding);
        renderFees(d.fees);
    });
}

function init(){
    setLoading(true);
    setPreset(365); // default: last 12 months
    ajax('GetFilterOptions',{},function(o){
        if(!o||!o.success){ setLoading(false); showErr((o&&o.message)||'Unable to load filters.'); return; }
        opts=o;
        fill('fYear',o.years,'All years','value','text');
        fill('fFaculty',o.faculties,'All faculties','value','text');
        fill('fProg',o.programmes,'All programmes','value','text');
        fill('fIntake',o.intakes,'All intakes','value','text');
        fill('fSession',o.sessions,'All sessions','value','text');
        fill('fGender',o.genders,'All','value','text');
        fill('fStatus',o.statuses,'All statuses','value','text');
        fill('fCampus',o.campuses,'All campuses','value','text');
        if(o.currentYear){ qs('fYear').value=o.currentYear; }
        loadDashboard();
    });
}

// wire events
document.addEventListener('DOMContentLoaded',function(){
    qs('gdApply').addEventListener('click',loadDashboard);
    qs('gdRefresh').addEventListener('click',loadDashboard);
    qs('gdReset').addEventListener('click',function(){
        ['fSem','fFaculty','fProg','fIntake','fSession','fGender','fStatus','fCampus'].forEach(function(id){ qs(id).value=''; });
        if(opts&&opts.currentYear) qs('fYear').value=opts.currentYear; else qs('fYear').value='';
        setPreset(365);
        var b=qs('gdFilter').querySelectorAll('.gd-presets button'); for(var i=0;i<b.length;i++) b[i].classList.remove('on');
        loadDashboard();
    });
    var pbtns=qs('gdFilter').querySelectorAll('.gd-presets button');
    for(var i=0;i<pbtns.length;i++){ (function(btn){ btn.addEventListener('click',function(){
        for(var j=0;j<pbtns.length;j++) pbtns[j].classList.remove('on'); btn.classList.add('on');
        setPreset(btn.getAttribute('data-preset')); loadDashboard();
    }); })(pbtns[i]); }
    // cascade programme by faculty (visual filter only; server still validates)
    init();
});
})();
</script>
</asp:Content>
