<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="UserRolePermissions.aspx.cs" Inherits="COOPERP_NewScreens_UserRolePermissions" Title="Permissions - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--brand:#174DA4;--brand-dk:#05275C;--danger:#dc2626;--success:#16a34a;--warn:#b45309;--surf:#f5f7fa;--bdr:#e0e5ed;--txt:#1a1a2e;--muted:#64748b;}
.acc-tabs{display:flex;gap:2px;background:#fff;border-bottom:1px solid var(--bdr);padding:0 20px;overflow-x:auto;}
.acc-tab{padding:11px 16px;font-size:12px;font-weight:600;color:var(--muted);text-decoration:none;border-bottom:2px solid transparent;white-space:nowrap;}
.acc-tab:hover{color:var(--brand);}
.acc-tab--active{color:var(--brand-dk);border-bottom-color:var(--brand-dk);}

/* ── Header ──────────────────────────────────────────────────────────────────*/
.urm-header{background:#fff;border-bottom:1px solid var(--bdr);padding:20px 28px;display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;}
.urm-header__title{font-size:18px;font-weight:700;color:var(--txt);margin:0;}
.urm-header__sub{font-size:12px;color:var(--muted);margin:2px 0 0;}

/* ── Role info bar ────────────────────────────────────────────────────────── */
.role-info-bar{display:none;background:#eff6ff;border-bottom:2px solid var(--brand);padding:10px 28px;align-items:center;gap:12px;flex-wrap:wrap;}
.role-info-bar.visible{display:flex;}
.role-info-bar__dot{width:12px;height:12px;border-radius:50%;flex-shrink:0;}
.role-info-bar__name{font-size:13px;font-weight:700;color:var(--txt);}
.role-info-bar__code{font-family:monospace;font-size:10px;color:var(--muted);background:#fff;border:1px solid var(--bdr);padding:1px 6px;}
.role-info-bar__kv{font-size:11px;color:var(--muted);}
.role-info-bar__kv b{color:var(--txt);}
.role-info-bar__sep{width:1px;height:16px;background:var(--bdr);}

/* ── Progress bar ─────────────────────────────────────────────────────────── */
.perm-progress-wrap{display:none;background:#fff;border-bottom:1px solid var(--bdr);padding:8px 28px;align-items:center;gap:10px;}
.perm-progress-wrap.visible{display:flex;}
.perm-progress-track{flex:1;height:6px;background:#e0e5ed;border-radius:3px;overflow:hidden;max-width:260px;}
.perm-progress-bar{height:100%;background:var(--brand);border-radius:3px;transition:width .3s;}
.perm-progress-lbl{font-size:11px;color:var(--muted);}
.perm-progress-lbl b{color:var(--txt);}

/* ── Toolbar ─────────────────────────────────────────────────────────────── */
.urm-toolbar{background:var(--surf);border-bottom:1px solid var(--bdr);padding:12px 28px;display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
.urm-toolbar label{font-size:11px;font-weight:600;color:#374151;white-space:nowrap;}
.urm-toolbar select{height:34px;border:1px solid var(--bdr);background:#fff;font-size:12px;padding:0 10px;outline:none;min-width:220px;}
.urm-toolbar select:focus{border-color:var(--brand);}
.perm-search-wrap{position:relative;margin-left:auto;}
.perm-search-wrap input{height:34px;border:1px solid var(--bdr);background:#fff;font-size:12px;padding:0 10px 0 32px;outline:none;width:220px;box-sizing:border-box;}
.perm-search-wrap input:focus{border-color:var(--brand);}
.perm-search-ico{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:#94a3b8;pointer-events:none;}

/* ── Buttons ──────────────────────────────────────────────────────────────── */
.urm-btn{display:inline-flex;align-items:center;gap:4px;padding:6px 14px;font-size:11px;font-weight:600;border:none;cursor:pointer;border-radius:0;white-space:nowrap;}
.urm-btn--primary{background:var(--brand-dk);color:#fff;}
.urm-btn--primary:hover{background:var(--brand);}
.urm-btn--outline{background:#fff;color:#374151;border:1px solid var(--bdr);}
.urm-btn--outline:hover{background:var(--surf);}
.urm-btn--ghost{background:transparent;color:var(--brand);border:1px solid transparent;padding:5px 10px;}
.urm-btn--ghost:hover{background:#eff6ff;}
.urm-btn:disabled{opacity:.5;cursor:not-allowed;}

/* ── Matrix table ────────────────────────────────────────────────────────── */
.perm-wrap{overflow-x:auto;}
table.perm-table{width:100%;border-collapse:collapse;font-size:11px;}
.perm-table th{background:var(--surf);color:#374151;font-weight:600;padding:9px 14px;text-align:left;border-bottom:2px solid var(--bdr);white-space:nowrap;position:sticky;top:0;z-index:2;}
.perm-table th.center{text-align:center;}
.perm-table td{padding:8px 14px;border-bottom:1px solid #f1f5f9;color:#374151;vertical-align:middle;}
.perm-table tr.section-header td{background:var(--brand-dk);color:#fff;font-weight:700;font-size:10px;letter-spacing:.5px;text-transform:uppercase;padding:6px 14px;}
.perm-table tr.section-header:hover td{background:var(--brand);}
.perm-table tr.group-header td{background:#eef2ff;color:#374151;font-weight:600;font-size:11px;padding:5px 22px;border-bottom:1px solid var(--bdr);}
.perm-table tr.group-header:hover td{background:#e0e7ff;}
.perm-table tr.perm-leaf:hover td{background:#f8fafc;}
.perm-table tr.perm-hidden{display:none;}
.perm-item-name{padding-left:32px!important;}
.perm-slug{font-family:monospace;font-size:10px;color:#94a3b8;display:block;margin-top:2px;}
.perm-check-cell{text-align:center;}
.perm-check{width:15px;height:15px;cursor:pointer;accent-color:var(--brand);}
.perm-check:disabled{opacity:.3;cursor:not-allowed;}

/* section header inner layout */
.section-hd{display:flex;align-items:center;justify-content:space-between;gap:10px;}
.section-hd__label{flex:1;}
.section-hd__chk{cursor:pointer;width:14px;height:14px;accent-color:#fff;opacity:.8;flex-shrink:0;}

/* ── Status/save bar ────────────────────────────────────────────────────────*/
.perm-statusbar{position:sticky;bottom:0;background:#fff;border-top:1px solid var(--bdr);padding:12px 28px;display:flex;align-items:center;gap:12px;z-index:10;box-shadow:0 -2px 8px rgba(0,0,0,.06);}
.perm-dirty-msg{font-size:11px;color:var(--warn);display:none;}
.perm-dirty-msg.visible{display:inline;}

/* ── Toast ───────────────────────────────────────────────────────────────── */
.pa-toast{display:none;position:fixed;bottom:70px;right:24px;z-index:3000;background:#fff;border:1px solid var(--bdr);border-left:4px solid var(--success);padding:12px 18px;font-size:12px;box-shadow:0 4px 18px rgba(0,0,0,.12);max-width:320px;border-radius:2px;}
.pa-toast.visible{display:block;}
.pa-toast--err{border-left-color:var(--danger);}

/* ── Empty / placeholder ─────────────────────────────────────────────────── */
.perm-placeholder{padding:56px 28px;text-align:center;color:#94a3b8;font-size:13px;}
.perm-placeholder strong{color:var(--txt);}
.perm-no-match{text-align:center;padding:24px;color:#94a3b8;font-size:12px;font-style:italic;}

/* ── Role pill selector (A5) ─────────────────────────────────────────────── */
.perm-pillbar{background:#fff;border-bottom:1px solid var(--bdr);padding:14px 28px;}
.perm-pillbar__lbl{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:9px;display:block;}
.perm-pills{display:flex;flex-wrap:wrap;gap:8px;}
.perm-pill{display:inline-flex;align-items:center;gap:7px;padding:6px 13px;border:1px solid var(--bdr);background:#fff;border-radius:20px;font-size:12px;font-weight:600;color:var(--txt);cursor:pointer;transition:border-color .12s,background .12s,box-shadow .12s;}
.perm-pill:hover{border-color:var(--brand);background:#f5f8ff;}
.perm-pill.active{border-color:var(--brand-dk);background:var(--brand-dk);color:#fff;box-shadow:0 2px 10px rgba(5,39,92,.22);}
.perm-pill__dot{width:10px;height:10px;border-radius:50%;flex-shrink:0;}
.perm-pill.active .perm-pill__dot{box-shadow:0 0 0 2px rgba(255,255,255,.55);}
.perm-pill__count{font-size:10px;font-weight:600;opacity:.65;}
.perm-pill.active .perm-pill__count{opacity:.9;}

/* ── Section counts + collapse ───────────────────────────────────────────── */
.section-hd{cursor:pointer;}
.section-hd__caret{flex-shrink:0;transition:transform .15s;opacity:.85;}
.perm-table tr.section-header.collapsed .section-hd__caret{transform:rotate(-90deg);}
.section-hd__count{font-size:10px;font-weight:700;background:rgba(255,255,255,.22);padding:2px 9px;border-radius:10px;white-space:nowrap;}
.section-hd__count.full{background:var(--success);}
.section-hd__spacer{flex:1;}
.perm-table tr.is-collapsed{display:none!important;}
.group-hd__count{font-size:10px;color:var(--muted);font-weight:600;margin-left:8px;}

/* ── Toolbar grouping polish ─────────────────────────────────────────────── */
.urm-toolbar .tb-sep{width:1px;height:22px;background:var(--bdr);margin:0 2px;}
.urm-toolbar select.tb-aux{min-width:0;width:auto;max-width:170px;height:34px;border:1px solid var(--bdr);background:#fff;font-size:12px;padding:0 8px;}
@media(max-width:720px){
  .urm-header,.perm-pillbar,.role-info-bar,.perm-progress-wrap,.urm-toolbar,.perm-statusbar{padding-left:16px;padding-right:16px;}
  .perm-search-wrap{margin-left:0;width:100%;}
  .perm-search-wrap input{width:100%;}
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Access hub tabs -->
<div class="acc-tabs">
    <a href="AccessControlCenter.aspx" class="acc-tab">Overview</a>
    <a href="UserRoleUsers.aspx" class="acc-tab">Users</a>
    <a href="UserRoleRoles.aspx" class="acc-tab">Roles</a>
    <a href="UserRolePermissions.aspx" class="acc-tab acc-tab--active">Permissions</a>
    <a href="UserRoleAudit.aspx" class="acc-tab">Audit</a>
</div>

<!-- Header -->
<div class="urm-header">
    <div>
        <div class="urm-header__title">Permission Matrix</div>
        <div class="urm-header__sub">Configure which pages and features each role can access</div>
    </div>
    <a href="UserRoleRoles.aspx" class="urm-btn urm-btn--outline">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
        Back to Roles
    </a>
</div>

<!-- Role pill selector -->
<div class="perm-pillbar">
    <span class="perm-pillbar__lbl">Select a role to configure</span>
    <div class="perm-pills" id="rolePills"></div>
</div>

<!-- Role info bar (shown after loading) -->
<div class="role-info-bar" id="roleInfoBar">
    <div class="role-info-bar__dot" id="roleInfoDot"></div>
    <span class="role-info-bar__name" id="roleInfoName"></span>
    <span class="role-info-bar__code" id="roleInfoCode"></span>
    <span class="role-info-bar__sep"></span>
    <span class="role-info-bar__kv" id="roleInfoUsers"></span>
    <span class="role-info-bar__sep"></span>
    <span class="role-info-bar__kv" id="roleInfoPerms"></span>
</div>

<!-- Progress bar -->
<div class="perm-progress-wrap" id="permProgressWrap">
    <span class="perm-progress-lbl" id="permProgressLbl">0 / 0 granted</span>
    <div class="perm-progress-track">
        <div class="perm-progress-bar" id="permProgressBar" style="width:0%"></div>
    </div>
    <span class="perm-progress-lbl" id="permProgressPct" style="min-width:36px;text-align:right;"></span>
</div>

<!-- Toolbar -->
<div class="urm-toolbar" id="permToolbar" style="display:none;">
    <select id="ddlRole" onchange="loadMatrix()" style="display:none;">
        <option value="">— select a role —</option>
        <asp:Literal ID="litRoleOptions" runat="server"></asp:Literal>
    </select>

    <button type="button" class="urm-btn urm-btn--ghost" id="btnExpandToggle" onclick="toggleAllSections()" style="display:none;">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="7 13 12 18 17 13"/><polyline points="7 6 12 11 17 6"/></svg>
        <span id="expandToggleLbl">Collapse all</span>
    </button>
    <button type="button" class="urm-btn urm-btn--ghost" id="btnSelectAll" onclick="selectAllVisible()" style="display:none;">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
        Grant All
    </button>
    <button type="button" class="urm-btn urm-btn--ghost" id="btnClearAll" onclick="clearAllVisible()" style="display:none;" style="color:#dc2626;">
        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        Revoke All
    </button>

    <span class="tb-sep" id="tbSep1" style="display:none;"></span>
    <select id="ddlCopyFrom" class="tb-aux" onchange="copyFromRole(this.value)" title="Copy all grants from another role into this matrix (review, then Save)" style="display:none;">
        <option value="">Copy from role…</option>
    </select>
    <select id="ddlCompare" class="tb-aux" onchange="compareRole(this.value)" title="Highlight differences against another role" style="display:none;">
        <option value="">Compare with…</option>
    </select>

    <div class="perm-search-wrap">
        <svg class="perm-search-ico" xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" id="permSearch" placeholder="Filter menu items…"
               oninput="filterMatrix()" style="display:none;" />
    </div>
</div>

<style>
.perm-leaf.perm-diff-add td.perm-item-name{box-shadow:inset 3px 0 0 #16a34a;background:#f0fdf4;}
.perm-leaf.perm-diff-rem td.perm-item-name{box-shadow:inset 3px 0 0 #dc2626;background:#fef2f2;}
.perm-cmp-legend{display:none;align-items:center;gap:16px;margin:0 0 10px;padding:8px 14px;background:#f5f7fa;border:1px solid #e0e5ed;border-radius:4px;font-size:11px;color:#1a1a2e;}
.perm-cmp-legend.visible{display:flex;}
.perm-cmp-legend b{font-weight:600;}
.perm-cmp-swatch{display:inline-block;width:10px;height:10px;border-radius:2px;margin-right:5px;vertical-align:middle;}
</style>
<div class="perm-cmp-legend" id="cmpLegend">
    <span id="cmpLegendTitle"></span>
    <span><span class="perm-cmp-swatch" style="background:#16a34a;"></span>This role has it, <b id="cmpOther1"></b> doesn't</span>
    <span><span class="perm-cmp-swatch" style="background:#dc2626;"></span><b id="cmpOther2"></b> has it, this role doesn't</span>
    <a href="javascript:void(0)" onclick="compareRole('')" style="margin-left:auto;color:#174DA4;font-weight:600;text-decoration:none;">Clear comparison &times;</a>
</div>

<!-- Permission matrix -->
<div class="perm-wrap" id="matrixWrap">
    <div class="perm-placeholder" id="permPlaceholder">
        <svg xmlns="http://www.w3.org/2000/svg" width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="#cbd5e1" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom:12px;display:block;margin-left:auto;margin-right:auto;"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
        <div style="font-size:14px;font-weight:600;color:#475569;margin-bottom:4px;">Pick a role above to begin</div>
        Tick the pages and features that role may open, then <strong>Save Changes</strong>.<br>
        Use <strong>Copy from role</strong> to start from a template, or <strong>Compare</strong> to see the difference between two roles.
    </div>
    <table class="perm-table" id="permTable" style="display:none;">
        <thead>
            <tr>
                <th style="min-width:300px;">Menu Item / Page</th>
                <th class="center" style="width:90px;">Can Access</th>
            </tr>
        </thead>
        <tbody id="permBody"></tbody>
    </table>
    <div class="perm-no-match" id="noMatchMsg" style="display:none;">No menu items match your filter.</div>
</div>

<!-- Sticky save bar -->
<div class="perm-statusbar">
    <button type="button" class="urm-btn urm-btn--primary" id="btnSave" onclick="savePermissions()" disabled>
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
        Save Changes
    </button>
    <button type="button" class="urm-btn urm-btn--outline" id="btnDiscard" onclick="discardChanges()" style="display:none;">Discard</button>
    <span class="perm-dirty-msg" id="dirtyMsg">&#9888; You have unsaved changes</span>
</div>

<!-- Toast -->
<div class="pa-toast" id="paToast"></div>

<script type="text/javascript">
(function(){
var currentRoleId   = null;
var currentRoleName = '';
var currentRoleCode = '';
var currentRoleColor= '#174DA4';
var originalChecked = {};
var dirty           = false;
var _totalLeafs     = 0;
var _allCollapsed   = false;

// Role pills + URL pre-selection run from the init block at the very end of this
// IIFE, so every handler (loadMatrix, markActivePill, …) already exists.

// ── Load matrix ───────────────────────────────────────────────────────────────
window.loadMatrix = function(){
    var roleId = document.getElementById('ddlRole').value;
    if(!roleId){
        reset();
        return;
    }

    // Update URL without reload
    if(history.replaceState){
        history.replaceState(null,'','UserRolePermissions.aspx?role_id='+encodeURIComponent(roleId));
    }

    currentRoleId = roleId;
    markActivePill(roleId);

    // Get selected option meta
    var sel = document.getElementById('ddlRole');
    var opt = sel.options[sel.selectedIndex];
    currentRoleName  = opt.getAttribute('data-name')  || opt.text;
    currentRoleColor = opt.getAttribute('data-color')  || '#174DA4';
    currentRoleCode  = opt.getAttribute('data-code')   || '';

    dirty = false;
    updateDirty();
    document.getElementById('permSearch').value = '';

    fetch('UserRolePermissions.aspx?ajax=matrix&role_id=' + encodeURIComponent(roleId))
        .then(function(r){ return r.json(); })
        .then(function(d){
            if(!d.ok){ showToast(d.error||'Failed to load matrix.','err'); return; }
            renderMatrix(d.items, d.granted, d.is_admin, d.total, d.granted_count);
        })
        .catch(function(){ showToast('Network error.','err'); });
};

function reset(){
    currentRoleId = null;
    document.getElementById('permTable').style.display     = 'none';
    document.getElementById('permPlaceholder').style.display = 'block';
    document.getElementById('noMatchMsg').style.display    = 'none';
    document.getElementById('btnSave').disabled            = true;
    document.getElementById('btnDiscard').style.display   = 'none';
    document.getElementById('roleInfoBar').classList.remove('visible');
    document.getElementById('permProgressWrap').classList.remove('visible');
    document.getElementById('btnSelectAll').style.display = 'none';
    document.getElementById('btnClearAll').style.display  = 'none';
    document.getElementById('permSearch').style.display   = 'none';
    document.getElementById('ddlCopyFrom').style.display  = 'none';
    document.getElementById('ddlCompare').style.display   = 'none';
    document.getElementById('btnExpandToggle').style.display = 'none';
    document.getElementById('tbSep1').style.display       = 'none';
    document.getElementById('permToolbar').style.display  = 'none';
    clearCompareHighlights();
    markActivePill(null);
    if(history.replaceState) history.replaceState(null,'','UserRolePermissions.aspx');
}

// ── Render matrix ─────────────────────────────────────────────────────────────
function renderMatrix(items, granted, isAdmin, total, grantedCount){
    var body = document.getElementById('permBody');
    body.innerHTML = '';
    originalChecked = {};
    _totalLeafs = total;

    var sectionIdx   = -1;
    var sectionNodes = [];   // array of {tr, leafRows[]}
    var currentLeafs = [];

    for(var i=0;i<items.length;i++){
        var item = items[i];
        var tr = document.createElement('tr');

        if(item.type === 'section'){
            sectionIdx++;
            currentLeafs = [];
            tr.className = 'section-header';
            tr.setAttribute('data-section', sectionIdx);

            var inner = '<div class="section-hd" onclick="onSectionHeaderClick(event,'+sectionIdx+')" title="Click to expand / collapse">';
            inner += '<svg class="section-hd__caret" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>';
            inner += '<span class="section-hd__label">' + escHtml(item.label) + '</span>';
            inner += '<span class="section-hd__count" id="seccount_'+sectionIdx+'"></span>';
            inner += '<span class="section-hd__spacer"></span>';
            if(!isAdmin){
                inner += '<input type="checkbox" class="section-hd__chk perm-section-chk" '+
                         'data-section="'+sectionIdx+'" '+
                         'onclick="event.stopPropagation();toggleSection(this,'+sectionIdx+')" '+
                         'title="Grant / revoke this whole section" />';
            }
            inner += '</div>';
            tr.innerHTML = '<td colspan="2">'+inner+'</td>';
            body.appendChild(tr);

            sectionNodes.push({hdrChk: tr.querySelector('.perm-section-chk'), leafRows: currentLeafs});
            continue;
        }

        if(item.type === 'group'){
            tr.className = 'group-header';
            tr.setAttribute('data-section', sectionIdx);
            tr.innerHTML = '<td colspan="2" class="perm-item-name">' + escHtml(item.label) + '</td>';
            body.appendChild(tr);
            continue;
        }

        // Leaf
        var checked = isAdmin || (granted.indexOf(item.slug) >= 0);
        originalChecked[item.slug] = checked;

        tr.className = 'perm-leaf';
        tr.setAttribute('data-section', sectionIdx);
        tr.setAttribute('data-slug', item.slug);
        tr.setAttribute('data-label', (item.label||'').toLowerCase());

        var chkId = 'chk_' + item.slug.replace(/[^a-z0-9]/gi,'_');
        tr.innerHTML =
            '<td class="perm-item-name">' +
                escHtml(item.label) +
                '<span class="perm-slug">' + escHtml(item.slug) + '</span>' +
            '</td>' +
            '<td class="perm-check-cell">' +
                '<input type="checkbox" class="perm-check" id="'+chkId+'"' +
                ' data-slug="'+escHtml(item.slug)+'"' +
                (checked ? ' checked' : '') +
                (isAdmin ? ' disabled title="Admin role has wildcard access."' : '') +
                ' onchange="onLeafChange(this,'+sectionIdx+')" />' +
            '</td>';

        body.appendChild(tr);
        currentLeafs.push(tr);
    }

    // Sync section header checkboxes initial state
    if(!isAdmin){
        for(var s=0;s<sectionNodes.length;s++){
            syncSectionChk(s, sectionNodes[s].hdrChk, sectionNodes[s].leafRows);
        }
    }

    document.getElementById('permTable').style.display     = '';
    document.getElementById('permPlaceholder').style.display = 'none';
    document.getElementById('noMatchMsg').style.display    = 'none';
    document.getElementById('btnSelectAll').style.display  = isAdmin ? 'none' : '';
    document.getElementById('btnClearAll').style.display   = isAdmin ? 'none' : '';
    document.getElementById('permSearch').style.display    = '';
    document.getElementById('ddlCopyFrom').style.display   = isAdmin ? 'none' : '';
    document.getElementById('ddlCompare').style.display    = isAdmin ? 'none' : '';
    document.getElementById('permToolbar').style.display   = '';
    document.getElementById('btnExpandToggle').style.display = '';
    document.getElementById('tbSep1').style.display        = isAdmin ? 'none' : '';
    _allCollapsed = false;
    document.getElementById('expandToggleLbl').textContent = 'Collapse all';
    populateAuxRoleDropdowns();
    clearCompareHighlights();

    updateRoleInfoBar(isAdmin, grantedCount, total);
    updateProgress(isAdmin ? total : grantedCount, total);
    updateSectionCounts();
    dirty = false;
    updateDirty();
}

function syncSectionChk(sectionIdx, chkEl, leafRows){
    if(!chkEl || !leafRows || !leafRows.length) return;
    var enabled = leafRows.filter(function(r){ return !r.querySelector('.perm-check:disabled'); });
    if(!enabled.length){ if(chkEl) chkEl.style.display='none'; return; }
    var checked = enabled.filter(function(r){ return r.querySelector('.perm-check') && r.querySelector('.perm-check').checked; });
    chkEl.indeterminate = checked.length > 0 && checked.length < enabled.length;
    chkEl.checked = checked.length === enabled.length;
}

// ── Section toggle ────────────────────────────────────────────────────────────
window.toggleSection = function(chk, idx){
    var rows = document.querySelectorAll('#permBody tr.perm-leaf[data-section="'+idx+'"]');
    for(var i=0;i<rows.length;i++){
        var cb = rows[i].querySelector('.perm-check:not(:disabled)');
        if(cb) cb.checked = chk.checked;
    }
    dirty = true;
    updateDirty();
    updateProgressFromDOM();
};

window.onLeafChange = function(chk, sectionIdx){
    // sync the section header checkbox
    var rows = document.querySelectorAll('#permBody tr.perm-leaf[data-section="'+sectionIdx+'"]');
    var sHdr = document.querySelector('#permBody tr.section-header[data-section="'+sectionIdx+'"] .perm-section-chk');
    var leafArr = [];
    for(var i=0;i<rows.length;i++) leafArr.push(rows[i]);
    syncSectionChk(sectionIdx, sHdr, leafArr);
    dirty = true;
    updateDirty();
    updateProgressFromDOM();
};

// ── Grant All / Revoke All visible ────────────────────────────────────────────
window.selectAllVisible = function(){
    var checks = document.querySelectorAll('#permBody tr.perm-leaf:not(.perm-hidden) .perm-check:not(:disabled)');
    for(var i=0;i<checks.length;i++) checks[i].checked = true;
    syncAllSectionChks();
    dirty = true; updateDirty(); updateProgressFromDOM();
};

window.clearAllVisible = function(){
    var checks = document.querySelectorAll('#permBody tr.perm-leaf:not(.perm-hidden) .perm-check:not(:disabled)');
    for(var i=0;i<checks.length;i++) checks[i].checked = false;
    syncAllSectionChks();
    dirty = true; updateDirty(); updateProgressFromDOM();
};

function syncAllSectionChks(){
    var sections = document.querySelectorAll('#permBody tr.section-header');
    for(var s=0;s<sections.length;s++){
        var idx = sections[s].getAttribute('data-section');
        var rows= document.querySelectorAll('#permBody tr.perm-leaf[data-section="'+idx+'"]');
        var chk = sections[s].querySelector('.perm-section-chk');
        var arr=[]; for(var r=0;r<rows.length;r++) arr.push(rows[r]);
        syncSectionChk(idx, chk, arr);
    }
}

// ── Matrix search filter ──────────────────────────────────────────────────────
window.filterMatrix = function(){
    var q = (document.getElementById('permSearch').value||'').toLowerCase().trim();
    var leafRows = document.querySelectorAll('#permBody tr.perm-leaf');
    var sectionRows = document.querySelectorAll('#permBody tr.section-header, #permBody tr.group-header');
    var anyVisible = false;

    for(var i=0;i<leafRows.length;i++){
        var label = leafRows[i].getAttribute('data-label')||'';
        var slug  = leafRows[i].getAttribute('data-slug')||'';
        var show  = !q || label.indexOf(q)>=0 || slug.indexOf(q)>=0;
        leafRows[i].classList.toggle('perm-hidden', !show);
        if(show) anyVisible = true;
    }

    // Show/hide section + group headers based on whether their section has visible leaves
    var sections = document.querySelectorAll('#permBody tr.section-header');
    for(var s=0;s<sections.length;s++){
        var idx = sections[s].getAttribute('data-section');
        var hasVisible = document.querySelectorAll('#permBody tr.perm-leaf[data-section="'+idx+'"]:not(.perm-hidden)').length > 0;
        sections[s].classList.toggle('perm-hidden', !hasVisible && !!q);
    }
    var groups = document.querySelectorAll('#permBody tr.group-header');
    for(var g=0;g<groups.length;g++){
        var gIdx = groups[g].getAttribute('data-section');
        var gVisible = document.querySelectorAll('#permBody tr.perm-leaf[data-section="'+gIdx+'"]:not(.perm-hidden)').length > 0;
        groups[g].classList.toggle('perm-hidden', !gVisible && !!q);
    }

    document.getElementById('noMatchMsg').style.display = (!anyVisible && !!q) ? '' : 'none';
};

// ── Save permissions ───────────────────────────────────────────────────────────
window.savePermissions = function(){
    if(!currentRoleId || !dirty) return;

    var slugs = [];
    var checks = document.querySelectorAll('.perm-check:not(:disabled)');
    for(var i=0;i<checks.length;i++){
        if(checks[i].checked) slugs.push(checks[i].getAttribute('data-slug'));
    }

    // Change summary vs the loaded state (+added / −removed)
    var added = 0, removed = 0, nowSet = {};
    for(var a=0;a<slugs.length;a++){ nowSet[slugs[a]] = true; if(!originalChecked[slugs[a]]) added++; }
    for(var k in originalChecked){ if(originalChecked[k] && !nowSet[k]) removed++; }
    var summary = (added||removed) ? ' (+' + added + ' / −' + removed + ')' : '';

    var btn = document.getElementById('btnSave');
    btn.disabled = true;
    btn.textContent = 'Saving…';

    fetch('UserRolePermissions.aspx?ajax=save', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'role_id=' + encodeURIComponent(currentRoleId) +
              '&slugs='  + encodeURIComponent(slugs.join(','))
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
        btn.textContent = 'Save Changes';
        if(d.ok){
            dirty = false;
            updateDirty();
            showToast('Permissions saved — ' + slugs.length + ' access grant' + (slugs.length!==1?'s':'') + ' active' + summary + '.','ok');
            loadMatrix();
        } else {
            btn.disabled = false;
            showToast(d.error||'Failed to save.','err');
        }
    })
    .catch(function(){
        btn.disabled = false;
        btn.textContent = 'Save Changes';
        showToast('Network error.','err');
    });
};

// ── Discard ────────────────────────────────────────────────────────────────────
window.discardChanges = function(){
    dirty = false;
    loadMatrix();
};

// ── Dirty tracking ─────────────────────────────────────────────────────────────
window.markDirty = function(){
    dirty = true;
    updateDirty();
};

function updateDirty(){
    document.getElementById('btnSave').disabled             = !dirty || !currentRoleId;
    document.getElementById('btnDiscard').style.display    = dirty ? '' : 'none';
    var msg = document.getElementById('dirtyMsg');
    dirty ? msg.classList.add('visible') : msg.classList.remove('visible');
}

// ── Role info bar ──────────────────────────────────────────────────────────────
function updateRoleInfoBar(isAdmin, grantedCount, total){
    document.getElementById('roleInfoBar').classList.add('visible');
    document.getElementById('roleInfoDot').style.background = currentRoleColor;
    document.getElementById('roleInfoName').textContent = currentRoleName;
    document.getElementById('roleInfoCode').textContent = currentRoleCode;
    document.getElementById('roleInfoUsers').innerHTML  = 'Permissions: <b>' + (isAdmin ? 'All (wildcard)' : grantedCount + ' / ' + total) + '</b>';

    var sel = document.getElementById('ddlRole');
    var opt = sel.options[sel.selectedIndex];
    var userCount = opt.getAttribute('data-users') || '?';
    document.getElementById('roleInfoPerms').innerHTML = 'Users assigned: <b>' + userCount + '</b>';

    document.getElementById('permProgressWrap').classList.add('visible');
}

// ── Progress bar ───────────────────────────────────────────────────────────────
function updateProgress(granted, total){
    var pct = total > 0 ? Math.round(granted / total * 100) : 0;
    document.getElementById('permProgressBar').style.width = pct + '%';
    document.getElementById('permProgressLbl').innerHTML   = '<b>'+granted+'</b> / ' + total + ' granted';
    document.getElementById('permProgressPct').textContent = pct + '%';
}

function updateProgressFromDOM(){
    var checks  = document.querySelectorAll('.perm-check:not(:disabled)');
    var checked = 0;
    for(var i=0;i<checks.length;i++) if(checks[i].checked) checked++;
    updateProgress(checked, _totalLeafs);
    updateSectionCounts();
}

// ── Copy from / Compare with another role ───────────────────────────────────────
function populateAuxRoleDropdowns(){
    var src  = document.getElementById('ddlRole');
    var copy = document.getElementById('ddlCopyFrom');
    var cmp  = document.getElementById('ddlCompare');
    copy.innerHTML = '<option value="">Copy from role…</option>';
    cmp.innerHTML  = '<option value="">Compare with…</option>';
    for(var i=0;i<src.options.length;i++){
        var o = src.options[i];
        if(!o.value || o.value === currentRoleId) continue;
        copy.appendChild(new Option(o.text, o.value));
        cmp.appendChild(new Option(o.text, o.value));
    }
}

function fetchRoleGrants(roleId, cb){
    fetch('UserRolePermissions.aspx?ajax=matrix&role_id=' + encodeURIComponent(roleId))
        .then(function(r){ return r.json(); })
        .then(function(d){
            if(!d.ok){ showToast(d.error||'Failed to load role.','err'); cb(null,false); return; }
            cb(d.granted || [], !!d.is_admin);
        })
        .catch(function(){ showToast('Network error.','err'); cb(null,false); });
}

function roleNameById(id){
    var src = document.getElementById('ddlRole');
    for(var i=0;i<src.options.length;i++) if(src.options[i].value===id) return src.options[i].getAttribute('data-name')||src.options[i].text;
    return 'role';
}

window.copyFromRole = function(srcId){
    document.getElementById('ddlCopyFrom').value = '';
    if(!srcId || !currentRoleId) return;
    var nm = roleNameById(srcId);
    if(!confirm('Copy all grants from "' + nm + '" into this matrix?\n\nThis replaces the current ticks on screen. Nothing is saved until you click Save Changes.')) return;
    fetchRoleGrants(srcId, function(grants, isAdmin){
        if(grants===null) return;
        if(isAdmin){ showToast('Cannot copy from the admin role (wildcard access).','err'); return; }
        var gset = {}; for(var i=0;i<grants.length;i++) gset[grants[i]] = true;
        var rows = document.querySelectorAll('#permBody tr.perm-leaf');
        for(var r=0;r<rows.length;r++){
            var cb = rows[r].querySelector('.perm-check:not(:disabled)');
            if(cb) cb.checked = !!gset[cb.getAttribute('data-slug')];
        }
        syncAllSectionChks();
        dirty = true; updateDirty(); updateProgressFromDOM();
        showToast('Copied ' + grants.length + ' grant' + (grants.length!==1?'s':'') + ' from "' + nm + '". Review, then Save.','ok');
    });
};

window.compareRole = function(srcId){
    if(!srcId){ clearCompareHighlights(); document.getElementById('ddlCompare').value=''; return; }
    if(!currentRoleId) return;
    var nm = roleNameById(srcId);
    fetchRoleGrants(srcId, function(grants, isAdmin){
        if(grants===null) return;
        var gset = {}; for(var i=0;i<grants.length;i++) gset[grants[i]] = true;
        var rows = document.querySelectorAll('#permBody tr.perm-leaf');
        for(var r=0;r<rows.length;r++){
            var cb = rows[r].querySelector('.perm-check');
            rows[r].classList.remove('perm-diff-add','perm-diff-rem');
            if(!cb) continue;
            var cur = cb.checked, other = isAdmin || !!gset[cb.getAttribute('data-slug')];
            if(cur && !other) rows[r].classList.add('perm-diff-add');
            else if(!cur && other) rows[r].classList.add('perm-diff-rem');
        }
        document.getElementById('cmpOther1').textContent = nm;
        document.getElementById('cmpOther2').textContent = nm;
        document.getElementById('cmpLegendTitle').innerHTML = '<b>Comparing</b> ' + escHtml(currentRoleName) + ' vs ' + escHtml(nm);
        document.getElementById('cmpLegend').classList.add('visible');
    });
};

function clearCompareHighlights(){
    var rows = document.querySelectorAll('#permBody tr.perm-diff-add, #permBody tr.perm-diff-rem');
    for(var i=0;i<rows.length;i++) rows[i].classList.remove('perm-diff-add','perm-diff-rem');
    var lg = document.getElementById('cmpLegend');
    if(lg) lg.classList.remove('visible');
    var cmp = document.getElementById('ddlCompare');
    if(cmp) cmp.value = '';
}

// ── Unsaved-changes guard ───────────────────────────────────────────────────────
window.addEventListener('beforeunload', function(e){
    if(dirty){ e.preventDefault(); e.returnValue = ''; return ''; }
});

// ── Helpers ────────────────────────────────────────────────────────────────────
function escHtml(s){
    if(!s) return '';
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

window.showToast = function(msg, type){
    var t = document.getElementById('paToast');
    t.textContent = msg;
    t.className = 'pa-toast visible' + (type==='err' ? ' pa-toast--err' : '');
    clearTimeout(t._tmr);
    t._tmr = setTimeout(function(){ t.classList.remove('visible'); }, 3500);
};

// ── Role pill selector ─────────────────────────────────────────────────────────
window.buildRolePills = function(){
    var sel = document.getElementById('ddlRole');
    var box = document.getElementById('rolePills');
    if(!sel || !box) return;
    box.innerHTML = '';
    var n = 0;
    for(var i=0;i<sel.options.length;i++){
        var o = sel.options[i];
        if(!o.value) continue;
        n++;
        var color = o.getAttribute('data-color') || '#174DA4';
        var users = o.getAttribute('data-users') || '0';
        var name  = o.getAttribute('data-name')  || o.text;
        var code  = (o.getAttribute('data-code') || '').toLowerCase();
        var pill  = document.createElement('button');
        pill.type = 'button';
        pill.className = 'perm-pill';
        pill.setAttribute('data-id', o.value);
        pill.title = (code === 'admin')
            ? 'Administrator has full (wildcard) access'
            : users + ' user(s) assigned';
        pill.onclick = (function(id){ return function(){ selectRolePill(id); }; })(o.value);
        pill.innerHTML = '<span class="perm-pill__dot" style="background:' + escHtml(color) + '"></span>' +
                         escHtml(name) + '<span class="perm-pill__count">' + escHtml(String(users)) + '</span>';
        box.appendChild(pill);
    }
    if(n === 0) box.innerHTML = '<span style="font-size:12px;color:#94a3b8;">No active roles. Create one in the Roles tab.</span>';
};

window.selectRolePill = function(id){
    if(dirty && !confirm('You have unsaved changes that will be lost. Switch role anyway?')) return;
    dirty = false;
    var sel = document.getElementById('ddlRole');
    sel.value = String(id);
    markActivePill(id);
    loadMatrix();
};

window.markActivePill = function(id){
    var pills = document.querySelectorAll('#rolePills .perm-pill');
    for(var i=0;i<pills.length;i++)
        pills[i].classList.toggle('active', pills[i].getAttribute('data-id') === String(id));
};

// ── Section counts + collapse ──────────────────────────────────────────────────
window.updateSectionCounts = function(){
    var secs = document.querySelectorAll('#permBody tr.section-header');
    for(var s=0;s<secs.length;s++){
        var idx = secs[s].getAttribute('data-section');
        var leaves = document.querySelectorAll('#permBody tr.perm-leaf[data-section="'+idx+'"] .perm-check');
        var tot=0, g=0;
        for(var i=0;i<leaves.length;i++){ tot++; if(leaves[i].checked) g++; }
        var el = document.getElementById('seccount_'+idx);
        if(el){ el.textContent = g+'/'+tot; el.classList.toggle('full', tot>0 && g===tot); }
    }
};

window.onSectionHeaderClick = function(evt, idx){
    if(evt && evt.target && evt.target.classList && evt.target.classList.contains('perm-section-chk')) return;
    var hdr = document.querySelector('#permBody tr.section-header[data-section="'+idx+'"]');
    if(!hdr) return;
    var collapsed = hdr.classList.toggle('collapsed');
    var rows = document.querySelectorAll('#permBody tr[data-section="'+idx+'"]:not(.section-header)');
    for(var i=0;i<rows.length;i++) rows[i].classList.toggle('is-collapsed', collapsed);
};

window.toggleAllSections = function(){
    _allCollapsed = !_allCollapsed;
    var secs = document.querySelectorAll('#permBody tr.section-header');
    for(var s=0;s<secs.length;s++){
        var idx = secs[s].getAttribute('data-section');
        secs[s].classList.toggle('collapsed', _allCollapsed);
        var rows = document.querySelectorAll('#permBody tr[data-section="'+idx+'"]:not(.section-header)');
        for(var i=0;i<rows.length;i++) rows[i].classList.toggle('is-collapsed', _allCollapsed);
    }
    document.getElementById('expandToggleLbl').textContent = _allCollapsed ? 'Expand all' : 'Collapse all';
};

// ── Init (everything above is now defined) ─────────────────────────────────────
buildRolePills();
(function preselectRole(){
    var m = window.location.search.match(/[?&]role_id=([^&]+)/);
    if(!m) return;
    var sel = document.getElementById('ddlRole');
    var v   = decodeURIComponent(m[1]);
    for(var i=0;i<sel.options.length;i++){
        if(sel.options[i].value === v){ sel.selectedIndex = i; loadMatrix(); break; }
    }
})();
})();
</script>
</asp:Content>
