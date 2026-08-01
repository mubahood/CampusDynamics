<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AccessControlCenter.aspx.cs" Inherits="COOPERP_NewScreens_AccessControlCenter" Title="Access Control Center - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
:root{--brand:#174DA4;--brand-dk:#05275C;--danger:#dc2626;--success:#16a34a;--warn:#b45309;--surf:#f5f7fa;--bdr:#e0e5ed;--txt:#1a1a2e;--muted:#64748b;}

/* Header */
.urm-header{background:#fff;border-bottom:1px solid var(--bdr);padding:20px 28px;display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;}
.urm-header__title{font-size:18px;font-weight:700;color:var(--txt);margin:0;}
.urm-header__sub{font-size:12px;color:var(--muted);margin:2px 0 0;}

/* Shared hub tab bar */
.acc-tabs{display:flex;gap:2px;background:#fff;border-bottom:1px solid var(--bdr);padding:0 20px;overflow-x:auto;}
.acc-tab{padding:11px 16px;font-size:12px;font-weight:600;color:var(--muted);text-decoration:none;border-bottom:2px solid transparent;white-space:nowrap;}
.acc-tab:hover{color:var(--brand);}
.acc-tab--active{color:var(--brand-dk);border-bottom-color:var(--brand-dk);}

/* KPI grid */
.acc-kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px;padding:20px 28px;}
.acc-kpi{display:block;background:#fff;border:1px solid var(--bdr);border-left-width:4px;border-radius:4px;padding:14px 16px;text-decoration:none;transition:box-shadow .15s;}
.acc-kpi:hover{box-shadow:0 3px 14px rgba(0,0,0,.08);}
.acc-kpi--info{border-left-color:var(--brand);}
.acc-kpi--ok{border-left-color:var(--success);}
.acc-kpi--warn{border-left-color:var(--warn);}
.acc-kpi__val{font-size:26px;font-weight:800;letter-spacing:-.5px;color:var(--txt);line-height:1;}
.acc-kpi--warn .acc-kpi__val{color:var(--warn);}
.acc-kpi__lbl{font-size:11px;color:var(--muted);margin-top:6px;}

/* Section card */
.acc-card{background:#fff;border:1px solid var(--bdr);border-radius:4px;margin:0 28px 20px;}
.acc-card__hd{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--brand-dk);padding:12px 16px;border-bottom:1px solid var(--bdr);}
.acc-card__bd{padding:14px 16px;}

/* Needs attention */
.acc-att{display:flex;align-items:center;gap:10px;padding:11px 14px;border:1px solid #fde68a;background:#fffbeb;border-radius:4px;margin-bottom:10px;font-size:12px;color:#7c5e10;}
.acc-att:last-child{margin-bottom:0;}
.acc-att--ok{border-color:#bbf7d0;background:#f0fdf4;color:#166534;}
.acc-att__txt{flex:1;line-height:1.5;}
.acc-att .urm-btn{margin-left:auto;}

/* Role chips */
.acc-chips{display:flex;flex-wrap:wrap;gap:8px;}
.acc-chip{display:inline-flex;align-items:center;gap:6px;padding:5px 11px;border:1px solid var(--bdr);background:#fff;border-radius:20px;font-size:11px;color:var(--txt);text-decoration:none;}
.acc-chip:hover{border-color:var(--brand);background:#eff6ff;}
.acc-chip__dot{width:9px;height:9px;border-radius:50%;flex-shrink:0;}
.acc-chip b{font-size:12px;color:var(--brand-dk);}

/* Ungranted list */
.acc-ul{list-style:none;margin:0;padding:0;columns:2;column-gap:24px;}
@media(max-width:760px){.acc-ul{columns:1;}}
.acc-ul li{font-size:11px;color:var(--txt);padding:4px 0;break-inside:avoid;}
.acc-slug{font-family:monospace;font-size:10px;color:var(--brand);background:var(--surf);border:1px solid var(--bdr);padding:1px 6px;margin-right:6px;}
.acc-sec{font-size:9px;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.acc-muted{font-size:12px;color:var(--muted);margin:0;}

/* Buttons */
.urm-btn{display:inline-flex;align-items:center;gap:4px;padding:5px 12px;font-size:11px;font-weight:600;border:none;cursor:pointer;border-radius:0;white-space:nowrap;text-decoration:none;}
.urm-btn--primary{background:var(--brand-dk);color:#fff;}
.urm-btn--primary:hover{background:var(--brand);}

.acc-err{margin:16px 28px;padding:10px 14px;background:#fef2f2;border:1px solid #fca5a5;color:var(--danger);font-size:12px;border-radius:4px;}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="urm-header">
    <div>
        <h1 class="urm-header__title">Access Control Center</h1>
        <p class="urm-header__sub">Roles, permissions and user access &mdash; one place to see and manage who can do what.</p>
    </div>
    <a href="UserRoleUsers.aspx?filter=norole" class="urm-btn urm-btn--primary">Assign roles &rarr;</a>
</div>

<!-- Shared hub tab bar -->
<div class="acc-tabs">
    <a href="AccessControlCenter.aspx" class="acc-tab acc-tab--active">Overview</a>
    <a href="UserRoleUsers.aspx" class="acc-tab">Users</a>
    <a href="UserRoleRoles.aspx" class="acc-tab">Roles</a>
    <a href="UserRolePermissions.aspx" class="acc-tab">Permissions</a>
    <a href="UserRoleAudit.aspx" class="acc-tab">Audit</a>
</div>

<asp:Literal ID="litError" runat="server" />

<div class="acc-kpis"><asp:Literal ID="litKpis" runat="server" /></div>

<div class="acc-card">
    <div class="acc-card__hd">Needs attention</div>
    <div class="acc-card__bd"><asp:Literal ID="litAttention" runat="server" /></div>
</div>

<div class="acc-card">
    <div class="acc-card__hd">Roles at a glance</div>
    <div class="acc-card__bd"><div class="acc-chips"><asp:Literal ID="litRoleChips" runat="server" /></div></div>
</div>

<div class="acc-card" id="ungranted">
    <div class="acc-card__hd">Ungranted page slugs (reachable only by admins)</div>
    <div class="acc-card__bd"><asp:Literal ID="litUngranted" runat="server" /></div>
</div>

<div class="acc-card" id="drift">
    <div class="acc-card__hd">Permission drift (grants with no live menu item)</div>
    <div class="acc-card__bd"><asp:Literal ID="litDrift" runat="server" /></div>
</div>

<!-- A7: diagnostics -->
<style>
.acc-tools{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin:0 28px 24px;}
@media(max-width:860px){.acc-tools{grid-template-columns:1fr;}}
.acc-tool{background:#fff;border:1px solid var(--bdr);border-radius:4px;}
.acc-tool__hd{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--brand-dk);padding:12px 16px;border-bottom:1px solid var(--bdr);}
.acc-tool__bd{padding:14px 16px;}
.acc-tool__row{display:flex;gap:8px;flex-wrap:wrap;align-items:center;margin-bottom:10px;}
.acc-tool select,.acc-tool input[type=text]{flex:1;min-width:130px;padding:6px 9px;font-size:12px;border:1px solid var(--bdr);border-radius:0;font-family:inherit;}
.acc-tool__hint{font-size:11px;color:var(--muted);margin:0 0 10px;}
.acc-verdict{font-size:12px;line-height:1.6;padding:11px 14px;border-radius:4px;border:1px solid var(--bdr);display:none;}
.acc-verdict.show{display:block;}
.acc-verdict code{font-family:monospace;font-size:11px;background:#eef1f6;padding:1px 5px;}
.acc-verdict--allow{background:#f0fdf4;border-color:#bbf7d0;color:#166534;}
.acc-verdict--deny{background:#fef2f2;border-color:#fecaca;color:#991b1b;}
.acc-verdict--unknown{background:#fffbeb;border-color:#fde68a;color:#7c5e10;}
.acc-prev-sec{margin-top:10px;}
.acc-prev-sec__hd{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:var(--brand);border-bottom:1px solid #eef1f6;padding-bottom:4px;margin-bottom:5px;}
.acc-prev-item{font-size:11px;color:var(--txt);padding:2px 0;}
.acc-prev-item .acc-slug{margin-right:6px;}
</style>
<div class="acc-tools">
    <div class="acc-tool">
        <div class="acc-tool__hd">Preview a role's access</div>
        <div class="acc-tool__bd">
            <p class="acc-tool__hint">See exactly which screens a role can open — the menu that role would get.</p>
            <div class="acc-tool__row">
                <select id="prevRole"><option value="">— select a role —</option><asp:Literal ID="litRoleSelect" runat="server" /></select>
                <button type="button" class="urm-btn urm-btn--primary" onclick="runPreview()">Preview</button>
            </div>
            <div id="prevResult"></div>
        </div>
    </div>
    <div class="acc-tool">
        <div class="acc-tool__hd">Why can't a user see a page?</div>
        <div class="acc-tool__bd">
            <p class="acc-tool__hint">Enter a username and pick a page to get a plain-English explanation.</p>
            <div class="acc-tool__row">
                <input type="text" id="diagUser" placeholder="username / email" autocomplete="off" />
            </div>
            <div class="acc-tool__row">
                <select id="diagSlug"><option value="">— select a page —</option><asp:Literal ID="litSlugSelect" runat="server" /></select>
                <button type="button" class="urm-btn urm-btn--primary" onclick="runDiagnose()">Check</button>
            </div>
            <div class="acc-verdict" id="diagResult"></div>
        </div>
    </div>
</div>

<script type="text/javascript">
function accEsc(s){return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}

function runPreview(){
    var rid = document.getElementById('prevRole').value;
    var box = document.getElementById('prevResult');
    if(!rid){ box.innerHTML = '<p class="acc-muted">Select a role first.</p>'; return; }
    box.innerHTML = '<p class="acc-muted">Loading…</p>';
    fetch('AccessControlCenter.aspx?ajax=preview&role_id=' + encodeURIComponent(rid))
    .then(function(r){return r.json();})
    .then(function(d){
        if(!d.ok){ box.innerHTML = '<p class="acc-muted" style="color:#dc2626;">' + accEsc(d.error||'Failed.') + '</p>'; return; }
        if(d.is_admin){ box.innerHTML = '<div class="acc-verdict acc-verdict--allow show"><b>' + accEsc(d.role) + '</b> is an administrator — full access to every screen.</div>'; return; }
        if(!d.sections || !d.sections.length){ box.innerHTML = '<div class="acc-verdict acc-verdict--deny show"><b>' + accEsc(d.role) + '</b> is granted no screens yet.</div>'; return; }
        var h = '<div class="acc-verdict acc-verdict--allow show"><b>' + accEsc(d.role) + '</b> can open ' + d.total + ' screen(s):</div>';
        for(var s=0;s<d.sections.length;s++){
            var sec = d.sections[s];
            h += '<div class="acc-prev-sec"><div class="acc-prev-sec__hd">' + accEsc(sec.name) + '</div>';
            for(var i=0;i<sec.items.length;i++){
                h += '<div class="acc-prev-item"><span class="acc-slug">' + accEsc(sec.items[i].slug) + '</span>' + accEsc(sec.items[i].label) + '</div>';
            }
            h += '</div>';
        }
        box.innerHTML = h;
    })
    .catch(function(){ box.innerHTML = '<p class="acc-muted" style="color:#dc2626;">Network error.</p>'; });
}

function runDiagnose(){
    var u = (document.getElementById('diagUser').value||'').trim();
    var s = document.getElementById('diagSlug').value;
    var box = document.getElementById('diagResult');
    if(!u || !s){ box.className = 'acc-verdict acc-verdict--unknown show'; box.innerHTML = 'Enter a username and pick a page.'; return; }
    box.className = 'acc-verdict show'; box.textContent = 'Checking…';
    fetch('AccessControlCenter.aspx?ajax=diagnose&username=' + encodeURIComponent(u) + '&slug=' + encodeURIComponent(s))
    .then(function(r){return r.json();})
    .then(function(d){
        if(!d.ok){ box.className='acc-verdict acc-verdict--unknown show'; box.innerHTML = accEsc(d.error||'Failed.'); return; }
        box.className = 'acc-verdict acc-verdict--' + d.verdict + ' show';
        box.innerHTML = (d.page ? '<div style="font-weight:600;margin-bottom:3px;">' + accEsc(d.page) + '</div>' : '') + d.message;
    })
    .catch(function(){ box.className='acc-verdict acc-verdict--unknown show'; box.innerHTML='Network error.'; });
}
</script>

</asp:Content>
