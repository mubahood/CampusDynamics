<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master"
    AutoEventWireup="true" CodeFile="AdmissionLetterConfig.aspx.cs"
    Inherits="COOPERP_NewScreens_AdmissionLetterConfig"
    Title="Admission Letter Configuration" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Admission Letter Config (alc-) ─────────────────── */
.alc-page { max-width: 960px; }
.alc-hdr  { background:#05275C;color:#fff;padding:12px 16px;display:flex;align-items:center;justify-content:space-between; }
.alc-hdr h1 { margin:0;font-size:14px;font-weight:700;display:flex;align-items:center;gap:8px; }
.alc-hdr-sub { font-size:10px;opacity:.75;margin-top:2px; }
.alc-body { background:#fff;border:1px solid #e0e5ed;border-top:none; }

/* Tabs */
.alc-tabs { display:flex;border-bottom:2px solid #e0e5ed;background:#f5f7fa; }
.alc-tab  { padding:10px 18px;font-size:11px;font-weight:700;cursor:pointer;border:none;background:none;color:#666;border-bottom:2px solid transparent;margin-bottom:-2px;font-family:inherit;text-transform:uppercase;letter-spacing:.4px; }
.alc-tab.active { color:#05275C;border-bottom-color:#05275C;background:#fff; }
.alc-tab:hover { color:#174DA4; }
.alc-panel { display:none;padding:20px 24px 24px; }
.alc-panel.active { display:block; }

/* Fields */
.alc-section { font-size:10px;text-transform:uppercase;letter-spacing:.6px;color:#174DA4;font-weight:700;padding:10px 0 6px;border-bottom:1px solid #e8ecf4;margin:16px 0 12px; }
.alc-section:first-child { margin-top:0; }
.alc-grid2 { display:grid;grid-template-columns:1fr 1fr;gap:14px; }
.alc-grid3 { display:grid;grid-template-columns:1fr 1fr 1fr;gap:14px; }
.alc-group { margin-bottom:14px; }
.alc-label { display:block;font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#555;font-weight:600;margin-bottom:4px; }
.alc-label .alc-hint { font-size:9px;color:#999;text-transform:none;letter-spacing:0;font-weight:400;margin-left:4px; }
.alc-input,.alc-textarea { width:100%;padding:7px 9px;border:1px solid #cdd8e6;font-size:12px;font-family:inherit;box-sizing:border-box;background:#fff;border-radius:0; }
.alc-input:focus,.alc-textarea:focus { border-color:#174DA4;outline:none;box-shadow:0 0 0 2px rgba(23,77,164,.08); }
.alc-textarea { min-height:80px;resize:vertical;font-family:'Courier New',monospace;font-size:11px;line-height:1.5; }
.alc-textarea.tall { min-height:130px; }
.alc-textarea.xtall { min-height:200px; }

/* Buttons */
.alc-btn { padding:7px 16px;font-size:12px;font-weight:600;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:6px;font-family:inherit;border-radius:0; }
.alc-btn--primary { background:#05275C;color:#fff; }
.alc-btn--primary:hover { background:#174DA4; }
.alc-btn--ghost { background:#fff;border:1px solid #cdd3de;color:#555; }
.alc-btn--ghost:hover { border-color:#174DA4;color:#174DA4; }
.alc-btn--success { background:#16a34a;color:#fff; }
.alc-btn--danger { background:#dc2626;color:#fff; }

/* Fees table */
.alc-fees-table { width:100%;border-collapse:collapse;font-size:12px;margin-top:8px; }
.alc-fees-table th { background:#f0f4fc;color:#05275C;font-size:10px;text-transform:uppercase;letter-spacing:.4px;padding:7px 12px;text-align:left;border-bottom:2px solid #e0e5ed;font-weight:700; }
.alc-fees-table td { padding:7px 12px;border-bottom:1px solid #f0f2f5;vertical-align:middle; }
.alc-fees-table tr:hover td { background:#fafbfc; }
.alc-fees-table input { width:100%;padding:5px 7px;border:1px solid #cdd8e6;font-size:12px;font-family:inherit;box-sizing:border-box; }
.alc-fees-table .progcode-cell { font-family:monospace;font-weight:700;color:#05275C; }
.alc-empty { color:#aaa;font-style:italic;font-size:11px;padding:16px 0;text-align:center; }

/* Footer */
.alc-footer { display:flex;align-items:center;justify-content:space-between;padding:12px 24px;border-top:1px solid #e0e5ed;background:#f8f9fa; }
.alc-save-msg { font-size:11px;color:#16a34a;font-weight:600; }

/* Alert */
.alc-alert { padding:9px 14px;font-size:12px;margin:0 24px 12px; }
.alc-alert--ok  { background:#e6f4ea;color:#155724;border-left:4px solid #16a34a; }
.alc-alert--err { background:#fdecea;color:#b91c1c;border-left:4px solid #c62828; }

/* Preview bar */
.alc-preview-bar { background:#f0f4fc;border:1px solid #dce5f7;padding:10px 24px;font-size:11px;display:flex;align-items:center;gap:10px;border-bottom:1px solid #e0e5ed; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="alc-page">

    <div class="alc-hdr">
        <div>
            <h1>
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                Admission Letter Configuration
            </h1>
            <div class="alc-hdr-sub">Define and maintain the templates used to generate provisional and official admission letters.</div>
        </div>
        <a href="AdmissionLetter.aspx?eno=&type=provisional&preview=1" target="_blank" class="alc-btn alc-btn--ghost" style="color:#fff;border-color:rgba(255,255,255,.35);" title="Open letter preview in new tab">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
            Preview Letter
        </a>
    </div>

    <!-- Alert -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div class="alc-alert" id="alertBox" runat="server"></div>
    </asp:Panel>

    <!-- Preview bar -->
    <div class="alc-preview-bar">
        <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <span>Changes here affect both <strong>Provisional</strong> (student-generated) and <strong>Official</strong> (admin-generated) letters unless noted.
        Use <code>{{variable}}</code> placeholders — they are replaced with live student data when the letter is generated.</span>
    </div>

    <div class="alc-body">
        <!-- Tabs -->
        <div class="alc-tabs">
            <button type="button" class="alc-tab active" onclick="alcTab('general',this)">General</button>
            <button type="button" class="alc-tab" onclick="alcTab('body',this)">Letter Body</button>
            <button type="button" class="alc-tab" onclick="alcTab('fees',this)">Fees &amp; Payment</button>
            <button type="button" class="alc-tab" onclick="alcTab('sections',this)">Sections</button>
            <button type="button" class="alc-tab" onclick="alcTab('progfees',this)">Programme Fees</button>
        </div>

        <!-- ── GENERAL ── -->
        <div id="tab-general" class="alc-panel active">
            <div class="alc-section">Titles &amp; Signatory</div>
            <div class="alc-grid2">
                <div class="alc-group">
                    <label class="alc-label">Provisional Letter Title</label>
                    <asp:TextBox ID="txt_provisional_title" runat="server" CssClass="alc-input" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Official Letter Title</label>
                    <asp:TextBox ID="txt_official_title" runat="server" CssClass="alc-input" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Academic Registrar Name</label>
                    <asp:TextBox ID="txt_registrar_name" runat="server" CssClass="alc-input" placeholder="e.g. MUSISI FRED KAMOGA (PhD)" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Academic Registrar Title</label>
                    <asp:TextBox ID="txt_registrar_title" runat="server" CssClass="alc-input" placeholder="e.g. ACADEMIC REGISTRAR" />
                </div>
            </div>
            <div class="alc-section">Signature Image</div>
            <div class="alc-group">
                <label class="alc-label">Registrar Signature Image Path <span class="alc-hint">(URL relative to site root — e.g. /COOPERP/NewScreens/images/ar_signature.png — leave blank to omit)</span></label>
                <asp:TextBox ID="txt_registrar_sig_path" runat="server" CssClass="alc-input" placeholder="/COOPERP/NewScreens/images/ar_signature.png" />
            </div>
            <div id="sig_preview_wrap" style="margin-top:8px;min-height:24px;">
                <img id="sig_preview" src="" alt="" style="max-height:60px;display:none;border:1px solid #e0e5ed;padding:4px;background:#fff;" />
            </div>
            <script>
            (function(){
                var inp = document.getElementById('<%= txt_registrar_sig_path.ClientID %>');
                var img = document.getElementById('sig_preview');
                if (!inp || !img) return;
                function refresh(){ var v=(inp.value||'').trim(); if(v){img.src=v;img.style.display='block';}else{img.style.display='none';} }
                inp.addEventListener('input', refresh); inp.addEventListener('change', refresh); refresh();
            })();
            </script>
            <div class="alc-section">University &amp; Contact</div>
            <div class="alc-grid2">
                <div class="alc-group">
                    <label class="alc-label">University Name</label>
                    <asp:TextBox ID="txt_university_name" runat="server" CssClass="alc-input" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Admissions Email</label>
                    <asp:TextBox ID="txt_admissions_email" runat="server" CssClass="alc-input" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Logo URL <span class="alc-hint">(relative path e.g. /COOPERP/images/logo.png — leave blank to use text header)</span></label>
                    <asp:TextBox ID="txt_logo_path" runat="server" CssClass="alc-input" placeholder="e.g. /COOPERP/images/mru_logo.png" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">University Sub-Heading <span class="alc-hint">(tagline / address shown under name)</span></label>
                    <asp:TextBox ID="txt_univ_tagline" runat="server" CssClass="alc-input" placeholder="e.g. Kampala, Uganda | admissions@mru.ac.ug" />
                </div>
            </div>
            <div class="alc-section">Dates &amp; Deadlines</div>
            <div class="alc-grid3">
                <div class="alc-group">
                    <label class="alc-label">Academic Year <span class="alc-hint">{{acad_year}}</span></label>
                    <asp:TextBox ID="txt_acad_year" runat="server" CssClass="alc-input" placeholder="e.g. 2026/2027" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Registration Start Date <span class="alc-hint">{{reg_deadline_date}}</span></label>
                    <asp:TextBox ID="txt_reg_deadline_date" runat="server" CssClass="alc-input" placeholder="e.g. 03rd August, 2026" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Reg. Deadline Weeks <span class="alc-hint">{{reg_deadline_weeks}}</span></label>
                    <asp:TextBox ID="txt_reg_deadline_weeks" runat="server" CssClass="alc-input" placeholder="e.g. 3" />
                </div>
            </div>
            <div class="alc-section">Sponsorship &amp; Fees</div>
            <div class="alc-grid3">
                <div class="alc-group">
                    <label class="alc-label">Sponsor Type <span class="alc-hint">{{sponsor_type}}</span></label>
                    <asp:TextBox ID="txt_sponsor_type" runat="server" CssClass="alc-input" placeholder="e.g. Privately-Sponsored" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Default Tuition Fees <span class="alc-hint">(UGX, no commas)</span></label>
                    <asp:TextBox ID="txt_default_tuition" runat="server" CssClass="alc-input" placeholder="e.g. 780000" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Default Functional Fees <span class="alc-hint">(UGX, no commas)</span></label>
                    <asp:TextBox ID="txt_default_functional" runat="server" CssClass="alc-input" placeholder="e.g. 867000" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">NCHE Fee Amount <span class="alc-hint">{{nche_fee_amount}}</span></label>
                    <asp:TextBox ID="txt_nche_fee" runat="server" CssClass="alc-input" placeholder="e.g. 20,000" />
                </div>
                <div class="alc-group">
                    <label class="alc-label">Kabaka Education Fund Amount <span class="alc-hint">{{kabaka_fund_amount}}</span></label>
                    <asp:TextBox ID="txt_kabaka_fund" runat="server" CssClass="alc-input" placeholder="e.g. 24,000" />
                </div>
            </div>
        </div>

        <!-- ── LETTER BODY ── -->
        <div id="tab-body" class="alc-panel">
            <div class="alc-section">Opening</div>
            <div class="alc-group">
                <label class="alc-label">Introductory Paragraph <span class="alc-hint">Plain text. Use {{acad_year}}, {{programme_name}}</span></label>
                <asp:TextBox ID="txt_intro_paragraph" runat="server" CssClass="alc-textarea" TextMode="MultiLine" />
            </div>
            <div class="alc-group">
                <label class="alc-label">After-Programme HTML <span class="alc-hint">Raw HTML rendered directly after the programme block and before fees. Supports section headings. Use {{programme_name}}, {{reg_deadline_weeks}}, {{acad_year}}</span></label>
                <asp:TextBox ID="txt_body_paragraph" runat="server" CssClass="alc-textarea tall" TextMode="MultiLine" />
            </div>
            <div class="alc-section">Additional Pre-Fees Content</div>
            <div class="alc-group">
                <label class="alc-label">Pre-Fees HTML <span class="alc-hint">HTML rendered immediately before the fees section (e.g. documents list for provisional letters). Leave blank if not needed.</span></label>
                <asp:TextBox ID="txt_requirements_html" runat="server" CssClass="alc-textarea tall" TextMode="MultiLine" />
            </div>
            <div class="alc-group">
                <label class="alc-label">Disclaimer HTML <span class="alc-hint">HTML paragraph — e.g. warning about impersonation / falsification of documents. Leave blank if not needed.</span></label>
                <asp:TextBox ID="txt_disclaimer_html" runat="server" CssClass="alc-textarea" TextMode="MultiLine" />
            </div>
            <div class="alc-section">Closing</div>
            <div class="alc-group">
                <label class="alc-label">Closing Text <span class="alc-hint">HTML. Use {{university_name}}, {{admissions_email}}</span></label>
                <asp:TextBox ID="txt_closing_html" runat="server" CssClass="alc-textarea" TextMode="MultiLine" />
            </div>
        </div>

        <!-- ── FEES & PAYMENT ── -->
        <div id="tab-fees" class="alc-panel">
            <div class="alc-section">Fees Section</div>
            <div class="alc-group">
                <label class="alc-label">Fees Section Introduction <span class="alc-hint">Plain text shown before the fees table</span></label>
                <asp:TextBox ID="txt_fees_section_intro" runat="server" CssClass="alc-textarea" TextMode="MultiLine" />
            </div>
            <div class="alc-section">Payment Instructions</div>
            <div class="alc-group">
                <label class="alc-label">Payment Instructions <span class="alc-hint">HTML — Airtel/MTN mobile money instructions</span></label>
                <asp:TextBox ID="txt_payment_instructions_html" runat="server" CssClass="alc-textarea xtall" TextMode="MultiLine" />
            </div>
            <div class="alc-section">Additional Charges</div>
            <div class="alc-group">
                <label class="alc-label">Additional Charges &amp; NB <span class="alc-hint">HTML — NCHE fee, Kabaka fund, NB note. Use {{nche_fee_amount}}, {{kabaka_fund_amount}}</span></label>
                <asp:TextBox ID="txt_additional_charges_html" runat="server" CssClass="alc-textarea tall" TextMode="MultiLine" />
            </div>
        </div>

        <!-- ── SECTIONS ── -->
        <div id="tab-sections" class="alc-panel">
            <p style="font-size:11px;color:#666;margin-top:0;padding:0 0 8px;">These three sections render <strong>after</strong> the fees/payment block and <strong>before</strong> the closing text. Leave blank to omit a section.</p>
            <div class="alc-section">Section 1 — Orientation Programme</div>
            <div class="alc-group">
                <asp:TextBox ID="txt_orientation_html" runat="server" CssClass="alc-textarea" TextMode="MultiLine" />
            </div>
            <div class="alc-section">Section 2 — Change of Programme</div>
            <div class="alc-group">
                <asp:TextBox ID="txt_change_prog_html" runat="server" CssClass="alc-textarea" TextMode="MultiLine" />
            </div>
            <div class="alc-section">Section 3 — Registration</div>
            <div class="alc-group">
                <asp:TextBox ID="txt_registration_html" runat="server" CssClass="alc-textarea" TextMode="MultiLine" />
            </div>
        </div>

        <!-- ── PROGRAMME FEES ── -->
        <div id="tab-progfees" class="alc-panel">
            <p style="font-size:12px;color:#444;margin-top:0;">
                Set programme-specific fees that override the default values. Enter the programme code exactly as stored in the database (e.g. <code>BIT</code>, <code>BSWE</code>).
                If a programme is not listed here the <strong>default fees</strong> from the General tab are used.
            </p>
            <div style="display:flex;gap:8px;margin-bottom:12px;align-items:flex-end;">
                <div class="alc-group" style="margin:0;">
                    <label class="alc-label">Programme Code</label>
                    <input type="text" id="pf_code" class="alc-input" placeholder="e.g. BIT" style="width:120px;" />
                </div>
                <div class="alc-group" style="margin:0;">
                    <label class="alc-label">Tuition Fees (UGX)</label>
                    <input type="number" id="pf_tuition" class="alc-input" placeholder="780000" style="width:130px;" />
                </div>
                <div class="alc-group" style="margin:0;">
                    <label class="alc-label">Functional Fees (UGX)</label>
                    <input type="number" id="pf_functional" class="alc-input" placeholder="867000" style="width:130px;" />
                </div>
                <button type="button" class="alc-btn alc-btn--primary" onclick="pfAdd()">Add / Update</button>
            </div>
            <table class="alc-fees-table" id="pfTable">
                <thead>
                    <tr>
                        <th style="width:120px;">Programme Code</th>
                        <th>Tuition (UGX)</th>
                        <th>Functional (UGX)</th>
                        <th>Total</th>
                        <th style="width:80px;">Action</th>
                    </tr>
                </thead>
                <tbody id="pfBody">
                    <tr><td colspan="5" class="alc-empty">Loading…</td></tr>
                </tbody>
            </table>
            <div id="pfMsg" style="font-size:11px;margin-top:8px;min-height:16px;"></div>
        </div>

    </div>

    <!-- Footer -->
    <div class="alc-footer">
        <span class="alc-save-msg" id="saveMsg"></span>
        <div style="display:flex;gap:8px;">
            <a href="AdmissionLetter.aspx?type=provisional&preview=1" target="_blank" class="alc-btn alc-btn--ghost">
                Preview Provisional
            </a>
            <asp:Button ID="btnSave" runat="server" Text="Save All Changes"
                CssClass="alc-btn alc-btn--primary"
                OnClick="btnSave_Click" />
        </div>
    </div>
</div>

<script type="text/javascript">
var _pageUrl = '<%= ResolveUrl("~/COOPERP/NewScreens/AdmissionLetterConfig.aspx") %>';

function alcTab(id, btn) {
    document.querySelectorAll('.alc-panel').forEach(function(p){ p.classList.remove('active'); });
    document.querySelectorAll('.alc-tab').forEach(function(t){ t.classList.remove('active'); });
    document.getElementById('tab-' + id).classList.add('active');
    btn.classList.add('active');
    if (id === 'progfees') pfLoad();
}

// ── Programme Fees ─────────────────────────────────
function pfLoad() {
    fetch(_pageUrl + '?ajax=pf_list')
        .then(function(r){ return r.json(); })
        .then(function(d){
            var tbody = document.getElementById('pfBody');
            if (!d.ok || !d.rows || !d.rows.length) {
                tbody.innerHTML = '<tr><td colspan="5" class="alc-empty">No programme-specific fees configured. Default fees will be used for all programmes.</td></tr>';
                return;
            }
            tbody.innerHTML = d.rows.map(function(r){
                var total = (parseInt(r.tuition)||0) + (parseInt(r.functional)||0);
                return '<tr><td class="progcode-cell">' + h(r.code) + '</td>'
                    + '<td>' + fmt(r.tuition) + '</td>'
                    + '<td>' + fmt(r.functional) + '</td>'
                    + '<td><strong>' + fmt(total) + '</strong></td>'
                    + '<td><button class="alc-btn alc-btn--danger" style="padding:3px 10px;font-size:10px;" onclick="pfDel(\'' + h(r.code) + '\')">Delete</button></td></tr>';
            }).join('');
        })
        .catch(function(){ document.getElementById('pfBody').innerHTML = '<tr><td colspan="5" class="alc-empty" style="color:#c62828;">Error loading fees.</td></tr>'; });
}

function pfAdd() {
    var code = document.getElementById('pf_code').value.trim().toUpperCase();
    var tuition = parseInt(document.getElementById('pf_tuition').value) || 0;
    var functional = parseInt(document.getElementById('pf_functional').value) || 0;
    if (!code) { pfMsg('Programme code is required.', false); return; }
    if (!tuition && !functional) { pfMsg('Enter at least one fee amount.', false); return; }
    fetch(_pageUrl + '?ajax=pf_save', {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({code: code, tuition: tuition, functional: functional})
    }).then(function(r){ return r.json(); }).then(function(d){
        if (d.ok) { pfMsg('Saved.', true); pfLoad(); document.getElementById('pf_code').value=''; document.getElementById('pf_tuition').value=''; document.getElementById('pf_functional').value=''; }
        else pfMsg(d.error || 'Error.', false);
    }).catch(function(){ pfMsg('Network error.', false); });
}

function pfDel(code) {
    if (!confirm('Delete fees for ' + code + '?')) return;
    fetch(_pageUrl + '?ajax=pf_del', {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({code: code})
    }).then(function(r){ return r.json(); }).then(function(d){
        if (d.ok) { pfMsg('Deleted.', true); pfLoad(); }
        else pfMsg(d.error || 'Error.', false);
    });
}

function pfMsg(msg, ok) {
    var el = document.getElementById('pfMsg');
    el.textContent = msg;
    el.style.color = ok ? '#16a34a' : '#c62828';
    setTimeout(function(){ el.textContent=''; }, 3000);
}

function fmt(n) { return Number(n).toLocaleString(); }
function h(s) { return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

// Flash save message when form is submitted
(function(){
    var msg = '<%= HttpUtility.JavaScriptStringEncode(SaveMessage) %>';
    if (msg) {
        var el = document.getElementById('saveMsg');
        if (el) el.textContent = msg;
    }
})();
</script>
</asp:Content>
