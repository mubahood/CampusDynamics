<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="UserRoleUsers.aspx.cs" Inherits="COOPERP_NewScreens_UserRoleUsers" Title="Users & Roles - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*,*::before,*::after{box-sizing:border-box;}
:root{
    --brand:#174DA4;--brand-light:#e8eef8;--brand-dark:#0f3670;
    --danger:#dc3545;--success:#28a745;--warning:#ffc107;
    --grey:#6c757d;--border:#dee2e6;--radius:6px;
}
.acc-tabs{display:flex;gap:2px;background:#fff;border-bottom:1px solid #e0e5ed;padding:0 20px;overflow-x:auto;}
.acc-tab{padding:11px 16px;font-size:12px;font-weight:600;color:#64748b;text-decoration:none;border-bottom:2px solid transparent;white-space:nowrap;}
.acc-tab:hover{color:#174DA4;}
.acc-tab--active{color:#05275C;border-bottom-color:#05275C;}

/* ── Page header ── */
.pa-page-header{display:flex;align-items:center;gap:14px;margin-bottom:14px;flex-wrap:wrap;}
.pa-page-header__icon{width:44px;height:44px;border-radius:10px;background:var(--brand);display:flex;align-items:center;justify-content:center;color:#fff;flex-shrink:0;}
.pa-page-header__title{font-size:22px;font-weight:700;color:#1a1a1a;line-height:1.2;}
.pa-page-header__sub{font-size:12px;color:#888;margin-top:1px;}
.pa-page-header__actions{margin-left:auto;display:flex;gap:8px;align-items:center;flex-wrap:wrap;}

/* ── Stat chips ── */
.pa-list-stats{display:flex;gap:6px;flex-wrap:wrap;padding:8px 16px;background:#f8f9fa;border:1px solid #e0e5ed;border-radius:var(--radius);margin-bottom:12px;align-items:center;}
.pa-list-stat{display:inline-flex;align-items:center;gap:5px;padding:4px 12px;border-radius:10px;font-size:11px;font-weight:700;cursor:pointer;transition:opacity .15s,box-shadow .15s;user-select:none;}
.pa-list-stat:hover{opacity:.8;box-shadow:0 0 0 2px rgba(0,0,0,.08);}
.pa-list-stat.is-active{box-shadow:0 0 0 2px var(--brand);}
.pa-list-stat__lbl{font-weight:400;opacity:.75;}
.ps--all    {background:#e8eef8;color:#174DA4;}
.ps--staff  {background:#d4edda;color:#155724;}
.ps--roles  {background:#cff4fc;color:#055160;}
.ps--norole {background:#e2e3e5;color:#383d41;}
.ps--locked {background:#f8d7da;color:#721c24;}

/* ── Card ── */
.cd-card{background:#fff;border:1px solid #e0e5ed;border-radius:var(--radius);margin-bottom:16px;overflow:visible;}

/* ── Filter bar ── */
.pa-filter-bar{display:flex;flex-wrap:wrap;gap:8px;align-items:center;padding:10px 14px;background:#f8f9fa;border-bottom:1px solid #e0e5ed;border-radius:var(--radius) var(--radius) 0 0;}
.pa-filter-bar input,
.pa-filter-bar select{font-size:12px;padding:6px 10px;border:1px solid var(--border);border-radius:var(--radius);background:#fff;color:#333;height:32px;}
.pa-filter-bar input:focus,
.pa-filter-bar select:focus{outline:none;border-color:var(--brand);box-shadow:0 0 0 2px rgba(23,77,164,.12);}
.pa-filter-bar input[type=text]{min-width:220px;}
.pa-filter-bar__count{margin-left:auto;font-size:11px;color:#888;white-space:nowrap;}

/* ── Table ── */
.pa-table-wrap{overflow-x:auto;}
.pa-table{width:100%;border-collapse:collapse;font-size:12px;min-width:900px;}
.pa-table th{text-align:left;padding:8px 10px;border-bottom:2px solid #e0e5ed;color:#555;font-weight:600;text-transform:uppercase;font-size:10px;letter-spacing:.3px;background:#fafbfc;white-space:nowrap;}
.pa-table td{padding:8px 10px;border-bottom:1px solid #f5f7fa;color:#333;vertical-align:middle;}
.pa-table tr:last-child td{border-bottom:none;}
.pa-table tbody tr.pa-row:hover td{background:#f4f8ff;}
.pa-row{transition:background .1s;}
.pa-col-num{width:36px;text-align:center;color:#bbb;font-size:11px;padding:8px 4px;}

/* ── Avatar + user cell ── */
.uru-user{display:flex;align-items:center;gap:10px;}
.uru-avatar{width:34px;height:34px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;color:#fff;flex-shrink:0;letter-spacing:.3px;}
.uru-user__name{font-weight:600;color:#1a1a2e;font-size:12px;white-space:nowrap;}
.uru-user__email{font-size:10px;color:#888;margin-top:2px;max-width:170px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}

/* ── Employee meta cell ── */
.uru-emp__name{font-weight:600;color:#333;font-size:12px;}
.uru-emp__code{font-size:10px;color:#aaa;margin-top:2px;letter-spacing:.2px;font-family:monospace;}
.uru-emp__desg{font-size:10px;color:#888;margin-top:2px;}

/* ── Type badge ── */
.uru-type{display:inline-block;padding:2px 7px;border-radius:10px;font-size:10px;font-weight:700;letter-spacing:.2px;white-space:nowrap;}
.uru-type--staff  {background:#e8eef8;color:#174DA4;}
.uru-type--student{background:#f1f5f9;color:#6c757d;}
.uru-type--system {background:#f3e8ff;color:#7c3aed;}

/* ── Role badges ── */
.role-badge{display:inline-block;padding:2px 8px;border-radius:3px;font-size:10px;font-weight:700;color:#fff;margin:1px 2px;white-space:nowrap;letter-spacing:.2px;}
.no-role{color:#aaa;font-style:italic;font-size:11px;}

/* ── Account status badge ── */
.uru-status{display:inline-block;padding:2px 8px;border-radius:10px;font-size:10px;font-weight:700;white-space:nowrap;}
.uru-status--active  {background:#d4edda;color:#155724;}
.uru-status--locked  {background:#f8d7da;color:#721c24;}
.uru-status--inactive{background:#fff3cd;color:#856404;}
.uru-status--noact   {background:#f1f5f9;color:#6c757d;}

/* ── Action dropdown ── */
.pa-col-act{width:110px;text-align:right;}
.pa-col-act-hdr{width:110px;text-align:right;}
.pa-act-menu{position:relative;display:inline-block;}
.pa-act-btn{display:inline-flex;align-items:center;gap:4px;padding:5px 10px;font-size:11px;font-weight:600;border:1px solid var(--border);border-radius:var(--radius);background:#fff;cursor:pointer;color:#555;white-space:nowrap;transition:all .15s;}
.pa-act-btn:hover,.pa-act-btn.is-open{border-color:var(--brand);color:var(--brand);background:var(--brand-light);}
.pa-act-btn svg{transition:transform .15s;}
.pa-act-btn.is-open svg{transform:rotate(180deg);}
.pa-act-drop{position:absolute;right:0;top:calc(100% + 3px);min-width:190px;background:#fff;border:1px solid #d0d7e3;border-radius:var(--radius);box-shadow:0 6px 20px rgba(0,0,0,.14);z-index:9999;display:none;overflow:hidden;}
.pa-act-drop.is-open{display:block;}
.pa-act-item{display:flex;align-items:center;gap:9px;padding:8px 14px;font-size:12px;color:#333;cursor:pointer;border:none;background:none;width:100%;text-align:left;transition:background .1s;line-height:1.3;}
.pa-act-item:hover{background:#f4f8ff;color:var(--brand);}
.pa-act-item svg{color:#aaa;flex-shrink:0;}
.pa-act-item:hover svg{color:var(--brand);}
.pa-act-item--danger{color:var(--danger);}
.pa-act-item--danger:hover{background:#fff5f5;color:var(--danger);}
.pa-act-item--danger svg{color:var(--danger);}
.pa-act-sep{height:1px;background:var(--border);margin:3px 0;}

/* ── Buttons ── */
.hr-btn{display:inline-flex;align-items:center;gap:6px;padding:7px 14px;font-size:12px;font-weight:600;border:none;border-radius:var(--radius);cursor:pointer;transition:all .15s;text-decoration:none;white-space:nowrap;font-family:inherit;}
.hr-btn--primary{background:var(--brand);color:#fff;}
.hr-btn--primary:hover:not(:disabled){background:var(--brand-dark);}
.hr-btn--outline{background:transparent;border:1px solid var(--border);color:#555;}
.hr-btn--outline:hover:not(:disabled){border-color:var(--brand);color:var(--brand);}
.hr-btn--danger{background:var(--danger);color:#fff;}
.hr-btn--danger:hover:not(:disabled){background:#b02a37;}
.hr-btn:disabled{opacity:.5;cursor:not-allowed;}

/* ── Modals ── */
.pa-modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;}
.pa-modal-overlay.is-open{display:flex;}
.pa-modal{background:#fff;width:480px;max-width:92vw;border-radius:var(--radius);box-shadow:0 8px 32px rgba(0,0,0,.18);overflow:hidden;}
.pa-modal__head{padding:14px 18px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;}
.pa-modal__head--danger{background:var(--danger);}
.pa-modal__head--danger .pa-modal__title{color:#fff;}
.pa-modal__head--danger .pa-modal__close{color:rgba(255,255,255,.75);}
.pa-modal__head--danger .pa-modal__close:hover{color:#fff;}
.pa-modal__title{font-size:14px;font-weight:700;color:#333;}
.pa-modal__close{background:none;border:none;font-size:20px;cursor:pointer;color:#999;padding:0 4px;line-height:1;}
.pa-modal__close:hover{color:#333;}
.pa-modal__body{padding:18px;font-size:13px;color:#333;line-height:1.5;}
.pa-modal__foot{padding:12px 18px;border-top:1px solid var(--border);display:flex;justify-content:flex-end;gap:8px;}
.urm-field{margin-bottom:14px;}
.urm-field:last-child{margin-bottom:0;}
.urm-field label{display:block;font-size:11px;font-weight:600;color:#374151;margin-bottom:4px;}
.urm-field select,.urm-field input[type=text],.urm-field input[type=date],.urm-field textarea{width:100%;height:34px;border:1px solid var(--border);font-size:12px;padding:0 10px;outline:none;border-radius:var(--radius);box-sizing:border-box;background:#fff;font-family:inherit;color:#333;}
.urm-field select:focus,.urm-field input:focus{border-color:var(--brand);box-shadow:0 0 0 2px rgba(23,77,164,.12);}
.urm-field textarea{height:72px;padding:8px 10px;resize:vertical;}
.urm-field input[readonly]{background:#f4f5f7;color:#6c757d;}
.urm-hint{font-size:10px;color:#999;margin-top:3px;}

/* ── Revoke confirm ── */
.revoke-box{background:#fff5f5;border:1px solid #fca5a5;border-radius:var(--radius);padding:12px 14px;margin-bottom:12px;}
.revoke-box__role{font-size:14px;font-weight:700;color:#991b1b;margin-bottom:2px;}
.revoke-box__user{font-size:11px;color:#6b7280;}
.revoke-note{font-size:11px;color:#6c757d;line-height:1.5;margin:0;}

/* ── Batch bar ── */
.pa-batch-bar{display:none;align-items:center;gap:10px;padding:10px 16px;background:linear-gradient(90deg,#eef2ff,#e8eef8);border:1px solid #c5d3e8;border-radius:var(--radius);margin-bottom:12px;flex-wrap:wrap;}
.pa-batch-bar.is-active{display:flex;}
.pa-batch-count{font-size:12px;font-weight:700;color:var(--brand);min-width:110px;white-space:nowrap;}
.pa-batch-divider{width:1px;height:22px;background:rgba(23,77,164,.25);flex-shrink:0;}
.pa-batch-label{font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#888;font-weight:600;}
.pa-batch-actions{display:flex;gap:6px;flex-wrap:wrap;align-items:center;}
.pa-batch-btn{display:inline-flex;align-items:center;gap:5px;padding:6px 14px;font-size:11px;font-weight:600;border:none;border-radius:var(--radius);cursor:pointer;transition:all .15s;white-space:nowrap;font-family:inherit;}
.pa-batch-btn--primary{background:#dbeafe;color:#1e40af;border:1px solid #bfdbfe;}
.pa-batch-btn--primary:not(:disabled):hover{background:#bfdbfe;}
.pa-batch-btn--danger{background:#fee2e2;color:#991b1b;border:1px solid #fca5a5;}
.pa-batch-btn--danger:not(:disabled):hover{background:#fca5a5;}
.pa-batch-btn--outline{background:#fff;color:#555;border:1px solid var(--border);}
.pa-batch-btn--outline:hover{border-color:var(--brand);color:var(--brand);}
.pa-batch-btn:disabled{opacity:.4;cursor:not-allowed;}
/* ── Checkbox column ── */
.pa-col-chk{width:38px;text-align:center;}
.pa-col-chk input[type=checkbox]{cursor:pointer;width:14px;height:14px;accent-color:var(--brand);}
.pa-row.is-selected td{background:#ebf0ff!important;}
/* ── Batch modal info ── */
.pa-batch-info{padding:10px 14px;background:#eff6ff;border:1px solid #bfdbfe;border-radius:var(--radius);margin-bottom:12px;font-size:13px;color:#1e40af;line-height:1.5;}
.pa-batch-info strong{font-weight:700;}
.pa-batch-emp-list{background:#fafbfc;border:1px solid #e0e5ed;border-radius:4px;padding:8px 12px;max-height:130px;overflow-y:auto;font-size:12px;color:#555;margin-bottom:14px;line-height:1.7;}
/* ── Toast ── */
.pa-toast{position:fixed;bottom:24px;right:24px;padding:12px 20px;font-size:13px;font-weight:600;color:#fff;z-index:9999;border-radius:var(--radius);opacity:0;transform:translateY(12px);transition:all .3s ease;pointer-events:none;max-width:360px;box-shadow:0 4px 16px rgba(0,0,0,.15);}
.pa-toast.is-visible{opacity:1;transform:translateY(0);}
.pa-toast--ok {background:var(--success);}
.pa-toast--err{background:var(--danger);}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Access hub tabs -->
<div class="acc-tabs">
    <a href="AccessControlCenter.aspx" class="acc-tab">Overview</a>
    <a href="UserRoleUsers.aspx" class="acc-tab acc-tab--active">Users</a>
    <a href="UserRoleRoles.aspx" class="acc-tab">Roles</a>
    <a href="UserRolePermissions.aspx" class="acc-tab">Permissions</a>
    <a href="UserRoleAudit.aspx" class="acc-tab">Audit</a>
</div>

<!-- Page Header -->
<div class="pa-page-header">
    <div class="pa-page-header__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24"
             fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
        </svg>
    </div>
    <div>
        <div class="pa-page-header__title">Users &amp; Role Assignment</div>
        <div class="pa-page-header__sub">Assign, review and revoke system access roles for all users</div>
    </div>
    <div class="pa-page-header__actions">
        <a href="UserRoleRoles.aspx" class="hr-btn hr-btn--outline">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="3"/>
                <path d="M19.07 4.93a10 10 0 1 1-14.14 0"/>
            </svg>
            Manage Roles
        </a>
        <a href="UserRolePermissions.aspx" class="hr-btn hr-btn--outline">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
            </svg>
            Permissions
        </a>
        <a href="UserRoleAudit.aspx" class="hr-btn hr-btn--outline">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
            </svg>
            Audit Log
        </a>
    </div>
</div>

<!-- Stat chips -->
<asp:Literal ID="litStats" runat="server"></asp:Literal>

<!-- Batch action bar (visible when rows are selected) -->
<div class="pa-batch-bar" id="batchBar">
    <span class="pa-batch-count" id="batchCount">0 selected</span>
    <div class="pa-batch-divider"></div>
    <span class="pa-batch-label">Batch action:</span>
    <div class="pa-batch-actions">
        <button type="button" class="pa-batch-btn pa-batch-btn--primary" onclick="openBatchAssignModal()">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Assign Role to Selected
        </button>
        <button type="button" class="pa-batch-btn pa-batch-btn--danger" id="btnBatchRevoke" onclick="openBatchRevokeModal()" disabled>
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            Revoke All Roles
        </button>
    </div>
    <button type="button" class="pa-batch-btn pa-batch-btn--outline" style="margin-left:auto;" onclick="clearSelection()">
        Clear Selection
    </button>
</div>

<!-- Table Card -->
<div class="cd-card">

    <!-- Filter bar -->
    <div class="pa-filter-bar">
        <input type="text" id="txtSearch" placeholder="&#x1F50D; Search username, name, email or department…"
               oninput="urmFilter()" autocomplete="off" />
        <select id="selType" onchange="urmFilter()">
            <option value="">All Users</option>
            <option value="staff">Staff Only</option>
            <option value="student">Students</option>
            <option value="system">System Accounts</option>
        </select>
        <select id="selRole" onchange="urmFilter()">
            <option value="">All Role Status</option>
            <option value="1">Has Role</option>
            <option value="0">No Role Assigned</option>
        </select>
        <select id="selStatus" onchange="urmFilter()">
            <option value="">All Account Status</option>
            <option value="active">Active</option>
            <option value="locked">Locked</option>
            <option value="inactive">Inactive</option>
        </select>
        <span class="pa-filter-bar__count" id="lblCount"></span>
    </div>

    <!-- Table -->
    <div class="pa-table-wrap">
    <table class="pa-table">
        <thead>
            <tr>
                <th class="pa-col-chk"><input type="checkbox" id="chkAll" onclick="onSelectAll(this)" title="Select / deselect all visible users" /></th>
                <th class="pa-col-num">#</th>
                <th style="min-width:190px;">Account</th>
                <th style="min-width:170px;">Full Name / Employee</th>
                <th style="min-width:130px;">Department</th>
                <th style="min-width:160px;">Assigned Roles</th>
                <th style="width:110px;">Last Active</th>
                <th style="width:90px;">Status</th>
                <th class="pa-col-act-hdr">Actions</th>
            </tr>
        </thead>
        <tbody id="tblBody">
            <asp:Literal ID="litRows" runat="server"></asp:Literal>
        </tbody>
    </table>
    </div>

</div>

<!-- ══════════════════════════════════════════
     MANAGE ROLES MODAL (multi-select)
     ══════════════════════════════════════════ -->
<style>
.mr-user{font-size:12px;color:#374151;margin:0 0 12px;}
.mr-user b{color:#05275C;}
.mr-tools{display:flex;gap:8px;margin-bottom:8px;align-items:center;}
.mr-tools input{flex:1;height:30px;border:1px solid #e0e5ed;font-size:12px;padding:0 9px;outline:none;border-radius:0;}
.mr-tools input:focus{border-color:#174DA4;}
.mr-tools button{font-size:11px;font-weight:600;border:1px solid #e0e5ed;background:#fff;padding:5px 11px;cursor:pointer;color:#374151;border-radius:0;white-space:nowrap;}
.mr-tools button:hover{background:#f5f7fa;}
.mr-checklist{max-height:46vh;overflow-y:auto;border:1px solid #e0e5ed;border-radius:4px;}
.role-check{display:flex;align-items:center;gap:9px;padding:9px 12px;border-bottom:1px solid #f1f5f9;cursor:pointer;font-size:13px;color:#1a1a2e;}
.role-check:last-child{border-bottom:none;}
.role-check:hover{background:#f8fafc;}
.role-check input{width:16px;height:16px;cursor:pointer;accent-color:#174DA4;flex-shrink:0;}
.role-check__dot{width:11px;height:11px;border-radius:50%;flex-shrink:0;}
.role-check__name{flex:1;font-weight:600;}
.role-check.was-assigned .role-check__name::after{content:'current';font-size:9px;font-weight:600;color:#16a34a;background:#f0fdf4;border:1px solid #bbf7d0;padding:1px 6px;border-radius:10px;margin-left:8px;vertical-align:middle;}
.role-check__sys{font-size:9px;font-weight:700;color:#fff;background:#7c3aed;padding:1px 6px;border-radius:2px;}
.mr-summary{font-size:12px;color:#64748b;margin-top:10px;min-height:18px;}
.mr-summary .add{color:#16a34a;font-weight:700;}
.mr-summary .rem{color:#dc2626;font-weight:700;}
.mr-none{padding:18px;text-align:center;color:#94a3b8;font-size:12px;}
</style>
<div class="pa-modal-overlay" id="modalAssign">
    <div class="pa-modal">
        <div class="pa-modal__head">
            <span class="pa-modal__title">Manage Roles</span>
            <button type="button" class="pa-modal__close" onclick="closeModal('modalAssign')">&times;</button>
        </div>
        <div class="pa-modal__body">
            <input type="hidden" id="mrUsername" />
            <div class="mr-user" id="mrUserLabel"></div>

            <div class="mr-tools">
                <input type="text" id="mrFilter" placeholder="&#x1F50D; Filter roles…" oninput="filterRoleChecklist()" autocomplete="off" />
                <button type="button" onclick="setAllRoles(true)">Select all</button>
                <button type="button" onclick="setAllRoles(false)">Clear all</button>
            </div>

            <div class="mr-checklist" id="roleChecklist">
                <asp:Literal ID="litRoleChecklist" runat="server"></asp:Literal>
                <div class="mr-none" id="mrNone" style="display:none;">No roles match your filter.</div>
            </div>

            <div class="mr-summary" id="mrSummary"></div>

            <div class="urm-field" style="margin-top:12px;">
                <label>Expires on <span style="color:#aaa;font-weight:400">(optional — applies to newly added roles)</span></label>
                <input type="date" id="assignExpiry" />
            </div>
            <div class="urm-field">
                <label>Notes <span style="color:#aaa;font-weight:400">(optional)</span></label>
                <textarea id="assignNotes" placeholder="Reason for this change…"></textarea>
            </div>

            <!-- hidden: kept so the batch-assign modal can clone the role options -->
            <select id="assignRoleId" style="display:none;">
                <option value="">— select a role —</option>
                <asp:Literal ID="litRoleOptions" runat="server"></asp:Literal>
            </select>
        </div>
        <div class="pa-modal__foot">
            <button type="button" class="hr-btn hr-btn--outline" onclick="closeModal('modalAssign')">Cancel</button>
            <button type="button" class="hr-btn hr-btn--primary" id="btnSaveAssign" onclick="saveRoles()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                     fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="20 6 9 17 4 12"/>
                </svg>
                Save Roles
            </button>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════
     REVOKE CONFIRM MODAL
     ══════════════════════════════════════════ -->
<div class="pa-modal-overlay" id="modalRevoke">
    <div class="pa-modal" style="width:420px;">
        <div class="pa-modal__head pa-modal__head--danger">
            <span class="pa-modal__title">Confirm Role Revocation</span>
            <button type="button" class="pa-modal__close" onclick="closeModal('modalRevoke')">&times;</button>
        </div>
        <div class="pa-modal__body">
            <div class="revoke-box">
                <div class="revoke-box__role" id="revokeRoleName"></div>
                <div class="revoke-box__user" id="revokeUserLabel"></div>
            </div>
            <p class="revoke-note">This will immediately remove the role. The user will lose all associated permissions on their next page visit.</p>
        </div>
        <div class="pa-modal__foot">
            <button type="button" class="hr-btn hr-btn--outline" onclick="closeModal('modalRevoke')">Cancel</button>
            <button type="button" class="hr-btn hr-btn--danger" id="btnConfirmRevoke" onclick="confirmRevoke()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24"
                     fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
                Revoke Role
            </button>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════
     BATCH ASSIGN MODAL
     ══════════════════════════════════════════ -->
<div class="pa-modal-overlay" id="modalBatchAssign">
    <div class="pa-modal">
        <div class="pa-modal__head">
            <span class="pa-modal__title">Batch Assign Role</span>
            <button type="button" class="pa-modal__close" onclick="closeModal('modalBatchAssign')">&times;</button>
        </div>
        <div class="pa-modal__body">
            <div class="pa-batch-info">
                Assigning to <strong id="batchAssignCount"></strong>.
                Existing roles are preserved — this adds the selected role to each user.
            </div>
            <div class="urm-field">
                <label>Role to Assign <span style="color:var(--danger)">*</span></label>
                <select id="batchAssignRoleId">
                    <option value="">— select a role —</option>
                </select>
            </div>
            <div class="urm-field">
                <label>Expires On</label>
                <input type="date" id="batchAssignExpiry" />
                <div class="urm-hint">Leave blank for permanent. Applies to all selected users.</div>
            </div>
            <div class="urm-field">
                <label>Notes <span style="color:#aaa;font-weight:400">(optional)</span></label>
                <textarea id="batchAssignNotes" placeholder="e.g. New staff onboarding — Jan 2026"></textarea>
            </div>
        </div>
        <div class="pa-modal__foot">
            <button type="button" class="hr-btn hr-btn--outline" onclick="closeModal('modalBatchAssign')">Cancel</button>
            <button type="button" class="hr-btn hr-btn--primary" id="btnSaveBatchAssign" onclick="saveBatchAssign()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Assign to All Selected
            </button>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════
     BATCH REVOKE MODAL
     ══════════════════════════════════════════ -->
<div class="pa-modal-overlay" id="modalBatchRevoke">
    <div class="pa-modal" style="width:460px;">
        <div class="pa-modal__head pa-modal__head--danger">
            <span class="pa-modal__title">Batch Revoke All Roles</span>
            <button type="button" class="pa-modal__close" onclick="closeModal('modalBatchRevoke')">&times;</button>
        </div>
        <div class="pa-modal__body">
            <div class="pa-batch-info" id="batchRevokeInfo" style="background:#fff5f5;border-color:#fca5a5;color:#991b1b;"></div>
            <div class="pa-batch-emp-list" id="batchRevokeList"></div>
            <p class="revoke-note">All active roles will be immediately removed from each listed user. Users with no roles are skipped.</p>
        </div>
        <div class="pa-modal__foot">
            <button type="button" class="hr-btn hr-btn--outline" onclick="closeModal('modalBatchRevoke')">Cancel</button>
            <button type="button" class="hr-btn hr-btn--danger" id="btnConfirmBatchRevoke" onclick="confirmBatchRevoke()">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                Revoke All Roles
            </button>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════════
     EFFECTIVE-ACCESS DRAWER
     ══════════════════════════════════════════ -->
<style>
.eff-scrim{position:fixed;inset:0;background:rgba(15,23,42,.45);opacity:0;visibility:hidden;transition:opacity .2s;z-index:1200;}
.eff-scrim.is-open{opacity:1;visibility:visible;}
.eff-drawer{position:fixed;top:0;right:0;height:100%;width:440px;max-width:92vw;background:#fff;box-shadow:-6px 0 28px rgba(0,0,0,.18);transform:translateX(100%);transition:transform .22s ease;z-index:1201;display:flex;flex-direction:column;}
.eff-drawer.is-open{transform:translateX(0);}
.eff-drawer__head{padding:16px 20px;border-bottom:1px solid #e0e5ed;display:flex;align-items:flex-start;justify-content:space-between;gap:12px;}
.eff-drawer__title{font-size:15px;font-weight:700;color:#05275C;margin:0;}
.eff-drawer__sub{font-size:11px;color:#64748b;margin:3px 0 0;}
.eff-drawer__close{background:none;border:none;font-size:22px;line-height:1;color:#94a3b8;cursor:pointer;}
.eff-drawer__body{padding:16px 20px;overflow-y:auto;flex:1;}
.eff-roles{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:14px;}
.eff-rolechip{display:inline-flex;align-items:center;gap:5px;padding:4px 10px;border-radius:20px;color:#fff;font-size:11px;font-weight:600;}
.eff-summary{font-size:12px;color:#1a1a2e;background:#f5f7fa;border:1px solid #e0e5ed;padding:8px 12px;border-radius:4px;margin-bottom:14px;}
.eff-sec{margin-bottom:14px;}
.eff-sec__hd{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#174DA4;padding-bottom:5px;border-bottom:1px solid #eef1f6;margin-bottom:6px;}
.eff-item{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:5px 0;border-bottom:1px dashed #f0f2f7;}
.eff-item:last-child{border-bottom:none;}
.eff-item__lbl{font-size:12px;color:#1a1a2e;}
.eff-item__slug{font-family:monospace;font-size:9px;color:#94a3b8;}
.eff-item__roles{display:flex;flex-wrap:wrap;gap:4px;justify-content:flex-end;}
.eff-dot{width:9px;height:9px;border-radius:50%;flex-shrink:0;}
.eff-empty{font-size:12px;color:#64748b;text-align:center;padding:30px 0;}
.eff-admin{font-size:13px;color:#166534;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:4px;padding:14px;text-align:center;}
</style>
<div class="eff-scrim" id="effScrim" onclick="closeDrawer()"></div>
<div class="eff-drawer" id="effDrawer" role="dialog" aria-label="Effective access">
    <div class="eff-drawer__head">
        <div>
            <div class="eff-drawer__title" id="effTitle">Effective access</div>
            <div class="eff-drawer__sub" id="effSub"></div>
        </div>
        <button type="button" class="eff-drawer__close" onclick="closeDrawer()">&times;</button>
    </div>
    <div class="eff-drawer__body" id="effBody"></div>
</div>

<!-- Toast -->
<div class="pa-toast" id="paToast"></div>

<script type="text/javascript">
// ═══════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════
function findParentTr(el) {
    while (el && el.tagName !== 'TR') el = el.parentNode;
    return el || null;
}
function escHtml(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ═══════════════════════════════════════════════════════
//  FILTER
// ═══════════════════════════════════════════════════════
var _roleIdFilter = '';   // set via ?role_id=… (Members link from Roles tab)

function urmFilter() {
    var q      = (document.getElementById('txtSearch').value  || '').toLowerCase().trim();
    var type   = (document.getElementById('selType').value    || '');
    var role   = (document.getElementById('selRole').value    || '');
    var status = (document.getElementById('selStatus').value  || '');

    var rows = document.querySelectorAll('#tblBody tr.pa-row');
    var n = 0, idx = 0;
    for (var i = 0; i < rows.length; i++) {
        var row    = rows[i];
        var search = (row.getAttribute('data-search')  || '').toLowerCase();
        var rType  = (row.getAttribute('data-type')    || '');
        var rRole  = (row.getAttribute('data-hasrole') || '0');
        var rStat  = (row.getAttribute('data-status')  || '');

        var show = true;
        if (q      && search.indexOf(q) < 0) show = false;
        if (type   && rType  !== type)       show = false;
        if (role   && rRole  !== role)       show = false;
        if (status && rStat  !== status)     show = false;
        if (_roleIdFilter) {
            var rids = ('' + (row.getAttribute('data-roleids') || '')).split(',');
            if (rids.indexOf(_roleIdFilter) < 0) show = false;
        }

        row.style.display = show ? '' : 'none';
        if (show) {
            idx++;
            var numCell = row.querySelector('.pa-col-num');
            if (numCell) numCell.textContent = idx;
            n++;
        }
    }
    document.getElementById('lblCount').textContent = n + ' user' + (n !== 1 ? 's' : '');
    updateSelectAllState();
}

// Apply deep-link filters from the hub (?filter=norole, ?role_id=N from Members)
(function applyDeepLinkFilter(){
    try {
        var qs = new URLSearchParams(window.location.search);
        var f  = (qs.get('filter') || '').toLowerCase();
        if (f === 'norole') { document.getElementById('selRole').value = '0'; }

        var rid = (qs.get('role_id') || '').trim();
        if (rid && /^[0-9]+$/.test(rid)) {
            _roleIdFilter = rid;
            var card = document.querySelector('.cd-card');
            if (card && card.parentNode) {
                var banner = document.createElement('div');
                banner.className = 'pa-rolefilter-banner';
                banner.style.cssText = 'display:flex;align-items:center;gap:10px;margin:0 0 12px;padding:9px 14px;background:#eff6ff;border:1px solid #bfdbfe;border-radius:4px;font-size:12px;color:#05275C;';
                banner.innerHTML = '<span style="flex:1;">Showing only users assigned to the selected role.</span>' +
                    '<a href="UserRoleUsers.aspx" style="color:#174DA4;font-weight:600;text-decoration:none;">Show all users &times;</a>';
                card.parentNode.insertBefore(banner, card);
            }
        }
    } catch (e) { /* older browsers: ignore */ }
})();
urmFilter();

function filterByChip(typeVal, roleVal) {
    document.getElementById('selType').value   = typeVal;
    document.getElementById('selRole').value   = roleVal;
    document.getElementById('selStatus').value = '';
    document.getElementById('txtSearch').value = '';
    urmFilter();
    if (event && event.currentTarget) event.currentTarget.classList.add('is-active');
}

// ═══════════════════════════════════════════════════════
//  SELECTION & BATCH BAR
// ═══════════════════════════════════════════════════════
var _sel = {};   // username -> { displayName, hasRole }

function getRowMeta(row) {
    var nameEl = row.querySelector('.uru-user__name');
    return {
        displayName : nameEl ? nameEl.textContent.trim() : '',
        hasRole     : row.getAttribute('data-hasrole') === '1'
    };
}

function onSelectAll(cb) {
    var checks = document.querySelectorAll('#tblBody .pa-row-chk');
    for (var i = 0; i < checks.length; i++) {
        var chk = checks[i];
        var row = findParentTr(chk);
        if (row && row.style.display === 'none') continue;   // skip hidden rows
        chk.checked = cb.checked;
        var uname = chk.value;
        if (cb.checked) {
            _sel[uname] = getRowMeta(row);
            if (row) row.classList.add('is-selected');
        } else {
            delete _sel[uname];
            if (row) row.classList.remove('is-selected');
        }
    }
    updateBatchBar();
}

function onRowCheck(cb, evt) {
    if (evt) evt.stopPropagation();
    var uname = cb.value;
    var row   = findParentTr(cb);
    if (cb.checked) {
        _sel[uname] = getRowMeta(row);
        if (row) row.classList.add('is-selected');
    } else {
        delete _sel[uname];
        if (row) row.classList.remove('is-selected');
    }
    updateSelectAllState();
    updateBatchBar();
}

function updateSelectAllState() {
    var allChks     = document.querySelectorAll('#tblBody .pa-row-chk');
    var visibleChks = [];
    for (var i = 0; i < allChks.length; i++) {
        var r = findParentTr(allChks[i]);
        if (!r || r.style.display !== 'none') visibleChks.push(allChks[i]);
    }
    var checkedCnt = 0;
    for (var j = 0; j < visibleChks.length; j++) if (visibleChks[j].checked) checkedCnt++;
    var ca = document.getElementById('chkAll');
    if (ca) {
        ca.indeterminate = checkedCnt > 0 && checkedCnt < visibleChks.length;
        ca.checked       = visibleChks.length > 0 && checkedCnt === visibleChks.length;
    }
}

function updateBatchBar() {
    var keys = Object.keys(_sel);
    var n    = keys.length;
    var bar  = document.getElementById('batchBar');
    var cnt  = document.getElementById('batchCount');
    if (bar) bar.classList.toggle('is-active', n > 0);
    if (cnt) cnt.textContent = n + ' user' + (n !== 1 ? 's' : '') + ' selected';

    // Enable Revoke button only if at least one selected user has a role
    var hasWithRole = false;
    for (var k in _sel) { if (_sel[k].hasRole) { hasWithRole = true; break; } }
    var btnRev = document.getElementById('btnBatchRevoke');
    if (btnRev) btnRev.disabled = !hasWithRole;
}

function clearSelection() {
    _sel = {};
    var checks = document.querySelectorAll('#tblBody .pa-row-chk');
    for (var i = 0; i < checks.length; i++) checks[i].checked = false;
    var ca = document.getElementById('chkAll');
    if (ca) { ca.checked = false; ca.indeterminate = false; }
    var rows = document.querySelectorAll('#tblBody tr.pa-row.is-selected');
    for (var j = 0; j < rows.length; j++) rows[j].classList.remove('is-selected');
    updateBatchBar();
}

// ═══════════════════════════════════════════════════════
//  ACTION DROPDOWN
// ═══════════════════════════════════════════════════════
function toggleActMenu(btn) {
    var drop    = btn.nextElementSibling;
    var wasOpen = drop && drop.classList.contains('is-open');
    closeAllMenus();
    if (!wasOpen && drop) { drop.classList.add('is-open'); btn.classList.add('is-open'); }
}
function closeAllMenus() {
    var drops = document.querySelectorAll('.pa-act-drop.is-open');
    for (var i = 0; i < drops.length; i++) drops[i].classList.remove('is-open');
    var btns  = document.querySelectorAll('.pa-act-btn.is-open');
    for (var j = 0; j < btns.length; j++) btns[j].classList.remove('is-open');
}
document.addEventListener('click', function (e) {
    var inMenu = false, t = e.target;
    while (t && t !== document) {
        if (t.className && typeof t.className === 'string' && t.className.indexOf('pa-act-menu') >= 0) { inMenu = true; break; }
        t = t.parentNode;
    }
    if (!inMenu) closeAllMenus();
});

// Action item delegation (single-row assign / revoke)
document.addEventListener('click', function (e) {
    var item = null, t = e.target;
    while (t && t !== document) {
        if (t.getAttribute && t.getAttribute('data-action')) { item = t; break; }
        t = t.parentNode;
    }
    if (!item) return;
    e.stopPropagation();
    closeAllMenus();
    var action = item.getAttribute('data-action');
    var uname  = item.getAttribute('data-uname') || '';
    if      (action === 'manage')    { var tr = findParentTr(item); openManageRoles(uname, tr ? (tr.getAttribute('data-roleids') || '') : ''); }
    else if (action === 'effective') { openEffectiveDrawer(uname); }
});

document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
        closeAllMenus();
        closeModal('modalAssign');
        closeModal('modalRevoke');
        closeModal('modalBatchAssign');
        closeModal('modalBatchRevoke');
        closeDrawer();
    }
});

// ═══════════════════════════════════════════════════════
//  MODAL HELPERS
// ═══════════════════════════════════════════════════════
function closeModal(id) { document.getElementById(id).classList.remove('is-open'); }

// ═══════════════════════════════════════════════════════
//  MANAGE ROLES (multi-select: assign + remove in one go)
// ═══════════════════════════════════════════════════════
function openManageRoles(username, currentCsv) {
    document.getElementById('mrUsername').value = username;
    document.getElementById('mrUserLabel').innerHTML = 'Tick the roles for <b>' + escHtml(username) + '</b>. Unticking a current role removes it.';

    var current = {};
    (currentCsv || '').split(',').forEach(function(x){ x = x.trim(); if (x) current[x] = 1; });

    var boxes = document.querySelectorAll('#roleChecklist .mr-box');
    for (var i = 0; i < boxes.length; i++) {
        var on  = !!current[boxes[i].value];
        boxes[i].checked = on;
        boxes[i].setAttribute('data-orig', on ? '1' : '0');
        var lbl = boxes[i].closest('.role-check');
        if (lbl) lbl.classList.toggle('was-assigned', on);
    }

    document.getElementById('assignExpiry').value = '';
    document.getElementById('assignNotes').value  = '';
    document.getElementById('mrFilter').value     = '';
    filterRoleChecklist();
    updateRoleSummary();

    var btn = document.getElementById('btnSaveAssign');
    btn.disabled = false; btn.textContent = 'Save Roles';
    document.getElementById('modalAssign').classList.add('is-open');
    setTimeout(function(){ document.getElementById('mrFilter').focus(); }, 80);
}

function filterRoleChecklist() {
    var q = (document.getElementById('mrFilter').value || '').toLowerCase().trim();
    var rows = document.querySelectorAll('#roleChecklist .role-check');
    var shown = 0;
    for (var i = 0; i < rows.length; i++) {
        var name = (rows[i].getAttribute('data-name') || '');
        var show = !q || name.indexOf(q) >= 0;
        rows[i].style.display = show ? '' : 'none';
        if (show) shown++;
    }
    document.getElementById('mrNone').style.display = (shown === 0) ? 'block' : 'none';
}

function setAllRoles(on) {
    var boxes = document.querySelectorAll('#roleChecklist .role-check');
    for (var i = 0; i < boxes.length; i++) {
        if (boxes[i].style.display === 'none') continue;       // only affect visible (filtered) rows
        var cb = boxes[i].querySelector('.mr-box');
        if (cb) cb.checked = on;
    }
    updateRoleSummary();
}

function updateRoleSummary() {
    var boxes = document.querySelectorAll('#roleChecklist .mr-box');
    var add = 0, rem = 0;
    for (var i = 0; i < boxes.length; i++) {
        var orig = boxes[i].getAttribute('data-orig') === '1';
        if (boxes[i].checked && !orig) add++;
        else if (!boxes[i].checked && orig) rem++;
    }
    var el = document.getElementById('mrSummary');
    if (!add && !rem) el.innerHTML = 'No changes yet.';
    else el.innerHTML = '<span class="add">+' + add + ' to add</span> &nbsp;·&nbsp; <span class="rem">&minus;' + rem + ' to remove</span>';
}

function saveRoles() {
    var username = document.getElementById('mrUsername').value;
    var expiry   = document.getElementById('assignExpiry').value;
    var notes    = document.getElementById('assignNotes').value;

    var ids = [], add = 0, rem = 0;
    var boxes = document.querySelectorAll('#roleChecklist .mr-box');
    for (var i = 0; i < boxes.length; i++) {
        var orig = boxes[i].getAttribute('data-orig') === '1';
        if (boxes[i].checked) ids.push(boxes[i].value);
        if (boxes[i].checked && !orig) add++;
        else if (!boxes[i].checked && orig) rem++;
    }

    if (!add && !rem) { showToast('No changes to save.', 'err'); return; }
    if (rem > 0 && !confirm('This will remove ' + rem + ' role' + (rem !== 1 ? 's' : '') + ' from this user. Continue?')) return;

    var btn = document.getElementById('btnSaveAssign');
    btn.disabled = true; btn.textContent = 'Saving…';

    fetch('UserRoleUsers.aspx?ajax=set_roles', {
        method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'username=' + encodeURIComponent(username) +
              '&role_ids=' + encodeURIComponent(ids.join(',')) +
              '&expiry='   + encodeURIComponent(expiry) +
              '&notes='    + encodeURIComponent(notes)
    })
    .then(function(r){ return r.json(); })
    .then(function(d){
        btn.disabled = false; btn.textContent = 'Save Roles';
        if (d.ok) {
            closeModal('modalAssign');
            var msg = 'Roles updated';
            var parts = [];
            if (d.added)   parts.push('+' + d.added + ' added');
            if (d.removed) parts.push('−' + d.removed + ' removed');
            if (parts.length) msg += ' (' + parts.join(', ') + ')';
            showToast(msg + '.', 'ok');
            setTimeout(function(){ location.reload(); }, 1100);
        } else showToast(d.error || 'Failed to save.', 'err');
    })
    .catch(function(){ btn.disabled = false; btn.textContent = 'Save Roles'; showToast('Network error.', 'err'); });
}

// ═══════════════════════════════════════════════════════
//  SINGLE REVOKE ROLE
// ═══════════════════════════════════════════════════════
var _revokeUser = '', _revokeRoleId = 0;

function openRevokeModal(username, roleId, roleName) {
    _revokeUser = username; _revokeRoleId = roleId;
    document.getElementById('revokeRoleName').textContent  = roleName;
    document.getElementById('revokeUserLabel').textContent = 'User: ' + username;
    var btn = document.getElementById('btnConfirmRevoke');
    btn.disabled = false; btn.textContent = 'Revoke Role';
    document.getElementById('modalRevoke').classList.add('is-open');
}

function confirmRevoke() {
    var btn = document.getElementById('btnConfirmRevoke');
    btn.disabled = true; btn.textContent = 'Revoking…';
    fetch('UserRoleUsers.aspx?ajax=revoke', {
        method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'username=' + encodeURIComponent(_revokeUser) + '&role_id=' + encodeURIComponent(_revokeRoleId)
    })
    .then(function(r){return r.json();})
    .then(function(d){
        btn.disabled=false; btn.textContent='Revoke Role';
        closeModal('modalRevoke');
        if(d.ok){showToast('Role revoked.','ok');setTimeout(function(){location.reload();},900);}
        else showToast(d.error||'Failed.','err');
    })
    .catch(function(){btn.disabled=false;btn.textContent='Revoke Role';showToast('Network error.','err');});
}

// ═══════════════════════════════════════════════════════
//  BATCH ASSIGN ROLE
// ═══════════════════════════════════════════════════════
function openBatchAssignModal() {
    var keys = Object.keys(_sel);
    if (!keys.length) { showToast('No users selected.', 'err'); return; }

    // Populate role options by cloning from single-assign select
    var srcSelect  = document.getElementById('assignRoleId');
    var destSelect = document.getElementById('batchAssignRoleId');
    destSelect.innerHTML = '<option value="">— select a role —</option>';
    var opts = srcSelect.options;
    for (var i = 1; i < opts.length; i++) {
        var o = document.createElement('option');
        o.value       = opts[i].value;
        o.textContent = opts[i].text;
        destSelect.appendChild(o);
    }

    document.getElementById('batchAssignCount').textContent = keys.length + ' user' + (keys.length !== 1 ? 's' : '');
    document.getElementById('batchAssignExpiry').value = '';
    document.getElementById('batchAssignNotes').value  = '';
    var btn = document.getElementById('btnSaveBatchAssign');
    btn.disabled = false; btn.textContent = 'Assign to All Selected';
    document.getElementById('modalBatchAssign').classList.add('is-open');
}

function saveBatchAssign() {
    var keys   = Object.keys(_sel);
    var roleId = document.getElementById('batchAssignRoleId').value;
    var expiry = document.getElementById('batchAssignExpiry').value;
    var notes  = document.getElementById('batchAssignNotes').value;

    if (!keys.length) { showToast('No users selected.', 'err'); return; }
    if (!roleId)      { showToast('Please select a role.', 'err'); return; }

    var btn = document.getElementById('btnSaveBatchAssign');
    btn.disabled = true; btn.textContent = 'Assigning…';

    fetch('UserRoleUsers.aspx?ajax=batch_assign', {
        method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'usernames=' + encodeURIComponent(keys.join(',')) +
              '&role_id='  + encodeURIComponent(roleId) +
              '&expiry='   + encodeURIComponent(expiry) +
              '&notes='    + encodeURIComponent(notes)
    })
    .then(function(r){return r.json();})
    .then(function(d){
        btn.disabled=false; btn.textContent='Assign to All Selected';
        if(d.ok){
            closeModal('modalBatchAssign');
            showToast('Role assigned to ' + (d.count || keys.length) + ' user(s).', 'ok');
            setTimeout(function(){location.reload();}, 1200);
        } else showToast(d.error||'Failed.','err');
    })
    .catch(function(){btn.disabled=false;btn.textContent='Assign to All Selected';showToast('Network error.','err');});
}

// ═══════════════════════════════════════════════════════
//  BATCH REVOKE ALL ROLES
// ═══════════════════════════════════════════════════════
function openBatchRevokeModal() {
    var keys      = Object.keys(_sel);
    var withRoles = keys.filter(function(u){ return _sel[u].hasRole; });

    if (!withRoles.length) {
        showToast('None of the selected users have roles to revoke.', 'err');
        return;
    }

    var infoEl = document.getElementById('batchRevokeInfo');
    infoEl.innerHTML = '<strong>' + withRoles.length + ' user' + (withRoles.length !== 1 ? 's' : '') +
                       '</strong> will have all their roles removed.';
    if (keys.length > withRoles.length) {
        infoEl.innerHTML += ' <span style="font-weight:400;font-size:11px;">' +
            (keys.length - withRoles.length) + ' selected user(s) with no roles will be skipped.</span>';
    }

    var listEl = document.getElementById('batchRevokeList');
    var html = '';
    for (var i = 0; i < Math.min(withRoles.length, 10); i++) {
        var meta = _sel[withRoles[i]];
        var name = meta.displayName || withRoles[i];
        html += '<div>' + escHtml(name) + (name !== withRoles[i] ? ' &mdash; <span style="color:#888;">' + escHtml(withRoles[i]) + '</span>' : '') + '</div>';
    }
    if (withRoles.length > 10)
        html += '<div style="color:#888;font-style:italic;">…and ' + (withRoles.length - 10) + ' more</div>';
    listEl.innerHTML = html;

    var btn = document.getElementById('btnConfirmBatchRevoke');
    btn.disabled = false; btn.textContent = 'Revoke All Roles';
    document.getElementById('modalBatchRevoke').classList.add('is-open');
}

function confirmBatchRevoke() {
    var keys      = Object.keys(_sel);
    var withRoles = keys.filter(function(u){ return _sel[u].hasRole; });
    if (!withRoles.length) { closeModal('modalBatchRevoke'); return; }

    var btn = document.getElementById('btnConfirmBatchRevoke');
    btn.disabled = true; btn.textContent = 'Revoking…';

    fetch('UserRoleUsers.aspx?ajax=batch_revoke_all', {
        method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'usernames=' + encodeURIComponent(withRoles.join(','))
    })
    .then(function(r){return r.json();})
    .then(function(d){
        btn.disabled=false; btn.textContent='Revoke All Roles';
        closeModal('modalBatchRevoke');
        if(d.ok){
            showToast((d.count || withRoles.length) + ' user(s) had all roles revoked.', 'ok');
            setTimeout(function(){location.reload();}, 900);
        } else showToast(d.error||'Failed.','err');
    })
    .catch(function(){btn.disabled=false;btn.textContent='Revoke All Roles';showToast('Network error.','err');});
}

// ═══════════════════════════════════════════════════════
//  EFFECTIVE-ACCESS DRAWER
// ═══════════════════════════════════════════════════════
function closeDrawer() {
    document.getElementById('effDrawer').classList.remove('is-open');
    document.getElementById('effScrim').classList.remove('is-open');
}

function openEffectiveDrawer(username) {
    document.getElementById('effTitle').textContent = 'Access for ' + username;
    document.getElementById('effSub').textContent   = 'Loading…';
    document.getElementById('effBody').innerHTML     = '<div class="eff-empty">Loading…</div>';
    document.getElementById('effDrawer').classList.add('is-open');
    document.getElementById('effScrim').classList.add('is-open');

    fetch('UserRoleUsers.aspx?ajax=effective&username=' + encodeURIComponent(username))
    .then(function(r){return r.json();})
    .then(function(d){ renderEffective(d); })
    .catch(function(){
        document.getElementById('effSub').textContent = '';
        document.getElementById('effBody').innerHTML  = '<div class="eff-empty" style="color:#dc2626;">Network error loading access.</div>';
    });
}

function renderEffective(d) {
    if (!d || !d.ok) {
        document.getElementById('effSub').textContent = '';
        document.getElementById('effBody').innerHTML  = '<div class="eff-empty" style="color:#dc2626;">' + escHtml((d && d.error) || 'Could not load access.') + '</div>';
        return;
    }

    // Role chips header
    var sub = '';
    if (d.role_count > 0) {
        sub = d.role_count + ' role' + (d.role_count !== 1 ? 's' : '');
        if (!d.is_admin) sub += ' · ' + d.total_slugs + ' page' + (d.total_slugs !== 1 ? 's' : '');
    } else {
        sub = 'No active roles';
    }
    document.getElementById('effSub').textContent = sub;

    var html = '';
    if (d.roles && d.roles.length) {
        html += '<div class="eff-roles">';
        for (var i = 0; i < d.roles.length; i++) {
            var r = d.roles[i];
            html += '<span class="eff-rolechip" style="background:' + escHtml(r.color || '#64748b') + '">' + escHtml(r.name) + '</span>';
        }
        html += '</div>';
    }

    if (d.is_admin) {
        html += '<div class="eff-admin"><strong>Full system access</strong><br>This user holds the Administrator role and can open every screen.</div>';
        document.getElementById('effBody').innerHTML = html;
        return;
    }

    if (d.role_count === 0) {
        html += '<div class="eff-empty">This user has no active role, so they currently have no granted screens.</div>';
        document.getElementById('effBody').innerHTML = html;
        return;
    }

    if (!d.sections || !d.sections.length) {
        html += '<div class="eff-empty">This user\'s role(s) grant no page permissions yet.</div>';
        document.getElementById('effBody').innerHTML = html;
        return;
    }

    html += '<div class="eff-summary">Showing every screen this user can open, grouped by area, with the role that grants each.</div>';
    for (var s = 0; s < d.sections.length; s++) {
        var sec = d.sections[s];
        html += '<div class="eff-sec"><div class="eff-sec__hd">' + escHtml(sec.name) + '</div>';
        for (var k = 0; k < sec.items.length; k++) {
            var it = sec.items[k];
            html += '<div class="eff-item"><div><div class="eff-item__lbl">' + escHtml(it.label) + '</div>' +
                    '<div class="eff-item__slug">' + escHtml(it.slug) + '</div></div><div class="eff-item__roles">';
            for (var rr = 0; rr < it.roles.length; rr++) {
                html += '<span class="eff-dot" style="background:' + escHtml(it.roles[rr].color || '#64748b') + '" title="' + escHtml(it.roles[rr].name) + '"></span>';
            }
            html += '</div></div>';
        }
        html += '</div>';
    }
    document.getElementById('effBody').innerHTML = html;
}

// ═══════════════════════════════════════════════════════
//  TOAST
// ═══════════════════════════════════════════════════════
var _toastTimer;
function showToast(msg, type) {
    var t = document.getElementById('paToast');
    t.textContent = msg;
    t.className   = 'pa-toast pa-toast--' + (type || 'ok') + ' is-visible';
    clearTimeout(_toastTimer);
    _toastTimer = setTimeout(function(){ t.classList.remove('is-visible'); }, 3800);
}
</script>
</asp:Content>
