<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ElectionCandidates.aspx.cs" Inherits="COOPERP_NewScreens_ElectionCandidates" Title="Election Candidates - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ELECTION CANDIDATES — RESPONSIVE ===== */

/* -- Page Header --------------------------------------- */
.el-page-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 12px 0 10px; margin-bottom: 14px;
    border-bottom: 2px solid #174DA4; flex-wrap: wrap; gap: 8px;
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
    display: grid; grid-template-columns: repeat(4, 1fr);
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
.el-stat--red   .el-stat__icon { background: #fdecea; } .el-stat--red   .el-stat__val { color: #dc3545; }

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
.el-filter-input {
    border: 1px solid #ddd; border-radius: 6px;
    padding: 5px 8px; font-size: 11px; background: #fff; color: #333;
    min-width: 180px;
}
.el-filter-input:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.el-filter-select {
    border: 1px solid #ddd; border-radius: 6px;
    padding: 5px 8px; font-size: 11px; background: #fff; color: #333;
    cursor: pointer; min-width: 140px;
}
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

/* -- Candidate Row ------------------------------------- */
.el-cand { display: flex; align-items: center; gap: 10px; }
.el-cand__photo {
    width: 38px; height: 38px; border-radius: 50%; border: 2px solid #e4e8f0;
    object-fit: cover; flex-shrink: 0; background: #f5f7fa;
}
.el-cand__photo--placeholder {
    width: 38px; height: 38px; border-radius: 50%; border: 2px solid #e4e8f0;
    background: #e8f0fc; display: flex; align-items: center; justify-content: center;
    font-size: 14px; font-weight: 700; color: #174DA4; flex-shrink: 0;
    text-transform: uppercase;
}
.el-cand__info { min-width: 0; }
.el-cand__name { font-weight: 600; color: #1a1a2e; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.el-cand__regno { font-size: 10px; color: #888; margin-top: 1px; }
.el-cand__slogan { font-size: 10px; color: #555; font-style: italic; margin-top: 2px; max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

/* -- Status Badge -------------------------------------- */
.el-status { display: inline-block; padding: 2px 8px; border-radius: 10px; font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: .3px; }
.el-status--pending   { background: #fff8e1; color: #e67e00; border: 1px solid #ffd54f; }
.el-status--approved  { background: #e6f4ea; color: #28a745; border: 1px solid #a5d6a7; }
.el-status--rejected  { background: #fdecea; color: #d93025; border: 1px solid #ef9a9a; }
.el-status--disqualified { background: #f5f5f5; color: #666; border: 1px solid #ccc; }

/* -- Buttons ------------------------------------------- */
.el-btn {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 5px 12px; border-radius: 6px; font-size: 11px; font-weight: 600;
    cursor: pointer; transition: all .15s; text-decoration: none; border: none;
}
.el-btn--primary { background: #174DA4; color: #fff; }
.el-btn--primary:hover { background: #0f3576; }
.el-btn--success { background: #28a745; color: #fff; }
.el-btn--success:hover { background: #1e8537; }
.el-btn--danger  { background: #dc3545; color: #fff; }
.el-btn--danger:hover  { background: #b12330; }
.el-btn--outline {
    background: transparent; border: 1px solid #ddd; color: #555;
}
.el-btn--outline:hover { background: #f5f7fa; border-color: #bbb; }
.el-btn--xs { padding: 3px 7px; font-size: 10px; }

/* -- Action Buttons Row -------------------------------- */
.el-actions-row { display: flex; gap: 4px; flex-wrap: wrap; }

/* -- Flash Alert --------------------------------------- */
.el-flash { padding: 8px 14px; border-radius: 6px; font-size: 12px; display: flex; align-items: center; gap: 8px; margin-bottom: 12px; }
.el-flash--ok  { background: #e6f4ea; color: #1a7c35; border: 1px solid #a5d6a7; }
.el-flash--err { background: #fdecea; color: #b71c1c; border: 1px solid #ef9a9a; }

/* -- Pending Nominations Banner ----------------------- */
.el-banner-pending {
    display: flex; align-items: center; gap: 10px;
    background: linear-gradient(135deg, #fff8e1, #fff3cd); border: 1px solid #ffc107;
    border-left: 4px solid #e67e00; border-radius: 6px;
    padding: 10px 14px; margin-bottom: 12px;
    animation: elBannerPulse 2s ease-in-out 1;
}
@keyframes elBannerPulse { 0%,100%{box-shadow:none} 50%{box-shadow:0 0 12px rgba(230,126,0,.2)} }
.el-banner-pending__icon { width: 32px; height: 32px; background: #fff3cd; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.el-banner-pending__text { font-size: 12px; color: #6d4c00; line-height: 1.4; }
.el-banner-pending__text strong { color: #e67e00; }
.el-banner-pending__action {
    margin-left: auto; flex-shrink: 0;
    background: #e67e00; color: #fff; padding: 5px 12px; border-radius: 6px;
    font-size: 11px; font-weight: 600; text-decoration: none; cursor: pointer; border: none;
    transition: background .15s;
}
.el-banner-pending__action:hover { background: #c96b00; }

/* -- Modal --------------------------------------------- */
.el-overlay {
    display: none; position: fixed; inset: 0; background: rgba(0,0,0,.35);
    z-index: 9000; align-items: flex-start; justify-content: center;
    padding-top: 60px; overflow-y: auto;
}
.el-overlay.is-open { display: flex; }
.el-modal {
    background: #fff; border-radius: 8px; box-shadow: 0 10px 40px rgba(0,0,0,.18);
    width: 560px; max-width: 92vw; margin-bottom: 40px;
    animation: elSlideUp .2s ease-out;
}
@keyframes elSlideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.el-modal__header {
    padding: 12px 16px; border-bottom: 1px solid #e4e8f0;
    display: flex; align-items: center; justify-content: space-between;
    background: #fafbfc; border-radius: 8px 8px 0 0;
}
.el-modal__title { font-size: 14px; font-weight: 700; color: #1a1a2e; display: flex; align-items: center; gap: 8px; }
.el-modal__close {
    width: 28px; height: 28px; display: flex; align-items: center; justify-content: center;
    border-radius: 50%; border: none; background: transparent; cursor: pointer;
    color: #999; font-size: 18px;
}
.el-modal__close:hover { background: #f0f0f0; color: #333; }
.el-modal__body { padding: 14px 16px; max-height: 60vh; overflow-y: auto; }

/* -- Form ---------------------------------------------- */
.el-form-row { margin-bottom: 10px; }
.el-form-label { font-size: 11px; font-weight: 600; color: #555; margin-bottom: 3px; display: block; }
.el-form-input, .el-form-select, .el-form-textarea {
    width: 100%; border: 1px solid #ddd; border-radius: 6px;
    padding: 7px 10px; font-size: 12px; color: #333; box-sizing: border-box;
    transition: border-color .15s, box-shadow .15s;
}
.el-form-input:focus, .el-form-select:focus, .el-form-textarea:focus {
    border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none;
}
.el-form-textarea { resize: vertical; min-height: 60px; font-family: inherit; }
.el-modal__footer {
    padding: 10px 16px; border-top: 1px solid #e4e8f0; background: #fafbfc;
    display: flex; justify-content: flex-end; gap: 6px; border-radius: 0 0 8px 8px;
}

/* -- Student Search ------------------------------------ */
.el-search-box { position: relative; }
.el-search-results {
    position: absolute; top: 100%; left: 0; right: 0; z-index: 100;
    background: #fff; border: 1px solid #ddd; border-top: none;
    border-radius: 0 0 6px 6px; box-shadow: 0 4px 12px rgba(0,0,0,.1);
    max-height: 200px; overflow-y: auto; display: none;
}
.el-search-results.is-open { display: block; }
.el-search-item {
    padding: 7px 10px; cursor: pointer; border-bottom: 1px solid #f0f0f0;
    font-size: 11px; display: flex; align-items: center; gap: 8px;
}
.el-search-item:hover { background: #f0f5ff; }
.el-search-item__regno { font-weight: 700; color: #174DA4; min-width: 80px; }
.el-search-item__name  { color: #333; flex: 1; }
.el-search-item__prog  { color: #888; font-size: 10px; }
.el-search-loading { text-align: center; padding: 10px; color: #999; font-size: 11px; }
.el-selected-student {
    display: flex; align-items: center; gap: 10px;
    background: #f0f5ff; border: 1px solid #c6d9f7; border-radius: 6px;
    padding: 7px 10px; font-size: 12px; margin-top: 4px;
}
.el-selected-student__clear {
    margin-left: auto; cursor: pointer; color: #999; font-size: 14px;
    background: none; border: none; padding: 2px 4px;
}
.el-selected-student__clear:hover { color: #d93025; }

/* -- Empty State --------------------------------------- */
.el-empty { text-align: center; padding: 40px 10px; color: #aaa; }
.el-empty svg { margin: 0 auto 8px; opacity: .5; display: block; }
.el-empty__title { font-size: 14px; font-weight: 600; color: #888; }
.el-empty__sub   { font-size: 11px; color: #aaa; margin-top: 3px; max-width: 280px; margin-left: auto; margin-right: auto; }

/* -- Photo Upload (modal) ------------------------------ */
.el-photo-row { display:flex; align-items:center; gap:14px; }
.el-photo-circle { width:70px; height:70px; border-radius:50%; overflow:hidden; border:2px solid #c6d9f7;
    flex-shrink:0; background:#f0f5ff; display:flex; align-items:center; justify-content:center;
    font-size:22px; font-weight:700; color:#174DA4; }
.el-photo-circle img { width:100%; height:100%; object-fit:cover; }
.el-photo-details { flex:1; }
.el-photo-btn { display:inline-flex; align-items:center; gap:5px; font-size:11px; font-weight:600;
    color:#174DA4; background:none; border:1.5px solid #c6d9f7; border-radius:6px; padding:5px 12px;
    cursor:pointer; transition:all .15s; margin-bottom:4px; }
.el-photo-btn:hover { background:#eff6ff; border-color:#174DA4; }
.el-photo-btn svg { width:12px; height:12px; }
.el-photo-input { display:none; }
.el-photo-name { font-size:10px; color:#888; margin-top:2px; }
.el-photo-clear { font-size:10px; color:#dc2626; cursor:pointer; text-decoration:underline; margin-left:6px; display:none; }

/* -- Reason Modal -------------------------------------- */
.el-reason-label { font-size: 12px; color: #555; margin-bottom: 6px; display: block; }

/* -- Responsive ---------------------------------------- */
@media(max-width:768px){
    .el-stats { grid-template-columns: repeat(2, 1fr); }
    .el-modal { width: 100%; max-width: 100vw; border-radius: 0; margin-bottom: 0; }
    .el-cand__slogan { max-width: 120px; }
}
@media(max-width:480px){
    .el-stats { grid-template-columns: 1fr; }
    .el-filters { flex-direction: column; }
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

<!-- Flash -->
<asp:Literal ID="litFlash" runat="server" />

<!-- Page Header -->
<div class="el-page-header">
    <div class="el-page-header__left">
        <div class="el-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        </div>
        <div>
            <div class="el-page-header__title">Election Candidates</div>
            <div class="el-page-header__sub">Manage candidates for each election and post</div>
        </div>
    </div>
    <button type="button" class="el-btn el-btn--primary" onclick="openCandidateModal(0);">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        Add Candidate
    </button>
</div>

<!-- Stats -->
<div class="el-stats">
    <div class="el-stat el-stat--blue">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litTotalCandidates" runat="server" Text="0" /></div>
            <div class="el-stat__label">Total Candidates</div>
        </div>
    </div>
    <div class="el-stat el-stat--green">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litApproved" runat="server" Text="0" /></div>
            <div class="el-stat__label">Approved</div>
        </div>
    </div>
    <div class="el-stat el-stat--amber">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e67e00" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litPending" runat="server" Text="0" /></div>
            <div class="el-stat__label">Pending</div>
        </div>
    </div>
    <div class="el-stat el-stat--red">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litRejected" runat="server" Text="0" /></div>
            <div class="el-stat__label">Rejected / DQ</div>
        </div>
    </div>
</div>

<!-- Pending Self-Nomination Banner -->
<asp:Panel ID="pnlPendingBanner" runat="server" Visible="false">
<div class="el-banner-pending">
    <div class="el-banner-pending__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e67e00" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
    </div>
    <div class="el-banner-pending__text">
        <strong><asp:Literal ID="litPendingCount" runat="server" /></strong> pending self-nomination(s) require review.
        <asp:Literal ID="litPendingDetail" runat="server" />
    </div>
    <button type="button" class="el-banner-pending__action" onclick="filterPending();">Review Now</button>
</div>
</asp:Panel>

<!-- Candidates Card -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
            Candidates
        </div>
    </div>

    <!-- Filters -->
    <div class="el-filters">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="el-filter-input" placeholder="Search name, reg no..." />
        <asp:DropDownList ID="ddlElection" runat="server" CssClass="el-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" />
        <asp:DropDownList ID="ddlPost" runat="server" CssClass="el-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" />
        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="el-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Value="ALL" Text="All Statuses" />
            <asp:ListItem Value="Pending" Text="Pending" />
            <asp:ListItem Value="Approved" Text="Approved" />
            <asp:ListItem Value="Rejected" Text="Rejected" />
            <asp:ListItem Value="Disqualified" Text="Disqualified" />
        </asp:DropDownList>
        <asp:Button ID="btnSearch" runat="server" CssClass="el-btn el-btn--primary" Text="Search"
            OnClick="btnSearch_Click" />
    </div>

    <!-- Batch Actions -->
    <div class="el-batch-bar" id="candBatchBar">
        <asp:HiddenField ID="hdnBatchCandIds" runat="server" />
        <span class="el-batch-bar__count" id="candBatchCount">0 selected</span>
        <asp:Button ID="btnBatchCandApprove" runat="server" CssClass="el-btn el-btn--success el-btn--xs" Text="&#x2713; Approve" OnClick="btnBatchCandApprove_Click" OnClientClick="return collectCandIds('Approve selected candidates?');" />
        <asp:Button ID="btnBatchCandReject" runat="server" CssClass="el-btn el-btn--ghost el-btn--xs" Text="Reject" OnClick="btnBatchCandReject_Click" OnClientClick="return collectCandIds('Reject selected candidates?');" />
        <asp:Button ID="btnBatchCandDisqualify" runat="server" CssClass="el-btn el-btn--ghost el-btn--xs" Text="Disqualify" OnClick="btnBatchCandDisqualify_Click" OnClientClick="return collectCandIds('Disqualify selected candidates?');" />
        <asp:Button ID="btnBatchCandDelete" runat="server" CssClass="el-btn el-btn--warn el-btn--xs" Text="Delete" OnClick="btnBatchCandDelete_Click" OnClientClick="return collectCandIds('Delete selected candidates? This cannot be undone!');" />
    </div>

    <!-- Table -->
    <div style="overflow-x:auto;">
        <table class="el-table">
            <thead>
                <tr>
                    <th style="width:28px;text-align:center;"><input type="checkbox" id="chkAllCands" onclick="selectAllCands(this)" title="Select all" style="cursor:pointer;" /></th>
                    <th style="width:30px;">#</th>
                    <th>Candidate</th>
                    <th>Post</th>
                    <th>Election</th>
                    <th>Status</th>
                    <th style="text-align:center;">Votes</th>
                    <th style="width:160px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litGridBody" runat="server" />
            </tbody>
        </table>
    </div>
</div>

<!-- ═══════ ADD/EDIT CANDIDATE MODAL ═══════ -->
<div class="el-overlay" id="candidateModal">
    <div class="el-modal">
        <div class="el-modal__header">
            <div class="el-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                <span id="candidateModalTitle">Add Candidate</span>
            </div>
            <button type="button" class="el-modal__close" onclick="closeCandidateModal();">&times;</button>
        </div>
        <div class="el-modal__body">
            <asp:HiddenField ID="hdnCandidateId" runat="server" Value="0" />
            <asp:HiddenField ID="hdnCandPhotoUrl" runat="server" />

            <!-- Student Search -->
            <div class="el-form-row">
                <label class="el-form-label">Student *</label>
                <div class="el-search-box" id="studentSearchBox">
                    <input type="text" id="txtStudentSearch" class="el-form-input"
                        placeholder="Type reg no or name to search..." autocomplete="off"
                        oninput="searchStudents(this.value);" />
                    <div class="el-search-results" id="searchResults"></div>
                </div>
                <div class="el-selected-student" id="selectedStudent" style="display:none;">
                    <span id="selectedStudentText"></span>
                    <button type="button" class="el-selected-student__clear" onclick="clearStudent();">&times;</button>
                </div>
                <asp:HiddenField ID="hdnRegno" runat="server" />
                <asp:HiddenField ID="hdnCandidateName" runat="server" />
            </div>

            <!-- Election -->
            <div class="el-form-row">
                <label class="el-form-label">Election *</label>
                <asp:DropDownList ID="ddlModalElection" runat="server" CssClass="el-form-select" />
            </div>

            <!-- Post -->
            <div class="el-form-row">
                <label class="el-form-label">Post / Position *</label>
                <asp:DropDownList ID="ddlModalPost" runat="server" CssClass="el-form-select" />
            </div>

            <!-- Slogan -->
            <div class="el-form-row">
                <label class="el-form-label">Slogan</label>
                <asp:TextBox ID="txtSlogan" runat="server" CssClass="el-form-input" MaxLength="200"
                    placeholder="e.g. &quot;Your voice, my mission&quot;" />
            </div>

            <!-- Manifesto -->
            <div class="el-form-row">
                <label class="el-form-label">Manifesto</label>
                <asp:TextBox ID="txtManifesto" runat="server" CssClass="el-form-textarea" TextMode="MultiLine" Rows="4"
                    placeholder="Candidate's manifesto or agenda..." />
            </div>

            <!-- Status -->
            <div class="el-form-row">
                <label class="el-form-label">Status</label>
                <asp:DropDownList ID="ddlModalStatus" runat="server" CssClass="el-form-select">
                    <asp:ListItem Value="Pending" Text="Pending" />
                    <asp:ListItem Value="Approved" Text="Approved" />
                    <asp:ListItem Value="Rejected" Text="Rejected" />
                    <asp:ListItem Value="Disqualified" Text="Disqualified" />
                </asp:DropDownList>
            </div>

            <!-- Photo -->
            <div class="el-form-row">
                <label class="el-form-label">Candidate Photo <span style="font-size:10px;font-weight:400;color:#888;">(optional)</span></label>
                <div class="el-photo-row">
                    <div class="el-photo-circle" id="adminPhotoCircle"></div>
                    <div class="el-photo-details">
                        <button type="button" class="el-photo-btn" onclick="document.getElementById('fuCandPhoto').click();">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                            Upload Photo
                        </button>
                        <input type="file" id="fuCandPhoto" name="fuCandPhoto" accept="image/jpeg,image/png,image/gif,image/webp" class="el-photo-input" onchange="previewAdminPhoto(this)" />
                        <div class="el-photo-name" id="adminPhotoName">No file chosen</div>
                        <span class="el-photo-clear" id="adminPhotoClear" onclick="clearAdminPhoto()">Remove / keep existing</span>
                    </div>
                </div>
                <div style="font-size:10px;color:#888;margin-top:4px;">JPG, PNG, GIF, WEBP, max 5 MB. Leave blank to keep existing photo.</div>
            </div>
        </div>
        <div class="el-modal__footer">
            <button type="button" class="el-btn el-btn--outline" onclick="closeCandidateModal();">Cancel</button>
            <asp:Button ID="btnSaveCandidate" runat="server" CssClass="el-btn el-btn--primary"
                Text="Save Candidate" OnClick="btnSaveCandidate_Click" />
        </div>
    </div>
</div>

<!-- ═══════ STATUS CHANGE MODAL ═══════ -->
<div class="el-overlay" id="statusModal">
    <div class="el-modal" style="width:400px;">
        <div class="el-modal__header">
            <div class="el-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                <span id="statusModalTitle">Update Status</span>
            </div>
            <button type="button" class="el-modal__close" onclick="closeStatusModal();">&times;</button>
        </div>
        <div class="el-modal__body">
            <asp:HiddenField ID="hdnStatusCandId" runat="server" Value="0" />
            <asp:HiddenField ID="hdnNewStatus" runat="server" />
            <div class="el-form-row">
                <label class="el-reason-label" id="statusReasonLabel">Reason for rejection (optional):</label>
                <asp:TextBox ID="txtStatusReason" runat="server" CssClass="el-form-textarea" TextMode="MultiLine" Rows="3"
                    placeholder="Explain the reason..." />
            </div>
        </div>
        <div class="el-modal__footer">
            <button type="button" class="el-btn el-btn--outline" onclick="closeStatusModal();">Cancel</button>
            <asp:Button ID="btnStatusChange" runat="server" CssClass="el-btn el-btn--primary"
                Text="Confirm" OnClick="btnStatusChange_Click" />
        </div>
    </div>
</div>

<!-- ═══════ DELETE CONFIRMATION MODAL ═══════ -->
<div class="el-overlay" id="deleteModal">
    <div class="el-modal" style="width:380px;">
        <div class="el-modal__header">
            <div class="el-modal__title" style="color:#dc3545;">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                Delete Candidate
            </div>
            <button type="button" class="el-modal__close" onclick="closeDeleteModal();">&times;</button>
        </div>
        <div class="el-modal__body">
            <asp:HiddenField ID="hdnDeleteId" runat="server" Value="0" />
            <p style="font-size:12px; color:#555; margin:0;">
                Are you sure you want to remove <strong id="deleteNameSpan"></strong> from this election?
                This action cannot be undone.
            </p>
        </div>
        <div class="el-modal__footer">
            <button type="button" class="el-btn el-btn--outline" onclick="closeDeleteModal();">Cancel</button>
            <asp:Button ID="btnDeleteCandidate" runat="server" CssClass="el-btn el-btn--danger"
                Text="Delete" OnClick="btnDeleteCandidate_Click" />
        </div>
    </div>
</div>

<script type="text/javascript">
// ─── Candidate Modal ─────────────────────────────────────────────────────
function openCandidateModal(id) {
    document.getElementById('candidateModal').classList.add('is-open');
    var titleEl = document.getElementById('candidateModalTitle');

    if (id > 0) {
        // Edit mode — find TR with data
        titleEl.textContent = 'Edit Candidate';
        var row = document.querySelector('tr[data-cid="' + id + '"]');
        if (row) {
            document.getElementById('<%= hdnCandidateId.ClientID %>').value = id;
            document.getElementById('<%= hdnRegno.ClientID %>').value = row.getAttribute('data-regno');
            document.getElementById('<%= hdnCandidateName.ClientID %>').value = row.getAttribute('data-name');

            // Show selected student
            document.getElementById('txtStudentSearch').style.display = 'none';
            document.getElementById('searchResults').classList.remove('is-open');
            var selDiv = document.getElementById('selectedStudent');
            selDiv.style.display = 'flex';
            document.getElementById('selectedStudentText').textContent =
                row.getAttribute('data-regno') + ' — ' + row.getAttribute('data-name');

            setDropdown('<%= ddlModalElection.ClientID %>', row.getAttribute('data-eid'));
            setDropdown('<%= ddlModalPost.ClientID %>', row.getAttribute('data-pid'));
            document.getElementById('<%= txtSlogan.ClientID %>').value = row.getAttribute('data-slogan') || '';
            document.getElementById('<%= txtManifesto.ClientID %>').value = row.getAttribute('data-manifesto') || '';
            setDropdown('<%= ddlModalStatus.ClientID %>', row.getAttribute('data-cstatus'));

            // Photo
            var photoUrl = row.getAttribute('data-photo') || '';
            document.getElementById('<%= hdnCandPhotoUrl.ClientID %>').value = photoUrl;
            adminPhotoDisplay(photoUrl);
            document.getElementById('fuCandPhoto').value = '';
            document.getElementById('adminPhotoName').textContent = 'No new file chosen';
            document.getElementById('adminPhotoClear').style.display = 'none';
        }
    } else {
        // Add mode
        titleEl.textContent = 'Add Candidate';
        document.getElementById('<%= hdnCandidateId.ClientID %>').value = '0';
        document.getElementById('<%= hdnRegno.ClientID %>').value = '';
        document.getElementById('<%= hdnCandidateName.ClientID %>').value = '';
        document.getElementById('<%= txtSlogan.ClientID %>').value = '';
        document.getElementById('<%= txtManifesto.ClientID %>').value = '';
        setDropdown('<%= ddlModalStatus.ClientID %>', 'Pending');
        clearStudent();
        document.getElementById('txtStudentSearch').style.display = '';
        document.getElementById('txtStudentSearch').value = '';

        // Photo
        document.getElementById('<%= hdnCandPhotoUrl.ClientID %>').value = '';
        adminPhotoDisplay('');
        document.getElementById('fuCandPhoto').value = '';
        document.getElementById('adminPhotoName').textContent = 'No file chosen';
        document.getElementById('adminPhotoClear').style.display = 'none';

        // Pre-select current filter election/post
        var elSel = document.getElementById('<%= ddlElection.ClientID %>');
        if (elSel && elSel.value !== '0') setDropdown('<%= ddlModalElection.ClientID %>', elSel.value);
        var postSel = document.getElementById('<%= ddlPost.ClientID %>');
        if (postSel && postSel.value !== '0') setDropdown('<%= ddlModalPost.ClientID %>', postSel.value);
    }
}

function closeCandidateModal() {
    document.getElementById('candidateModal').classList.remove('is-open');
}

function setDropdown(clientId, val) {
    var dd = document.getElementById(clientId);
    if (!dd) return;
    for (var i = 0; i < dd.options.length; i++) {
        if (dd.options[i].value === val) { dd.selectedIndex = i; return; }
    }
}

// ─── Student Search (AJAX) ───────────────────────────────────────────────
var _searchTimer = null;
function searchStudents(query) {
    clearTimeout(_searchTimer);
    var box = document.getElementById('searchResults');
    if (query.length < 2) { box.classList.remove('is-open'); return; }

    _searchTimer = setTimeout(function () {
        box.innerHTML = '<div class="el-search-loading">Searching...</div>';
        box.classList.add('is-open');

        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'ElectionCandidates.aspx?ajax=searchstudent&q=' + encodeURIComponent(query), true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.length === 0) {
                        box.innerHTML = '<div class="el-search-loading">No students found</div>';
                    } else {
                        var html = '';
                        for (var i = 0; i < data.length; i++) {
                            html += '<div class="el-search-item" onclick="selectStudent(\'' +
                                data[i].regno + "', '" + escHtml(data[i].name) + "', '" +
                                escHtml(data[i].prog) + "');\">" +
                                '<span class="el-search-item__regno">' + escHtml(data[i].regno) + '</span>' +
                                '<span class="el-search-item__name">' + escHtml(data[i].name) + '</span>' +
                                '<span class="el-search-item__prog">' + escHtml(data[i].prog) + '</span>' +
                                '</div>';
                        }
                        box.innerHTML = html;
                    }
                } catch (ex) {
                    box.innerHTML = '<div class="el-search-loading">Error parsing results</div>';
                }
            }
        };
        xhr.send();
    }, 300);
}

function selectStudent(regno, name, prog) {
    document.getElementById('<%= hdnRegno.ClientID %>').value = regno;
    document.getElementById('<%= hdnCandidateName.ClientID %>').value = name;
    document.getElementById('txtStudentSearch').style.display = 'none';
    document.getElementById('searchResults').classList.remove('is-open');

    var selDiv = document.getElementById('selectedStudent');
    selDiv.style.display = 'flex';
    document.getElementById('selectedStudentText').textContent = regno + ' — ' + name + ' (' + prog + ')';
}

function clearStudent() {
    document.getElementById('<%= hdnRegno.ClientID %>').value = '';
    document.getElementById('<%= hdnCandidateName.ClientID %>').value = '';
    document.getElementById('txtStudentSearch').style.display = '';
    document.getElementById('txtStudentSearch').value = '';
    document.getElementById('selectedStudent').style.display = 'none';
    document.getElementById('searchResults').classList.remove('is-open');
}

function escHtml(s) {
    if (!s) return '';
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}

// ─── Status Change Modal ─────────────────────────────────────────────────
function openStatusModal(candId, newStatus) {
    document.getElementById('statusModal').classList.add('is-open');
    document.getElementById('<%= hdnStatusCandId.ClientID %>').value = candId;
    document.getElementById('<%= hdnNewStatus.ClientID %>').value = newStatus;
    document.getElementById('<%= txtStatusReason.ClientID %>').value = '';

    var title = document.getElementById('statusModalTitle');
    var label = document.getElementById('statusReasonLabel');

    if (newStatus === 'Approved') {
        title.textContent = 'Approve Candidate';
        label.textContent = 'Note (optional):';
    } else if (newStatus === 'Rejected') {
        title.textContent = 'Reject Candidate';
        label.textContent = 'Reason for rejection:';
    } else if (newStatus === 'Disqualified') {
        title.textContent = 'Disqualify Candidate';
        label.textContent = 'Reason for disqualification:';
    } else {
        title.textContent = 'Change Status to ' + newStatus;
        label.textContent = 'Reason (optional):';
    }
}

function closeStatusModal() {
    document.getElementById('statusModal').classList.remove('is-open');
}

// ─── Delete Modal ────────────────────────────────────────────────────────
function openDeleteModal(candId, name) {
    document.getElementById('deleteModal').classList.add('is-open');
    document.getElementById('<%= hdnDeleteId.ClientID %>').value = candId;
    document.getElementById('deleteNameSpan').textContent = name;
}

function closeDeleteModal() {
    document.getElementById('deleteModal').classList.remove('is-open');
}

// ─── Admin Photo Upload ─────────────────────────────────────────────────
function adminPhotoDisplay(url) {
    var circle = document.getElementById('adminPhotoCircle');
    if (!circle) return;
    if (url) {
        circle.innerHTML = '<img src="' + url + '" alt="" />';
    } else {
        circle.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="1.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>';
    }
}

function previewAdminPhoto(input) {
    if (!input.files || !input.files[0]) return;
    var file = input.files[0];
    if (file.size > 5 * 1024 * 1024) {
        alert('Photo must be 5 MB or smaller. Please choose a smaller file.');
        input.value = '';
        return;
    }
    var reader = new FileReader();
    reader.onload = function (ev) {
        adminPhotoDisplay(ev.target.result);
        document.getElementById('adminPhotoName').textContent = file.name;
        document.getElementById('adminPhotoClear').style.display = 'inline';
    };
    reader.readAsDataURL(file);
}

function clearAdminPhoto() {
    document.getElementById('fuCandPhoto').value = '';
    document.getElementById('adminPhotoName').textContent = 'No file chosen';
    document.getElementById('adminPhotoClear').style.display = 'none';
    var existing = document.getElementById('<%= hdnCandPhotoUrl.ClientID %>').value;
    adminPhotoDisplay(existing);
}

// ─── Batch Candidates ───────────────────────────────────────────────────
function selectAllCands(source) {
    var boxes = document.querySelectorAll('.cand-chk');
    for (var i = 0; i < boxes.length; i++) boxes[i].checked = source.checked;
    updateCandBatchBar();
}

function updateCandBatchBar() {
    var boxes = document.querySelectorAll('.cand-chk:checked');
    var bar   = document.getElementById('candBatchBar');
    var lbl   = document.getElementById('candBatchCount');
    if (boxes.length > 0) {
        bar.classList.add('is-active');
        lbl.textContent = boxes.length + ' candidate(s) selected';
    } else {
        bar.classList.remove('is-active');
        var all = document.getElementById('chkAllCands');
        if (all) all.checked = false;
    }
}

function collectCandIds(msg) {
    var boxes = document.querySelectorAll('.cand-chk:checked');
    if (boxes.length === 0) { alert('Please select at least one candidate.'); return false; }
    var ids = [];
    for (var i = 0; i < boxes.length; i++) ids.push(boxes[i].value);
    document.getElementById('<%= hdnBatchCandIds.ClientID %>').value = ids.join(',');
    return confirm(msg + '\n(' + boxes.length + ' candidate(s) selected)');
}

// ─── Filter to Pending (banner action) ──────────────────────────────────
function filterPending() {
    var ddl = document.getElementById('<%= ddlStatusFilter.ClientID %>');
    if (ddl) {
        ddl.value = 'Pending';
        __doPostBack(ddl.name, '');
    }
}
</script>
</asp:Content>
