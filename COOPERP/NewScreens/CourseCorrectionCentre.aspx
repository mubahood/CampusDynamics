<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="CourseCorrectionCentre.aspx.cs" Inherits="COOPERP_NewScreens_CourseCorrectionCentre" Title="Course Records Correction Centre" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box;}
.cc-wrap{max-width:1320px;margin:0 auto;padding:10px 12px 24px;font-size:12px;color:#1a1a2e;}
.cc-head{display:flex;flex-wrap:wrap;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:12px;}
.cc-title{font-size:17px;font-weight:800;color:#05275C;letter-spacing:-.02em;margin:0 0 3px;}
.cc-sub{font-size:11px;color:#64748b;line-height:1.5;max-width:720px;margin:0;}
.cc-scope{display:inline-flex;align-items:center;gap:6px;padding:5px 9px;background:#f5f7fa;border:1px solid #e0e5ed;font-size:10.5px;color:#05275C;font-weight:700;}
.cc-scope svg{flex:0 0 auto;}

/* operation tabs */
.cc-ops{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:8px;margin-bottom:14px;}
.cc-op{border:1px solid #e0e5ed;background:#fff;border-radius:4px;padding:11px 12px;cursor:pointer;text-align:left;transition:border-color .12s,box-shadow .12s;min-width:0;}
.cc-op:hover{border-color:#174DA4;}
.cc-op.on{border-color:#05275C;box-shadow:inset 0 0 0 1px #05275C;background:#f8fafd;}
.cc-op__t{display:flex;align-items:center;gap:7px;font-weight:800;color:#05275C;font-size:12px;margin-bottom:3px;}
.cc-op__d{font-size:10.5px;color:#64748b;line-height:1.45;}
.cc-op[disabled]{opacity:.45;cursor:not-allowed;}

/* stepper */
.cc-steps{display:flex;align-items:center;gap:0;margin:0 0 14px;flex-wrap:wrap;}
.cc-step{display:flex;align-items:center;gap:6px;padding:6px 12px 6px 10px;background:#f5f7fa;border:1px solid #e0e5ed;font-size:10.5px;font-weight:700;color:#94a3b8;margin-right:-1px;}
.cc-step.on{background:#05275C;border-color:#05275C;color:#fff;}
.cc-step.done{background:#fff;color:#174DA4;border-color:#c7d4e8;}
.cc-step__n{display:inline-flex;align-items:center;justify-content:center;width:16px;height:16px;border-radius:50%;background:rgba(255,255,255,.22);font-size:9.5px;}
.cc-step.done .cc-step__n,.cc-step:not(.on) .cc-step__n{background:#e0e5ed;color:#64748b;}
.cc-step.done .cc-step__n{background:#dbe7f8;color:#174DA4;}

.cc-card{border:1px solid #e0e5ed;background:#fff;border-radius:4px;padding:14px;margin-bottom:12px;}
.cc-card__h{font-size:12px;font-weight:800;color:#05275C;margin:0 0 3px;}
.cc-card__s{font-size:10.5px;color:#64748b;margin:0 0 11px;line-height:1.5;}

.cc-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:10px;}
.cc-f{display:flex;flex-direction:column;gap:4px;min-width:0;}
.cc-f label{font-size:9.5px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;}
.cc-f input[type=text],.cc-f select,.cc-f textarea{width:100%;padding:7px 8px;border:1px solid #e0e5ed;border-radius:0;font-size:12px;font-family:inherit;color:#1a1a2e;background:#fff;}
.cc-f input:focus,.cc-f select:focus,.cc-f textarea:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 2px rgba(23,77,164,.10);}
.cc-f .hint{font-size:9.5px;color:#94a3b8;line-height:1.4;}
.cc-chk{display:flex;align-items:flex-start;gap:7px;padding:8px 9px;border:1px solid #e0e5ed;background:#fafbfd;cursor:pointer;}
.cc-chk input{margin:1px 0 0;flex:0 0 auto;}
.cc-chk span{font-size:11px;line-height:1.45;}
.cc-chk b{display:block;font-size:11px;color:#05275C;}
.cc-chk em{font-style:normal;color:#64748b;font-size:10px;}

/* code picker */
.cc-pick{position:relative;}
.cc-drop{position:absolute;z-index:40;top:100%;left:0;right:0;max-height:270px;overflow:auto;background:#fff;border:1px solid #c7d4e8;border-top:none;display:none;box-shadow:0 6px 18px rgba(5,39,92,.10);}
.cc-drop.show{display:block;}
.cc-drop__i{padding:7px 9px;cursor:pointer;border-bottom:1px solid #f1f5f9;display:flex;justify-content:space-between;gap:8px;align-items:baseline;}
.cc-drop__i:hover,.cc-drop__i.hl{background:#f0f5fd;}
.cc-drop__c{font-weight:800;color:#05275C;font-size:11.5px;font-family:ui-monospace,Menlo,Consolas,monospace;}
.cc-drop__n{font-size:10px;color:#64748b;flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.cc-drop__r{font-size:9.5px;color:#94a3b8;white-space:nowrap;font-weight:700;}
.cc-chosen{margin-top:5px;font-size:10.5px;color:#174DA4;font-weight:700;}
.cc-chosen span{color:#64748b;font-weight:400;}

/* similar-code helper */
.cc-sim{margin-top:10px;border:1px solid #e0e5ed;background:#fafbfd;padding:9px 10px;border-radius:4px;}
.cc-sim__h{font-size:10.5px;font-weight:800;color:#05275C;margin-bottom:6px;display:flex;justify-content:space-between;align-items:center;gap:8px;}
.cc-sim__l{display:flex;flex-wrap:wrap;gap:6px;max-height:150px;overflow:auto;}
.cc-simg{border:1px solid #e0e5ed;background:#fff;padding:4px 7px;font-size:10px;cursor:pointer;font-family:ui-monospace,Menlo,Consolas,monospace;}
.cc-simg:hover{border-color:#174DA4;}
.cc-simg b{color:#05275C;}
.cc-simg i{font-style:normal;color:#94a3b8;}

/* preview */
.cc-kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:8px;margin-bottom:11px;}
.cc-kpi{border:1px solid #e0e5ed;border-radius:4px;padding:9px 10px;background:#fff;min-width:0;}
.cc-kpi__l{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;margin-bottom:3px;}
.cc-kpi__v{font-size:20px;font-weight:800;color:#05275C;line-height:1;letter-spacing:-.02em;}
.cc-kpi--go .cc-kpi__v{color:#16a34a;}
.cc-kpi--skip .cc-kpi__v{color:#b45309;}
.cc-verd{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:11px;}
.cc-vd{border:1px solid #e0e5ed;background:#fff;padding:5px 9px;font-size:10.5px;border-radius:4px;}
.cc-vd b{color:#05275C;font-weight:800;}
.cc-vd.go{border-color:#bbf7d0;background:#f0fdf4;}
.cc-vd.no{border-color:#fde68a;background:#fffbeb;}

.cc-tblwrap{overflow-x:auto;border:1px solid #e0e5ed;border-radius:4px;}
table.cc-tbl{width:100%;border-collapse:collapse;font-size:11px;min-width:820px;}
table.cc-tbl th{background:#f5f7fa;color:#05275C;font-size:9.5px;text-transform:uppercase;letter-spacing:.35px;text-align:left;padding:6px 7px;border-bottom:1px solid #e0e5ed;white-space:nowrap;font-weight:800;}
table.cc-tbl td{padding:5px 7px;border-bottom:1px solid #f1f5f9;vertical-align:top;}
table.cc-tbl tr:last-child td{border-bottom:none;}
table.cc-tbl tr.go td{background:#fbfefc;}
table.cc-tbl tr.no td{background:#fffdf7;color:#78716c;}
.cc-mono{font-family:ui-monospace,Menlo,Consolas,monospace;font-weight:700;color:#05275C;}
.cc-badge{display:inline-block;padding:1px 6px;font-size:9px;font-weight:800;border-radius:0;text-transform:uppercase;letter-spacing:.3px;}
.cc-badge.go{background:#dcfce7;color:#166534;}
.cc-badge.no{background:#fef3c7;color:#92400e;}
.cc-nm{font-size:10px;color:#64748b;display:block;}

/* actions */
.cc-actions{display:flex;flex-wrap:wrap;gap:8px;align-items:center;justify-content:space-between;margin-top:14px;}
.cc-actions__r{display:flex;gap:8px;flex-wrap:wrap;}
.cc-btn{display:inline-flex;align-items:center;gap:6px;padding:8px 15px;border:1px solid #05275C;background:#05275C;color:#fff;font-size:11.5px;font-weight:700;cursor:pointer;border-radius:0;font-family:inherit;}
.cc-btn:hover{background:#0a3573;}
.cc-btn[disabled]{opacity:.45;cursor:not-allowed;}
.cc-btn--ghost{background:#fff;color:#05275C;}
.cc-btn--ghost:hover{background:#f5f7fa;}
.cc-btn--go{background:#16803d;border-color:#16803d;}
.cc-btn--go:hover{background:#146c34;}
.cc-btn--danger{background:#b42318;border-color:#b42318;}

.cc-msg{padding:9px 11px;border-radius:4px;font-size:11px;margin-bottom:11px;display:none;line-height:1.5;}
.cc-msg.show{display:block;}
.cc-msg.err{background:#fef2f2;border:1px solid #fecaca;color:#991b1b;}
.cc-msg.ok{background:#f0fdf4;border:1px solid #bbf7d0;color:#166534;}
.cc-msg.warn{background:#fffbeb;border:1px solid #fde68a;color:#92400e;}

.cc-loader{display:none;align-items:center;gap:8px;font-size:11px;color:#64748b;padding:16px 0;}
.cc-loader.show{display:flex;}
.cc-spin{width:14px;height:14px;border:2px solid #e0e5ed;border-top-color:#174DA4;border-radius:50%;animation:ccspin .7s linear infinite;}
@keyframes ccspin{to{transform:rotate(360deg);}}

.cc-confirm{border:1px solid #fde68a;background:#fffbeb;padding:12px;border-radius:4px;}
.cc-confirm__h{font-weight:800;color:#92400e;margin-bottom:6px;font-size:12px;}
.cc-sum{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:8px;margin:10px 0;}
.cc-sum__i{background:#fff;border:1px solid #e0e5ed;padding:8px 10px;border-radius:4px;}
.cc-sum__l{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#64748b;font-weight:800;}
.cc-sum__v{font-size:12px;font-weight:700;color:#05275C;margin-top:2px;word-break:break-word;}

.cc-receipt{border:1px solid #bbf7d0;background:#f0fdf4;padding:14px;border-radius:4px;}
.cc-receipt__r{font-family:ui-monospace,Menlo,Consolas,monospace;font-size:16px;font-weight:800;color:#166534;letter-spacing:-.01em;}
.cc-hide{display:none;}

@media (max-width:640px){
  .cc-wrap{padding:8px;}
  .cc-steps{gap:4px;}
  .cc-step{padding:5px 8px;font-size:9.5px;margin-right:0;}
  .cc-actions{flex-direction:column;align-items:stretch;}
  .cc-actions__r{width:100%;}
  .cc-btn{flex:1;justify-content:center;}
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="cc-wrap">

  <div class="cc-head">
    <div style="min-width:0;">
      <h1 class="cc-title">Course Records Correction Centre</h1>
      <p class="cc-sub">Move student registrations onto the right course code or the right semester, or consolidate two catalogue entries that are the same course. Every correction is previewed first, applied in one transaction, recorded record by record, and can be reversed later.</p>
    </div>
    <div class="cc-scope">
      <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
      <asp:Literal ID="litScope" runat="server" />
    </div>
  </div>

  <asp:HiddenField ID="hdnIsAdmin" runat="server" />

  <!-- operation chooser -->
  <div class="cc-ops" id="ccOps">
    <button type="button" class="cc-op on" data-op="COURSE_TRANSFER">
      <span class="cc-op__t">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
        Course Code Transfer</span>
      <span class="cc-op__d">The registration is on the wrong code — a spaced variant, or a code without its stream suffix. Moves students from one code to another.</span>
    </button>
    <button type="button" class="cc-op" data-op="TERM_TRANSFER">
      <span class="cc-op__t">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
        Registration Term Transfer</span>
      <span class="cc-op__d">The course was registered in the wrong academic year or semester. Moves registrations, and the marks attached to them, to the correct term.</span>
    </button>
    <button type="button" class="cc-op" data-op="REGISTRATION_REMOVAL">
      <span class="cc-op__t">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
        Registration Removal</span>
      <span class="cc-op__d">The student was never meant to be on the course &mdash; it is not on their curriculum, or it belongs to another specialisation. Removes the registration and everything recorded against it.</span>
    </button>
    <button type="button" class="cc-op" data-op="MARKS_RESET">
      <span class="cc-op__t">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7v6h6"></path><path d="M3.51 13a9 9 0 1 0 2.13-9.36L3 7"></path></svg>
        Marks Reset</span>
      <span class="cc-op__d">The mark is wrong or was never theirs. Erases coursework, exam, total, the published result and the transcript entry, and returns the record to Not Entered. The student stays on the course.</span>
    </button>
    <button type="button" class="cc-op" data-op="COURSE_MERGE" id="ccOpMerge">
      <span class="cc-op__t">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="18" cy="18" r="3"></circle><circle cx="6" cy="6" r="3"></circle><path d="M6 21V9a9 9 0 0 0 9 9"></path></svg>
        Course Code Merge</span>
      <span class="cc-op__d">Two catalogue entries are genuinely one course. Consolidates students, curriculum, timetables and settings, and archives the retired code. Administrators only.</span>
    </button>
  </div>

  <!-- stepper -->
  <div class="cc-steps" id="ccStepper">
    <div class="cc-step on" data-s="1"><span class="cc-step__n">1</span> What to correct</div>
    <div class="cc-step" data-s="2"><span class="cc-step__n">2</span> Scope</div>
    <div class="cc-step" data-s="3"><span class="cc-step__n">3</span> Preview</div>
    <div class="cc-step" data-s="4"><span class="cc-step__n">4</span> Confirm</div>
    <div class="cc-step" data-s="5"><span class="cc-step__n">5</span> Receipt</div>
  </div>

  <div class="cc-msg" id="ccMsg"></div>

  <!-- ══ STEP 1 ══ -->
  <div class="cc-card" id="ccS1">
    <h2 class="cc-card__h" id="ccS1h">Choose the codes</h2>
    <p class="cc-card__s" id="ccS1s">Pick the code the registrations are wrongly on, then the code they should be on. The number beside each code is how many registrations currently carry it — usually the larger one is the code to keep.</p>

    <div class="cc-grid">
      <div class="cc-f cc-pick" id="ccSrcWrap">
        <label>Move from — course code</label>
        <input type="text" id="ccSrc" placeholder="Type at least two characters" autocomplete="off" />
        <div class="cc-drop" id="ccSrcDrop"></div>
        <div class="cc-chosen" id="ccSrcInfo"></div>
      </div>
      <div class="cc-f cc-pick" id="ccTgtWrap">
        <label>Move to — course code</label>
        <input type="text" id="ccTgt" placeholder="Type at least two characters" autocomplete="off" />
        <div class="cc-drop" id="ccTgtDrop"></div>
        <div class="cc-chosen" id="ccTgtInfo"></div>
      </div>
    </div>

    <div class="cc-grid cc-hide" id="ccTermRow" style="margin-top:10px;">
      <div class="cc-f">
        <label>Move from — academic year</label>
        <select id="ccSrcYear"></select>
      </div>
      <div class="cc-f">
        <label>Move from — semester</label>
        <select id="ccSrcSem"><option value="">Any semester</option><option value="1">Semester 1</option><option value="2">Semester 2</option><option value="3">Semester 3</option></select>
      </div>
      <div class="cc-f">
        <label>Move to — academic year</label>
        <select id="ccTgtYear"></select>
      </div>
      <div class="cc-f">
        <label>Move to — semester</label>
        <select id="ccTgtSem"><option value="1">Semester 1</option><option value="2">Semester 2</option><option value="3">Semester 3</option></select>
      </div>
    </div>

    <div class="cc-f cc-hide" id="ccRemoveBasisWrap" style="margin-top:4px;">
      <label>What should not have been registered</label>
      <div class="cc-grid">
        <label class="cc-chk"><input type="radio" name="ccBasis" value="code" checked="checked" /><span><b>A named course</b><em>Everyone in scope registered on the course code you choose above.</em></span></label>
        <label class="cc-chk"><input type="radio" name="ccBasis" value="not_in_curriculum" /><span><b>Courses not on the student's curriculum</b><em>The course does not appear in their programme's curriculum at all &mdash; usually a registration made against the wrong programme.</em></span></label>
        <label class="cc-chk"><input type="radio" name="ccBasis" value="other_specialisation" /><span><b>Courses belonging to another specialisation</b><em>The course is only offered under a specialisation the student is not taking. Students with no specialisation recorded are matched by this too.</em></span></label>
      </div>
    </div>

    <div class="cc-sim" id="ccSim" style="display:none;">
      <div class="cc-sim__h">
        <span>Codes that look like duplicates of each other</span>
        <button type="button" class="cc-btn cc-btn--ghost" id="ccSimLoad" style="padding:4px 9px;font-size:10px;">Scan the catalogue</button>
      </div>
      <div class="cc-sim__l" id="ccSimList"><span style="font-size:10.5px;color:#94a3b8;">Scan to list codes that differ only by spacing, punctuation or case.</span></div>
    </div>

    <div class="cc-actions">
      <span style="font-size:10.5px;color:#94a3b8;">Nothing is changed until you confirm at step 4.</span>
      <div class="cc-actions__r"><button type="button" class="cc-btn" id="ccTo2">Continue to scope</button></div>
    </div>
  </div>

  <!-- ══ STEP 2 ══ -->
  <div class="cc-card cc-hide" id="ccS2">
    <h2 class="cc-card__h">Narrow who is affected</h2>
    <p class="cc-card__s">Leave a filter blank to include everything you are allowed to see. Your own faculty or department limit always applies, whatever is set here.</p>

    <div class="cc-grid">
      <div class="cc-f cc-pick">
        <label>Programme</label>
        <input type="text" id="ccProgQ" placeholder="Type to search all programmes" autocomplete="off" />
        <input type="hidden" id="ccProg" value="" />
        <div class="cc-drop" id="ccProgDrop"></div>
        <span class="hint" id="ccProgPick">All programmes in my scope</span>
      </div>
      <div class="cc-f cc-pick" id="ccSpecWrap">
        <label>Specialisation</label>
        <input type="text" id="ccSpecQ" placeholder="Choose a programme first" autocomplete="off" />
        <input type="hidden" id="ccSpec" value="" />
        <div class="cc-drop" id="ccSpecDrop"></div>
        <span class="hint" id="ccSpecPick">All specialisations</span>
      </div>
      <div class="cc-f cc-pick" id="ccFacWrap">
        <label>Faculty</label>
        <input type="text" id="ccFacQ" placeholder="Type to search faculties" autocomplete="off" />
        <input type="hidden" id="ccFac" value="" />
        <div class="cc-drop" id="ccFacDrop"></div>
        <span class="hint" id="ccFacPick">All faculties</span>
      </div>
      <div class="cc-f" id="ccYearWrap"><label>Academic year</label><select id="ccYear"><option value="">All years</option></select></div>
      <div class="cc-f" id="ccSemWrap"><label>Semester</label><select id="ccSem"><option value="">All semesters</option><option value="1">Semester 1</option><option value="2">Semester 2</option><option value="3">Semester 3</option></select></div>
      <div class="cc-f"><label>Mark stage</label><select id="ccStage"><option value="">Any stage</option></select></div>
      <div class="cc-f"><label>Registration type</label><select id="ccRtype"><option value="">Any type</option><option value="NORMAL">Normal</option><option value="RT">Retake</option></select></div>
    </div>

    <div class="cc-f" style="margin-top:10px;">
      <label>Specific students (optional)</label>
      <textarea id="ccStudents" rows="2" placeholder="e.g. MRU2027000002, 27/U/BAED/0001/K/DAY — separate with commas, spaces or new lines. Leave blank for everyone matching the filters above."></textarea>
      <span class="hint">Student numbers and entry numbers both work, and the two can be mixed in the same list. Use this to correct one student, or to re-run a correction for the few that were left alone.</span>
    </div>

    <div class="cc-f" id="ccPolicyWrap" style="margin-top:12px;">
      <label>When the student already holds the destination</label>
      <div class="cc-grid">
        <label class="cc-chk"><input type="radio" name="ccPolicy" value="resolve" checked="checked" /><span><b>Settle the duplicate — keep the better mark, remove the leftover</b><em>The higher mark ends up on the destination and the duplicate on the retired code is removed, so nothing is left behind. Where the destination has no mark it takes the source's. Where both are equal, the duplicate is simply removed.</em></span></label>
        <label class="cc-chk"><input type="radio" name="ccPolicy" value="leave" /><span><b>Leave duplicates alone and list them</b><em>Nothing is written for those students. Use this to see the conflicts first.</em></span></label>
      </div>
      <span class="hint">Either way both sides are recorded in full before anything changes, so the whole batch can be reversed &mdash; including a mark that was overwritten and a record that was removed.</span>
    </div>

    <div class="cc-grid" style="margin-top:10px;">
      <label class="cc-chk"><input type="checkbox" id="ccPub" checked="checked" /><span><b>Include records whose marks are published</b><em>Included by default, since a wrong course code needs correcting whether or not the mark has been published. The mark travels with the record and is not altered. Untick to correct only unpublished records.</em></span></label>
      <label class="cc-chk" id="ccResWrap"><input type="checkbox" id="ccRes" checked="checked" /><span><b>Carry results and transcript entries across</b><em>Keeps the mark attached to the corrected registration. Untick only if the results are being handled separately.</em></span></label>
      <label class="cc-chk" id="ccAllTermsWrap"><input type="checkbox" id="ccAllTerms" /><span><b>Also move related records from other terms</b><em>Use when the same wrong code appears in more than one term for the same student.</em></span></label>
      <label class="cc-chk cc-hide" id="ccRemMarkedWrap"><input type="checkbox" id="ccRemMarked" /><span><b>Also remove registrations that carry a mark</b><em>Off by default. A marked registration is left alone unless you tick this &mdash; and if you do, the result recorded against it is removed with it.</em></span></label>
      <label class="cc-chk cc-hide" id="ccResetPubWrap"><input type="checkbox" id="ccResetPub" checked="checked" /><span><b>Also erase the published result and transcript entry</b><em>On by default. Leaving a published result behind while the record reads Not Entered is the inconsistency this exists to remove &mdash; and the result would still count toward the CGPA.</em></span></label>
      <label class="cc-chk cc-hide" id="ccResetCompWrap"><input type="checkbox" id="ccResetComp" checked="checked" /><span><b>Also erase the captured coursework and practical components</b><em>On by default. The assignment and test marks the total was built from, so a re-entry starts from a clean sheet.</em></span></label>
    </div>

    <div class="cc-actions">
      <button type="button" class="cc-btn cc-btn--ghost" id="ccBack1">Back</button>
      <div class="cc-actions__r"><button type="button" class="cc-btn" id="ccTo3">Preview the effect</button></div>
    </div>
  </div>

  <!-- ══ STEP 3 ══ -->
  <div class="cc-card cc-hide" id="ccS3">
    <h2 class="cc-card__h">What this correction would do</h2>
    <p class="cc-card__s">Every registration matching your selection, with the decision the system reached for each one. Nothing has been changed yet.</p>

    <div class="cc-loader" id="ccLoad3"><span class="cc-spin"></span> Working out what would be affected…</div>

    <div id="ccPvBody" class="cc-hide">
      <div class="cc-kpis">
        <div class="cc-kpi"><div class="cc-kpi__l">Records examined</div><div class="cc-kpi__v" id="kScan">0</div></div>
        <div class="cc-kpi cc-kpi--go"><div class="cc-kpi__l">Will be acted on</div><div class="cc-kpi__v" id="kGo">0</div></div>
        <div class="cc-kpi cc-kpi--skip"><div class="cc-kpi__l">Left alone</div><div class="cc-kpi__v" id="kSkip">0</div></div>
        <div class="cc-kpi"><div class="cc-kpi__l">Students</div><div class="cc-kpi__v" id="kStu">0</div></div>
        <div class="cc-kpi"><div class="cc-kpi__l">Related records</div><div class="cc-kpi__v" id="kSat">0</div></div>
      </div>
      <div class="cc-verd" id="ccVerd"></div>
      <div class="cc-msg warn" id="ccCu"></div>
      <div class="cc-hide" id="ccCgpaWrap">
        <h3 class="cc-card__h" style="margin-top:4px;">What this does to each student's CGPA</h3>
        <p class="cc-card__s">CGPA is not a stored figure &mdash; it is worked out from the published results each time it is asked for. Erasing a result therefore moves it on its own; this is what it becomes.</p>
        <div class="cc-tblwrap" style="margin-bottom:11px;">
          <table class="cc-tbl" style="min-width:520px;">
            <thead><tr><th>Student</th><th>Courses</th><th>Results erased</th><th>CGPA now</th><th>CGPA after</th><th>Change</th></tr></thead>
            <tbody id="ccCgpaRows"></tbody>
          </table>
        </div>
      </div>
      <div class="cc-confirm cc-hide" id="ccCuPick" style="margin-bottom:11px;">
        <div class="cc-confirm__h">Which credit-unit value should the merged course keep?</div>
        <div class="cc-grid">
          <label class="cc-chk"><input type="radio" name="ccCuW" value="target" /><span><b id="ccCuT">Keep the surviving code's value</b><em>Nothing changes for students already on it.</em></span></label>
          <label class="cc-chk"><input type="radio" name="ccCuW" value="source" /><span><b id="ccCuS">Take the retiring code's value</b><em>The surviving course is updated, which changes every GPA computed from it.</em></span></label>
        </div>
      </div>
      <div class="cc-tblwrap">
        <table class="cc-tbl">
          <thead><tr><th>Student</th><th>Programme</th><th>Course</th><th>Term</th><th>Status</th><th>Stage</th><th>Mark</th><th>Decision</th></tr></thead>
          <tbody id="ccRows"></tbody>
        </table>
      </div>
      <p style="font-size:10px;color:#94a3b8;margin:7px 0 0;" id="ccRowNote"></p>
    </div>

    <div class="cc-actions">
      <button type="button" class="cc-btn cc-btn--ghost" id="ccBack2">Back</button>
      <div class="cc-actions__r"><button type="button" class="cc-btn" id="ccTo4" disabled="disabled">Continue to confirm</button></div>
    </div>
  </div>

  <!-- ══ STEP 4 ══ -->
  <div class="cc-card cc-hide" id="ccS4">
    <h2 class="cc-card__h">Confirm the correction</h2>
    <p class="cc-card__s">This writes to student records. It is recorded against your name and can be reversed from the Correction Register afterwards.</p>

    <div class="cc-sum" id="ccSum"></div>

    <div class="cc-f" style="margin-bottom:10px;">
      <label>Why is this correction being made? (required)</label>
      <textarea id="ccReason" rows="2" placeholder="For example: registrations were captured against the spaced variant of the code during the 2024 migration."></textarea>
      <span class="hint">Stored with the batch so anyone reviewing it later knows why.</span>
    </div>

    <div class="cc-confirm">
      <div class="cc-confirm__h">Type the code you are moving away from to confirm</div>
      <div class="cc-f"><input type="text" id="ccTypeIt" placeholder="Type it exactly" autocomplete="off" /></div>
    </div>

    <div class="cc-actions">
      <button type="button" class="cc-btn cc-btn--ghost" id="ccBack3">Back</button>
      <div class="cc-actions__r">
        <button type="button" class="cc-btn cc-btn--go" id="ccApply" disabled="disabled">Apply the correction</button>
      </div>
    </div>
    <div class="cc-loader" id="ccLoad4"><span class="cc-spin"></span> Applying — this runs in one transaction and will not stop halfway…</div>
  </div>

  <!-- ══ STEP 5 ══ -->
  <div class="cc-card cc-hide" id="ccS5">
    <h2 class="cc-card__h">Correction applied</h2>
    <div class="cc-receipt">
      <div class="cc-receipt__r" id="ccRef">—</div>
      <p style="margin:6px 0 0;font-size:11.5px;color:#166534;" id="ccDone"></p>
      <div class="cc-sum" id="ccRSum"></div>
    </div>
    <div class="cc-actions">
      <a class="cc-btn cc-btn--ghost" href="CourseCorrectionRegister.aspx">Open the Correction Register</a>
      <div class="cc-actions__r"><button type="button" class="cc-btn" id="ccAgain">Make another correction</button></div>
    </div>
  </div>

</div>

<script type="text/javascript">
(function(){
'use strict';
var OP='COURSE_TRANSFER', OPTS=null, PV=null, STEP=1;
var srcSel=null, tgtSel=null, IS_ADMIN=false, BUSY=false, progCombo=null, facCombo=null, specCombo=null;

function q(id){ return document.getElementById(id); }
function esc(s){ return s==null?'':String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function n(v){ return (Number(v)||0).toLocaleString('en-US'); }
function show(el,on){ if(el) el.className = el.className.replace(/\s*cc-hide/,'') + (on?'':' cc-hide'); }

function ajax(method,params,cb){
    var x=new XMLHttpRequest();
    x.open('POST','CourseCorrectionCentre.aspx/'+method,true);
    x.setRequestHeader('Content-Type','application/json; charset=utf-8');
    x.timeout=600000;
    x.onload=function(){
        try{ var o=JSON.parse(x.responseText); cb(typeof o.d==='string'?JSON.parse(o.d):o.d); }
        catch(e){
            // A sign-in redirect comes back as HTML, not JSON — the usual cause here.
            var looksLikeLogin = /login|sign in|<!DOCTYPE/i.test(x.responseText||'');
            cb({success:false, message: looksLikeLogin
                ? 'Your session has expired. Open the page again and sign in — nothing was changed.'
                : 'The server did not return valid data. It may still be starting up — try again in a moment.'});
        }
    };
    x.onerror=function(){ cb({success:false,message:'Network error — the correction was not sent.'}); };
    x.ontimeout=function(){ cb({success:false,message:'That took too long. Narrow the selection and try again.'}); };
    x.send(JSON.stringify(params||{}));
}

function msg(t,kind){
    var m=q('ccMsg');
    if(!t){ m.className='cc-msg'; m.innerHTML=''; return; }
    m.className='cc-msg show '+(kind||'err'); m.innerHTML=esc(t);
    try{ m.scrollIntoView({behavior:'smooth',block:'nearest'}); }catch(e){}
}

function goStep(s){
    STEP=s; msg('');
    [1,2,3,4,5].forEach(function(i){ show(q('ccS'+i), i===s); });
    var st=q('ccStepper').getElementsByClassName('cc-step');
    for(var i=0;i<st.length;i++){
        var num=Number(st[i].getAttribute('data-s'));
        st[i].className='cc-step'+(num===s?' on':(num<s?' done':''));
    }
    try{ window.scrollTo({top:0,behavior:'smooth'}); }catch(e){ window.scrollTo(0,0); }
}

/* ---------- operation ---------- */
function setOp(op){
    OP=op;
    var b=q('ccOps').getElementsByClassName('cc-op');
    for(var i=0;i<b.length;i++) b[i].className='cc-op'+(b[i].getAttribute('data-op')===op?' on':'');
    var isTerm = op==='TERM_TRANSFER', isMerge = op==='COURSE_MERGE',
        isDel = op==='REGISTRATION_REMOVAL', isReset = op==='MARKS_RESET';
    var noTarget = isTerm||isDel||isReset;
    show(q('ccTermRow'), isTerm);
    show(q('ccRemoveBasisWrap'), isDel);
    q('ccSrcWrap').style.display = 'flex';
    q('ccTgtWrap').style.display = noTarget ? 'none' : 'flex';
    q('ccSim').style.display = (isMerge||op==='COURSE_TRANSFER') ? 'block' : 'none';
    q('ccYearWrap').style.display = isTerm ? 'none' : 'flex';
    q('ccSemWrap').style.display = isTerm ? 'none' : 'flex';
    q('ccAllTermsWrap').style.display = noTarget ? 'none' : 'flex';
    // conflict policy, result-carrying and mark handling only apply to the operation that needs them
    var pol=q('ccPolicyWrap'); if(pol) pol.style.display = (isDel||isReset) ? 'none' : 'flex';
    var rem=q('ccRemMarkedWrap'); if(rem) rem.style.display = isDel ? 'flex' : 'none';
    var res=q('ccResWrap'); if(res) res.style.display = (isDel||isReset) ? 'none' : 'flex';
    var rp=q('ccResetPubWrap'); if(rp) rp.style.display = isReset ? 'flex' : 'none';
    var rc=q('ccResetCompWrap'); if(rc) rc.style.display = isReset ? 'flex' : 'none';
    var pubw=q('ccPub'); if(pubw&&pubw.parentNode) pubw.parentNode.style.display = isReset ? 'none' : 'flex';

    if(isReset){
        q('ccS1h').textContent='Choose whose marks to erase';
        q('ccS1s').textContent='The student stays on the course; only the mark goes. Narrow it on the next step to a course, a programme or named students — a reset cannot be run across everything. You will see the effect on each CGPA before anything is written.';
        q('ccSrcWrap').getElementsByTagName('label')[0].textContent='Course code (optional — leave blank to reset across a programme or a student list)';
    }else if(isDel){
        q('ccS1h').textContent='Choose what to remove';
        q('ccS1s').textContent='Registrations that should never have been made. Nothing is deleted until you confirm, every removed record is stored first, and the whole batch can be put back from the Correction Register.';
        q('ccSrcWrap').getElementsByTagName('label')[0].textContent='Course code to remove';
        syncBasis();
    }else if(isTerm){
        q('ccS1h').textContent='Choose the term to correct';
        q('ccS1s').textContent='Pick the term the registrations are wrongly in, then the term they belong to. You may limit it to a single course code, or leave the code blank to move every course in that term.';
        q('ccSrcWrap').getElementsByTagName('label')[0].textContent='Limit to one course code (optional)';
    }else if(isMerge){
        q('ccS1h').textContent='Choose the codes to consolidate';
        q('ccS1s').textContent='The retiring code is merged into the surviving code across students, curriculum, timetables and settings. The retired entry is archived, never deleted.';
        q('ccSrcWrap').getElementsByTagName('label')[0].textContent='Retire this code';
        q('ccTgtWrap').getElementsByTagName('label')[0].textContent='Keep this code';
    }else{
        q('ccS1h').textContent='Choose the codes';
        q('ccS1s').textContent='Pick the code the registrations are wrongly on, then the code they should be on. The number beside each code is how many registrations currently carry it — usually the larger one is the code to keep.';
        q('ccSrcWrap').getElementsByTagName('label')[0].textContent='Move from — course code';
        q('ccTgtWrap').getElementsByTagName('label')[0].textContent='Move to — course code';
    }
    goStep(1);
}

/* ---------- searchable picker over a list already in the browser ----------
   Programmes (131) and faculties are loaded once, so filtering happens locally
   with no round trip. Keyboard: arrows to move, Enter to take, Escape to clear. */
function localCombo(qId, hiddenId, dropId, pickId, allLabel){
    var inp=q(qId), hid=q(hiddenId), drop=q(dropId), pick=q(pickId);
    var items=[], view=[], hl=-1;

    function close(){ drop.className='cc-drop'; hl=-1; }
    function setPick(it){
        hid.value = it ? it.value : '';
        inp.value = it ? it.text : '';
        pick.textContent = it ? ('Selected: '+it.text) : allLabel;
        pick.style.color = it ? '#174DA4' : '#94a3b8';
    }
    function render(){
        if(!view.length){ drop.innerHTML='<div class="cc-drop__i"><span class="cc-drop__n">Nothing matches.</span></div>'; drop.className='cc-drop show'; return; }
        var h='<div class="cc-drop__i" data-i="-1"><span class="cc-drop__n"><em>'+esc(allLabel)+'</em></span></div>';
        view.forEach(function(it,i){
            h+='<div class="cc-drop__i'+(i===hl?' hl':'')+'" data-i="'+i+'">'+
               '<span class="cc-drop__c">'+esc(it.value)+'</span>'+
               '<span class="cc-drop__n">'+esc(it.text)+'</span></div>';
        });
        drop.innerHTML=h; drop.className='cc-drop show';
        var els=drop.getElementsByClassName('cc-drop__i');
        for(var k=0;k<els.length;k++){
            els[k].addEventListener('mousedown',function(e){
                e.preventDefault();
                var i=Number(this.getAttribute('data-i'));
                setPick(i<0?null:view[i]); close();
            });
        }
    }
    function filter(){
        var v=inp.value.trim().toLowerCase();
        view = !v ? items.slice(0,60) : items.filter(function(it){
            return it.text.toLowerCase().indexOf(v)>=0 || it.value.toLowerCase().indexOf(v)>=0;
        }).slice(0,60);
        hl = view.length ? 0 : -1;
        render();
    }
    inp.addEventListener('input',function(){ hid.value=''; pick.textContent=allLabel; pick.style.color='#94a3b8'; filter(); });
    inp.addEventListener('focus',filter);
    inp.addEventListener('blur',function(){ setTimeout(function(){ close(); if(!hid.value) setPick(null); },160); });
    inp.addEventListener('keydown',function(e){
        if(e.keyCode===40){ hl=Math.min(hl+1,view.length-1); render(); e.preventDefault(); }
        else if(e.keyCode===38){ hl=Math.max(hl-1,0); render(); e.preventDefault(); }
        else if(e.keyCode===13){ if(hl>=0&&view[hl]) setPick(view[hl]); close(); e.preventDefault(); }
        else if(e.keyCode===27){ setPick(null); close(); }
    });

    return { load:function(list){ items=list||[]; setPick(null); }, clear:function(){ setPick(null); } };
}

/* ---------- code picker ---------- */
function picker(inputId, dropId, infoId, onPick){
    var inp=q(inputId), drop=q(dropId), info=q(infoId), timer=null, items=[];
    function close(){ drop.className='cc-drop'; }
    function render(list){
        items=list||[];
        if(!items.length){ drop.innerHTML='<div class="cc-drop__i"><span class="cc-drop__n">No matching course code.</span></div>'; drop.className='cc-drop show'; return; }
        var h='';
        items.forEach(function(it,i){
            h+='<div class="cc-drop__i" data-i="'+i+'"><span class="cc-drop__c">'+esc(it.code)+'</span>'+
               '<span class="cc-drop__n">'+esc(it.name||'(no title)')+'</span>'+
               '<span class="cc-drop__r">'+n(it.regs)+' regs &middot; '+(Number(it.cu)||0)+' CU'+(it.state&&it.state!=='ACTIVE'?' &middot; '+esc(it.state):'')+'</span></div>';
        });
        drop.innerHTML=h; drop.className='cc-drop show';
        var els=drop.getElementsByClassName('cc-drop__i');
        for(var k=0;k<els.length;k++){
            els[k].addEventListener('click',function(){
                var it=items[Number(this.getAttribute('data-i'))];
                if(!it) return;
                inp.value=it.code;
                info.innerHTML=esc(it.name||'(no title)')+' <span>&middot; '+(Number(it.cu)||0)+' CU &middot; '+n(it.regs)+' registrations</span>';
                onPick(it); close();
            });
        }
    }
    inp.addEventListener('input',function(){
        onPick(null); info.innerHTML='';
        var v=inp.value.trim();
        if(timer) clearTimeout(timer);
        if(v.length<2){ close(); return; }
        timer=setTimeout(function(){ ajax('SearchCourses',{term:v},function(r){ if(r&&r.success) render(r.items); else close(); }); },220);
    });
    inp.addEventListener('blur',function(){ setTimeout(close,180); });
    inp.addEventListener('focus',function(){ if(inp.value.trim().length>=2 && items.length) drop.className='cc-drop show'; });
}

/* ---------- config ---------- */
function cfg(){
    return {
        operation: OP,
        sourceCode: q('ccSrc').value.trim(),
        targetCode: OP==='TERM_TRANSFER' ? '' : q('ccTgt').value.trim(),
        sourceYear: OP==='TERM_TRANSFER' ? q('ccSrcYear').value : q('ccYear').value,
        sourceSemester: OP==='TERM_TRANSFER' ? q('ccSrcSem').value : q('ccSem').value,
        targetYear: OP==='TERM_TRANSFER' ? q('ccTgtYear').value : '',
        targetSemester: OP==='TERM_TRANSFER' ? q('ccTgtSem').value : '',
        programme: q('ccProg').value,
        specialisation: q('ccSpec').value,
        faculty: q('ccFac') ? q('ccFac').value : '',
        department: '',
        removalBasis: basis(),
        removeMarked: q('ccRemMarked') ? q('ccRemMarked').checked : false,
        resetPublished: q('ccResetPub') ? q('ccResetPub').checked : true,
        resetComponents: q('ccResetComp') ? q('ccResetComp').checked : true,
        studyYear: '',
        markStage: q('ccStage').value,
        registrationType: q('ccRtype').value,
        courseStatus: '',
        students: q('ccStudents').value,
        includePublished: q('ccPub').checked,
        moveResults: q('ccRes').checked,
        allTerms: q('ccAllTerms').checked,
        creditUnitWinner: cuWinner(),
        conflictPolicy: policy(),
        reason: q('ccReason').value.trim()
    };
}

function policy(){
    var r=document.getElementsByName('ccPolicy');
    for(var i=0;i<r.length;i++) if(r[i].checked) return r[i].value;
    return 'resolve';
}

function basis(){
    var r=document.getElementsByName('ccBasis');
    for(var i=0;i<r.length;i++) if(r[i].checked) return r[i].value;
    return 'code';
}

/* A course code is only needed when removing one named course. */
function syncBasis(){
    if(OP!=='REGISTRATION_REMOVAL') return;
    var byCode = basis()==='code';
    q('ccSrcWrap').style.display = byCode ? 'flex' : 'none';
    q('ccS1s').textContent = byCode
        ? 'Everyone in scope registered on the course code you choose. Nothing is deleted until you confirm, and the whole batch can be put back.'
        : 'The system finds the registrations itself, from the curriculum. Narrow the scope on the next step, preview what it found, and nothing is deleted until you confirm.';
}

/* Specialisations belong to a programme, so the list narrows as soon as one is chosen.
   With no programme picked the full list is offered, each labelled with its programme. */
function cascadeSpec(){
    if(!specCombo || !OPTS) return;
    var prog=q('ccProg').value;
    var all=OPTS.specialisations||[];
    var list=(prog ? all.filter(function(s){ return s.programme===prog; }) : all).map(function(s){
        return { value:s.value,
                 text:(prog?'':s.programme+' — ')+s.text+(s.abbrev?' ('+s.abbrev+')':'')+
                      (s.active?'':' [inactive]')+(s.students?' · '+s.students+' students':'') };
    });
    specCombo.load(list);
    var inp=q('ccSpecQ');
    inp.placeholder = list.length ? 'Type to search '+list.length+' specialisation'+(list.length===1?'':'s')
                                  : (prog ? 'This programme has no specialisations' : 'No specialisations available');
    inp.disabled = list.length===0;
}

function cuWinner(){
    var r=document.getElementsByName('ccCuW');
    for(var i=0;i<r.length;i++) if(r[i].checked) return r[i].value;
    return '';
}

/* ---------- preview ---------- */
function runPreview(){
    goStep(3);
    show(q('ccPvBody'),false); q('ccLoad3').className='cc-loader show';
    q('ccTo4').disabled=true; q('ccCu').className='cc-msg';
    ajax('Preview',{configJson:JSON.stringify(cfg())},function(r){
        q('ccLoad3').className='cc-loader';
        if(!r||!r.success){ msg((r&&r.message)||'Preview failed.'); return; }
        PV=r;
        q('kScan').textContent=n(r.scanned); q('kGo').textContent=n(r.actionable);
        q('kSkip').textContent=n(r.skipped); q('kStu').textContent=n(r.students);
        q('kSat').textContent=n(r.satelliteRows);

        var vh='';
        (r.verdictCounts||[]).forEach(function(v){
            vh+='<span class="cc-vd '+(v.verdict==='MOVED'?'go':'no')+'"><b>'+n(v.count)+'</b> &middot; '+esc(v.label)+'</span>';
        });
        q('ccVerd').innerHTML=vh;

        // Marks reset: show what each student's CGPA becomes before anything is written.
        var ci=r.cgpaImpact||[];
        show(q('ccCgpaWrap'), OP==='MARKS_RESET' && ci.length>0);
        if(OP==='MARKS_RESET' && ci.length){
            var ch='', lim=Math.min(ci.length,300);
            for(var k=0;k<lim;k++){
                var s=ci[k], d=Number(s.change)||0;
                ch+='<tr><td class="cc-mono">'+esc(s.regno)+'</td><td>'+n(s.courses)+'</td><td>'+n(s.resultsLost)+'</td>'+
                    '<td>'+(Number(s.cgpaBefore)||0).toFixed(2)+'</td><td>'+(Number(s.cgpaAfter)||0).toFixed(2)+'</td>'+
                    '<td style="color:'+(d<0?'#b42318':(d>0?'#166534':'#64748b'))+';font-weight:700;">'+
                    (d>0?'+':'')+d.toFixed(2)+'</td></tr>';
            }
            if(ci.length>lim) ch+='<tr><td colspan="6" style="color:#94a3b8;">…and '+n(ci.length-lim)+' more students.</td></tr>';
            q('ccCgpaRows').innerHTML=ch;
        }

        show(q('ccCuPick'), false);
        if(r.creditConflict){
            q('ccCu').className='cc-msg warn show';
            q('ccCu').innerHTML='These two codes carry different credit units — <b>'+r.sourceCredit+'</b> against <b>'+r.targetCredit+
                '</b>. Moving students changes the credit their mark counts for, and every GPA computed from it.';
            if(OP==='COURSE_MERGE'){
                q('ccCuT').textContent='Keep '+esc(cfg().targetCode)+"'s value — "+r.targetCredit+' CU';
                q('ccCuS').textContent='Take '+esc(cfg().sourceCode)+"'s value — "+r.sourceCredit+' CU';
                show(q('ccCuPick'), true);
            }
        }
        if(!r.targetExists && OP!=='TERM_TRANSFER'){
            q('ccCu').className='cc-msg warn show';
            q('ccCu').innerHTML='The destination code is not in the course catalogue. Add it first, otherwise the corrected registrations will have no course title or credit units.';
        }

        var rows=r.rows||[], h='', lim=Math.min(rows.length,400);
        for(var i=0;i<lim;i++){
            var x=rows[i], act=ACT[x.verdict]||{cls:'no',label:'Leave'};
            h+='<tr class="'+act.cls+'">'+
               '<td><span class="cc-mono">'+esc(x.regno)+'</span><span class="cc-nm">'+esc(x.studentName)+'</span></td>'+
               '<td>'+esc(x.progId)+'</td>'+
               '<td class="cc-mono">'+esc(x.courseCode)+'</td>'+
               '<td>'+esc(x.acadYear)+' &middot; S'+x.semester+'</td>'+
               '<td>'+esc(x.courseStatus)+'</td>'+
               '<td>'+esc((x.markStage||'').replace(/_/g,' '))+'</td>'+
               '<td>'+markCell(x)+'</td>'+
               '<td><span class="cc-badge '+act.cls+'">'+esc(act.label)+'</span>'+
                   '<span class="cc-nm">'+esc(verdictText(x.verdict))+'</span>'+
                   (x.note?'<span class="cc-nm">'+esc(x.note)+'</span>':'')+'</td></tr>';
        }
        q('ccRows').innerHTML = h || '<tr><td colspan="8" style="text-align:center;padding:26px;color:#94a3b8;">Nothing matches this selection.</td></tr>';
        q('ccRowNote').textContent = rows.length>lim ? ('Showing the first '+n(lim)+' of '+n(rows.length)+' records. All of them are included when the correction runs.') : '';
        show(q('ccPvBody'),true);
        q('ccTo4').disabled = !(r.actionable>0);

        // A number that matched nothing is named rather than quietly dropped.
        var notes=[];
        if(r.resolvedFromEntryNo>0) notes.push(n(r.resolvedFromEntryNo)+' of the numbers you gave were entry numbers and were matched to their students.');
        if(r.unmatchedStudents && r.unmatchedStudents.length){
            var u=r.unmatchedStudents;
            notes.push('No record was found for '+n(u.length)+' of the numbers given: '+
                       u.slice(0,12).join(', ')+(u.length>12?' and '+n(u.length-12)+' more':'')+
                       '. Check them — they are not part of this correction.');
        }
        if(r.actionable===0) notes.unshift('Nothing in this selection can be acted on. The decision against each record explains why.');
        if(notes.length) msg(notes.join('  '),'warn');
    });
}

/* how each verdict is drawn, and what it is called */
var ACT={
  'MOVED':              {cls:'go', label:'Move'},
  'WILL_REMOVE':        {cls:'go', label:'Remove'},
  'SKIPPED_HAS_MARKS':  {cls:'no', label:'Leave'},
  'WILL_RESET':         {cls:'go', label:'Erase marks'},
  'SKIPPED_NO_MARKS':   {cls:'no', label:'Leave'},
  'RESOLVED_OVERWRITE': {cls:'go', label:'Replace'},
  'RESOLVED_FILLED':    {cls:'go', label:'Fill'},
  'RESOLVED_DISCARD':   {cls:'go', label:'Remove duplicate'},
  'SKIPPED_DUPLICATE':  {cls:'no', label:'Leave'},
  'SKIPPED_RESULT_CLASH':{cls:'no',label:'Leave'},
  'SKIPPED_PUBLISHED':  {cls:'no', label:'Leave'},
  'SKIPPED_SAME_TARGET':{cls:'no', label:'Leave'},
  'SKIPPED_OUT_OF_SCOPE':{cls:'no',label:'Leave'}
};

function verdictText(v){
    var m={ 'SKIPPED_DUPLICATE':'Already holds the destination',
            'SKIPPED_RESULT_CLASH':'Already has a result on the destination code',
            'SKIPPED_PUBLISHED':'Marks are published',
            'SKIPPED_SAME_TARGET':'Already on the destination',
            'SKIPPED_OUT_OF_SCOPE':'Outside your scope',
            'MOVED':'',
            'WILL_REMOVE':'',
            'WILL_RESET':'',
            'SKIPPED_NO_MARKS':'No mark recorded',
            'SKIPPED_HAS_MARKS':'A mark is recorded against it',
            'RESOLVED_OVERWRITE':'Higher mark replaces the one on the destination',
            'RESOLVED_FILLED':'Destination has no mark — it takes this one',
            'RESOLVED_DISCARD':'Destination is already as good or better' };
    return m[v]!==undefined ? m[v] : v;
}

/* source mark, and the destination's when the two are being compared */
function markCell(x){
    var s = x.total==null ? '&mdash;' : x.total;
    if(!x.targetId) return s;
    var d = x.targetTotal==null ? 'no mark' : x.targetTotal;
    var win = (x.verdict==='RESOLVED_OVERWRITE'||x.verdict==='RESOLVED_FILLED');
    return '<b style="color:'+(win?'#166534':'#78716c')+'">'+s+'</b>'+
           '<span class="cc-nm">destination: '+d+(win?'':' (kept)')+'</span>';
}

/* ---------- confirm ---------- */
function buildSummary(){
    var c=cfg(), s='';
    function item(l,v){ s+='<div class="cc-sum__i"><div class="cc-sum__l">'+esc(l)+'</div><div class="cc-sum__v">'+esc(v)+'</div></div>'; }
    if(OP==='MARKS_RESET'){
        item('Erasing marks on', c.sourceCode || 'every course in the scope below');
        item('Published result & transcript', c.resetPublished?'Erased too':'Left in place');
        item('Coursework components', c.resetComponents?'Erased too':'Left in place');
        item('Published results affected', n(PV.publishedResults||0));
    }else if(OP==='REGISTRATION_REMOVAL'){
        item('Removing', c.removalBasis==='code' ? ('Registrations on '+c.sourceCode)
             : (c.removalBasis==='not_in_curriculum' ? 'Courses not on the student’s curriculum'
                                                     : 'Courses belonging to another specialisation'));
        item('Marked registrations', c.removeMarked?'Included — their results go too':'Left alone');
    }else if(OP==='TERM_TRANSFER'){
        item('Moving from', c.sourceYear+' · Semester '+(c.sourceSemester||'any'));
        item('Moving to', c.targetYear+' · Semester '+c.targetSemester);
        if(c.sourceCode) item('Limited to course', c.sourceCode);
    }else{
        item('Moving from', c.sourceCode);
        item('Moving to', c.targetCode);
    }
    if(c.programme) item('Programme', c.programme);
    if(c.specialisation) item('Specialisation', (q('ccSpecQ').value||c.specialisation));
    item(OP==='REGISTRATION_REMOVAL'?'Registrations to remove'
        :OP==='MARKS_RESET'?'Registrations to erase marks on'
        :'Registrations to change', n(PV.actionable));
    item('Students affected', n(PV.students));
    item('Related records carried', n(PV.satelliteRows));
    item('Left alone', n(PV.skipped));
    item('Published marks', c.includePublished?'Included':'Excluded');
    item('Acting as', PV.roleNote+' — '+PV.scopeLabel);
    q('ccSum').innerHTML=s;

    // Settling duplicates removes records and can replace a mark, so say so plainly here.
    var nOver=0, nFill=0, nDrop=0;
    (PV.rows||[]).forEach(function(x){
        if(x.verdict==='RESOLVED_OVERWRITE') nOver++;
        else if(x.verdict==='RESOLVED_FILLED') nFill++;
        else if(x.verdict==='RESOLVED_DISCARD') nDrop++;
    });
    var dup=nOver+nFill+nDrop;
    if(dup>0){
        msg(n(dup)+' duplicate registration(s) will be settled: '+
            n(nOver)+' where the higher mark replaces the one on the destination, '+
            n(nFill)+' where the destination has no mark yet, and '+n(nDrop)+
            ' removed because the destination is already as good. All '+n(dup)+
            ' duplicate records are deleted — every one is recorded first and the batch can be reversed.','warn');
    }

    var want = (OP==='MARKS_RESET') ? (c.sourceCode || 'ERASE')
             : (OP==='REGISTRATION_REMOVAL') ? (c.sourceCode || 'REMOVE')
             : (OP==='TERM_TRANSFER') ? (c.sourceCode||c.sourceYear)
             : c.sourceCode;
    q('ccTypeIt').setAttribute('data-want', want);
    q('ccTypeIt').setAttribute('placeholder','Type "'+want+'" exactly');
    q('ccTypeIt').value=''; q('ccApply').disabled=true;
}

function checkConfirm(){
    var want=(q('ccTypeIt').getAttribute('data-want')||'').toUpperCase();
    var got=q('ccTypeIt').value.trim().toUpperCase();
    var reasonOk=q('ccReason').value.trim().length>=5;
    q('ccApply').disabled = !(want && got===want && reasonOk);
}

function runApply(){
    if(BUSY) return;                     // a second click must not start a second batch
    BUSY=true;
    q('ccApply').disabled=true; q('ccBack3').disabled=true; q('ccLoad4').className='cc-loader show'; msg('');
    ajax('ApplyCorrection',{configJson:JSON.stringify(cfg()), checksum:PV.checksum},function(r){
        BUSY=false;
        q('ccLoad4').className='cc-loader'; q('ccBack3').disabled=false;
        if(!r||!r.success){ msg((r&&r.message)||'The correction did not run.'); q('ccApply').disabled=false; return; }
        q('ccRef').textContent=r.batchRef;
        q('ccDone').textContent=r.message;
        var s='';
        function item(l,v){ s+='<div class="cc-sum__i"><div class="cc-sum__l">'+esc(l)+'</div><div class="cc-sum__v">'+esc(v)+'</div></div>'; }
        item('Registrations moved', n(r.rowsApplied));
        item('Related records moved', n(r.satelliteRows));
        item('Students', n(r.students));
        item('Left alone', n(r.rowsSkipped));
        item('Still on the old code', n(r.residual));
        item('Tables written', r.tablesTouched||'—');
        item('Took', (r.durationMs/1000).toFixed(1)+' seconds');
        q('ccRSum').innerHTML=s;
        goStep(5);
        if(r.residual>0) msg(n(r.residual)+' record(s) still carry the old code for these students — usually rows outside the term you selected. Run the correction again without a term filter to catch them.','warn');
    });
}

/* ---------- similar codes ---------- */
function loadSimilar(){
    var box=q('ccSimList');
    box.innerHTML='<span style="font-size:10.5px;color:#94a3b8;">Scanning…</span>';
    ajax('FindSimilarCodes',{},function(r){
        if(!r||!r.success){ box.innerHTML='<span style="font-size:10.5px;color:#b42318;">'+esc((r&&r.message)||'Scan failed.')+'</span>'; return; }
        var g=r.groups||[];
        if(!g.length){ box.innerHTML='<span style="font-size:10.5px;color:#94a3b8;">No codes differ only by spacing or punctuation.</span>'; return; }
        var h='';
        g.forEach(function(x){
            for(var i=0;i<x.codes.length;i++)
                h+='<span class="cc-simg" data-code="'+esc(x.codes[i])+'" data-peer="'+esc(x.codes[0])+'"><b>'+esc(x.codes[i])+'</b> <i>'+n(x.counts[i])+'</i></span>';
        });
        box.innerHTML=h;
        var els=box.getElementsByClassName('cc-simg');
        for(var k=0;k<els.length;k++){
            els[k].addEventListener('click',function(){
                var code=this.getAttribute('data-code'), peer=this.getAttribute('data-peer');
                if(code===peer){ q('ccTgt').value=code; } else { q('ccSrc').value=code; q('ccTgt').value=peer; }
                msg('Loaded '+q('ccSrc').value+' → '+q('ccTgt').value+'. Check the two are really the same course before continuing.','warn');
            });
        }
    });
}

/* ---------- boot ---------- */
function fill(sel,items,all){
    var el=q(sel); if(!el) return;
    var h = all!=null ? '<option value="">'+esc(all)+'</option>' : '';
    (items||[]).forEach(function(i){ h+='<option value="'+esc(i.value)+'">'+esc(i.text)+'</option>'; });
    el.innerHTML=h;
}

function boot(){
    // built before the options arrive, so the callback can just load them
    progCombo = localCombo('ccProgQ','ccProg','ccProgDrop','ccProgPick','All programmes in my scope');
    facCombo  = localCombo('ccFacQ','ccFac','ccFacDrop','ccFacPick','All faculties');
    specCombo = localCombo('ccSpecQ','ccSpec','ccSpecDrop','ccSpecPick','All specialisations');

    // Picking a programme narrows the specialisation list; clearing it widens it again.
    q('ccProgQ').addEventListener('change',cascadeSpec);
    q('ccProgQ').addEventListener('blur',function(){ setTimeout(cascadeSpec,200); });
    var bs=document.getElementsByName('ccBasis');
    for(var b=0;b<bs.length;b++) bs[b].addEventListener('change',syncBasis);

    ajax('GetOptions',{},function(r){
        if(!r||!r.success){ msg((r&&r.message)||'Could not load the filters.'); return; }
        if(!r.hasAccess){ msg('You do not have a marks-management scope, so no correction can be made. Contact the administrator.'); return; }
        OPTS=r;
        IS_ADMIN=!!r.isAdmin;
        fill('ccYear', r.years, 'All years');
        fill('ccStage', r.stages, 'Any stage');
        fill('ccSrcYear', r.years, null);
        fill('ccTgtYear', r.years, null);
        progCombo.load(r.programmes);
        cascadeSpec();
        if(r.faculties && r.faculties.length) facCombo.load(r.faculties);
        else q('ccFacWrap').style.display='none';
        if(!r.isAdmin){ var m=q('ccOpMerge'); m.disabled=true; m.title='Course Code Merge is restricted to administrators.'; }
    });

    picker('ccSrc','ccSrcDrop','ccSrcInfo',function(it){ srcSel=it; });
    picker('ccTgt','ccTgtDrop','ccTgtInfo',function(it){ tgtSel=it; });

    var ops=q('ccOps').getElementsByClassName('cc-op');
    for(var i=0;i<ops.length;i++) ops[i].addEventListener('click',function(){ if(!this.disabled) setOp(this.getAttribute('data-op')); });

    q('ccTo2').addEventListener('click',function(){
        var c=cfg();
        if(OP==='MARKS_RESET'){ goStep(2); return; }   // scope is checked on the next step
        if(OP==='REGISTRATION_REMOVAL'){
            if(c.removalBasis==='code' && !c.sourceCode){ msg('Choose the course code to remove.'); return; }
            goStep(2); return;
        }
        if(OP==='TERM_TRANSFER'){
            if(!c.sourceYear||!c.targetYear){ msg('Choose both the term to move from and the term to move to.'); return; }
            if(c.sourceYear===c.targetYear && c.sourceSemester===c.targetSemester){ msg('The two terms are the same.'); return; }
        }else{
            if(!c.sourceCode||!c.targetCode){ msg('Choose both course codes.'); return; }
            if(c.sourceCode.toUpperCase()===c.targetCode.toUpperCase()){ msg('The two codes are the same.'); return; }
        }
        goStep(2);
    });
    q('ccBack1').addEventListener('click',function(){ goStep(1); });
    q('ccTo3').addEventListener('click',runPreview);
    q('ccBack2').addEventListener('click',function(){ goStep(2); });
    q('ccTo4').addEventListener('click',function(){
        if(OP==='COURSE_MERGE' && PV && PV.creditConflict && !cuWinner()){
            msg('Choose which credit-unit value the merged course should keep before continuing.'); return;
        }
        buildSummary(); goStep(4);
    });
    q('ccBack3').addEventListener('click',function(){ goStep(3); });
    q('ccTypeIt').addEventListener('input',checkConfirm);
    q('ccReason').addEventListener('input',checkConfirm);
    q('ccApply').addEventListener('click',runApply);
    q('ccSimLoad').addEventListener('click',loadSimilar);
    q('ccAgain').addEventListener('click',function(){
        q('ccSrc').value=''; q('ccTgt').value=''; q('ccStudents').value=''; q('ccReason').value='';
        q('ccSrcInfo').innerHTML=''; q('ccTgtInfo').innerHTML=''; PV=null; srcSel=null; tgtSel=null;
        if(progCombo) progCombo.clear();
        if(facCombo) facCombo.clear();
        var rb=document.getElementsByName('ccCuW'); for(var i=0;i<rb.length;i++) rb[i].checked=false;
        goStep(1);
    });
}

if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',boot); else boot();
})();
</script>
</asp:Content>
