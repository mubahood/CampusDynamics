<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ElectionVoters.aspx.cs" Inherits="COOPERP_NewScreens_ElectionVoters" Title="Election Voters - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ELECTION VOTERS — RESPONSIVE ===== */

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
.el-filter-select {
    border: 1px solid #ddd; border-radius: 6px;
    padding: 5px 8px; font-size: 11px; background: #fff; color: #333;
    cursor: pointer; min-width: 140px;
}
.el-filter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }
.el-filter-input {
    border: 1px solid #ddd; border-radius: 6px;
    padding: 5px 8px; font-size: 11px; background: #fff; color: #333;
    min-width: 180px;
}
.el-filter-input:focus { border-color: #174DA4; box-shadow: 0 0 0 2px rgba(23,77,164,.10); outline: none; }

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

/* -- Voted Badge --------------------------------------- */
.el-voted { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; border-radius: 10px; font-size: 10px; font-weight: 600; }
.el-voted--yes { background: #e6f4ea; color: #28a745; border: 1px solid #a5d6a7; }
.el-voted--no  { background: #f5f5f5; color: #999; border: 1px solid #ddd; }

/* -- Eligible Toggle ----------------------------------- */
.el-toggle { position: relative; display: inline-block; width: 32px; height: 18px; cursor: pointer; }
.el-toggle input { opacity: 0; width: 0; height: 0; }
.el-toggle__slider {
    position: absolute; inset: 0; background: #ccc; border-radius: 18px; transition: .2s;
}
.el-toggle__slider:before {
    content: ''; position: absolute; height: 14px; width: 14px; left: 2px; bottom: 2px;
    background: #fff; border-radius: 50%; transition: .2s;
}
.el-toggle input:checked + .el-toggle__slider { background: #28a745; }
.el-toggle input:checked + .el-toggle__slider:before { transform: translateX(14px); }

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
.el-btn--outline {
    background: transparent; border: 1px solid #ddd; color: #555;
}
.el-btn--outline:hover { background: #f5f7fa; border-color: #bbb; }

/* -- Import Section ------------------------------------ */
.el-import-bar {
    background: #f0f5ff; border: 1px dashed #b3cef5; border-radius: 6px;
    padding: 12px 14px; margin-bottom: 12px;
    display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
}
.el-import-bar__title { font-size: 12px; font-weight: 600; color: #174DA4; min-width: fit-content; }
.el-import-bar__desc  { font-size: 11px; color: #666; flex: 1; min-width: 150px; }
.el-import-bar__actions { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }

/* -- Turnout Bar --------------------------------------- */
.el-turnout-lg { margin-bottom: 12px; }
.el-turnout-lg__bar {
    height: 24px; background: #f0f2f5; border-radius: 12px; overflow: hidden; position: relative;
}
.el-turnout-lg__fill {
    height: 100%; background: linear-gradient(90deg, #174DA4, #28a745);
    border-radius: 12px; transition: width .5s ease;
    display: flex; align-items: center; justify-content: flex-end; padding-right: 8px;
    min-width: 0;
}
.el-turnout-lg__text { font-size: 11px; color: #fff; font-weight: 700; white-space: nowrap; }
.el-turnout-lg__labels { display: flex; justify-content: space-between; margin-top: 3px; font-size: 10px; color: #888; }

/* -- Flash Alert --------------------------------------- */
.el-flash { padding: 8px 14px; border-radius: 6px; font-size: 12px; display: flex; align-items: center; gap: 8px; margin-bottom: 12px; }
.el-flash--ok  { background: #e6f4ea; color: #1a7c35; border: 1px solid #a5d6a7; }
.el-flash--err { background: #fdecea; color: #b71c1c; border: 1px solid #ef9a9a; }

/* -- Empty State --------------------------------------- */
.el-empty { text-align: center; padding: 40px 10px; color: #aaa; }
.el-empty svg { margin: 0 auto 8px; opacity: .5; display: block; }
.el-empty__title { font-size: 14px; font-weight: 600; color: #888; }
.el-empty__sub   { font-size: 11px; color: #aaa; margin-top: 3px; max-width: 320px; margin-left: auto; margin-right: auto; }

/* -- Responsive ---------------------------------------- */
@media(max-width:768px){
    .el-stats { grid-template-columns: repeat(2, 1fr); }
    .el-import-bar { flex-direction: column; align-items: stretch; }
    .el-filters { flex-direction: column; }
}
@media(max-width:480px){
    .el-stats { grid-template-columns: 1fr; }
}
/* -- Batch Actions ------------------------------------- */
.el-batch-bar { display:none; align-items:center; gap:7px; padding:7px 12px; background:#fffbeb; border-bottom:1px solid #fde68a; flex-wrap:wrap; }
.el-batch-bar.is-active { display:flex; }
.el-batch-bar__count { font-size:11px; font-weight:600; color:#92400e; flex:1; min-width:80px; }
.el-btn--xs { padding:4px 9px; font-size:10px; }
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
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg>
        </div>
        <div>
            <div class="el-page-header__title">Election Voters</div>
            <div class="el-page-header__sub">Manage voter rolls, import students &amp; track turnout</div>
        </div>
    </div>
</div>

<!-- Election Selector -->
<div style="margin-bottom: 12px;">
    <label style="font-size:11px; font-weight:600; color:#555; margin-right:6px;">Select Election:</label>
    <asp:DropDownList ID="ddlElection" runat="server" CssClass="el-filter-select" AutoPostBack="true"
        OnSelectedIndexChanged="ddlElection_Changed" style="min-width:250px;" />
</div>

<!-- No-election state -->
<asp:Panel ID="pnlNoElection" runat="server" Visible="true">
    <div class="cd-card">
        <div style="padding:40px; text-align:center;">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="1.5" style="margin:0 auto 8px; display:block;"><rect x="2" y="2" width="20" height="20" rx="2"/><path d="M9 11l3 3L22 4"/></svg>
            <div style="font-size:14px; font-weight:600; color:#888;">Select an election above</div>
            <div style="font-size:11px; color:#aaa; margin-top:3px;">Choose an election to manage its voter roll.</div>
        </div>
    </div>
</asp:Panel>

<!-- Election selected — content panel -->
<asp:Panel ID="pnlContent" runat="server" Visible="false">

    <!-- Turnout Progress -->
    <div class="el-turnout-lg">
        <div class="el-turnout-lg__bar">
            <div class="el-turnout-lg__fill" style='width:<%= TurnoutPct %>%;'>
                <span class="el-turnout-lg__text"><%= TurnoutPct %>%</span>
            </div>
        </div>
        <div class="el-turnout-lg__labels">
            <span>0%</span>
            <span>Voter Turnout</span>
            <span>100%</span>
        </div>
    </div>

    <!-- Stats -->
    <div class="el-stats">
        <div class="el-stat el-stat--blue">
            <div class="el-stat__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
            </div>
            <div class="el-stat__body">
                <div class="el-stat__val"><asp:Literal ID="litTotalVoters" runat="server" Text="0" /></div>
                <div class="el-stat__label">Registered Voters</div>
            </div>
        </div>
        <div class="el-stat el-stat--green">
            <div class="el-stat__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#28a745" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            </div>
            <div class="el-stat__body">
                <div class="el-stat__val"><asp:Literal ID="litVoted" runat="server" Text="0" /></div>
                <div class="el-stat__label">Have Voted</div>
            </div>
        </div>
        <div class="el-stat el-stat--amber">
            <div class="el-stat__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e67e00" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            </div>
            <div class="el-stat__body">
                <div class="el-stat__val"><asp:Literal ID="litNotVoted" runat="server" Text="0" /></div>
                <div class="el-stat__label">Not Voted</div>
            </div>
        </div>
        <div class="el-stat el-stat--red">
            <div class="el-stat__icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
            </div>
            <div class="el-stat__body">
                <div class="el-stat__val"><asp:Literal ID="litIneligible" runat="server" Text="0" /></div>
                <div class="el-stat__label">Ineligible</div>
            </div>
        </div>
    </div>

    <!-- Import Section -->
    <div class="el-import-bar">
        <div>
            <div class="el-import-bar__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align:-2px;"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                Import Voters
            </div>
            <div class="el-import-bar__desc">Import registered students as voters. Duplicates are automatically skipped.</div>
        </div>
        <div class="el-import-bar__actions">
            <asp:DropDownList ID="ddlImportProg" runat="server" CssClass="el-filter-select" style="min-width:160px;">
                <asp:ListItem Value="" Text="All Programmes" />
            </asp:DropDownList>
            <asp:DropDownList ID="ddlImportYear" runat="server" CssClass="el-filter-select" style="min-width:130px;">
                <asp:ListItem Value="" Text="All Years" />
            </asp:DropDownList>
            <asp:Button ID="btnImport" runat="server" CssClass="el-btn el-btn--success" Text="Import Students"
                OnClick="btnImport_Click" OnClientClick="return confirm('Import registered students as voters?');" />
        </div>
    </div>

    <!-- Voters Card -->
    <div class="cd-card">
        <div class="cd-card__header">
            <div class="cd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                Voter Roll
            </div>
            <div style="display:flex;align-items:center;gap:8px;">
                <asp:Literal ID="litVoterCount" runat="server" />
                <asp:Button ID="btnExportVotersCsv" runat="server" CssClass="el-btn el-btn--outline el-btn--xs"
                    Text="&#x2913; CSV" OnClick="btnExportVotersCsv_Click" ToolTip="Export voter roll as CSV" />
            </div>
        </div>

        <!-- Filters -->
        <div class="el-filters">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="el-filter-input" placeholder="Search name, reg no, programme..." />
            <asp:DropDownList ID="ddlVotedFilter" runat="server" CssClass="el-filter-select">
                <asp:ListItem Value="ALL" Text="All Voters" />
                <asp:ListItem Value="YES" Text="Voted" />
                <asp:ListItem Value="NO" Text="Not Voted" />
            </asp:DropDownList>
            <asp:Button ID="btnSearch" runat="server" CssClass="el-btn el-btn--primary" Text="Search"
                OnClick="btnSearch_Click" />
        </div>

        <!-- Batch Actions -->
        <div class="el-batch-bar" id="voterBatchBar">
            <asp:HiddenField ID="hdnBatchVoterIds" runat="server" />
            <span class="el-batch-bar__count" id="voterBatchCount">0 selected</span>
            <asp:Button ID="btnBatchVoterEligible" runat="server" CssClass="el-btn el-btn--success el-btn--xs" Text="&#x2713; Set Eligible" OnClick="btnBatchVoterEligible_Click" OnClientClick="return collectVoterIds('Mark selected as ELIGIBLE?');" />
            <asp:Button ID="btnBatchVoterIneligible" runat="server" CssClass="el-btn el-btn--ghost el-btn--xs" Text="&#x2715; Set Ineligible" OnClick="btnBatchVoterIneligible_Click" OnClientClick="return collectVoterIds('Mark selected as INELIGIBLE?');" />
            <asp:Button ID="btnBatchVoterRemove" runat="server" CssClass="el-btn el-btn--warn el-btn--xs" Text="Remove" OnClick="btnBatchVoterRemove_Click" OnClientClick="return collectVoterIds('Remove selected voters who have NOT voted yet?');" />
        </div>
        <!-- Table -->
        <div style="overflow-x:auto;">
            <table class="el-table">
                <thead>
                    <tr>
                        <th style="width:28px;text-align:center;"><input type="checkbox" id="chkAllVoters" onclick="selectAllVoters(this)" title="Select all" style="cursor:pointer;" /></th>
                        <th style="width:30px;">#</th>
                        <th>Reg No</th>
                        <th>Name</th>
                        <th>Programme</th>
                        <th>Email</th>
                        <th style="text-align:center;">Voted</th>
                        <th>Voted At</th>
                        <th style="text-align:center;">Eligible</th>
                        <th style="width:60px;text-align:center;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Literal ID="litGridBody" runat="server" />
                </tbody>
            </table>
        </div>
    </div>

    <!-- Hidden for eligibility toggle postback -->
    <asp:HiddenField ID="hdnToggleVoterId" runat="server" Value="0" />
    <asp:HiddenField ID="hdnToggleValue" runat="server" Value="0" />
    <asp:Button ID="btnToggleEligibility" runat="server" style="display:none;"
        OnClick="btnToggleEligibility_Click" />

    <!-- Hidden for single-voter delete -->
    <asp:HiddenField ID="hdnDeleteVoterId" runat="server" Value="0" />
    <asp:Button ID="btnDeleteVoter" runat="server" style="display:none;" OnClick="btnDeleteVoter_Click" />

</asp:Panel>

<script type="text/javascript">
function toggleEligibility(voterId, chk) {
    document.getElementById('<%= hdnToggleVoterId.ClientID %>').value = voterId;
    document.getElementById('<%= hdnToggleValue.ClientID %>').value = chk.checked ? '1' : '0';
    document.getElementById('<%= btnToggleEligibility.ClientID %>').click();
}

function selectAllVoters(source) {
    var boxes = document.querySelectorAll('.voter-chk');
    for (var i = 0; i < boxes.length; i++) boxes[i].checked = source.checked;
    updateVoterBatchBar();
}

function updateVoterBatchBar() {
    var boxes = document.querySelectorAll('.voter-chk:checked');
    var bar   = document.getElementById('voterBatchBar');
    var lbl   = document.getElementById('voterBatchCount');
    if (boxes.length > 0) {
        bar.classList.add('is-active');
        lbl.textContent = boxes.length + ' voter(s) selected';
    } else {
        bar.classList.remove('is-active');
        var all = document.getElementById('chkAllVoters');
        if (all) all.checked = false;
    }
}

function collectVoterIds(msg) {
    var boxes = document.querySelectorAll('.voter-chk:checked');
    if (boxes.length === 0) { alert('Please select at least one voter.'); return false; }
    var ids = [];
    for (var i = 0; i < boxes.length; i++) ids.push(boxes[i].value);
    document.getElementById('<%= hdnBatchVoterIds.ClientID %>').value = ids.join(',');
    return confirm(msg + '\n(' + boxes.length + ' voter(s) selected)');
}

function deleteVoter(voterId, name) {
    if (!confirm('Remove "' + name + '" from this voter roll?\nOnly works if they have NOT voted yet.')) return;
    document.getElementById('<%= hdnDeleteVoterId.ClientID %>').value = voterId;
    document.getElementById('<%= btnDeleteVoter.ClientID %>').click();
}
</script>
</asp:Content>
