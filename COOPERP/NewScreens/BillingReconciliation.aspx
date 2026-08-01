<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="BillingReconciliation.aspx.cs" Inherits="COOPERP_NewScreens_BillingReconciliation" Title="Billing Reconciliation - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== BILLING RECONCILIATION WIZARD ================================== */
.cd-page-header { background:#fff; padding:10px 14px; margin-bottom:12px; border:1px solid #e4e8f0; display:flex; align-items:center; gap:11px; }
.cd-page-header__icon { width:34px; height:34px; background:#05275C; display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
.cd-page-header__title { font-size:15px; font-weight:700; color:#1a1a1a; line-height:1.2; margin:0; }
.cd-page-header__sub { font-size:11px; color:#6b7280; margin-top:1px; }

.br-card { background:#fff; border:1px solid #e4e8f0; border-radius:4px; margin-bottom:14px; }
.br-card__body { padding:16px; }

/* Stepper */
.br-steps { display:flex; align-items:center; gap:0; padding:12px 16px; border-bottom:1px solid #eef1f5; background:#fafbfc; flex-wrap:wrap; }
.br-step { display:flex; align-items:center; gap:7px; font-size:11px; font-weight:600; color:#9aa3af; }
.br-step__num { width:22px; height:22px; border-radius:50%; background:#e4e8f0; color:#6b7280; display:flex; align-items:center; justify-content:center; font-size:11px; font-weight:700; }
.br-step.is-active { color:#05275C; }
.br-step.is-active .br-step__num { background:#174DA4; color:#fff; }
.br-step.is-done .br-step__num { background:#16a34a; color:#fff; }
.br-step__sep { flex:1; height:1px; background:#e4e8f0; margin:0 10px; min-width:18px; }

.br-phase { display:none; }
.br-phase.is-on { display:block; }

/* Form bits */
.br-fld { display:flex; flex-direction:column; gap:3px; }
.br-fld__lbl { font-size:9px; text-transform:uppercase; letter-spacing:.5px; color:#9aa3af; font-weight:700; }
.br-sel { border:1px solid #dde1e6; padding:7px 10px; font-size:12px; background:#fff; color:#333; min-width:160px; }
.br-sel:focus { border-color:#174DA4; box-shadow:0 0 0 3px rgba(23,77,164,.08); outline:none; }
.br-row { display:flex; gap:14px; flex-wrap:wrap; align-items:flex-end; }

.br-scope { display:flex; flex-direction:column; gap:8px; margin:14px 0; }
.br-scope__opt { display:flex; gap:10px; align-items:flex-start; border:1px solid #e4e8f0; padding:11px 13px; cursor:pointer; border-radius:4px; transition:border-color .15s, background .15s; }
.br-scope__opt:hover { border-color:#cdd8e6; background:#fafbff; }
.br-scope__opt.is-sel { border-color:#174DA4; background:#f3f7ff; box-shadow:0 0 0 1px #174DA4 inset; }
.br-scope__opt input { margin-top:2px; }
.br-scope__t { font-size:12px; font-weight:700; color:#1a1a2e; }
.br-scope__d { font-size:11px; color:#6b7280; margin-top:2px; line-height:1.45; }

/* Buttons */
.hr-btn { padding:8px 16px; font-size:12px; font-weight:600; border:none; cursor:pointer; border-radius:0; display:inline-flex; align-items:center; gap:6px; white-space:nowrap; transition:background .15s, transform .1s; text-decoration:none; }
.hr-btn:active { transform:scale(.98); }
.hr-btn:disabled { opacity:.5; cursor:not-allowed; }
.hr-btn--primary { background:#174DA4; color:#fff; } .hr-btn--primary:hover { background:#0f3a7d; }
.hr-btn--success { background:#16a34a; color:#fff; } .hr-btn--success:hover { background:#138a3e; }
.hr-btn--ghost { background:#fff; color:#555; border:1px solid #dde1e6; } .hr-btn--ghost:hover { border-color:#174DA4; color:#174DA4; }
.br-actions { display:flex; justify-content:space-between; gap:8px; padding:12px 16px; border-top:1px solid #eef1f5; background:#fafbfc; }

/* Summary cards */
.br-sum { display:grid; grid-template-columns:repeat(5,1fr); gap:8px; margin-bottom:14px; }
.br-sum__c { border:1px solid #e4e8f0; padding:11px 13px; border-radius:4px; position:relative; }
.br-sum__v { font-size:22px; font-weight:800; line-height:1.05; color:#05275C; font-variant-numeric:tabular-nums; }
.br-sum__l { font-size:9px; text-transform:uppercase; letter-spacing:.4px; color:#8a93a0; font-weight:700; margin-top:3px; }
.br-sum__c--reg .br-sum__v { color:#e67e00; }
.br-sum__c--bill .br-sum__v { color:#16a34a; }
.br-sum__c--paid .br-sum__v { color:#174DA4; }
.br-sum__c--money .br-sum__v { font-size:16px; color:#0f766e; }
@media (max-width:900px){ .br-sum { grid-template-columns:repeat(2,1fr); } }

/* Preview table */
.br-tablewrap { max-height:440px; overflow:auto; border:1px solid #e4e8f0; }
.br-table { width:100%; border-collapse:collapse; font-size:11px; }
.br-table th { position:sticky; top:0; z-index:1; background:#f5f7fa; color:#667; font-size:9.5px; text-transform:uppercase; letter-spacing:.4px; font-weight:700; padding:8px 9px; text-align:left; border-bottom:2px solid #e4e8f0; white-space:nowrap; }
.br-table td { padding:6px 9px; border-bottom:1px solid #f2f3f5; color:#1a1a2e; white-space:nowrap; }
.br-table tr:hover td { background:#f0f4ff; }
.br-table .num { text-align:right; font-variant-numeric:tabular-nums; }
.br-pill { display:inline-block; padding:1px 7px; font-size:9px; font-weight:700; text-transform:uppercase; letter-spacing:.3px; border-radius:4px; }
.br-pill--reg { background:#d4edda; color:#155724; }
.br-pill--unreg { background:#fff3cd; color:#856404; }
.br-pill--cleared { background:#cce5ff; color:#004085; }
.br-pill--act-bill { background:#e6f4ea; color:#138a3e; }
.br-pill--act-regbill { background:#fff3e0; color:#b45309; }
.br-tbar { display:flex; align-items:center; gap:10px; margin-bottom:8px; flex-wrap:wrap; }
.br-tbar__sp { flex:1; }
.br-muted { font-size:11px; color:#8a93a0; }

/* Confirm */
.br-confirm { background:#fff8e1; border:1px solid #ffe08a; border-left:3px solid #e67e00; padding:12px 14px; font-size:12px; color:#7c4a00; margin-bottom:14px; line-height:1.5; }
.br-confirm strong { color:#5a3600; }

/* Progress */
.br-prog { height:26px; background:#e9ecef; position:relative; overflow:hidden; margin:14px 0; }
.br-prog__fill { height:100%; background:linear-gradient(90deg,#16a34a,#22c55e); width:0; transition:width .3s; }
.br-prog__txt { position:absolute; inset:0; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; color:#1a1a2e; }
.br-live { display:grid; grid-template-columns:repeat(5,1fr); gap:8px; margin:12px 0; }
.br-live__c { text-align:center; padding:8px; background:#f5f7fa; border:1px solid #e4e8f0; }
.br-live__v { font-size:18px; font-weight:800; color:#05275C; }
.br-live__c--reg .br-live__v { color:#e67e00; }
.br-live__c--bill .br-live__v { color:#16a34a; }
.br-live__c--skip .br-live__v { color:#8a93a0; }
.br-live__c--err .br-live__v { color:#dc3545; }
.br-live__l { font-size:9px; text-transform:uppercase; letter-spacing:.3px; color:#8a93a0; font-weight:700; margin-top:2px; }
.br-log { max-height:220px; overflow-y:auto; background:#1a1a2e; padding:10px 12px; font-family:'Consolas','Monaco',monospace; font-size:10px; line-height:1.7; }
.br-log__e { color:#a0aec0; }
.br-log__e--ok { color:#68d391; }
.br-log__e--err { color:#fc8181; }
.br-log__e--skip { color:#cbd5e0; }
.br-log__e--info { color:#63b3ed; }

.br-spin { width:30px; height:30px; border:3px solid #e4e8f0; border-top-color:#174DA4; border-radius:50%; animation:brspin .8s linear infinite; margin:24px auto; }
@keyframes brspin { to { transform:rotate(360deg); } }
.br-empty { text-align:center; padding:40px 20px; color:#8a93a0; font-size:12px; }
.br-done { text-align:center; padding:18px 0 8px; }
.br-done__i { width:54px; height:54px; margin:0 auto 12px; background:#e6f4ea; border-radius:50%; display:flex; align-items:center; justify-content:center; }
.br-done__t { font-size:17px; font-weight:700; color:#1a1a2e; }
.br-done__s { font-size:12px; color:#6b7280; margin-top:4px; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="cd-page-header">
    <div class="cd-page-header__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"></rect><line x1="2" y1="10" x2="22" y2="10"></line></svg>
    </div>
    <div>
        <div class="cd-page-header__title">Billing Reconciliation Wizard</div>
        <div class="cd-page-header__sub">Find and bill students who were registered (or paid) but never billed for a semester &mdash; safely, in batches</div>
    </div>
</div>

<div class="br-card">
    <!-- Stepper -->
    <div class="br-steps">
        <div class="br-step is-active" id="stx1"><span class="br-step__num">1</span> Scope</div>
        <span class="br-step__sep"></span>
        <div class="br-step" id="stx2"><span class="br-step__num">2</span> Preview</div>
        <span class="br-step__sep"></span>
        <div class="br-step" id="stx3"><span class="br-step__num">3</span> Confirm</div>
        <span class="br-step__sep"></span>
        <div class="br-step" id="stx4"><span class="br-step__num">4</span> Process</div>
        <span class="br-step__sep"></span>
        <div class="br-step" id="stx5"><span class="br-step__num">5</span> Done</div>
    </div>

    <!-- STEP 1: SCOPE -->
    <div class="br-phase is-on" id="ph1">
        <div class="br-card__body">
            <div class="br-row">
                <div class="br-fld">
                    <span class="br-fld__lbl">Academic Year</span>
                    <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="br-sel" />
                </div>
                <div class="br-fld">
                    <span class="br-fld__lbl">Semester</span>
                    <asp:DropDownList ID="ddlSemester" runat="server" CssClass="br-sel">
                        <asp:ListItem Value="1" Text="Semester 1" />
                        <asp:ListItem Value="2" Text="Semester 2" />
                        <asp:ListItem Value="3" Text="Semester 3" />
                    </asp:DropDownList>
                </div>
            </div>

            <div class="br-scope" id="scopeBox">
                <label class="br-scope__opt is-sel" data-scope="paid">
                    <input type="radio" name="brscope" value="paid" checked="checked" />
                    <span>
                        <span class="br-scope__t">Registered &amp; already-paid <span style="color:#16a34a;">(recommended)</span></span>
                        <span class="br-scope__d">Bill students already Registered/Cleared but unbilled, plus Unregistered students who have already paid money (these are registered &amp; billed). Safest &mdash; only students who clearly enrolled.</span>
                    </span>
                </label>
                <label class="br-scope__opt" data-scope="safe">
                    <input type="radio" name="brscope" value="safe" />
                    <span>
                        <span class="br-scope__t">Only already-registered</span>
                        <span class="br-scope__d">Most conservative: bill only students already Registered/Late/Cleared but never billed. No status changes.</span>
                    </span>
                </label>
                <label class="br-scope__opt" data-scope="all">
                    <input type="radio" name="brscope" value="all" />
                    <span>
                        <span class="br-scope__t">Whole active cohort</span>
                        <span class="br-scope__d">Broadest: also register &amp; bill every Active/Admitted Unregistered student (including those who haven't paid). May bill no-shows.</span>
                    </span>
                </label>
            </div>
            <div class="br-muted">Alumni, staff accounts, and Discontinued / Halted / Dead-Year records are always excluded. Anyone already billed is skipped. The wizard is safe to re-run.</div>
        </div>
        <div class="br-actions">
            <span></span>
            <button type="button" class="hr-btn hr-btn--primary" onclick="loadPreview()">
                Load Preview
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"></polyline></svg>
            </button>
        </div>
    </div>

    <!-- STEP 2: PREVIEW -->
    <div class="br-phase" id="ph2">
        <div class="br-card__body">
            <div id="prevLoading"><div class="br-spin"></div><div style="text-align:center;color:#8a93a0;font-size:12px;">Scanning for skipped students&hellip;</div></div>
            <div id="prevContent" style="display:none;">
                <div class="br-sum">
                    <div class="br-sum__c"><div class="br-sum__v" id="suTotal">0</div><div class="br-sum__l">Candidates</div></div>
                    <div class="br-sum__c br-sum__c--reg"><div class="br-sum__v" id="suReg">0</div><div class="br-sum__l">Will Register + Bill</div></div>
                    <div class="br-sum__c br-sum__c--bill"><div class="br-sum__v" id="suBill">0</div><div class="br-sum__l">Bill Only</div></div>
                    <div class="br-sum__c br-sum__c--paid"><div class="br-sum__v" id="suPaid">0</div><div class="br-sum__l">Already Paid</div></div>
                    <div class="br-sum__c br-sum__c--money"><div class="br-sum__v" id="suMoney">0</div><div class="br-sum__l">Total Paid (UGX)</div></div>
                </div>
                <div class="br-tbar">
                    <label style="font-size:12px;font-weight:600;color:#1a1a2e;cursor:pointer;"><input type="checkbox" id="chkAll" checked="checked" onclick="toggleAll(this)" /> Select all</label>
                    <span class="br-muted" id="selInfo">0 selected</span>
                    <span class="br-tbar__sp"></span>
                    <button type="button" class="hr-btn hr-btn--ghost" onclick="exportCsv()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                        Export CSV
                    </button>
                </div>
                <div class="br-tablewrap">
                    <table class="br-table">
                        <thead><tr>
                            <th style="width:30px;"></th><th>Reg No</th><th>Name</th><th>Programme</th>
                            <th>Entry</th><th>Student</th><th>Reg Status</th><th class="num">Paid (UGX)</th><th>Action</th>
                        </tr></thead>
                        <tbody id="prevRows"></tbody>
                    </table>
                </div>
                <div id="prevEmpty" class="br-empty" style="display:none;">
                    No skipped students found for this period and scope. Nothing to bill.
                </div>
            </div>
        </div>
        <div class="br-actions">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="goStep(1)">&larr; Back</button>
            <button type="button" class="hr-btn hr-btn--primary" id="toConfirmBtn" onclick="goConfirm()" disabled="disabled">Review &amp; Confirm &rarr;</button>
        </div>
    </div>

    <!-- STEP 3: CONFIRM -->
    <div class="br-phase" id="ph3">
        <div class="br-card__body">
            <div class="br-confirm" id="confirmMsg"></div>
            <div class="br-sum" style="grid-template-columns:repeat(4,1fr);">
                <div class="br-sum__c"><div class="br-sum__v" id="cfSel">0</div><div class="br-sum__l">Selected</div></div>
                <div class="br-sum__c br-sum__c--reg"><div class="br-sum__v" id="cfReg">0</div><div class="br-sum__l">Register + Bill</div></div>
                <div class="br-sum__c br-sum__c--bill"><div class="br-sum__v" id="cfBill">0</div><div class="br-sum__l">Bill Only</div></div>
                <div class="br-sum__c"><div class="br-sum__v" id="cfPeriod" style="font-size:14px;">-</div><div class="br-sum__l">Period</div></div>
            </div>
            <div class="br-muted">Each student is billed via the standard registration billing engine (idempotent) and verified. If a bill cannot be confirmed, any status change for that student is rolled back automatically. Every action is written to the activity log.</div>
        </div>
        <div class="br-actions">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="goStep(2)">&larr; Back</button>
            <button type="button" class="hr-btn hr-btn--success" onclick="startProcessing()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                Start Billing
            </button>
        </div>
    </div>

    <!-- STEP 4: PROCESS -->
    <div class="br-phase" id="ph4">
        <div class="br-card__body">
            <div style="font-size:13px;font-weight:600;color:#1a1a2e;">Reconciling billing&hellip;</div>
            <div class="br-prog"><div class="br-prog__fill" id="progFill"></div><div class="br-prog__txt" id="progTxt">0%</div></div>
            <div class="br-live">
                <div class="br-live__c"><div class="br-live__v" id="lvProc">0</div><div class="br-live__l">Processed</div></div>
                <div class="br-live__c br-live__c--reg"><div class="br-live__v" id="lvReg">0</div><div class="br-live__l">Registered</div></div>
                <div class="br-live__c br-live__c--bill"><div class="br-live__v" id="lvBill">0</div><div class="br-live__l">Billed</div></div>
                <div class="br-live__c br-live__c--skip"><div class="br-live__v" id="lvSkip">0</div><div class="br-live__l">Skipped</div></div>
                <div class="br-live__c br-live__c--err"><div class="br-live__v" id="lvErr">0</div><div class="br-live__l">Errors</div></div>
            </div>
            <div class="br-log" id="procLog"></div>
        </div>
    </div>

    <!-- STEP 5: DONE -->
    <div class="br-phase" id="ph5">
        <div class="br-card__body">
            <div class="br-done">
                <div class="br-done__i"><svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg></div>
                <div class="br-done__t">Reconciliation Complete</div>
                <div class="br-done__s" id="doneSub">All selected students have been processed.</div>
            </div>
            <div class="br-live">
                <div class="br-live__c br-live__c--reg"><div class="br-live__v" id="dnReg">0</div><div class="br-live__l">Registered</div></div>
                <div class="br-live__c br-live__c--bill"><div class="br-live__v" id="dnBill">0</div><div class="br-live__l">Billed</div></div>
                <div class="br-live__c br-live__c--skip"><div class="br-live__v" id="dnSkip">0</div><div class="br-live__l">Skipped</div></div>
                <div class="br-live__c br-live__c--err"><div class="br-live__v" id="dnErr">0</div><div class="br-live__l">Errors</div></div>
                <div class="br-live__c"><div class="br-live__v" id="dnTotal">0</div><div class="br-live__l">Processed</div></div>
            </div>
        </div>
        <div class="br-actions">
            <button type="button" class="hr-btn hr-btn--ghost" onclick="restartWizard()">Run Another Period</button>
            <button type="button" class="hr-btn hr-btn--ghost" onclick="exportResults()">Export Result Log (CSV)</button>
        </div>
    </div>
</div>

<script type="text/javascript">
var AY = '<%= ddlAcadYear.ClientID %>', SEM = '<%= ddlSemester.ClientID %>';
function byId(x){ return document.getElementById(x); }
function esc(s){ var d=document.createElement('div'); d.textContent=(s==null?'':s); return d.innerHTML; }

var _rows = [];          // preview rows from server
var _scope = 'paid';
var _ctx = { ay:'', sem:0 };
var _proc = { ids:[], total:0, done:0, registered:0, billed:0, skipped:0, errors:0, running:false, log:[] };
var BATCH = 15;

// ---- scope radio ----
document.addEventListener('click', function(e){
    var opt = e.target.closest ? e.target.closest('.br-scope__opt') : null;
    if(!opt) return;
    document.querySelectorAll('.br-scope__opt').forEach(function(o){ o.classList.remove('is-sel'); });
    opt.classList.add('is-sel');
    var r = opt.querySelector('input'); if(r) r.checked = true;
});

function goStep(n){
    for(var i=1;i<=5;i++){
        byId('ph'+i).classList.toggle('is-on', i===n);
        var st = byId('stx'+i);
        st.classList.toggle('is-active', i===n);
        st.classList.toggle('is-done', i<n);
    }
}

// ---- STEP 1 -> 2 : preview ----
function loadPreview(){
    _ctx.ay = byId(AY).value; _ctx.sem = parseInt(byId(SEM).value,10)||0;
    var sc = document.querySelector('input[name=brscope]:checked'); _scope = sc ? sc.value : 'paid';
    if(!_ctx.ay || _ctx.sem<1){ alert('Please choose an academic year and semester.'); return; }
    goStep(2);
    byId('prevLoading').style.display=''; byId('prevContent').style.display='none';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', window.location.pathname + '?action=preview&ay='+encodeURIComponent(_ctx.ay)+'&sem='+_ctx.sem+'&scope='+_scope, true);
    xhr.onload = function(){
        byId('prevLoading').style.display='none'; byId('prevContent').style.display='';
        if(xhr.status!==200){ alert('Server error ('+xhr.status+').'); return; }
        var d; try { d = JSON.parse(xhr.responseText); } catch(e){ alert('Bad server response.'); return; }
        if(d.error){ alert(d.error); goStep(1); return; }
        _rows = d.rows || [];
        byId('suTotal').textContent = (d.total||0).toLocaleString();
        byId('suReg').textContent   = (d.willRegister||0).toLocaleString();
        byId('suBill').textContent  = (d.billOnly||0).toLocaleString();
        byId('suPaid').textContent  = (d.alreadyPaid||0).toLocaleString();
        byId('suMoney').textContent = parseInt(d.totalPaid||0,10).toLocaleString();
        renderRows();
    };
    xhr.onerror = function(){ byId('prevLoading').style.display='none'; alert('Network error.'); };
    xhr.send();
}

function renderRows(){
    var tb = byId('prevRows'), html='';
    for(var i=0;i<_rows.length;i++){
        var r=_rows[i];
        var rsCls = r.regstatus==='UNREGISTERED' ? 'unreg' : (r.regstatus==='CLEARED' ? 'cleared' : 'reg');
        var actCls = r.act==='register_bill' ? 'act-regbill' : 'act-bill';
        var actLbl = r.act==='register_bill' ? 'Register + Bill' : 'Bill';
        html += '<tr>'
            + '<td><input type="checkbox" class="brchk" data-id="'+r.id+'" data-act="'+r.act+'" checked onclick="updSel()"></td>'
            + '<td style="font-weight:600;color:#05275C;">'+esc(r.regno)+'</td>'
            + '<td>'+esc(r.name||'—')+'</td>'
            + '<td>'+esc(r.prog)+'</td>'
            + '<td>'+esc(r.entry)+'</td>'
            + '<td>'+esc(r.sstatus)+'</td>'
            + '<td><span class="br-pill br-pill--'+rsCls+'">'+esc(r.regstatus)+'</span></td>'
            + '<td class="num">'+parseInt(r.paid||0,10).toLocaleString()+'</td>'
            + '<td><span class="br-pill br-pill--'+actCls+'">'+actLbl+'</span></td>'
            + '</tr>';
    }
    tb.innerHTML = html;
    byId('prevEmpty').style.display = _rows.length ? 'none' : '';
    byId('chkAll').checked = _rows.length>0;
    updSel();
}

function toggleAll(cb){ document.querySelectorAll('.brchk').forEach(function(c){ c.checked=cb.checked; }); updSel(); }
function getSelected(){ var a=[]; document.querySelectorAll('.brchk:checked').forEach(function(c){ a.push({id:parseInt(c.getAttribute('data-id'),10),act:c.getAttribute('data-act')}); }); return a; }
function updSel(){
    var s=getSelected();
    byId('selInfo').textContent = s.length.toLocaleString()+' selected';
    byId('toConfirmBtn').disabled = s.length===0;
}

// ---- STEP 2 -> 3 : confirm ----
function goConfirm(){
    var s=getSelected(); if(!s.length) return;
    var reg=0, bill=0; s.forEach(function(x){ if(x.act==='register_bill') reg++; else bill++; });
    byId('cfSel').textContent=s.length.toLocaleString();
    byId('cfReg').textContent=reg.toLocaleString();
    byId('cfBill').textContent=bill.toLocaleString();
    byId('cfPeriod').textContent=_ctx.ay+' · Sem '+_ctx.sem;
    byId('confirmMsg').innerHTML = 'You are about to bill <strong>'+s.length.toLocaleString()+'</strong> student(s) for <strong>'+esc(_ctx.ay)+', Semester '+_ctx.sem+'</strong>. '
        + (reg>0 ? '<strong>'+reg.toLocaleString()+'</strong> of them will also be set to <strong>REGISTERED</strong>. ' : '')
        + 'This creates real fee charges. Please confirm the list is correct (use Export CSV on the previous step to review).';
    goStep(3);
}

// ---- STEP 3 -> 4 : process ----
function startProcessing(){
    var s=getSelected(); if(!s.length){ alert('Nothing selected.'); return; }
    _proc = { ids:s.map(function(x){return x.id;}), total:s.length, done:0, registered:0, billed:0, skipped:0, errors:0, running:true, log:[] };
    goStep(4);
    byId('progFill').style.width='0%'; byId('progTxt').textContent='0%';
    ['lvProc','lvReg','lvBill','lvSkip','lvErr'].forEach(function(x){ byId(x).textContent='0'; });
    byId('procLog').innerHTML='';
    logLine('info','Starting reconciliation of '+_proc.total.toLocaleString()+' student(s) in batches of '+BATCH+'…');
    nextBatch();
}

function nextBatch(){
    if(!_proc.running) return;
    if(_proc.done >= _proc.total){ finishProcessing(); return; }
    var batch = _proc.ids.slice(_proc.done, _proc.done+BATCH);
    var bnum = Math.floor(_proc.done/BATCH)+1;
    var xhr = new XMLHttpRequest();
    xhr.open('POST', window.location.pathname + '?action=process_batch', true);
    xhr.setRequestHeader('Content-Type','application/json');
    xhr.onload = function(){
        if(xhr.status!==200){ logLine('err','Server error ('+xhr.status+') — stopping.'); _proc.running=false; finishProcessing(); return; }
        var d; try { d=JSON.parse(xhr.responseText); } catch(e){ logLine('err','Parse error — stopping.'); _proc.running=false; finishProcessing(); return; }
        if(d.error){ logLine('err','Batch error: '+d.error); _proc.running=false; finishProcessing(); return; }
        _proc.done += batch.length;
        _proc.registered += d.registered; _proc.billed += d.billed; _proc.skipped += d.skipped; _proc.errors += d.errors;
        if(d.results){ d.results.forEach(function(r){ _proc.log.push(r);
            var t = r.s==='error'?'err':(r.s==='skip'?'skip':'ok');
            if(r.s==='error') logLine('err','#'+r.id+': '+(r.m||'failed'));
        }); }
        byId('lvProc').textContent=_proc.done.toLocaleString();
        byId('lvReg').textContent=_proc.registered.toLocaleString();
        byId('lvBill').textContent=_proc.billed.toLocaleString();
        byId('lvSkip').textContent=_proc.skipped.toLocaleString();
        byId('lvErr').textContent=_proc.errors.toLocaleString();
        var pct=Math.round(_proc.done/_proc.total*100);
        byId('progFill').style.width=pct+'%'; byId('progTxt').textContent=pct+'%';
        logLine(d.errors>0?'err':'ok','Batch '+bnum+': '+d.billed+' billed, '+d.registered+' registered, '+d.skipped+' skipped'+(d.errors>0?(', '+d.errors+' errors'):''));
        setTimeout(nextBatch, 60);
    };
    xhr.onerror = function(){ logLine('err','Network error — stopping.'); _proc.running=false; finishProcessing(); };
    xhr.send(JSON.stringify({ ids: batch }));
}

function finishProcessing(){
    _proc.running=false;
    byId('progFill').style.width='100%'; byId('progTxt').textContent='100%';
    logLine('ok','Done — '+_proc.billed.toLocaleString()+' billed, '+_proc.registered.toLocaleString()+' registered, '+_proc.skipped.toLocaleString()+' skipped, '+_proc.errors.toLocaleString()+' errors.');
    byId('dnReg').textContent=_proc.registered.toLocaleString();
    byId('dnBill').textContent=_proc.billed.toLocaleString();
    byId('dnSkip').textContent=_proc.skipped.toLocaleString();
    byId('dnErr').textContent=_proc.errors.toLocaleString();
    byId('dnTotal').textContent=_proc.done.toLocaleString();
    byId('doneSub').textContent = _proc.billed.toLocaleString()+' student(s) billed for '+_ctx.ay+' Semester '+_ctx.sem+'.';
    goStep(5);
}

function logLine(type,msg){
    var box=byId('procLog'); var el=document.createElement('div'); el.className='br-log__e br-log__e--'+type;
    el.textContent = msg; box.appendChild(el); box.scrollTop=box.scrollHeight;
}

// ---- CSV exports ----
function dl(name, text){
    var a=document.createElement('a');
    a.href='data:text/csv;charset=utf-8,'+encodeURIComponent(text); a.download=name;
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
}
function exportCsv(){
    var lines=['Reg No,Name,Programme,Entry Year,Student Status,Reg Status,Paid,Action'];
    _rows.forEach(function(r){
        lines.push([q(r.regno),q(r.name),q(r.prog),q(r.entry),q(r.sstatus),q(r.regstatus),r.paid,(r.act==='register_bill'?'Register+Bill':'Bill')].join(','));
    });
    dl('skipped_billing_'+_ctx.ay.replace(/\//g,'_')+'_sem'+_ctx.sem+'.csv', lines.join('\n'));
}
function exportResults(){
    var byId2={}; _rows.forEach(function(r){ byId2[r.id]=r; });
    var lines=['Reg No,Name,Result,Detail'];
    _proc.log.forEach(function(r){ var s=byId2[r.id]||{}; lines.push([q(s.regno||r.id),q(s.name||''),q(r.s),q(r.m||'')].join(',')); });
    dl('reconciliation_result_'+_ctx.ay.replace(/\//g,'_')+'_sem'+_ctx.sem+'.csv', lines.join('\n'));
}
function q(v){ v=(v==null?'':String(v)); return (v.indexOf(',')>=0||v.indexOf('"')>=0) ? '"'+v.replace(/"/g,'""')+'"' : v; }

function restartWizard(){ _rows=[]; goStep(1); }
</script>
</asp:Content>
