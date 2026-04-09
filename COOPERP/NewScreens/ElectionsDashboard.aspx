<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ElectionsDashboard.aspx.cs" Inherits="COOPERP_NewScreens_ElectionsDashboard" Title="Elections Dashboard - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ELECTIONS DASHBOARD — RESPONSIVE ===== */

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

/* -- Stats --------------------------------------------- */
.el-stats {
    display: grid; grid-template-columns: repeat(5, 1fr);
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
.el-stat--grey  .el-stat__icon { background: #f0f0f0; } .el-stat--grey  .el-stat__val { color: #555; }

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
.el-filter-select {
    border: 1px solid #ddd; border-radius: 6px;
    padding: 5px 8px; font-size: 11px; background: #fff; color: #333;
    cursor: pointer; min-width: 120px;
}
.el-filter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }

/* -- Table --------------------------------------------- */
.el-table { width: 100%; border-collapse: collapse; font-size: 12px; }
.el-table th {
    background: #f5f7fa; border-bottom: 2px solid #e4e8f0;
    padding: 8px 12px; text-align: left; font-size: 10px;
    text-transform: uppercase; letter-spacing: .4px; color: #555; font-weight: 700; white-space: nowrap;
}
.el-table td { padding: 8px 12px; border-bottom: 1px solid #f0f2f5; vertical-align: middle; }
.el-table tr:hover td { background: #f8faff; }

/* -- Status badges ------------------------------------- */
.el-status {
    display: inline-block; padding: 2px 8px; font-size: 9px; font-weight: 700;
    text-transform: uppercase; letter-spacing: .4px; border-radius: 3px;
}
.el-status--draft     { background: #e2e3e5; color: #383d41; }
.el-status--upcoming  { background: #e8f0fc; color: #174DA4; }
.el-status--nominations { background: #fff3cd; color: #856404; }
.el-status--active    { background: #d4edda; color: #155724; }
.el-status--closed    { background: #f8d7da; color: #721c24; }
.el-status--cancelled { background: #e2e3e5; color: #6c757d; }

/* -- Turnout bar --------------------------------------- */
.el-turnout { display: flex; align-items: center; gap: 6px; }
.el-turnout__bar { width: 60px; height: 6px; background: #eee; border-radius: 3px; overflow: hidden; }
.el-turnout__fill { height: 100%; background: #174DA4; border-radius: 3px; transition: width .3s; }
.el-turnout__text { font-size: 10px; color: #555; white-space: nowrap; }

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

/* -- Flash --------------------------------------------- */
.el-flash {
    padding: 9px 14px; margin-bottom: 10px; border-radius: 6px;
    font-size: 12px; display: flex; align-items: center; gap: 8px;
}
.el-flash--ok  { background: #e6f4ea; color: #155724; border-left: 3px solid #28a745; }
.el-flash--err { background: #fdecea; color: #b91c1c; border-left: 3px solid #dc3545; }

/* -- Action popover ------------------------------------ */
.el-action-wrapper { position: relative; display: inline-block; }
.el-action-trigger {
    background: none; border: 1px solid #ddd; border-radius: 5px;
    padding: 3px 7px; cursor: pointer; color: #555;
    display: inline-flex; align-items: center;
    transition: border-color .15s, background .15s;
}
.el-action-trigger:hover { border-color: #174DA4; color: #174DA4; background: #f0f4ff; }
.el-action-popover {
    display: none; position: absolute; right: 0; top: calc(100% + 2px);
    z-index: 9999; background: #fff; border: 1px solid #e4e8f0;
    border-radius: 6px; box-shadow: 0 6px 20px rgba(0,0,0,.13); min-width: 170px;
}
.el-action-popover.is-open { display: block; }
.el-action-popover__menu   { list-style: none; margin: 0; padding: 4px 0; }
.el-action-popover__btn {
    width: 100%; background: none; border: none; padding: 7px 14px;
    font-size: 11px; color: #333; cursor: pointer;
    display: flex; align-items: center; gap: 8px; text-align: left;
    transition: background .12s;
}
.el-action-popover__btn:hover { background: #f0f4ff; color: #174DA4; }
.el-action-popover__btn--danger:hover { background: #fdecea; color: #dc3545; }
.el-action-popover__divider { height: 1px; background: #f0f0f0; margin: 3px 0; }

/* -- Modal --------------------------------------------- */
.el-modal-overlay {
    display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,.48); z-index: 10000;
    align-items: center; justify-content: center;
    padding: 16px; box-sizing: border-box;
}
.el-modal {
    background: #fff; width: 640px; max-width: 100%;
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
.el-modal__close { background: none; border: none; color: rgba(255,255,255,.8); font-size: 22px; cursor: pointer; line-height: 1; padding: 0 2px; }
.el-modal__close:hover { color: #fff; }
.el-modal__body { padding: 16px; flex: 1; overflow-y: auto; }
.el-modal__footer {
    padding: 10px 16px; border-top: 1px solid #e4e8f0;
    display: flex; justify-content: flex-end; gap: 8px;
    flex-shrink: 0; background: #fafbfc; border-radius: 0 0 8px 8px;
}
.el-modal__section {
    font-size: 9px; text-transform: uppercase; letter-spacing: .6px;
    color: #174DA4; font-weight: 700; padding: 6px 0 4px;
    border-bottom: 1px solid #e8ecf4; margin-bottom: 8px; margin-top: 14px;
}
.el-modal__section:first-child { margin-top: 0; }

/* -- Form ---------------------------------------------- */
.el-form-group  { margin-bottom: 10px; }
.el-form-label  { display: block; font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #555; font-weight: 600; margin-bottom: 3px; }
.el-form-label .req { color: #dc3545; margin-left: 2px; }
.el-form-input, .el-form-select, .el-form-textarea {
    width: 100%; padding: 6px 9px; border: 1px solid #ccc;
    border-radius: 5px; font-size: 12px; box-sizing: border-box; background: #fff;
    transition: border-color .15s, box-shadow .15s;
}
.el-form-input:focus, .el-form-select:focus, .el-form-textarea:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.el-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.el-form-row3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; }
.el-form-hint { font-size: 10px; color: #888; margin-top: 2px; }
.el-checkbox-row { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 6px; }
.el-checkbox-row label { display: flex; align-items: center; gap: 5px; font-size: 11px; color: #333; cursor: pointer; }
.el-checkbox-row input[type=checkbox] { accent-color: #174DA4; }

/* -- Empty state --------------------------------------- */
.el-empty { text-align: center; padding: 40px 20px; color: #999; }
.el-empty svg { margin-bottom: 10px; opacity: .4; }
.el-empty__title { font-size: 14px; font-weight: 600; color: #666; }
.el-empty__sub { font-size: 12px; margin-top: 4px; }

/* -- Responsive ---------------------------------------- */
@media (max-width: 992px) {
    .el-stats { grid-template-columns: repeat(3, 1fr); }
}
@media (max-width: 768px) {
    .el-stats { grid-template-columns: 1fr; }
    .el-form-row, .el-form-row3 { grid-template-columns: 1fr; }
}
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="el-page-header">
    <div class="el-page-header__left">
        <div class="el-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="20" rx="2"></rect><path d="M9 11l3 3L22 4"></path></svg>
        </div>
        <div>
            <h1 class="el-page-header__title">Elections Dashboard</h1>
            <div class="el-page-header__sub">Manage university leadership elections</div>
        </div>
    </div>
    <button type="button" class="el-btn el-btn--primary" onclick="openElectionModal(0);">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Create Election
    </button>
</div>

<asp:Literal ID="litFlash" runat="server" />

<!-- Stats Row -->
<div class="el-stats">
    <div class="el-stat el-stat--blue">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><rect x="2" y="2" width="20" height="20" rx="2"></rect><path d="M9 11l3 3L22 4"></path></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litTotalElections" runat="server" Text="0" /></div>
            <div class="el-stat__label">Total Elections</div>
        </div>
    </div>
    <div class="el-stat el-stat--green">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litActiveElections" runat="server" Text="0" /></div>
            <div class="el-stat__label">Active</div>
        </div>
    </div>
    <div class="el-stat el-stat--amber">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e67e00" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litUpcomingElections" runat="server" Text="0" /></div>
            <div class="el-stat__label">Upcoming</div>
        </div>
    </div>
    <div class="el-stat el-stat--grey">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#555" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litTotalVoters" runat="server" Text="0" /></div>
            <div class="el-stat__label">Total Voters</div>
        </div>
    </div>
    <div class="el-stat el-stat--red">
        <div class="el-stat__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        </div>
        <div class="el-stat__body">
            <div class="el-stat__val"><asp:Literal ID="litTotalCandidates" runat="server" Text="0" /></div>
            <div class="el-stat__label">Total Candidates</div>
        </div>
    </div>
</div>

<!-- Elections Table Card -->
<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="20" height="20" rx="2"></rect><path d="M9 11l3 3L22 4"></path></svg>
            All Elections
        </div>
    </div>
    <div class="el-filters">
        <label style="font-size:10px; color:#888; text-transform:uppercase; letter-spacing:.4px; font-weight:600;">Status:</label>
        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="el-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_Changed">
            <asp:ListItem Text="All Statuses" Value="ALL" />
            <asp:ListItem Text="Draft" Value="Draft" />
            <asp:ListItem Text="Upcoming" Value="Upcoming" />
            <asp:ListItem Text="Nominations" Value="Nominations" />
            <asp:ListItem Text="Active" Value="Active" />
            <asp:ListItem Text="Closed" Value="Closed" />
            <asp:ListItem Text="Cancelled" Value="Cancelled" />
        </asp:DropDownList>
    </div>
    <div style="overflow-x:auto;">
        <table class="el-table">
            <thead>
                <tr>
                    <th style="width:30px;">#</th>
                    <th>Election</th>
                    <th>Period</th>
                    <th>Status</th>
                    <th>Posts</th>
                    <th>Candidates</th>
                    <th>Voter Turnout</th>
                    <th style="width:70px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Literal ID="litGridBody" runat="server" />
            </tbody>
        </table>
    </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════════ -->
<!-- MODAL — Create / Edit Election                                        -->
<!-- ═══════════════════════════════════════════════════════════════════════ -->
<div id="electionModal" class="el-modal-overlay" onclick="if(event.target===this)closeElectionModal();">
    <div class="el-modal">
        <div class="el-modal__header">
            <span id="elModalTitle">Create Election</span>
            <button type="button" class="el-modal__close" onclick="closeElectionModal();">&times;</button>
        </div>
        <div class="el-modal__body">
            <asp:HiddenField ID="hdnElectionId" runat="server" Value="0" />

            <div class="el-modal__section">Basic Information</div>

            <div class="el-form-group">
                <label class="el-form-label">Election Name <span class="req">*</span></label>
                <asp:TextBox ID="txtElectionName" runat="server" CssClass="el-form-input" placeholder="e.g. Guild Elections 2025/2026" />
            </div>

            <div class="el-form-group">
                <label class="el-form-label">Description</label>
                <asp:TextBox ID="txtElectionDesc" runat="server" CssClass="el-form-textarea" TextMode="MultiLine" Rows="2" placeholder="Brief description of this election..." />
            </div>

            <div class="el-form-row3">
                <div class="el-form-group">
                    <label class="el-form-label">Academic Year</label>
                    <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="el-form-select" />
                </div>
                <div class="el-form-group">
                    <label class="el-form-label">Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="el-form-select">
                        <asp:ListItem Text="Draft" Value="Draft" />
                        <asp:ListItem Text="Upcoming" Value="Upcoming" />
                        <asp:ListItem Text="Nominations" Value="Nominations" />
                        <asp:ListItem Text="Active" Value="Active" />
                        <asp:ListItem Text="Closed" Value="Closed" />
                        <asp:ListItem Text="Cancelled" Value="Cancelled" />
                    </asp:DropDownList>
                </div>
                <div class="el-form-group">&nbsp;</div>
            </div>

            <div class="el-modal__section">Voting Period</div>

            <div class="el-form-row">
                <div class="el-form-group">
                    <label class="el-form-label">Start Date &amp; Time <span class="req">*</span></label>
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="el-form-input" TextMode="DateTimeLocal" />
                </div>
                <div class="el-form-group">
                    <label class="el-form-label">End Date &amp; Time <span class="req">*</span></label>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="el-form-input" TextMode="DateTimeLocal" />
                </div>
            </div>

            <div class="el-modal__section">Configuration</div>

            <div class="el-checkbox-row">
                <label><asp:CheckBox ID="chkRequireReg" runat="server" Checked="true" /> Require Active Registration</label>
                <label><asp:CheckBox ID="chkRequireFees" runat="server" /> Require Fees Cleared</label>
                <label><asp:CheckBox ID="chkShowLiveResults" runat="server" /> Show Live Results During Voting</label>
                <label><asp:CheckBox ID="chkShowVoteCounts" runat="server" Checked="true" /> Show Actual Vote Counts</label>
                <label><asp:CheckBox ID="chkResultsPublic" runat="server" /> Public Results Page (No Login)</label>
            </div>
        </div>
        <div class="el-modal__footer">
            <button type="button" class="el-btn el-btn--ghost" onclick="closeElectionModal();">Cancel</button>
            <asp:Button ID="btnSaveElection" runat="server" Text="Save Election" CssClass="el-btn el-btn--primary" OnClick="btnSaveElection_Click" />
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
            <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
            <p style="font-size:13px; margin:12px 0 4px; font-weight:600; color:#333;">Delete this election?</p>
            <p id="deleteElName" style="font-size:12px; color:#666;"></p>
            <p style="font-size:11px; color:#999; margin-top:4px;">Elections with votes cannot be deleted. They can only be cancelled.</p>
        </div>
        <div class="el-modal__footer">
            <button type="button" class="el-btn el-btn--ghost" onclick="closeDeleteModal();">Cancel</button>
            <asp:HiddenField ID="hdnDeleteId" runat="server" Value="0" />
            <asp:Button ID="btnDeleteElection" runat="server" Text="Delete" CssClass="el-btn el-btn--danger" OnClick="btnDeleteElection_Click" />
        </div>
    </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════════════ -->
<!-- MODAL — Status Change                                                 -->
<!-- ═══════════════════════════════════════════════════════════════════════ -->
<asp:HiddenField ID="hdnStatusId" runat="server" Value="0" />
<asp:HiddenField ID="hdnNewStatus" runat="server" Value="" />

<script type="text/javascript">
// ── Election Modal ───────────────────────────────────────────────────────
function openElectionModal(id) {
    document.getElementById('elModalTitle').textContent = id > 0 ? 'Edit Election' : 'Create Election';
    document.getElementById('<%= hdnElectionId.ClientID %>').value = id;

    if (id > 0) {
        var row = document.querySelector('tr[data-el-id="' + id + '"]');
        if (row) {
            document.getElementById('<%= txtElectionName.ClientID %>').value = row.getAttribute('data-name') || '';
            document.getElementById('<%= txtElectionDesc.ClientID %>').value = row.getAttribute('data-desc') || '';
            setDropdown('<%= ddlAcadYear.ClientID %>', row.getAttribute('data-ay') || '');
            setDropdown('<%= ddlStatus.ClientID %>', row.getAttribute('data-status') || 'Draft');
            document.getElementById('<%= txtStartDate.ClientID %>').value = row.getAttribute('data-start') || '';
            document.getElementById('<%= txtEndDate.ClientID %>').value = row.getAttribute('data-end') || '';
            document.getElementById('<%= chkRequireReg.ClientID %>').checked = row.getAttribute('data-rr') === '1';
            document.getElementById('<%= chkRequireFees.ClientID %>').checked = row.getAttribute('data-rfc') === '1';
            document.getElementById('<%= chkShowLiveResults.ClientID %>').checked = row.getAttribute('data-slr') === '1';
            document.getElementById('<%= chkShowVoteCounts.ClientID %>').checked = row.getAttribute('data-svc') === '1';
            document.getElementById('<%= chkResultsPublic.ClientID %>').checked = row.getAttribute('data-rp') === '1';
        }
    } else {
        document.getElementById('<%= txtElectionName.ClientID %>').value = '';
        document.getElementById('<%= txtElectionDesc.ClientID %>').value = '';
        document.getElementById('<%= txtStartDate.ClientID %>').value = '';
        document.getElementById('<%= txtEndDate.ClientID %>').value = '';
        document.getElementById('<%= chkRequireReg.ClientID %>').checked = true;
        document.getElementById('<%= chkRequireFees.ClientID %>').checked = false;
        document.getElementById('<%= chkShowLiveResults.ClientID %>').checked = false;
        document.getElementById('<%= chkShowVoteCounts.ClientID %>').checked = true;
        document.getElementById('<%= chkResultsPublic.ClientID %>').checked = false;
    }

    document.getElementById('electionModal').style.display = 'flex';
    setTimeout(function() { document.getElementById('<%= txtElectionName.ClientID %>').focus(); }, 100);
}

function closeElectionModal() { document.getElementById('electionModal').style.display = 'none'; }

function setDropdown(id, val) {
    var dd = document.getElementById(id);
    for (var i = 0; i < dd.options.length; i++) {
        if (dd.options[i].value === val) { dd.selectedIndex = i; return; }
    }
}

// ── Delete Modal ─────────────────────────────────────────────────────────
function openDeleteModal(id, name) {
    document.getElementById('<%= hdnDeleteId.ClientID %>').value = id;
    document.getElementById('deleteElName').textContent = name;
    document.getElementById('deleteModal').style.display = 'flex';
}
function closeDeleteModal() { document.getElementById('deleteModal').style.display = 'none'; }

// ── Status Change ────────────────────────────────────────────────────────
function changeStatus(id, newStatus) {
    if (!confirm('Change this election status to "' + newStatus + '"?')) return;
    document.getElementById('<%= hdnStatusId.ClientID %>').value = id;
    document.getElementById('<%= hdnNewStatus.ClientID %>').value = newStatus;
    document.getElementById('<%= btnStatusChange.ClientID %>').click();
}

// ── Action Popover ───────────────────────────────────────────────────────
document.addEventListener('click', function(e) {
    if (!e.target.closest('.el-action-wrapper')) {
        var open = document.querySelectorAll('.el-action-popover.is-open');
        for (var i = 0; i < open.length; i++) open[i].classList.remove('is-open');
    }
});
function toggleActions(btn) {
    var pop = btn.nextElementSibling;
    var isOpen = pop.classList.contains('is-open');
    var all = document.querySelectorAll('.el-action-popover.is-open');
    for (var i = 0; i < all.length; i++) all[i].classList.remove('is-open');
    if (!isOpen) pop.classList.add('is-open');
}
</script>

<asp:Button ID="btnStatusChange" runat="server" Text="" OnClick="btnStatusChange_Click" style="display:none;" />
</asp:Content>
