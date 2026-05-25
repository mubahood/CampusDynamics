<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="UserRoleRoles.aspx.cs" Inherits="COOPERP_NewScreens_UserRoleRoles" Title="Roles - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--brand:#174DA4;--brand-dk:#05275C;--danger:#dc2626;--success:#16a34a;--warn:#b45309;--surf:#f5f7fa;--bdr:#e0e5ed;--txt:#1a1a2e;--muted:#64748b;}

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
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

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
            <div class="urm-field">
                <label>Role Name <span style="color:var(--danger)">*</span></label>
                <input type="text" id="roleName" placeholder="e.g. Registrar" maxlength="80" />
            </div>
            <div class="urm-field">
                <label>Role Code <span style="color:var(--danger)">*</span>
                    <span style="font-weight:400;color:#94a3b8"> — lowercase, underscores only, unique</span></label>
                <input type="text" id="roleCode" placeholder="e.g. registrar" maxlength="40"
                       oninput="this.value=this.value.toLowerCase().replace(/[^a-z0-9_]/g,'')" />
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

// ── Color sync ────────────────────────────────────────────────────────────────
function setColor(hex){
    if(!hex) hex='#174DA4';
    document.getElementById('roleColorPicker').value = hex;
    document.getElementById('roleColorHex').value    = hex;
    document.getElementById('colorSwatch').style.background = hex;
}
window.onPickerChange = function(){
    var v = document.getElementById('roleColorPicker').value;
    document.getElementById('roleColorHex').value = v;
    document.getElementById('colorSwatch').style.background = v;
};
window.onHexChange = function(){
    var v = document.getElementById('roleColorHex').value.trim();
    if(/^#[0-9a-fA-F]{6}$/.test(v)){
        document.getElementById('roleColorPicker').value = v;
        document.getElementById('colorSwatch').style.background = v;
    }
};

// ── Create modal ──────────────────────────────────────────────────────────────
window.openCreateModal = function(){
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
    document.getElementById('modalRole').classList.add('active');
    setTimeout(function(){ document.getElementById('roleName').focus(); }, 80);
};

// ── Edit modal ────────────────────────────────────────────────────────────────
window.openEditModal = function(id, name, code, color, desc){
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

// ── Toast ─────────────────────────────────────────────────────────────────────
window.showToast = function(msg, type){
    var t = document.getElementById('paToast');
    t.textContent = msg;
    t.className = 'pa-toast visible' + (type === 'err' ? ' pa-toast--err' : '');
    clearTimeout(t._tmr);
    t._tmr = setTimeout(function(){ t.classList.remove('visible'); }, 3500);
};
})();
</script>
</asp:Content>
