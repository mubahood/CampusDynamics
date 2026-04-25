<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DoubleBillingController.aspx.cs"
    Inherits="COOPERP_NewScreens_DoubleBillingController"
    MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    Title="Double Billing Controller — Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box;}
.dbc-wrap{max-width:1380px;margin:0 auto;padding:8px 10px 20px;}

/* ── Stats ── */
.dbc-stats{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:8px;margin-bottom:10px;}
.dbc-stat{padding:10px 12px;border:1px solid #e3e9f2;background:#fff;display:flex;flex-direction:column;gap:3px;}
.dbc-stat__lbl{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;line-height:1.25;}
.dbc-stat__val{font-size:20px;line-height:1;font-weight:800;letter-spacing:-.02em;}
.dbc-stat--students .dbc-stat__val{color:#174DA4;}
.dbc-stat--affected .dbc-stat__val{color:#b45309;}
.dbc-stat--dups     .dbc-stat__val{color:#c62828;}
.dbc-stat--amount   .dbc-stat__val{color:#2e7d32;}
.dbc-stat--index    .dbc-stat__val{font-size:13px;color:#00897b;}

/* ── Card ── */
.dbc-card{background:#fff;border:1px solid #e3e9f2;overflow:visible;margin-bottom:10px;}
.dbc-card__head{padding:8px 12px;border-bottom:1px solid #edf1f6;display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;}
.dbc-card__title{font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.dbc-muted{color:#6b7280;font-size:10px;}

/* ── Filters ── */
.dbc-filters{padding:8px 12px;border-bottom:1px solid #eef2f6;background:#fff;display:flex;gap:6px;align-items:flex-end;flex-wrap:wrap;}
.dbc-fg{display:flex;flex-direction:column;gap:2px;}
.dbc-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;}
.dbc-input,.dbc-select{height:30px;border:1px solid #cdd8e6;padding:4px 8px;font-size:11px;background:#fff;color:#1a1a2e;font-family:inherit;}
.dbc-input:focus,.dbc-select:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12);}

/* ── Buttons ── */
.dbc-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;padding:5px 10px;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;min-height:30px;text-decoration:none;font-family:inherit;white-space:nowrap;}
.dbc-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff;}
.dbc-btn--primary{background:#05275C;color:#fff;border-color:#05275C;}
.dbc-btn--primary:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.dbc-btn--danger{background:#c62828;color:#fff;border-color:#c62828;}
.dbc-btn--danger:hover{background:#d32f2f;}
.dbc-btn--success{background:#2e7d32;color:#fff;border-color:#2e7d32;}
.dbc-btn--success:hover{background:#388e3c;}
.dbc-btn:disabled{opacity:.45;cursor:not-allowed;}

/* ── Progress ── */
.dbc-progress-wrap{display:none;padding:8px 12px;border-bottom:1px solid #f0f2f5;}
.dbc-progress-wrap.active{display:block;}
.dbc-progress-bar{width:100%;height:4px;background:#e8ecf2;}
.dbc-progress-fill{height:100%;background:#174DA4;width:0;transition:width .25s ease;}
.dbc-progress-row{display:flex;justify-content:space-between;margin-top:4px;}
.dbc-progress-label{font-size:10px;color:#555;}
.dbc-progress-pct{font-size:10px;font-weight:800;color:#174DA4;}

/* ── Notice ── */
.dbc-notice{padding:8px 12px;font-size:11px;font-weight:600;display:none;align-items:flex-start;gap:7px;}
.dbc-notice.visible{display:flex;}
.dbc-notice--info{background:#e8f0fc;color:#174DA4;}
.dbc-notice--warn{background:#fff8e1;color:#b45309;}
.dbc-notice--success{background:#e6f4ea;color:#155724;}
.dbc-notice--err{background:#fef2f2;color:#c62828;}

/* ── Log ── */
.dbc-log{display:none;max-height:140px;overflow-y:auto;background:#0f172a;border-top:1px solid #e0e5ed;padding:8px 12px;font-family:Consolas,monospace;font-size:10px;color:#94a3b8;}
.dbc-log.active{display:block;}
.dbc-log-line{padding:1px 0;border-bottom:1px solid #1e293b;}
.dbc-log-line:last-child{border-bottom:none;}
.log-ok{color:#4ade80;}.log-err{color:#f87171;}.log-info{color:#60a5fa;}

/* ── Meta / Pager ── */
.dbc-meta{padding:6px 12px;border-bottom:1px solid #eef2f6;font-size:10px;color:#64748b;display:flex;justify-content:space-between;gap:8px;flex-wrap:wrap;background:#fff;align-items:center;}
.dbc-pager{display:flex;gap:3px;flex-wrap:wrap;}
.dbc-pager a,.dbc-pager span{border:1px solid #d4dbe8;background:#fff;color:#334155;font-size:9px;text-decoration:none;padding:4px 7px;}
.dbc-pager .active{background:#05275C;border-color:#05275C;color:#fff;}

/* ── Table ── */
.dbc-table-wrap{overflow:auto;background:#fff;}
.dbc-table{width:100%;min-width:820px;border-collapse:collapse;font-size:11px;table-layout:auto;}
.dbc-table th{background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;padding:6px 10px;text-align:left;white-space:nowrap;}
.dbc-table td{border-bottom:1px solid #eef2f6;font-size:11px;color:#1f2937;padding:6px 10px;vertical-align:middle;background:#fff;}
.dbc-table tbody tr:hover td{background:#fafcff;}
.dbc-table td.r{text-align:right;}
.dbc-table td.c{text-align:center;}

/* ── Badges / Pills ── */
.dbc-pill{display:inline-block;padding:2px 7px;font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;}
.dbc-pill--detected{background:#fff3cd;color:#92400e;}
.dbc-pill--fixed{background:#e6f4ea;color:#2e7d32;}
.dbc-pill--clean{background:#e8f0fc;color:#174DA4;}
.dbc-pill--error{background:#fef2f2;color:#c62828;}
.dbc-meth-pills{display:flex;gap:3px;flex-wrap:wrap;}
.dbc-meth{display:inline-block;padding:1px 5px;font-size:9px;font-weight:800;background:#ede9fe;color:#5b21b6;border:1px solid #ddd6fe;}
.dbc-code{font-family:Consolas,monospace;font-size:10px;color:#174DA4;font-weight:700;white-space:nowrap;}

/* ── Row action buttons ── */
.dbc-row-btn{padding:3px 8px;font-size:10px;font-weight:700;border:1px solid;cursor:pointer;display:inline-flex;align-items:center;gap:3px;background:#fff;font-family:inherit;}
.dbc-row-btn--details{color:#174DA4;border-color:#bbdefb;background:#e8f0fc;}
.dbc-row-btn--details:hover{background:#d0e4fb;}
.dbc-row-btn--fix{color:#2e7d32;border-color:#c3e6cb;background:#e6f4ea;}
.dbc-row-btn--fix:hover{background:#c8e6c9;}
.dbc-row-btn:disabled{opacity:.4;cursor:not-allowed;}

/* ── Empty state ── */
.dbc-empty{text-align:center;padding:32px 16px;color:#aaa;}
.dbc-empty__icon{font-size:2rem;margin-bottom:8px;}
.dbc-empty__text{font-size:11px;}

/* ── Modal ── */
.dbc-overlay{display:none;position:fixed;inset:0;background:rgba(5,15,35,.5);z-index:9000;align-items:center;justify-content:center;padding:16px;}
.dbc-overlay.show{display:flex;}
.dbc-modal{background:#fff;max-width:960px;width:100%;max-height:92vh;display:flex;flex-direction:column;box-shadow:0 20px 60px rgba(5,15,35,.2);}
.dbc-modal__head{background:#05275C;padding:11px 16px;display:flex;align-items:center;justify-content:space-between;flex-shrink:0;}
.dbc-modal__head h3{margin:0;font-size:13px;font-weight:700;color:#fff;}
.dbc-modal__close{background:rgba(255,255,255,.15);border:none;cursor:pointer;color:#fff;width:26px;height:26px;font-size:16px;display:flex;align-items:center;justify-content:center;}
.dbc-modal__close:hover{background:rgba(255,255,255,.3);}
.dbc-modal__body{flex:1;overflow-y:auto;padding:14px;}
.dbc-modal__foot{display:flex;justify-content:flex-end;gap:7px;padding:10px 14px;border-top:1px solid #e0e5ed;background:#f8f9fb;flex-shrink:0;}
.dbc-modal-kv{display:grid;grid-template-columns:repeat(3,1fr);gap:8px 14px;margin-bottom:12px;}
.dbc-modal-kv dt{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;margin:0;}
.dbc-modal-kv dd{font-size:12px;font-weight:700;color:#1f2937;margin:0 0 2px;}

/* ── Toast ── */
.dbc-toast{position:fixed;bottom:22px;right:22px;background:#1f2937;color:#fff;font-size:11px;font-weight:700;padding:10px 18px;z-index:9999;display:none;}
.dbc-toast.show{display:block;}
.dbc-toast--ok{background:#15803d;}
.dbc-toast--err{background:#b91c1c;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="dbc-wrap">

<div id="dbcToast" class="dbc-toast"></div>
<div id="dbcOverlay" class="dbc-overlay" onclick="if(event.target===this)closeDetails()">
    <div class="dbc-modal">
        <div class="dbc-modal__head">
            <h3 id="modalTitle">Duplicate Transactions</h3>
            <button class="dbc-modal__close" onclick="closeDetails()">&#x2715;</button>
        </div>
        <div class="dbc-modal__body">
            <dl class="dbc-modal-kv" id="modalKV"></dl>
            <div id="modalNotice"></div>
            <div style="overflow-x:auto;margin-top:8px;">
                <table class="dbc-table" id="modalTable">
                    <thead><tr>
                        <th>TID</th><th>Type</th><th class="r">Amount</th><th>Particulars</th>
                        <th>Folio</th><th>Tracking Ref</th><th>Teller</th><th>Date</th>
                    </tr></thead>
                    <tbody id="modalBody"></tbody>
                </table>
            </div>
        </div>
        <div class="dbc-modal__foot">
            <button class="dbc-btn" onclick="closeDetails()">Close</button>
            <button class="dbc-btn dbc-btn--danger" id="btnModalFix" onclick="fixFromModal()" style="display:none">Fix This Account</button>
        </div>
    </div>
</div>

<%-- ── Page Header ─────────────────────────────────────────────────── --%>
<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;flex-wrap:wrap;gap:8px;">
    <div>
        <div style="font-size:15px;font-weight:800;color:#05275C;letter-spacing:-.01em;">Double Billing Controller</div>
        <div class="dbc-muted">Detect and fix duplicate fee entries in student ledgers</div>
    </div>
    <div style="display:flex;gap:6px;flex-wrap:wrap;">
        <button class="dbc-btn" onclick="refreshSummary()" id="btnRefresh">&#8635; Refresh Stats</button>
        <button class="dbc-btn dbc-btn--primary" onclick="runFullScan()" id="btnScan">&#128269; Scan Students</button>
        <button class="dbc-btn dbc-btn--danger" onclick="fixAllAffected()" id="btnFixAll" style="display:none">&#x2714; Fix All Affected</button>
    </div>
</div>

<%-- ── Stat Cards (populated via AJAX) ───────────────────────────── --%>
<div class="dbc-stats">
    <div class="dbc-stat dbc-stat--students"><div class="dbc-stat__lbl">Student Accts</div><div class="dbc-stat__val" id="statStudents">—</div></div>
    <div class="dbc-stat dbc-stat--affected"><div class="dbc-stat__lbl">Affected</div><div class="dbc-stat__val" id="statAffected">—</div></div>
    <div class="dbc-stat dbc-stat--dups"><div class="dbc-stat__lbl">Duplicate Entries</div><div class="dbc-stat__val" id="statDups">—</div></div>
    <div class="dbc-stat dbc-stat--amount"><div class="dbc-stat__lbl">Overbilled (DR)</div><div class="dbc-stat__val" id="statAmt">—</div></div>
    <div class="dbc-stat dbc-stat--index"><div class="dbc-stat__lbl">UNIQUE Index</div><div class="dbc-stat__val" id="statIndex">Checking…</div></div>
</div>

<%-- ── Scan Progress Card (hidden until scan starts) ────────────── --%>
<div class="dbc-card" id="scanCard" style="display:none;">
    <div class="dbc-card__head">
        <span class="dbc-card__title">Scan Progress</span>
        <span class="dbc-muted" id="scanStatus">Starting…</span>
    </div>
    <div class="dbc-progress-wrap active">
        <div class="dbc-progress-bar"><div class="dbc-progress-fill" id="progressFill"></div></div>
        <div class="dbc-progress-row">
            <span class="dbc-progress-label" id="progressLabel">Initialising…</span>
            <span class="dbc-progress-pct" id="progressPct">0%</span>
        </div>
    </div>
    <div class="dbc-notice" id="noticeBar"></div>
    <div class="dbc-log" id="logConsole"></div>
</div>

<%-- ── Cases Table Card (server-rendered) ───────────────────────── --%>
<div class="dbc-card">
    <div class="dbc-card__head">
        <span class="dbc-card__title">Detected Cases</span>
        <button class="dbc-btn dbc-btn--primary" onclick="runFullScan()">&#128269; Run New Scan</button>
    </div>

    <%-- GET-based filter bar --%>
    <form method="get" action="DoubleBillingController.aspx" class="dbc-filters">
        <div class="dbc-fg">
            <label>Search (Reg No)</label>
            <input type="text" name="q" class="dbc-input" style="width:160px;"
                   value="<%= Server.HtmlEncode(Request.QueryString["q"] ?? "") %>" placeholder="Reg no…" />
        </div>
        <div class="dbc-fg">
            <label>Status</label>
            <select name="status" class="dbc-select">
                <option value="">All Statuses</option>
                <option value="Detected"<%= Request.QueryString["status"]=="Detected"?" selected":"" %>>Detected</option>
                <option value="Fixed"<%= Request.QueryString["status"]=="Fixed"?" selected":"" %>>Fixed</option>
                <option value="Clean"<%= Request.QueryString["status"]=="Clean"?" selected":"" %>>Clean</option>
            </select>
        </div>
        <div class="dbc-fg">
            <label>Per Page</label>
            <select name="ps" class="dbc-select">
                <option value="50"<%= (Request.QueryString["ps"]??"50")=="50"?" selected":"" %>>50</option>
                <option value="100"<%= (Request.QueryString["ps"]??"50")=="100"?" selected":"" %>>100</option>
                <option value="200"<%= (Request.QueryString["ps"]??"50")=="200"?" selected":"" %>>200</option>
            </select>
        </div>
        <div class="dbc-fg" style="justify-content:flex-end;"><label>&nbsp;</label>
            <button type="submit" class="dbc-btn dbc-btn--primary">Apply</button>
        </div>
        <div class="dbc-fg" style="justify-content:flex-end;"><label>&nbsp;</label>
            <a href="DoubleBillingController.aspx" class="dbc-btn">Reset</a>
        </div>
    </form>

    <%-- Meta row --%>
    <div class="dbc-meta">
        <span><asp:Literal ID="litMeta" runat="server" /></span>
        <div class="dbc-pager"><asp:Literal ID="litPager" runat="server" /></div>
    </div>

    <%-- Table body server-rendered --%>
    <div class="dbc-table-wrap">
        <table class="dbc-table">
            <thead>
                <tr>
                    <th>Reg No</th>
                    <th class="r">Dups</th>
                    <th class="r">DR Overbilled</th>
                    <th>Methods Fired</th>
                    <th class="c">Status</th>
                    <th>Last Scanned</th>
                    <th class="c">Actions</th>
                </tr>
            </thead>
            <tbody><asp:Literal ID="litRows" runat="server" /></tbody>
        </table>
    </div>

    <%-- Bottom pager --%>
    <div class="dbc-meta" style="border-top:1px solid #eef2f6;border-bottom:none;">
        <span><asp:Literal ID="litTotal2" runat="server" /></span>
        <div class="dbc-pager"><asp:Literal ID="litPager2" runat="server" /></div>
    </div>
</div>

</div><%-- /.dbc-wrap --%>

<script>
(function(){
'use strict';
var BASE = window.location.pathname;
var BATCH = 50;
var _busy = false;
var _scanTotal = 0, _scanOffset = 0, _scanFound = 0;
var _fixQueue = [], _fixIndex = 0, _fixTotal = 0;
var _liveRows = [];
var _modalRegno = null;

function qs(id){ return document.getElementById(id); }
function fmt(n){ return n==null?'0':Number(n).toLocaleString('en-UG'); }
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

function xhr(url,cb){
    var r=new XMLHttpRequest(); r.open('GET',url,true); r.timeout=90000;
    r.onload=function(){ try{cb(null,JSON.parse(r.responseText));}catch(e){cb('Parse error');} };
    r.onerror=function(){cb('Network error');}; r.ontimeout=function(){cb('Timed out');};
    r.send();
}

function showToast(msg,type){
    var t=qs('dbcToast'); if(!t) return;
    t.textContent=msg; t.className='dbc-toast show'+(type?' dbc-toast--'+type:'');
    setTimeout(function(){t.className='dbc-toast';},3500);
}
function log(msg,cls){
    var el=qs('logConsole'); el.classList.add('active');
    var ts=new Date().toLocaleTimeString();
    el.innerHTML+='<div class="dbc-log-line '+(cls||'')+'">['+ts+'] '+msg+'</div>';
    el.scrollTop=el.scrollHeight;
}
function setProgress(pct,label){
    var f=qs('progressFill'),l=qs('progressLabel'),p=qs('progressPct');
    if(f) f.style.width=Math.min(100,Math.max(0,pct))+'%';
    if(l) l.textContent=label||'';
    if(p) p.textContent=Math.round(pct)+'%';
}
function setNotice(html,type,persist){
    var el=qs('noticeBar'); el.className='dbc-notice visible dbc-notice--'+(type||'info'); el.innerHTML=html;
    if(!persist) setTimeout(function(){el.className='dbc-notice';},8000);
}
function setBusy(b){
    _busy=b;
    ['btnScan','btnRefresh'].forEach(function(id){var el=qs(id);if(el)el.disabled=b;});
}

// ── Stats ──────────────────────────────────────────────────────────
function refreshSummary(){
    xhr(BASE+'?ajax=summary',function(err,d){
        if(err||!d||!d.ok) return;
        qs('statStudents').textContent=fmt(d.totalStudents);
        qs('statAffected').textContent=fmt(d.affectedCount)+(d.fixedCount>0?' ('+d.fixedCount+' fixed)':'');
        qs('statDups').textContent=fmt(d.grandTotalDups);
        qs('statAmt').textContent='UGX '+fmt(d.grandTotalAmount);
        var idx=qs('statIndex');
        idx.textContent=d.uniqueIndexActive?'\u2714 Active':'\u2718 Missing!';
        idx.style.color=d.uniqueIndexActive?'#00897b':'#c62828';
    });
}

// ── Full batched scan ───────────────────────────────────────────────
function runFullScan(){
    if(_busy) return;
    qs('scanCard').style.display='';
    qs('logConsole').innerHTML=''; qs('logConsole').classList.remove('active');
    qs('noticeBar').className='dbc-notice'; _liveRows=[];
    setBusy(true); setProgress(1,'Initialising scan…');
    log('Querying student accounts…','log-info');
    xhr(BASE+'?ajax=scan_init',function(err,d){
        if(err||!d||!d.ok){
            setProgress(0,''); setBusy(false);
            setNotice('Scan failed: '+(err||(d&&d.error)||'Unknown'),'err',true);
            log('Init failed: '+(err||(d&&d.error)),'log-err'); return;
        }
        _scanTotal=d.total; _scanOffset=0; _scanFound=0;
        if(_scanTotal===0){ setBusy(false); setNotice('No student accounts found.','warn',true); return; }
        log('Found '+fmt(_scanTotal)+' accounts. Scanning in batches of '+BATCH+'…','log-info');
        qs('scanStatus').textContent='0 / '+fmt(_scanTotal)+' scanned';
        setTimeout(scanNextBatch,10);
    });
}

function scanNextBatch(){
    if(_scanOffset>=_scanTotal){ onScanComplete(); return; }
    xhr(BASE+'?ajax=scan_batch&offset='+_scanOffset+'&size='+BATCH+'&_t='+Date.now(),function(err,d){
        if(err||!d||!d.ok){
            log('Batch error at '+_scanOffset+': '+(err||(d&&d.error)),'log-err');
            _scanOffset+=BATCH;
        } else {
            (d.affected||[]).forEach(function(r){
                _scanFound++; _liveRows.push(r);
                log('[OK] '+r.regno+' — '+r.dupCount+' dups, UGX '+fmt(r.dupAmount),'log-ok');
            });
            _scanOffset+=d.scanned;
            if(d.done||_scanOffset>=_scanTotal){ onScanComplete(); return; }
        }
        var pct=Math.min(98,Math.round((_scanOffset/_scanTotal)*100));
        setProgress(pct,fmt(_scanOffset)+' / '+fmt(_scanTotal)+' scanned — '+_scanFound+' affected');
        qs('scanStatus').textContent=fmt(_scanOffset)+' / '+fmt(_scanTotal)+' scanned';
        setTimeout(scanNextBatch,0);
    });
}

function onScanComplete(){
    setProgress(100,'Scan complete — '+_scanFound+' affected.');
    qs('scanStatus').textContent='Complete'; setBusy(false);
    setTimeout(function(){setProgress(0,'');},4000);
    if(_scanFound>0){
        setNotice('<strong>'+fmt(_scanFound)+'</strong> account(s) detected. Reload page to see updated table, or use Fix All.','warn',true);
        qs('btnFixAll').style.display='';
    } else {
        setNotice('\u2714 No duplicate billing found across '+fmt(_scanTotal)+' accounts.','success',true);
    }
    log('Scan done. Checked: '+fmt(_scanTotal)+' | Affected: '+_scanFound,'log-ok');
    refreshSummary();
}

// ── Fix one (called from server-rendered row buttons) ────────────
window.fixOne=function(regno){
    if(!confirm('Fix duplicate billing for '+regno+'?\n\nDuplicate entries will be deleted. Cannot be undone.')) return;
    log('Fixing '+regno+'…','log-info'); qs('scanCard').style.display='';
    xhr(BASE+'?ajax=fix_one&regno='+encodeURIComponent(regno)+'&_t='+Date.now(),function(err,d){
        if(err||!d||!d.ok){
            showToast('Error fixing '+regno+': '+(err||(d&&d.error)||'Unknown'),'err');
            log('Error: '+regno+' — '+(err||(d&&d.error)),'log-err'); return;
        }
        showToast('Fixed '+regno+' — '+d.deleted+' entries removed.','ok');
        log('Fixed '+regno+' — deleted='+d.deleted+' bal '+d.balBefore+' → '+d.balAfter,'log-ok');
        refreshSummary();
        setTimeout(function(){location.reload();},1200);
    });
};

// ── Fix All (from latest live scan) ────────────────────────────────
function fixAllAffected(){
    if(_liveRows.length===0){ showToast('Run a scan first to find affected accounts.','err'); return; }
    var toFix=_liveRows.filter(function(r){return r.status!=='Fixed';});
    if(toFix.length===0){ showToast('All scan results already fixed.','ok'); return; }
    if(!confirm('Fix ALL '+toFix.length+' affected account(s)?\n\nAll duplicate entries will be deleted.')) return;
    _fixQueue=toFix.slice(); _fixIndex=0; _fixTotal=_fixQueue.length;
    setBusy(true); setProgress(0,'0 / '+_fixTotal+' fixed');
    log('Batch fix — '+_fixTotal+' account(s)…','log-info');
    qs('btnFixAll').style.display='none';
    fixNextInQueue();
}
function fixNextInQueue(){
    if(_fixIndex>=_fixQueue.length){
        setProgress(100,'All done!'); setBusy(false);
        setTimeout(function(){setProgress(0,'');},4000);
        log('Batch fix complete. '+_fixTotal+' processed.','log-ok');
        setNotice('\u2714 Batch fix done — '+_fixTotal+' account(s) processed. Reloading…','success',true);
        refreshSummary(); setTimeout(function(){location.reload();},2000); return;
    }
    var r=_fixQueue[_fixIndex];
    setProgress(Math.round((_fixIndex/_fixTotal)*100),(_fixIndex+1)+'/'+_fixTotal+' — '+r.regno);
    log('['+(_fixIndex+1)+'/'+_fixTotal+'] Fixing '+r.regno+'…','log-info');
    xhr(BASE+'?ajax=fix_one&regno='+encodeURIComponent(r.regno)+'&_t='+Date.now(),function(err,d){
        if(err||!d||!d.ok) log('Error: '+r.regno+' — '+(err||(d&&d.error)),'log-err');
        else { r.status='Fixed'; log('OK: '+r.regno+' del='+d.deleted+' bal '+d.balBefore+'→'+d.balAfter,'log-ok'); }
        _fixIndex++; setTimeout(fixNextInQueue,120);
    });
}

// ── Details Modal ──────────────────────────────────────────────────
window.showDetails=function(regno,name){
    _modalRegno=regno;
    qs('modalTitle').textContent='Duplicates: '+regno+(name?' — '+name:'');
    qs('modalKV').innerHTML='<dt style="color:#6b7280;">Loading…</dt>';
    qs('modalNotice').innerHTML=''; qs('modalBody').innerHTML='';
    qs('btnModalFix').style.display='none';
    qs('dbcOverlay').classList.add('show');
    xhr(BASE+'?ajax=details&regno='+encodeURIComponent(regno)+'&_t='+Date.now(),function(err,d){
        if(err||!d||!d.ok){ qs('modalKV').innerHTML='<dt style="color:#c62828;">Error: '+esc(err||(d&&d.error))+'</dt>'; return; }
        qs('modalKV').innerHTML=
            '<dt>Reg No</dt><dd><span class="dbc-code">'+esc(d.regno)+'</span></dd>'+
            '<dt>Duplicates</dt><dd style="color:#c62828;font-size:14px;">'+d.dupCount+'</dd>'+
            '<dt>Overbilled DR</dt><dd style="color:#c62828;">UGX '+fmt(d.dupDrAmount)+'</dd>'+
            '<dt>Balance</dt><dd>'+esc(d.balance)+'</dd>';
        if(!d.transactions||d.transactions.length===0){
            qs('modalNotice').innerHTML='<div class="dbc-notice visible dbc-notice--success">\u2714 No duplicates found now.</div>'; return;
        }
        var rows='';
        d.transactions.forEach(function(t){
            var tc=t.type==='DR'?'#c62828':'#2e7d32';
            rows+='<tr>'+
                '<td><span class="dbc-code">'+t.tid+'</span></td>'+
                '<td><strong style="color:'+tc+'">'+esc(t.type)+'</strong></td>'+
                '<td class="r">UGX '+fmt(t.amount)+'</td>'+
                '<td style="max-width:200px;word-break:break-word;font-size:10px;">'+esc(t.particulars)+'</td>'+
                '<td><span class="dbc-code">'+esc(t.folio)+'</span></td>'+
                '<td class="c">'+(t.trackingRef||'—')+'</td>'+
                '<td>'+esc(t.teller)+'</td>'+
                '<td style="white-space:nowrap;">'+esc(t.date)+'</td></tr>';
        });
        qs('modalBody').innerHTML=rows;
        qs('btnModalFix').style.display='';
    });
};
window.closeDetails=function(){ qs('dbcOverlay').classList.remove('show'); _modalRegno=null; };
window.fixFromModal=function(){ if(!_modalRegno) return; var r=_modalRegno; closeDetails(); window.fixOne(r); };

// Init
refreshSummary();
window.runFullScan    = runFullScan;
window.fixAllAffected = fixAllAffected;
window.refreshSummary = refreshSummary;
}());
</script>
</asp:Content>