<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="UserRoleRoles.aspx.cs" Inherits="COOPERP_NewScreens_UserRoleRoles" Title="Roles - Campus Dynamics" %>

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

/* ── Stat chips ───────────────────────────────────────────────────────────── */
.pa-list-stats{display:flex;align-items:center;gap:8px;padding:10px 28px;background:var(--surf);border-bottom:1px solid var(--bdr);flex-wrap:wrap;}
.pa-list-stat{display:inline-flex;align-items:center;gap:5px;padding:5px 12px;border:1px solid var(--bdr);background:#fff;font-size:11px;white-space:nowrap;}
.pa-list-stat b{font-size:14px;font-weight:700;color:var(--txt);}
.pa-list-stat__lbl{color:var(--muted);}
.ps--all{border-left:3px solid var(--brand-dk);}
.ps--users{border-left:3px solid var(--success);}
.ps--admin{border-left:3px solid #7c3aed;}

/* ── Toolbar ─────────────────────────────────────────────────────────────── */
.urm-toolbar{background:var(--surf);border-bottom:1px solid var(--bdr);padding:12px 28px;display:flex;align-items:center;gap:12px;flex-wrap:wrap;}
.urm-search{flex:1;min-width:200px;max-width:360px;position:relative;}
.urm-search input{width:100%;height:34px;border:1px solid var(--bdr);background:#fff;font-size:12px;padding:0 10px 0 32px;outline:none;box-sizing:border-box;}
.urm-search input:focus{border-color:var(--brand);}
.urm-search__ico{position:absolute;left:9px;top:50%;transform:translateY(-50%);color:#94a3b8;pointer-events:none;}

/* ── Roles grid ───────────────────────────────────────────────────────────── */
.roles-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:16px;padding:24px 28px;}

/* ── Role card ───────────────────────────────────────────────────────────── */
.role-card{background:#fff;border:1px solid var(--bdr);border-radius:4px;overflow:hidden;display:flex;flex-direction:column;transition:box-shadow .15s,border-color .15s;}
.role-card:hover{box-shadow:0 3px 14px rgba(0,0,0,.09);}
.role-card__bar{height:4px;flex-shrink:0;}
.role-card__body{padding:16px;flex:1;}
.role-card__title-row{display:flex;align-items:flex-start;gap:8px;margin-bottom:6px;}
.role-card__name{font-size:14px;font-weight:700;color:var(--txt);line-height:1.3;}
.role-card__sys{font-size:9px;font-weight:700;color:#fff;background:#7c3aed;padding:2px 6px;border-radius:2px;white-space:nowrap;margin-top:2px;}
.role-card__code{font-family:monospace;font-size:10px;color:var(--muted);background:var(--surf);border:1px solid var(--bdr);display:inline-block;padding:1px 7px;margin-bottom:8px;}
.role-card__desc{font-size:11px;color:var(--muted);line-height:1.5;margin-bottom:12px;min-height:16px;}
.role-card__stats{display:flex;align-items:center;gap:16px;margin-top:8px;}
.role-card__kv{display:flex;align-items:baseline;gap:4px;}
.role-card__kv-num{font-size:20px;font-weight:700;color:var(--txt);line-height:1;}
.role-card__kv-lbl{font-size:10px;color:var(--muted);}
.role-card__kv-sep{width:1px;height:24px;background:var(--bdr);}
.role-card__foot{padding:10px 14px;border-top:1px solid #f1f5f9;display:flex;gap:6px;background:#f8fafc;flex-wrap:wrap;align-items:center;}

/* ── Buttons ──────────────────────────────────────────────────────────────── */
.urm-btn{display:inline-flex;align-items:center;gap:4px;padding:5px 12px;font-size:11px;font-weight:600;border:none;cursor:pointer;border-radius:0;white-space:nowrap;text-decoration:none;}
.urm-btn--primary{background:var(--brand-dk);color:#fff;}
.urm-btn--primary:hover{background:var(--brand);}
.urm-btn--outline{background:#fff;color:#374151;border:1px solid var(--bdr);}
.urm-btn--outline:hover{background:var(--surf);}
.urm-btn--ghost{background:transparent;color:var(--brand);border:1px solid transparent;}
.urm-btn--ghost:hover{background:#eff6ff;border-color:#bfdbfe;}
.urm-btn--danger{background:#fef2f2;color:var(--danger);border:1px solid #fca5a5;}
.urm-btn--danger:hover{background:var(--danger);color:#fff;}
.urm-btn--sm{padding:3px 9px;font-size:10px;}
.urm-btn:disabled{opacity:.5;cursor:not-allowed;}

/* ── Modals ───────────────────────────────────────────────────────────────── */
.urm-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.46);z-index:1000;align-items:center;justify-content:center;}
.urm-overlay.active{display:flex;}
.urm-modal{background:#fff;border-radius:2px;width:490px;max-width:95vw;box-shadow:0 20px 60px rgba(0,0,0,.2);overflow:hidden;}
.urm-modal--sm{width:420px;}
.urm-modal__head{background:var(--brand-dk);color:#fff;padding:16px 20px;display:flex;align-items:center;justify-content:space-between;}
.urm-modal__head--danger{background:var(--danger);}
.urm-modal__head h3{margin:0;font-size:14px;font-weight:600;}
.urm-modal__close{background:none;border:none;color:rgba(255,255,255,.7);cursor:pointer;font-size:20px;line-height:1;padding:2px;}
.urm-modal__close:hover{color:#fff;}
.urm-modal__body{padding:22px 20px;}
.urm-modal__foot{padding:12px 20px;border-top:1px solid var(--bdr);display:flex;justify-content:flex-end;gap:8px;}
.urm-field{margin-bottom:16px;}
.urm-field label{display:block;font-size:11px;font-weight:600;color:#374151;margin-bottom:4px;}
.urm-field input[type=text],.urm-field textarea{width:100%;height:34px;border:1px solid var(--bdr);font-size:12px;padding:0 10px;outline:none;box-sizing:border-box;background:#fff;}
.urm-field input[type=text]:focus,.urm-field textarea:focus{border-color:var(--brand);}
.urm-field textarea{height:68px;padding:8px 10px;resize:vertical;}
.urm-hint{font-size:10px;color:var(--muted);margin-top:3px;}
.urm-hint--warn{color:var(--warn);}
.color-row{display:flex;align-items:center;gap:8px;}
.color-row input[type=color]{width:44px;height:34px;border:1px solid var(--bdr);cursor:pointer;padding:2px;flex-shrink:0;}
.color-row input[type=text]{flex:1;}
.color-swatch{width:30px;height:30px;border-radius:2px;border:1px solid var(--bdr);flex-shrink:0;}

/* ── Toast ───────────────────────────────────────────────────────────────── */
.pa-toast{display:none;position:fixed;bottom:24px;right:24px;z-index:3000;background:#fff;border:1px solid var(--bdr);border-left:4px solid var(--success);padding:12px 18px;font-size:12px;box-shadow:0 4px 18px rgba(0,0,0,.12);max-width:320px;border-radius:2px;}
.pa-toast.visible{display:block;}
.pa-toast--err{border-left-color:var(--danger);}

/* ── Empty state ─────────────────────────────────────────────────────────── */
.empty-state{grid-column:1/-1;text-align:center;padding:60px 24px;color:#94a3b8;font-size:13px;}
.empty-state strong{color:var(--txt);}

/* ── Modal live preview + colour swatches ────────────────────────────────── */
.role-preview-wrap{display:flex;align-items:center;gap:10px;margin-bottom:18px;padding:12px 14px;background:var(--surf);border:1px dashed var(--bdr);border-radius:4px;}
.role-preview-wrap__lbl{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);}
.role-badge-preview{display:inline-flex;align-items:center;gap:7px;padding:6px 14px;border-radius:20px;background:#fff;border:1px solid var(--bdr);font-size:13px;font-weight:700;color:var(--txt);max-width:100%;}
.role-badge-preview .rp-dot{width:11px;height:11px;border-radius:50%;background:var(--brand);flex-shrink:0;}
.role-badge-preview .rp-code{font-family:monospace;font-size:10px;font-weight:600;color:var(--muted);}
.swatches{display:flex;flex-wrap:wrap;gap:7px;margin-top:9px;}
.swatch{width:24px;height:24px;border-radius:50%;border:2px solid #fff;box-shadow:0 0 0 1px var(--bdr);cursor:pointer;transition:transform .1s;padding:0;}
.swatch:hover{transform:scale(1.18);}
.swatch.sel{box-shadow:0 0 0 2px var(--brand-dk);}

/* ── Card footer action grouping ─────────────────────────────────────────── */
.role-card__foot{justify-content:flex-start;}
.role-card__foot .spacer{flex:1;}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Access hub tabs -->
<div class="acc-tabs">
    <a href="AccessControlCenter.aspx" class="acc-tab">Overview</a>
    <a href="UserRoleUsers.aspx" class="acc-tab">Users</a>
    <a href="UserRoleRoles.aspx" class="acc-tab acc-tab--active">Roles</a>
    <a href="UserRolePermissions.aspx" class="acc-tab">Permissions</a>
    <a href="UserRoleAudit.aspx" class="acc-tab">Audit</a>
</div>

<!-- Header -->
<div class="urm-header">
    <div>
        <div class="urm-header__title">Role Management</div>
        <div class="urm-header__sub">Create, edit and manage system access roles</div>
    </div>
    <button type="button" class="urm-btn urm-btn--primary" onclick="openCreateModal()">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        New Role
    </button>
</div>

<!-- Stat chips -->
<asp:Literal ID="litStats" runat="server"></asp:Literal>

<!-- Toolbar -->
<div class="urm-toolbar">
    <div class="urm-search">
        <svg class="urm-search__ico" xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" id="txtSearch" placeholder="Search by name or code…" oninput="filterCards()" />
    </div>
    <span id="lblCount" style="font-size:11px;color:var(--muted);"></span>
    <span style="margin-left:auto;font-size:11px;color:var(--muted);">Click a card to manage its permissions →</span>
</div>

<!-- Roles grid -->
<div class="roles-grid" id="rolesGrid">
    <asp:Literal ID="litCards" runat="server"></asp:Literal>
</div>

<!-- ══════════════════════════════════════════
     CREATE / EDIT MODAL
     ══════════════════════════════════════════ -->
<div class="urm-overlay" id="modalRole">
    <div class="urm-modal">
        <div class="urm-modal__head">
            <h3 id="modalRoleTitle">New Role</h3>
            <button type="button" class="urm-modal__close" onclick="closeModal('modalRole')">&times;</button>
        </div>
        <div class="urm-modal__body">
            <input type="hidden" id="editRoleId" value="" />

            <!-- Live preview -->
            <div class="role-preview-wrap">
                <span class="role-preview-wrap__lbl">Preview</span>
                <span class="role-badge-preview" id="rolePreview">
                    <span class="rp-dot" id="rpDot"></span>
                    <span id="rpName">New Role</span>
                    <span class="rp-code" id="rpCode"></span>
                </span>
            </div>

            <div class="urm-field">
                <label>Role Name <span style="color:var(--danger)">*</span></label>
                <input type="text" id="roleName" placeholder="e.g. Registrar" maxlength="80" oninput="onRoleNameInput()" />
            </div>
            <div class="urm-field">
                <label>Role Code <span style="color:var(--danger)">*</span>
                    <span style="font-weight:400;color:#94a3b8"> — auto-filled from the name; lowercase, unique</span></label>
                <input type="text" id="roleCode" placeholder="e.g. registrar" maxlength="40"
                       oninput="onRoleCodeInput(this)" />
                <div class="urm-hint" id="codeHint"></div>
            </div>
            <div class="urm-field">
                <label>Badge Colour</label>
                <div class="color-row">
                    <input type="color" id="roleColorPicker" value="#174DA4" oninput="onPickerChange()" />
                    <input type="text" id="roleColorHex" value="#174DA4" maxlength="7"
                           oninput="onHexChange()" placeholder="#174DA4" />
                    <div class="color-swatch" id="colorSwatch" style="background:#174DA4;"></div>
                </div>
                <div class="swatches" id="swatches"></div>
            </div>
            <div class="urm-field">
                <label>Description <span style="font-weight:400;color:#94a3b8">(optional)</span></label>
                <textarea id="roleDesc" placeholder="Brief description of this role's responsibilities…" maxlength="500"></textarea>
            </div>
        </div>
        <div class="urm-modal__foot">
            <button type="button" class="urm-btn urm-btn--outline" onclick="closeModal('modalRole')">Cancel</button>
            <button type="button" class="urm-btn urm-btn--primary" id="btnSaveRole" onclick="saveRole()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Save Role
            </button>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════
     DELETE CONFIRM MODAL
     ══════════════════════════════════════════ -->
<div class="urm-overlay" id="modalDelete">
    <div class="urm-modal urm-modal--sm">
        <div class="urm-modal__head urm-modal__head--danger">
            <h3>Delete Role</h3>
            <button type="button" class="urm-modal__close" onclick="closeModal('modalDelete')">&times;</button>
        </div>
        <div class="urm-modal__body">
            <p style="font-size:13px;margin:0 0 10px;color:#374151;">
                Delete <strong id="delRoleName" style="color:var(--danger)"></strong>?
            </p>
            <p style="font-size:12px;color:var(--muted);margin:0;line-height:1.5;">
                This will deactivate the role and immediately revoke it from all assigned users.
                The action cannot be undone.
            </p>
            <input type="hidden" id="delRoleId" />
        </div>
        <div class="urm-modal__foot">
            <button type="button" class="urm-btn urm-btn--outline" onclick="closeModal('modalDelete')">Cancel</button>
            <button type="button" class="urm-btn urm-btn--danger" id="btnConfirmDelete" onclick="confirmDelete()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/></svg>
                Delete Role
            </button>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════
     CLONE ROLE MODAL
     ══════════════════════════════════════════ -->
<div class="urm-overlay" id="modalClone">
    <div class="urm-modal">
        <div class="urm-modal__head">
            <h3>Clone Role</h3>
            <button type="button" class="urm-modal__close" onclick="closeModal('modalClone')">&times;</button>
        </div>
        <div class="urm-modal__body">
            <input type="hidden" id="cloneSrcId" value="" />
            <p style="font-size:12px;color:var(--muted);margin:0 0 12px;line-height:1.5;">
                Creates a new role with the <strong>same permissions, colour and description</strong> as
                <strong id="cloneSrcName" style="color:var(--brand-dk)"></strong>. You can adjust its permissions afterwards.
            </p>
            <div class="urm-field">
                <label>New Role Name <span style="color:var(--danger)">*</span></label>
                <input type="text" id="cloneName" placeholder="e.g. Assistant Registrar" maxlength="80" />
            </div>
            <div class="urm-field">
                <label>New Role Code <span style="color:var(--danger)">*</span>
                    <span style="font-weight:400;color:#94a3b8"> — lowercase, underscores only, unique</span></label>
                <input type="text" id="cloneCode" placeholder="e.g. asst_registrar" maxlength="40"
                       oninput="this.value=this.value.toLowerCase().replace(/[^a-z0-9_]/g,'')" />
            </div>
        </div>
        <div class="urm-modal__foot">
            <button type="button" class="urm-btn urm-btn--outline" onclick="closeModal('modalClone')">Cancel</button>
            <button type="button" class="urm-btn urm-btn--primary" id="btnSaveClone" onclick="saveClone()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                Create Clone
            </button>
        </div>
    </div>
</div>

<!-- Toast -->
<div class="pa-toast" id="paToast"></div>

<script type="text/javascript">
(function(){
// ── Search / filter ──────────────────────────────────────────────────────────
window.filterCards = function(){
    var q = (document.getElementById('txtSearch').value||'').toLowerCase();
    var cards = document.querySelectorAll('#rolesGrid .role-card');
    var vis = 0;
    for(var i=0;i<cards.length;i++){
        var t = (cards[i].getAttribute('data-search')||'').toLowerCase();
        var show = !q || t.indexOf(q)>=0;
        cards[i].style.display = show ? '' : 'none';
        if(show) vis++;
    }
    document.getElementById('lblCount').textContent = vis + ' role' + (vis!==1?'s':'') + ' shown';
};
filterCards();

// ── Modal helpers ─────────────────────────────────────────────────────────────
window.closeModal = function(id){ document.getElementById(id).classList.remove('active'); };

// ── Live preview + auto-code + swatches ─────────────────────────────────────────
var _codeTouched = false;
var SWATCHES = ['#05275C','#174DA4','#2563eb','#0891b2','#0d9488','#16a34a',
                '#ca8a04','#ea580c','#dc2626','#db2777','#7c3aed','#475569'];

function escHtml(s){return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}

function slugify(s){
    return (s||'').toLowerCase().replace(/[^a-z0-9]+/g,'_').replace(/^_+|_+$/g,'').slice(0,40);
}

function updateRolePreview(){
    var name  = (document.getElementById('roleName').value||'').trim() || 'New Role';
    var code  = (document.getElementById('roleCode').value||'').trim();
    var color = document.getElementById('roleColorHex').value.trim() || '#174DA4';
    document.getElementById('rpName').textContent = name;
    document.getElementById('rpCode').textContent = code ? code : '';
    document.getElementById('rpDot').style.background = color;
    // mark matching swatch
    var sw = document.querySelectorAll('#swatches .swatch');
    for(var i=0;i<sw.length;i++)
        sw[i].classList.toggle('sel', (sw[i].getAttribute('data-c')||'').toLowerCase() === color.toLowerCase());
}

function buildSwatches(){
    var box = document.getElementById('swatches'); if(!box) return;
    box.innerHTML = '';
    for(var i=0;i<SWATCHES.length;i++){
        var b = document.createElement('button');
        b.type='button'; b.className='swatch'; b.style.background=SWATCHES[i];
        b.setAttribute('data-c', SWATCHES[i]);
        b.title = SWATCHES[i];
        b.onclick = (function(c){ return function(){ pickSwatch(c); }; })(SWATCHES[i]);
        box.appendChild(b);
    }
}

window.pickSwatch = function(hex){ setColor(hex); };

window.onRoleNameInput = function(){
    if(!_codeTouched && !document.getElementById('roleCode').readOnly){
        document.getElementById('roleCode').value = slugify(document.getElementById('roleName').value);
    }
    updateRolePreview();
};

window.onRoleCodeInput = function(el){
    el.value = el.value.toLowerCase().replace(/[^a-z0-9_]/g,'');
    _codeTouched = (el.value.length > 0);
    updateRolePreview();
};

// ── Color sync ────────────────────────────────────────────────────────────────
function setColor(hex){
    if(!hex) hex='#174DA4';
    document.getElementById('roleColorPicker').value = hex;
    document.getElementById('roleColorHex').value    = hex;
    document.getElementById('colorSwatch').style.background = hex;
    updateRolePreview();
}
window.onPickerChange = function(){
    var v = document.getElementById('roleColorPicker').value;
    document.getElementById('roleColorHex').value = v;
    document.getElementById('colorSwatch').style.background = v;
    updateRolePreview();
};
window.onHexChange = function(){
    var v = document.getElementById('roleColorHex').value.trim();
    if(/^#[0-9a-fA-F]{6}$/.test(v)){
        document.getElementById('roleColorPicker').value = v;
        document.getElementById('colorSwatch').style.background = v;
    }
    updateRolePreview();
};

// ── Create modal ──────────────────────────────────────────────────────────────
window.openCreateModal = function(){
    _codeTouched = false;
    document.getElementById('editRoleId').value = '';
    document.getElementById('roleName').value   = '';
    document.getElementById('roleCode').value   = '';
    document.getElementById('roleCode').readOnly = false;
    document.getElementById('codeHint').textContent = '';
    document.getElementById('codeHint').className   = 'urm-hint';
    setColor('#174DA4');
    document.getElementById('roleDesc').value = '';
    document.getElementById('modalRoleTitle').textContent = 'New Role';
    document.getElementById('btnSaveRole').textContent    = 'Save Role';
    document.getElementById('btnSaveRole').disabled       = false;
    updateRolePreview();
    document.getElementById('modalRole').classList.add('active');
    setTimeout(function(){ document.getElementById('roleName').focus(); }, 80);
};

// ── Edit modal ────────────────────────────────────────────────────────────────
window.openEditModal = function(id, name, code, color, desc){
    _codeTouched = true;
    document.getElementById('editRoleId').value = id;
    document.getElementById('roleName').value   = name;
    document.getElementById('roleCode').value   = code;
    document.getElementById('roleCode').readOnly = true;
    document.getElementById('codeHint').textContent = 'Role code cannot be changed after creation.';
    document.getElementById('codeHint').className   = 'urm-hint urm-hint--warn';
    setColor(color);
    document.getElementById('roleDesc').value = desc;
    document.getElementById('modalRoleTitle').textContent = 'Edit Role';
    document.getElementById('btnSaveRole').textContent    = 'Save Changes';
    document.getElementById('btnSaveRole').disabled       = false;
    updateRolePreview();
    document.getElementById('modalRole').classList.add('active');
    setTimeout(function(){ document.getElementById('roleName').focus(); }, 80);
};

// ── Save role ─────────────────────────────────────────────────────────────────
window.saveRole = function(){
    var id    = document.getElementById('editRoleId').value.trim();
    var name  = document.getElementById('roleName').value.trim();
    var code  = document.getElementById('roleCode').value.trim();
    var color = document.getElementById('roleColorHex').value.trim();
    var desc  = document.getElementById('roleDesc').value.trim();

    if(!name){ showToast('Role name is required.','err'); return; }
    if(!code){ showToast('Role code is required.','err'); return; }
    if(!color || !/^#[0-9a-fA-F]{6}$/.test(color)) color = '#174DA4';

    var btn = document.getElementById('btnSaveRole');
    btn.disabled = true;
    btn.textContent = 'Saving…';

    fetch('UserRoleRoles.aspx?ajax=' + (id ? 'update' : 'create'), {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'id='    + encodeURIComponent(id)    +
              '&name=' + encodeURIComponent(name)  +
              '&code=' + encodeURIComponent(code)  +
              '&color='+ encodeURIComponent(color) +
              '&desc=' + encodeURIComponent(desc)
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
        btn.disabled = false;
        btn.textContent = id ? 'Save Changes' : 'Save Role';
        if(d.ok){
            closeModal('modalRole');
            showToast(id ? 'Role updated.' : 'Role created.', 'ok');
            setTimeout(function(){ location.reload(); }, 1000);
        } else showToast(d.error || 'Failed to save.', 'err');
    })
    .catch(function(){
        btn.disabled = false;
        btn.textContent = id ? 'Save Changes' : 'Save Role';
        showToast('Network error.', 'err');
    });
};

// ── Delete modal ──────────────────────────────────────────────────────────────
window.openDeleteModal = function(id, name){
    document.getElementById('delRoleId').value            = id;
    document.getElementById('delRoleName').textContent    = name;
    document.getElementById('btnConfirmDelete').disabled  = false;
    document.getElementById('btnConfirmDelete').textContent = 'Delete Role';
    document.getElementById('modalDelete').classList.add('active');
};

window.confirmDelete = function(){
    var id  = document.getElementById('delRoleId').value;
    var btn = document.getElementById('btnConfirmDelete');
    btn.disabled = true;
    btn.textContent = 'Deleting…';

    fetch('UserRoleRoles.aspx?ajax=delete', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'id=' + encodeURIComponent(id)
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
        btn.disabled = false;
        btn.textContent = 'Delete Role';
        closeModal('modalDelete');
        if(d.ok){
            showToast('Role deleted.', 'ok');
            setTimeout(function(){ location.reload(); }, 900);
        } else showToast(d.error || 'Failed.', 'err');
    })
    .catch(function(){
        btn.disabled = false;
        btn.textContent = 'Delete Role';
        showToast('Network error.', 'err');
    });
};

// ── Clone modal ───────────────────────────────────────────────────────────────
window.openCloneModal = function(srcId, srcName, srcCode){
    document.getElementById('cloneSrcId').value         = srcId;
    document.getElementById('cloneSrcName').textContent = srcName;
    document.getElementById('cloneName').value          = srcName + ' (copy)';
    document.getElementById('cloneCode').value          = (srcCode + '_copy').toLowerCase().replace(/[^a-z0-9_]/g,'');
    var btn = document.getElementById('btnSaveClone');
    btn.disabled = false; btn.textContent = 'Create Clone';
    document.getElementById('modalClone').classList.add('active');
    setTimeout(function(){ document.getElementById('cloneName').focus(); }, 80);
};

window.saveClone = function(){
    var srcId = document.getElementById('cloneSrcId').value.trim();
    var name  = document.getElementById('cloneName').value.trim();
    var code  = document.getElementById('cloneCode').value.trim();
    if(!name){ showToast('New role name is required.','err'); return; }
    if(!code){ showToast('New role code is required.','err'); return; }

    var btn = document.getElementById('btnSaveClone');
    btn.disabled = true; btn.textContent = 'Cloning…';

    fetch('UserRoleRoles.aspx?ajax=clone', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'source_id=' + encodeURIComponent(srcId) +
              '&name='     + encodeURIComponent(name)  +
              '&code='     + encodeURIComponent(code)
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
        btn.disabled = false; btn.textContent = 'Create Clone';
        if(d.ok){
            closeModal('modalClone');
            showToast('Role cloned (' + (d.copied || 0) + ' permission(s) copied).', 'ok');
            setTimeout(function(){ location.reload(); }, 1100);
        } else showToast(d.error || 'Failed to clone.', 'err');
    })
    .catch(function(){
        btn.disabled = false; btn.textContent = 'Create Clone';
        showToast('Network error.', 'err');
    });
};

// ── Toast ─────────────────────────────────────────────────────────────────────
window.showToast = function(msg, type){
    var t = document.getElementById('paToast');
    t.textContent = msg;
    t.className = 'pa-toast visible' + (type === 'err' ? ' pa-toast--err' : '');
    clearTimeout(t._tmr);
    t._tmr = setTimeout(function(){ t.classList.remove('visible'); }, 3500);
};

// ── Init (runs after SWATCHES and all handlers are defined) ─────────────────────
buildSwatches();
})();
</script>
</asp:Content>
