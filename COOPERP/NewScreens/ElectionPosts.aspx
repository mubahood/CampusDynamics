<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ElectionPosts.aspx.cs" Inherits="COOPERP_NewScreens_ElectionPosts" Title="Election Posts - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ELECTION POSTS — RESPONSIVE ===== */

/* -- Page Header --------------------------------------- */
.el-page-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 12px 0 10px; margin-bottom: 14px;
    border-bottom: 2px solid #174DA4;
    flex-wrap: wrap; gap: 8px;
}
.el-page-header__left { display: flex; align-items: center; gap: 10px; min-width: 0; }
.el-page-header__icon {
    width: 36px; height: 36px; background: #174DA4;
    display: flex; align-items: center; justify-content: center;
    border-radius: 6px; flex-shrink: 0;
}
.el-page-header__title { font-size: 16px; font-weight: 700; color: #1a1a2e; margin: 0; line-height: 1.2; }
.el-page-header__sub   { font-size: 11px; color: #888; margin-top: 1px; }

/* -- Stats Row ----------------------------------------- */
.el-stats {
    display: grid; grid-template-columns: repeat(3, 1fr);
    gap: 8px; margin-bottom: 12px;
}
.el-stat {
    background: #fff; border: 1px solid #e4e8f0;
    padding: 10px 14px; display: flex; align-items: center; gap: 10px;
    border-radius: 6px; transition: box-shadow .15s, transform .15s; cursor: default;
}
.el-stat:hover { box-shadow: 0 3px 12px rgba(23,77,164,.10); transform: translateY(-1px); }
.el-stat__icon { width: 34px; height: 34px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 6px; }
.el-stat__body { min-width: 0; }
.el-stat__val  { font-size: 20px; font-weight: 700; line-height: 1.1; }
.el-stat__label{ font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 1px; white-space: nowrap; }
.el-stat--blue  .el-stat__icon { background: #e8f0fc; } .el-stat--blue  .el-stat__val { color: #174DA4; }
.el-stat--green .el-stat__icon { background: #e6f4ea; } .el-stat--green .el-stat__val { color: #28a745; }
.el-stat--amber .el-stat__icon { background: #fff8e1; } .el-stat--amber .el-stat__val { color: #e67e00; }

/* -- Card ---------------------------------------------- */
.cd-card { background: #fff; border: 1px solid #e4e8f0; margin-bottom: 12px; border-radius: 6px; overflow: hidden; }
.cd-card__header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 9px 14px; border-bottom: 1px solid #e4e8f0; background: #fafbfc;
    flex-wrap: wrap; gap: 6px;
}
.cd-card__title { font-size: 13px; font-weight: 700; color: #1a1a1a; display: flex; align-items: center; gap: 7px; }

/* -- Filter Bar ---------------------------------------- */
.el-filters { background: #f8f9fa; border-bottom: 1px solid #e4e8f0; padding: 8px 12px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.el-filter-input { border: 1px solid #ddd; border-radius: 6px; padding: 5px 8px; font-size: 11px; background: #fff; color: #333; min-width: 180px; }
.el-filter-input:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.el-filter-select { border: 1px solid #ddd; border-radius: 6px; padding: 5px 8px; font-size: 11px; background: #fff; color: #333; cursor: pointer; min-width: 140px; }
.el-filter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }

/* -- Table --------------------------------------------- */
.el-table { width: 100%; border-collapse: collapse; font-size: 12px; }
.el-table th {
    background: #f5f7fa; border-bottom: 2px solid #e4e8f0;
    padding: 8px 12px; text-align: left; font-size: 10px;
    text-transform: uppercase; letter-spacing: .4px; color: #555; font-weight: 700;
    white-space: nowrap;
}
.el-table td { padding: 8px 12px; border-bottom: 1px solid #f0f2f5; vertical-align: middle; }
.el-table tr:hover td { background: #f8faff; }
.el-post-code { display: inline-block; padding: 2px 7px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px; border-radius: 3px; background: #e8f0fc; color: #174DA4; }
.el-badge-active { display: inline-block; padding: 2px 8px; font-size: 9px; font-weight: 700; border-radius: 3px; background: #d4edda; color: #155724; }
.el-badge-inactive { display: inline-block; padding: 2px 8px; font-size: 9px; font-weight: 700; border-radius: 3px; background: #e2e3e5; color: #383d41; }
.el-badge-count { display: inline-block; padding: 2px 7px; font-size: 10px; font-weight: 600; border-radius: 10px; background: rgba(23,77,164,.08); color: #174DA4; min-width: 20px; text-align: center; }

/* -- Buttons ------------------------------------------- */
.el-btn {
    padding: 6px 13px; font-size: 11px; font-weight: 600;
    border: none; cursor: pointer; border-radius: 6px;
    display: inline-flex; align-items: center; gap: 5px;
    white-space: nowrap; line-height: 1.4;
    transition: background .15s, box-shadow .15s, transform .1s;
}
.el-btn:active { transform: scale(.97); }
.el-btn--primary { background: #174DA4; color: #fff; }  .el-btn--primary:hover { background: #0f3a7d; box-shadow: 0 2px 8px rgba(23,77,164,.25); }
.el-btn--success { background: #28a745; color: #fff; }  .el-btn--success:hover { background: #218838; }
.el-btn--danger  { background: #dc3545; color: #fff; }  .el-btn--danger:hover  { background: #c82333; }
.el-btn--outline { background: #fff; color: #174DA4; border: 1px solid #174DA4; } .el-btn--outline:hover { background: #174DA4; color: #fff; }
.el-btn--ghost   { background: transparent; color: #555; border: 1px solid #ddd; } .el-btn--ghost:hover { border-color: #174DA4; color: #174DA4; background: rgba(23,77,164,.04); }
.el-btn--sm      { padding: 5px 10px; font-size: 10px; }

/* -- Flash Messages ------------------------------------ */
.el-flash {
    padding: 9px 14px; margin-bottom: 10px; border-radius: 6px;
    font-size: 12px; display: flex; align-items: center; gap: 8px;
}
.el-flash--ok  { background: #e6f4ea; color: #155724; border-left: 3px solid #28a745; }
.el-flash--err { background: #fdecea; color: #b91c1c; border-left: 3px solid #dc3545; }

/* -- Modal --------------------------------------------- */
.el-modal-overlay {
    display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,.48); z-index: 10000;
    align-items: center; justify-content: center;
    padding: 16px; box-sizing: border-box;
}
.el-modal {
    background: #fff; width: 580px; max-width: 100%;
    max-height: calc(100vh - 32px); overflow: hidden;
    border-radius: 8px; box-shadow: 0 16px 48px rgba(0,0,0,.25);
    display: flex; flex-direction: column;
    animation: elModalIn .18s ease;
}
@keyframes elModalIn { from { opacity: 0; transform: translateY(-12px) scale(.98); } to { opacity: 1; transform: none; } }
.el-modal__header {
    background: #174DA4; color: #fff; padding: 11px 16px;
    font-size: 13px; font-weight: 700;
    display: flex; align-items: center; justify-content: space-between;
    flex-shrink: 0; border-radius: 8px 8px 0 0;
}
.el-modal__close { background: none; border: none; color: rgba(255,255,255,.8); font-size: 22px; cursor: pointer; line-height: 1; padding: 0 2px; transition: color .15s; }
.el-modal__close:hover { color: #fff; }
.el-modal__body { padding: 16px; flex: 1; overflow-y: auto; }
.el-modal__footer {
    padding: 10px 16px; border-top: 1px solid #e4e8f0;
    display: flex; justify-content: flex-end; gap: 8px;
    flex-shrink: 0; background: #fafbfc; border-radius: 0 0 8px 8px;
}

/* -- Form ---------------------------------------------- */
.el-form-group  { margin-bottom: 10px; }
.el-form-label  { display: block; font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #555; font-weight: 600; margin-bottom: 3px; }
.el-form-label .req { color: #dc3545; margin-left: 2px; }
.el-form-input,
.el-form-select,
.el-form-textarea {
    width: 100%; padding: 6px 9px; border: 1px solid #ccc;
    border-radius: 5px; font-size: 12px; box-sizing: border-box; background: #fff;
    transition: border-color .15s, box-shadow .15s;
}
.el-form-input:focus,
.el-form-select:focus,
.el-form-textarea:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.el-form-row  { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.el-form-row3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
.el-form-hint { font-size: 10px; color: #888; margin-top: 2px; }

/* -- Toggle switch ------------------------------------- */
.el-toggle { display: flex; align-items: center; gap: 8px; cursor: pointer; }
.el-toggle input { display: none; }
.el-toggle__track {
    width: 36px; height: 20px; background: #ccc; border-radius: 10px;
    position: relative; transition: background .2s;
}
.el-toggle input:checked + .el-toggle__track { background: #28a745; }
.el-toggle__track::after {
    content: ''; position: absolute; top: 2px; left: 2px;
    width: 16px; height: 16px; background: #fff; border-radius: 50%;
    transition: transform .2s;
}
.el-toggle input:checked + .el-toggle__track::after { transform: translateX(16px); }
.el-toggle__label { font-size: 12px; color: #333; }

/* -- Empty state --------------------------------------- */
.el-empty { text-align: center; padding: 40px 20px; color: #999; }
.el-empty svg { margin-bottom: 10px; opacity: .4; }
.el-empty__title { font-size: 14px; font-weight: 600; color: #666; }
.el-empty__sub { font-size: 12px; margin-top: 4px; }

/* -- Responsive ---------------------------------------- */
@media (max-width: 768px) {
    .el-stats { grid-template-columns: 1fr; }
    .el-form-row, .el-form-row3 { grid-template-columns: 1fr; }
}
/* -- Batch Actions ------------------------------------- */
.el-batch-bar { display:none; align-items:center; gap:7px; padding:7px 12px; background:#fffbeb; border-bottom:1px solid #fde68a; flex-wrap:wrap; }
.el-batch-bar.is-active { display:flex; }
.el-batch-bar__count { font-size:11px; font-weight:600; color:#92400e; flex:1; min-width:80px; }
.el-btn--ghost { background:transparent; color:#555; border:1px solid #ccc; }
.el-btn--ghost:hover { border-color:#174DA4; color:#174DA4; background:rgba(23,77,164,.04); }
.el-btn--warn { background:#e67e00; color:#fff; border:none; }
.el-btn--warn:hover { background:#cc6f00; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="el-page-header">
    <div class="el-page-header__left">
        <div class="el-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect></svg>
        </div>
        <div>
            <h1 class="el-page-header__title">Election Posts</h1>
            <div class="el-page-header__sub">Define positions students can contest for in elections</div>
        </div>
    </div>
    <button type="button" class="el-btn el-btn--primary" onclick="openPostModal(0);">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Add Post
    </button>
</div>

<!-- Flash Messages -->
<asp:Literal ID="litFlash" runat="server" />

<!-- Stats Row -->
<div class="el-stats">
    <div class="el-stat el-stat--blue">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litTotalPosts" runat="server" Text="0" /></div>
            <div class="el-stat__label">Total Posts</div>
        </div>
    </div>
    <div class="el-stat el-stat--green">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litActivePosts" runat="server" Text="0" /></div>
            <div class="el-stat__label">Active Posts</div>
        </div>
    </div>
    <div class="el-stat el-stat--amber">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e67e00" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litTotalCandidates" runat="server" Text="0" /></div>
            <div class="el-stat__label">Total Candidates</div>
        </div>
    </div>
</div>

<!-- Posts Table Card -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect></svg>
            Defined Positions
        </div>
    </div>
    <!-- Filter Bar -->
    <div class="el-filters">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="el-filter-input" placeholder="Search post name, code..." />
        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="el-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Text="All Posts" Value="ALL" />
            <asp:ListItem Text="Active" Value="Active" />
            <asp:ListItem Text="Inactive" Value="Inactive" />
        </asp:DropDownList>
        <asp:Button ID="btnSearch" runat="server" CssClass="el-btn el-btn--primary el-btn--sm" Text="Search" OnClick="btnSearch_Click" />
    </div>
    <!-- Batch Actions -->
    <div class="el-batch-bar" id="postBatchBar">
        <asp:HiddenField ID="hdnBatchPostIds" runat="server" />
        <span class="el-batch-bar__count" id="postBatchCount">0 selected</span>
        <asp:Button ID="btnBatchActivatePosts" runat="server" CssClass="el-btn el-btn--success el-btn--xs" Text="&#x2713; Activate" OnClick="btnBatchActivatePosts_Click" OnClientClick="return collectPostIds('Activate selected posts?');" />
        <asp:Button ID="btnBatchDeactivatePosts" runat="server" CssClass="el-btn el-btn--ghost el-btn--xs" Text="Deactivate" OnClick="btnBatchDeactivatePosts_Click" OnClientClick="return collectPostIds('Deactivate selected posts?');" />
        <asp:Button ID="btnBatchDeletePosts" runat="server" CssClass="el-btn el-btn--warn el-btn--xs" Text="Delete" OnClick="btnBatchDeletePosts_Click" OnClientClick="return collectPostIds('Delete selected posts? Only posts with no candidates will be removed.');" />
    </div>
    <div style="overflow-x:auto;">
        <table class="el-table">
            <thead>
                <tr>
                    <th style="width:28px;text-align:center;"><input type="checkbox" id="chkAllPosts" onclick="selectAllPosts(this)" title="Select all" style="cursor:pointer;" /></th>
                    <th style="width:40px;">#</th>
                    <th>Post Name</th>
                    <th>Code</th>
                    <th>Max Winners</th>
                    <th>Candidates</th>
                    <th>Status</th>
                    <th>Order</th>
                    <th style="width:120px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litGridBody" runat="server" />
            </tbody>
        </table>
    </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════════ -->
<!-- MODAL — Add / Edit Post                                               -->
<!-- ═══════════════════════════════════════════════════════════════════════ -->
<div id="postModal" class="el-modal-overlay" onclick="if(event.target===this)closePostModal();">
    <div class="el-modal">
        <div class="el-modal__header">
            <span id="modalTitle">Add Election Post</span>
            <button type="button" class="el-modal__close" onclick="closePostModal();">&times;</button>
        </div>
        <div class="el-modal__body">
            <asp:HiddenField ID="hdnPostId" runat="server" Value="0" />

            <div class="el-form-row">
                <div class="el-form-group">
                    <label class="el-form-label">Post Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtPostName" runat="server" CssClass="el-form-input" placeholder="e.g. Guild President" />
                </div>
                <div class="el-form-group">
                    <label class="el-form-label">Post Code <span class="req">*</span></label>
                    <asp:TextBox ID="txtPostCode" runat="server" CssClass="el-form-input" placeholder="e.g. PRES" MaxLength="30" style="text-transform:uppercase;" />
                </div>
            </div>

            <div class="el-form-group">
                <label class="el-form-label">Description</label>
                <asp:TextBox ID="txtDescription" runat="server" CssClass="el-form-textarea" TextMode="MultiLine" Rows="2" placeholder="Brief description of this post..." />
            </div>

            <div class="el-form-group">
                <label class="el-form-label">Eligibility Requirements</label>
                <asp:TextBox ID="txtEligibility" runat="server" CssClass="el-form-textarea" TextMode="MultiLine" Rows="2" placeholder="Who can contest for this post..." />
            </div>

            <div class="el-form-group">
                <label class="el-form-label">Key Responsibilities</label>
                <asp:TextBox ID="txtResponsibilities" runat="server" CssClass="el-form-textarea" TextMode="MultiLine" Rows="2" placeholder="What this position holder does..." />
            </div>

            <div class="el-form-row3">
                <div class="el-form-group">
                    <label class="el-form-label">Max Winners</label>
                    <asp:TextBox ID="txtMaxWinners" runat="server" CssClass="el-form-input" TextMode="Number" Text="1" />
                    <div class="el-form-hint">Usually 1 per post</div>
                </div>
                <div class="el-form-group">
                    <label class="el-form-label">Display Order</label>
                    <asp:TextBox ID="txtDisplayOrder" runat="server" CssClass="el-form-input" TextMode="Number" Text="0" />
                    <div class="el-form-hint">Lower = shows first</div>
                </div>
                <div class="el-form-group">
                    <label class="el-form-label">Status</label>
                    <label class="el-toggle" style="margin-top:4px;">
                        <asp:CheckBox ID="chkActive" runat="server" Checked="true" />
                        <span class="el-toggle__track"></span>
                        <span class="el-toggle__label">Active</span>
                    </label>
                </div>
            </div>
        </div>
        <div class="el-modal__footer">
            <button type="button" class="el-btn el-btn--ghost" onclick="closePostModal();">Cancel</button>
            <asp:Button ID="btnSavePost" runat="server" Text="Save Post" CssClass="el-btn el-btn--primary" OnClick="btnSavePost_Click" />
        </div>
    </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════════ -->
<!-- MODAL — Delete Confirmation                                           -->
<!-- ═══════════════════════════════════════════════════════════════════════ -->
<div id="deleteModal" class="el-modal-overlay" onclick="if(event.target===this)closeDeleteModal();">
    <div class="el-modal" style="width:400px;">
        <div class="el-modal__header" style="background:#dc3545;">
            <span>Confirm Delete</span>
            <button type="button" class="el-modal__close" onclick="closeDeleteModal();">&times;</button>
        </div>
        <div class="el-modal__body" style="text-align:center; padding:24px 16px;">
            <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
            <p style="font-size:13px; margin:12px 0 4px; font-weight:600; color:#333;">Delete this post?</p>
            <p id="deletePostName" style="font-size:12px; color:#666;"></p>
            <p style="font-size:11px; color:#999; margin-top:4px;">Posts with linked candidates cannot be deleted.</p>
        </div>
        <div class="el-modal__footer">
            <button type="button" class="el-btn el-btn--ghost" onclick="closeDeleteModal();">Cancel</button>
            <asp:HiddenField ID="hdnDeleteId" runat="server" Value="0" />
            <asp:Button ID="btnDeletePost" runat="server" Text="Delete" CssClass="el-btn el-btn--danger" OnClick="btnDeletePost_Click" />
        </div>
    </div>
</div>

<script type="text/javascript">
function openPostModal(id) {
    document.getElementById('modalTitle').textContent = id > 0 ? 'Edit Election Post' : 'Add Election Post';
    document.getElementById('<%= hdnPostId.ClientID %>').value = id;

    if (id > 0) {
        // Populate from data attributes on the row
        var row = document.querySelector('tr[data-post-id="' + id + '"]');
        if (row) {
            document.getElementById('<%= txtPostName.ClientID %>').value = row.getAttribute('data-name') || '';
            document.getElementById('<%= txtPostCode.ClientID %>').value = row.getAttribute('data-code') || '';
            document.getElementById('<%= txtDescription.ClientID %>').value = row.getAttribute('data-desc') || '';
            document.getElementById('<%= txtEligibility.ClientID %>').value = row.getAttribute('data-elig') || '';
            document.getElementById('<%= txtResponsibilities.ClientID %>').value = row.getAttribute('data-resp') || '';
            document.getElementById('<%= txtMaxWinners.ClientID %>').value = row.getAttribute('data-maxw') || '1';
            document.getElementById('<%= txtDisplayOrder.ClientID %>').value = row.getAttribute('data-order') || '0';
            var chk = document.getElementById('<%= chkActive.ClientID %>');
            chk.checked = row.getAttribute('data-active') === '1';
        }
    } else {
        document.getElementById('<%= txtPostName.ClientID %>').value = '';
        document.getElementById('<%= txtPostCode.ClientID %>').value = '';
        document.getElementById('<%= txtDescription.ClientID %>').value = '';
        document.getElementById('<%= txtEligibility.ClientID %>').value = '';
        document.getElementById('<%= txtResponsibilities.ClientID %>').value = '';
        document.getElementById('<%= txtMaxWinners.ClientID %>').value = '1';
        document.getElementById('<%= txtDisplayOrder.ClientID %>').value = '0';
        document.getElementById('<%= chkActive.ClientID %>').checked = true;
    }

    var modal = document.getElementById('postModal');
    modal.style.display = 'flex';
    setTimeout(function() { document.getElementById('<%= txtPostName.ClientID %>').focus(); }, 100);
}

function closePostModal() { document.getElementById('postModal').style.display = 'none'; }

function openDeleteModal(id, name) {
    document.getElementById('<%= hdnDeleteId.ClientID %>').value = id;
    document.getElementById('deletePostName').textContent = name;
    document.getElementById('deleteModal').style.display = 'flex';
}

function closeDeleteModal() { document.getElementById('deleteModal').style.display = 'none'; }

// ─── Batch Posts ─────────────────────────────────────────────────────────
function selectAllPosts(source) {
    var boxes = document.querySelectorAll('.post-chk');
    for (var i = 0; i < boxes.length; i++) boxes[i].checked = source.checked;
    updatePostBatchBar();
}

function updatePostBatchBar() {
    var boxes = document.querySelectorAll('.post-chk:checked');
    var bar   = document.getElementById('postBatchBar');
    var lbl   = document.getElementById('postBatchCount');
    if (boxes.length > 0) {
        bar.classList.add('is-active');
        lbl.textContent = boxes.length + ' post(s) selected';
    } else {
        bar.classList.remove('is-active');
        var all = document.getElementById('chkAllPosts');
        if (all) all.checked = false;
    }
}

function collectPostIds(msg) {
    var boxes = document.querySelectorAll('.post-chk:checked');
    if (boxes.length === 0) { alert('Please select at least one post.'); return false; }
    var ids = [];
    for (var i = 0; i < boxes.length; i++) ids.push(boxes[i].value);
    document.getElementById('<%= hdnBatchPostIds.ClientID %>').value = ids.join(',');
    return confirm(msg + '\n(' + boxes.length + ' post(s) selected)');
}
</script>
</asp:Content>
