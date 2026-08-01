/* Shared client for the staged-marks consoles (Capture / Approve / Publish).
   Page-agnostic: AJAX targets location.pathname so one file serves all three.
   The stage ACTION is a modal wizard (params → preview → commit). The page itself
   only browses the queue + funnel + session history (each session is click-to-view). */
(function () {
'use strict';
var STAGE = { canAct: false, name: '', fromLabel: '', toLabel: '' };
var PAGE = 1, REC = 0, FAILED_ONLY = false;

function qs(id) { return document.getElementById(id); }
function esc(s) { return s ? String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;') : ''; }
function nz(v) { return (v === null || v === undefined || v === '') ? '—' : v; }
function num(v) { return (v === null || v === undefined || v === '') ? '—' : Number(v).toLocaleString(); }
function toast(m, err) {
    var t = document.createElement('div'); t.textContent = m;
    t.style.cssText = 'position:fixed;top:18px;right:18px;z-index:11000;padding:10px 16px;font-size:13px;font-weight:600;color:#fff;border-radius:0;box-shadow:0 4px 16px rgba(0,0,0,.2);background:' + (err ? '#dc3545' : '#16a34a');
    document.body.appendChild(t); setTimeout(function () { t.style.transition = 'opacity .4s'; t.style.opacity = '0'; setTimeout(function () { t.remove(); }, 400); }, 2800);
}
function call(method, params, cb) {
    var x = new XMLHttpRequest();
    x.open('POST', location.pathname + '/' + method, true);
    x.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
    x.onload = function () { try { var o = JSON.parse(x.responseText); cb(typeof o.d === 'string' ? JSON.parse(o.d) : o.d); } catch (e) { cb({ success: false, message: 'Parse error' }); } };
    x.onerror = function () { cb({ success: false, message: 'Network error' }); };
    x.send(JSON.stringify(params || {}));
}
function show(m) { m.style.display = 'flex'; } function hide(m) { m.style.display = 'none'; }

function boot() {
    call('Init', {}, function (d) {
        if (!d || !d.success) { qs('sc-scope').textContent = (d && d.message) || 'Failed to initialise.'; return; }
        STAGE.canAct = d.canAct; STAGE.name = d.stage; STAGE.fromLabel = d.fromLabel; STAGE.toLabel = d.toLabel;
        qs('sc-scope').innerHTML = 'Scope: <strong>' + esc(d.scope.label) + '</strong>';
        var chip = qs('sc-role'); chip.textContent = d.scope.isAdmin ? 'Administrator' : (d.scope.role || 'Scoped');
        setText('sc-from-label', d.fromLabel); setText('sc-to-label', d.toLabel);
        var arr = document.querySelectorAll('.sc-to-label'); for (var i=0;i<arr.length;i++) arr[i].textContent = d.toLabel;
        fillSelect('sc-year', d.years, 'All years', true);
        fillSelect('sc-prog', d.programmes, 'All programmes', false);
        fillSelect('sc-p-prog', d.programmes, 'All programmes in my scope', false);
        fillSelect('sc-p-year', d.years, 'All years', true);   // wizard academic-year dropdown
        var launch = qs('sc-launch');
        if (!d.canAct && launch) { launch.disabled = true; var n = qs('sc-cantact'); if (n) n.style.display = 'inline-block'; }
        var adv = qs('sc-advance-btn');
        if (adv) { adv.innerHTML = '&#10003; ' + (VERB[d.stage] || 'Advance') + ' selected'; if (!d.canAct) adv.style.display = 'none'; }
        loadStats(); loadBrowse(1);
    });
}
function setText(id, v) { var e = qs(id); if (e) e.textContent = v; }
function fillSelect(id, items, allText, plain) {
    var el = qs(id); if (!el) return; var h = '<option value="">' + allText + '</option>';
    (items || []).forEach(function (it) { if (plain) h += '<option value="' + esc(it) + '">' + esc(it) + '</option>';
        else h += '<option value="' + esc(it.value) + '">' + esc(it.text) + '</option>'; });
    el.innerHTML = h;
}
function loadStats() {
    call('Stats', {}, function (d) { if (!d || !d.success) return;
        set('sc-not', d.notEntered); set('sc-entered', d.entered); set('sc-captured', d.captured);
        set('sc-approved', d.approved); set('sc-published', d.published); set('sc-actionable', d.actionable); });
}
function set(id, v) { var e = qs(id); if (e) e.textContent = (v || 0).toLocaleString(); }

function loadBrowse(p) {
    PAGE = p || 1;
    var b = qs('sc-body'); b.innerHTML = '<tr><td colspan="10" class="sc-empty">Loading…</td></tr>';
    call('Browse', { year: qs('sc-year').value, sem: qs('sc-sem').value, prog: qs('sc-prog').value, q: qs('sc-q').value, page: PAGE, pageSize: 50, failedOnly: FAILED_ONLY }, function (d) {
        if (!d || !d.success) { b.innerHTML = '<tr><td colspan="10" class="sc-empty" style="color:#b42318">' + esc((d && d.message) || 'Error') + '</td></tr>'; return; }
        if (!d.rows.length) { b.innerHTML = '<tr><td colspan="10" class="sc-empty">' + (FAILED_ONLY ? 'No failed (F) marks' : 'No marks') + ' at the ' + esc(STAGE.fromLabel) + ' stage in your scope.</td></tr>'; qs('sc-pager').textContent=''; return; }
        b.innerHTML = d.rows.map(function (r) {
            return '<tr' + (r.failed ? ' class="sc-row--f"' : '') + '>' +
                '<td><input type="checkbox" class="sc-chk" value="' + r.id + '"></td>' +
                '<td><span class="sc-code">' + esc(r.studentNo || r.regno) + '</span><div class="sc-sub">' + esc(r.name) + '</div></td>' +
                '<td>' + esc(r.course) + '<div class="sc-sub">' + esc(r.courseName) + '</div></td>' +
                '<td>' + (r.lecturer ? esc(r.lecturer) : '<span class="sc-sub" style="opacity:.6">— unassigned —</span>') + '</td>' +
                '<td>' + esc(r.progName) + '</td>' +
                '<td class="sc-c">' + esc(r.acadYear) + ' / S' + esc(r.semester) + '</td>' +
                '<td class="sc-c">' + nz(r.cw) + '</td>' + '<td class="sc-c">' + nz(r.exam) + '</td>' +
                '<td class="sc-c"><strong>' + nz(r.total) + '</strong></td>' +
                '<td class="sc-c">' + (r.grade ? ('<span class="sc-grade' + (r.failed ? ' sc-grade--f' : '') + '">' + esc(r.grade) + '</span>') : '—') + '</td>' +
            '</tr>'; }).join('');
        qs('sc-pager').innerHTML = pager(d.page, d.pages, d.total);
    });
}
function pager(p, pages, total) {
    return '<span class="sc-pginfo">' + total.toLocaleString() + ' mark(s) · page ' + p + ' / ' + pages + '</span><span style="margin-left:auto"></span>' +
        '<button type="button" class="sc-btn sc-btn--ghost" ' + (p <= 1 ? 'disabled' : '') + ' onclick="SC.go(' + (p - 1) + ')">&laquo; Prev</button>' +
        '<button type="button" class="sc-btn sc-btn--ghost" ' + (p >= pages ? 'disabled' : '') + ' onclick="SC.go(' + (p + 1) + ')">Next &raquo;</button>';
}

/* ── Wizard: params → preview → commit (all in a modal) ── */
function openWizard() {
    if (!STAGE.canAct) { toast('Your role cannot perform this stage.', true); return; }
    // reset to params step
    qs('sc-p-year').value = ''; qs('sc-p-sem').value = ''; qs('sc-p-yos').value = '';
    qs('sc-p-prog').value = ''; qs('sc-p-all').checked = false; qs('sc-p-notes').value = '';
    var ff = qs('sc-p-fail'); if (ff) ff.value = 'INCLUDE';
    qs('sc-wiz-params').style.display = ''; qs('sc-wiz-preview').style.display = 'none'; qs('sc-wiz-preview').innerHTML = '';
    qs('sc-btn-preview').style.display = ''; qs('sc-btn-back').style.display = 'none'; qs('sc-commit-btn').style.display = 'none';
    REC = 0; show(qs('sc-modal'));
}
function doPreview() {
    var pv = qs('sc-wiz-preview'); pv.innerHTML = 'Preparing preview…';
    qs('sc-wiz-params').style.display = 'none'; pv.style.display = '';
    qs('sc-btn-preview').style.display = 'none'; qs('sc-btn-back').style.display = '';
    call('CreateAndPreview', {
        prog: qs('sc-p-prog').value, yos: parseInt(qs('sc-p-yos').value || '0', 10),
        acadYear: qs('sc-p-year').value, sem: parseInt(qs('sc-p-sem').value || '0', 10),
        all: qs('sc-p-all').checked, notes: qs('sc-p-notes').value,
        failMode: (qs('sc-p-fail') && qs('sc-p-fail').value) ? qs('sc-p-fail').value : 'INCLUDE'
    }, function (d) {
        if (!d || !d.success || !d.preview || !d.preview.success) { pv.innerHTML = '<div style="color:#b42318">' + esc((d && (d.message || (d.preview && d.preview.message))) || 'Preview failed.') + '</div>'; return; }
        var p = d.preview, st = p.stats || {}; REC = p.recordId;
        if (!p.count) { pv.innerHTML = '<div class="sc-empty">No marks match these parameters at the ' + esc(STAGE.fromLabel) + ' stage.</div>'; qs('sc-commit-btn').style.display = 'none'; return; }
        pv.innerHTML = '<div class="sc-pv-hd">Move <b>' + p.count.toLocaleString() + '</b> mark(s): <b>' + esc(STAGE.fromLabel) + '</b> &rarr; <b>' + esc(STAGE.toLabel) + '</b></div>' +
            statsBlock(st) + breakdownTbl(p.breakdown);
        var cb = qs('sc-commit-btn'); cb.style.display = ''; cb.textContent = 'Commit ' + p.count.toLocaleString() + ' mark(s)';
    });
}
function wizBack() {
    if (REC) { call('Cancel', { recordId: REC }, function () {}); REC = 0; }
    qs('sc-wiz-preview').style.display = 'none'; qs('sc-wiz-params').style.display = '';
    qs('sc-btn-preview').style.display = ''; qs('sc-btn-back').style.display = 'none'; qs('sc-commit-btn').style.display = 'none';
}
function commit() {
    if (!REC) return;
    var cb = qs('sc-commit-btn'); cb.disabled = true; cb.textContent = 'Committing…';
    call('Commit', { recordId: REC }, function (d) {
        cb.disabled = false;
        if (!d || !d.success) { toast((d && d.message) || 'Commit failed.', true); cb.textContent = 'Retry commit'; return; }
        toast(d.affected + ' mark(s) advanced to ' + STAGE.toLabel + '.'); REC = 0;
        hide(qs('sc-modal')); loadStats(); loadBrowse(1);
    });
}
function closeWizard() { if (REC) { call('Cancel', { recordId: REC }, function () {}); REC = 0; } hide(qs('sc-modal')); }

function statsBlock(st) {
    return '<div class="sc-pv-stats">' + kpi('Marks', num(st.marks)) + kpi('Students', num(st.students)) +
        kpi('Programmes', num(st.programmes)) + kpi('Avg total', nz(st.avgTotal)) +
        kpi('Pass rate', (st.passRate || 0) + '%') + kpiFail('Fails (F)', num(st.fails)) +
        kpi('Distinctions', num(st.distinctions)) + '</div>';
}
function kpi(l, v) { return '<div class="sc-kpi"><div class="sc-kpi__v">' + v + '</div><div class="sc-kpi__l">' + l + '</div></div>'; }
function kpiFail(l, v) { return '<div class="sc-kpi sc-kpi--f"><div class="sc-kpi__v">' + v + '</div><div class="sc-kpi__l">' + l + '</div></div>'; }
function breakdownTbl(bd) {
    if (!bd || !bd.length) return '';
    var h = '<table class="sc-pv-tbl"><thead><tr><th>Programme</th><th>Year/Sem</th><th style="text-align:right">Marks</th><th style="text-align:right">Students</th><th style="text-align:right">Fails (F)</th></tr></thead><tbody>';
    bd.forEach(function (g) { h += '<tr><td>' + esc(g.prog_name) + '</td><td>' + esc(g.acad_year) + ' / S' + esc(g.semester) + '</td><td style="text-align:right">' + g.count + '</td><td style="text-align:right">' + g.students + '</td><td style="text-align:right' + ((g.fails||0) > 0 ? ';color:#b42318;font-weight:800' : '') + '">' + (g.fails || 0) + '</td></tr>'; });
    return h + '</tbody></table>';
}
function toggleFailed() {
    FAILED_ONLY = !FAILED_ONLY;
    var btn = qs('sc-failed-toggle');
    if (btn) { if (FAILED_ONLY) btn.classList.add('sc-btn--danger'); else btn.classList.remove('sc-btn--danger'); btn.innerHTML = FAILED_ONLY ? '&#10003; Showing failed (F) only' : '&#9873; Show failed (F) only'; }
    loadBrowse(1);
}

/* ── Advance selected (forward) ── */
var VERB = { CAPTURE: 'Capture', APPROVE: 'Approve', PUBLISH: 'Publish' };
function advanceSelected() {
    if (!STAGE.canAct) { toast('Your role cannot perform this stage.', true); return; }
    var ids = []; var ch = document.querySelectorAll('.sc-chk:checked'); for (var i=0;i<ch.length;i++) ids.push(parseInt(ch[i].value,10));
    if (!ids.length) { toast('Select one or more marks first.', true); return; }
    var verb = VERB[STAGE.name] || 'Advance';
    var extra = (STAGE.name === 'PUBLISH') ? ' and publish them to results' : '';
    if (!confirm(verb + ' ' + ids.length + ' selected mark(s)?\n\nThis moves them to "' + STAGE.toLabel + '"' + extra + '.')) return;
    var btn = qs('sc-advance-btn'); if (btn) btn.disabled = true;
    call('AdvanceSelected', { ids: ids, notes: '' }, function (d) {
        if (btn) btn.disabled = false;
        if (!d || !d.success) { toast((d && d.message) || 'Advance failed.', true); return; }
        toast(d.message); loadStats(); loadBrowse(PAGE);
    });
}

/* ── Send-back ── */
function returnSelected() {
    var ids = []; var ch = document.querySelectorAll('.sc-chk:checked'); for (var i=0;i<ch.length;i++) ids.push(parseInt(ch[i].value,10));
    if (!ids.length) { toast('Select one or more marks first.', true); return; }
    var reason = prompt('Reason for sending these ' + ids.length + ' mark(s) back one stage:');
    if (!reason) return;
    call('ReturnMarks', { ids: ids, reason: reason }, function (d) {
        if (!d || !d.success) { toast((d && d.message) || 'Return failed.', true); return; }
        toast(d.message); loadStats(); loadBrowse(PAGE);
    });
}

/* ── History (click a row to view full details) ── */
function loadHistory() {
    var b = qs('sc-hist-body'); b.innerHTML = '<tr><td colspan="7" class="sc-empty">Loading…</td></tr>';
    call('Records', { page: 1 }, function (d) {
        if (!d || !d.success) { b.innerHTML = '<tr><td colspan="7" class="sc-empty" style="color:#b42318">' + esc((d&&d.message)||'Error') + '</td></tr>'; return; }
        if (!d.records.length) { b.innerHTML = '<tr><td colspan="7" class="sc-empty">No sessions yet.</td></tr>'; return; }
        b.innerHTML = d.records.map(function (r) {
            var badge = r.isMigration ? '<span class="sc-pill sc-pill--mig">migration</span>' : '<span class="sc-pill sc-pill--' + (r.status === 'COMMITTED' ? 'ok' : (r.status === 'CANCELLED' ? 'no' : 'draft')) + '">' + esc(r.status) + '</span>';
            var scopeTxt = r.all ? 'All in scope' : [r.prog, r.acadYear, r.semester ? 'S' + r.semester : '', r.yearOfStudy ? 'Y' + r.yearOfStudy : ''].filter(Boolean).join(' · ');
            return '<tr class="sc-rowclick" onclick="SC.viewRec(' + r.id + ')">' +
                '<td>#' + r.id + '</td><td>' + badge + '</td><td>' + esc(r.byName || r.by) + '<div class="sc-sub">' + esc(r.role) + '</div></td>' +
                '<td>' + esc(scopeTxt || '—') + '</td><td class="sc-c">' + nz(r.affected) + '</td>' +
                '<td>' + esc(r.committedAt || r.createdAt) + '</td>' +
                '<td><span class="sc-link">View &rsaquo;</span></td></tr>';
        }).join('');
    });
}
function viewRec(id) {
    var body = qs('sc-detail-body'); body.innerHTML = 'Loading…'; show(qs('sc-detail'));
    call('RecordDetail', { recordId: id }, function (d) {
        if (!d || !d.success) { body.innerHTML = '<div style="color:#b42318">' + esc((d&&d.message)||'Error') + '</div>'; return; }
        var r = d.record, st = d.stats || {}, sm = d.summary || {};
        var meta = '<table class="sc-meta"><tbody>' +
            row('Session', '#' + r.id + (r.isMigration ? ' (migration)' : '')) +
            row('Stage', esc(r.fromLabel) + ' &rarr; ' + esc(r.toLabel)) +
            row('Status', esc(r.status)) +
            row('Performed by', esc(r.byName || r.by) + (r.role ? ' (' + esc(r.role) + ')' : '')) +
            row('Created', esc(r.createdAt)) + row('Committed', esc(r.committedAt || '—')) +
            row('Scope / params', esc(r.all ? 'Everything in scope' : ([r.prog, r.acadYear, r.semester ? 'S' + r.semester : '', r.yearOfStudy ? 'Y' + r.yearOfStudy : ''].filter(Boolean).join(' · ') || '—'))) +
            row('Marks affected', num(r.affected)) +
            (r.notes ? row('Notes', esc(r.notes)) : '') + '</tbody></table>';
        var snap = (st && st.marks) ? ('<div class="sc-det-h">Performance snapshot (at commit)</div>' + statsBlock(st)) : '';
        var bd = (sm && sm.breakdown) ? ('<div class="sc-det-h">Breakdown</div>' + breakdownTbl(sm.breakdown)) : '';
        body.innerHTML = meta + snap + bd;
        var csv = qs('sc-detail-csv');
        if (r.status === 'COMMITTED' && r.affected && !r.isMigration) { csv.style.display = ''; csv.href = location.pathname + '?export=csv&rid=' + r.id; }
        else csv.style.display = 'none';
    });
}
function row(k, v) { return '<tr><th>' + k + '</th><td>' + v + '</td></tr>'; }
function closeDetail() { hide(qs('sc-detail')); }

function tab(which) {
    qs('sc-view-queue').style.display = which === 'queue' ? '' : 'none';
    qs('sc-view-hist').style.display = which === 'hist' ? '' : 'none';
    qs('sc-tab-queue').className = 'sc-tab' + (which === 'queue' ? ' active' : '');
    qs('sc-tab-hist').className = 'sc-tab' + (which === 'hist' ? ' active' : '');
    if (which === 'hist') loadHistory();
}

window.SC = { go: loadBrowse, openWizard: openWizard, doPreview: doPreview, wizBack: wizBack, commit: commit,
    closeWizard: closeWizard, returnSelected: returnSelected, advanceSelected: advanceSelected, tab: tab, viewRec: viewRec, closeDetail: closeDetail, toggleFailed: toggleFailed,
    apply: function(){ loadBrowse(1); }, reset: function(){ qs('sc-year').value=''; qs('sc-sem').value=''; qs('sc-prog').value=''; qs('sc-q').value=''; FAILED_ONLY=false; var tb=qs('sc-failed-toggle'); if(tb){ tb.classList.remove('sc-btn--danger'); tb.innerHTML='&#9873; Show failed (F) only'; } loadBrowse(1); },
    selectAll: function(cb){ var ch=document.querySelectorAll('.sc-chk'); for(var i=0;i<ch.length;i++) ch[i].checked=cb.checked; } };

if (document.readyState !== 'loading') boot(); else document.addEventListener('DOMContentLoaded', boot);
})();
