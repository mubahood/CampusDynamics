<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="BursaryBeneficiaries.aspx.cs" Inherits="COOPERP_NewScreens_BursaryBeneficiaries" Title="Bursary Beneficiaries - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== BURSARY BENEFICIARIES =========================================== */

/* Stats Row */
.bb-stats { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; margin-bottom: 14px; }
.bb-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.bb-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.bb-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.bb-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.bb-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.bb-stat--total { --stat-c: #174DA4; } .bb-stat--total .bb-stat__icon { background: #e8f0fc; } .bb-stat--total .bb-stat__val { color: #174DA4; }
.bb-stat--approved { --stat-c: #2e7d32; } .bb-stat--approved .bb-stat__icon { background: #e6f4ea; } .bb-stat--approved .bb-stat__val { color: #2e7d32; }
.bb-stat--pending { --stat-c: #e65100; } .bb-stat--pending .bb-stat__icon { background: #fff3e0; } .bb-stat--pending .bb-stat__val { color: #e65100; }
.bb-stat--rejected { --stat-c: #c62828; } .bb-stat--rejected .bb-stat__icon { background: #fde8e8; } .bb-stat--rejected .bb-stat__val { color: #c62828; }
.bb-stat--amount { --stat-c: #00897b; } .bb-stat--amount .bb-stat__icon { background: #e0f2f1; } .bb-stat--amount .bb-stat__val { color: #00695c; }

/* Card */
.bb-card { background: #fff; border: 1px solid #e0e5ed; overflow: hidden; margin-bottom: 14px; }
.bb-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 6px; }
.bb-card__title { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }
.bb-card__meta { font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.07); padding: 2px 8px; border: 1px solid rgba(23,77,164,.15); }

/* Filters */
.bb-filters { background: #f8f9fb; border-bottom: 1px solid #e0e5ed; padding: 10px 14px; }
.bb-filters__top { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; flex-wrap: wrap; }
.bb-filters__row { display: flex; gap: 8px; flex-wrap: wrap; align-items: flex-end; }
.bb-search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 380px; }
.bb-search-wrap svg { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #999; pointer-events: none; }
.bb-search-box { width: 100%; padding: 7px 12px 7px 32px; border: 1px solid #e0e5ed; font-size: 12px; background: #fff; box-sizing: border-box; }
.bb-search-box:focus { border-color: #174DA4; outline: none; }
.bb-filter-grp { display: flex; flex-direction: column; gap: 3px; }
.bb-filter-grp__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #999; font-weight: 600; }
.bb-filter-select { border: 1px solid #e0e5ed; padding: 6px 10px; font-size: 11px; background: #fff; color: #333; cursor: pointer; min-width: 110px; }
.bb-filter-select:focus { border-color: #174DA4; outline: none; }

/* Buttons */
.bb-btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.bb-btn--primary { background: #05275C; color: #fff; } .bb-btn--primary:hover { background: #174DA4; }
.bb-btn--ghost { background: transparent; border: 1px solid #e0e5ed; color: #555; } .bb-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.bb-btn--sm { padding: 5px 11px; font-size: 10px; }



/* Grid Footer */
.bb-grid-footer { display: flex; justify-content: space-between; align-items: center; padding: 8px 14px; background: #f8f9fb; border-top: 1px solid #e0e5ed; font-size: 11px; color: #666; flex-wrap: wrap; gap: 6px; }
.bb-grid-footer strong { color: #05275C; }

/* DevExpress Grid overrides */
.dxgvControl_Glass { border: 1px solid #e0e5ed !important; }
.dxgvHeader_Glass td { font-size: 10px !important; text-transform: uppercase !important; letter-spacing: .3px !important; background: #f5f7fa !important; color: #555 !important; border-bottom: 2px solid #e0e5ed !important; padding: 9px 12px !important; font-weight: 600 !important; }
.dxgvDataRow_Glass td, .dxgvDataRowAlt_Glass td { font-size: 11px !important; color: #1a1a2e !important; padding: 8px 12px !important; border-bottom: 1px solid #f0f2f5 !important; vertical-align: middle !important; }
.dxgvDataRow_Glass:hover td, .dxgvDataRowAlt_Glass:hover td { background: #f8f9fb !important; }
.dxgvFilterRow_Glass td { padding: 4px 6px !important; background: #fff !important; }
.dxgvFilterRow_Glass input { border: 1px solid #e0e5ed !important; font-size: 11px !important; padding: 3px 6px !important; }
.dxgvPagerBar_Glass { background: #f5f7fa !important; border-top: 1px solid #e0e5ed !important; padding: 6px 12px !important; }

/* ===== MODAL ============================================================ */
.fs-modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.45); z-index: 9998; }
.fs-modal-overlay--visible { display: flex; align-items: center; justify-content: center; }
.fs-modal { background: #fff; width: 560px; max-width: 96vw; max-height: 92vh; overflow-y: auto; box-shadow: 0 12px 40px rgba(0,0,0,.18); }
.fs-modal__header { background: #05275C; padding: 12px 18px; display: flex; align-items: center; justify-content: space-between; }
.fs-modal__title  { font-size: 13px; font-weight: 700; color: #fff; }
.fs-modal__close  { width: 24px; height: 24px; border: none; background: rgba(255,255,255,.15); cursor: pointer; color: #fff; font-size: 16px; line-height: 1; display: flex; align-items: center; justify-content: center; }
.fs-modal__close:hover { background: rgba(255,255,255,.3); }
.fs-modal__body   { padding: 16px 18px; }
.fs-modal__footer { padding: 11px 18px; border-top: 1px solid #e0e5ed; display: flex; gap: 8px; justify-content: flex-end; background: #f8f9fb; }

/* Form */
.fs-form-row { display: flex; gap: 10px; margin-bottom: 10px; flex-wrap: wrap; }
.fs-form-group { display: flex; flex-direction: column; gap: 3px; flex: 1; min-width: 130px; }
.fs-form-label { font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #666; font-weight: 700; }
.fs-form-label .req { color: #dc3545; }
.fs-form-input { border: 1px solid #cdd3de; padding: 6px 9px; font-size: 12px; color: #1a1a2e; background: #fff; width: 100%; box-sizing: border-box; }
.fs-form-input:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,.12); }
.fs-form-input:disabled, .fs-form-input[readonly] { background: #f5f7fa; color: #888; cursor: not-allowed; }

.fs-btn { padding: 5px 13px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: background .15s; line-height: 1.5; }
.fs-btn--primary { background: #05275C; color: #fff; } .fs-btn--primary:hover { background: #041d45; }
.fs-btn--ghost   { background: #fff; color: #444; border: 1px solid #cdd3de; } .fs-btn--ghost:hover { border-color: #05275C; color: #05275C; }

/* Toast */
.fs-toast { display: none; padding: 9px 14px; font-size: 12px; font-weight: 600; margin-bottom: 12px; border: 1px solid transparent; }
.fs-toast--success { display: block; background: #e6f4ea; color: #155724; border-color: #c3e6cb; }
.fs-toast--error   { display: block; background: #fde8e8; color: #c62828; border-color: #f5c6cb; }

/* Student lookup */
.bb-student-info { display: none; background: #f0f4ff; border: 1px solid #d0daf0; padding: 10px 14px; margin-bottom: 10px; font-size: 12px; }
.bb-student-info--visible { display: block; }
.bb-student-info--error { background: #fde8e8; border-color: #f5c6cb; color: #c62828; }
.bb-student-info__name { font-weight: 700; color: #05275C; font-size: 13px; }
.bb-student-info__detail { color: #555; margin-top: 2px; }

/* Autocomplete */
.bb-ac { position: relative; }
.bb-ac__list { display: none; position: absolute; left: 0; right: 0; top: 100%; background: #fff; border: 1px solid #cdd3de; border-top: none; z-index: 100; max-height: 200px; overflow-y: auto; box-shadow: 0 6px 16px rgba(0,0,0,.1); }
.bb-ac__list--visible { display: block; }
.bb-ac__item { padding: 8px 10px; font-size: 11px; cursor: pointer; border-bottom: 1px solid #f0f2f5; }
.bb-ac__item:hover { background: #f0f4ff; }
.bb-ac__item strong { color: #05275C; }

/* Row Action Button */
.bb-row-action { width:28px; height:28px; border:1px solid transparent; background:none; color:#666; font-size:18px; line-height:1; cursor:pointer; border-radius:4px; display:inline-flex; align-items:center; justify-content:center; transition:all .15s; }
.bb-row-action:hover { background:#eef1f6; border-color:#d0d5dd; color:#05275C; }

/* Action Popover (position:fixed to avoid clipping) */
.bb-action-pop { position:fixed; z-index:99999; background:#fff; border-radius:8px; box-shadow:0 8px 24px rgba(0,0,0,.16),0 2px 8px rgba(0,0,0,.08); border:1px solid #e0e5ed; min-width:170px; padding:4px 0; display:none; }
.bb-action-pop--visible { display:block; }
.bb-action-pop__item { display:flex; align-items:center; gap:8px; padding:9px 16px; font-size:13px; color:#333; cursor:pointer; border:none; background:none; width:100%; text-align:left; transition:background .12s; font-family:inherit; }
.bb-action-pop__item:hover { background:#f0f4ff; color:#05275C; }
.bb-action-pop__item--danger { color:#dc3545; }
.bb-action-pop__item--danger:hover { background:#fde8e8; color:#b91c1c; }
.bb-action-pop__sep { height:1px; background:#e5e7eb; margin:4px 0; }

/* Responsive */
@media (max-width: 900px) { .bb-stats { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 600px) { .bb-stats { grid-template-columns: 1fr; } }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Toast -->
<asp:Panel ID="pnlToast" runat="server" Visible="false">
    <div runat="server" id="divToast" class="fs-toast"></div>
</asp:Panel>

<!-- Stats -->
<div class="bb-stats">
    <div class="bb-stat bb-stat--total">
        <div class="bb-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg></div>
        <div><div class="bb-stat__val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div><div class="bb-stat__label">Total Beneficiaries</div></div>
    </div>
    <div class="bb-stat bb-stat--amount">
        <div class="bb-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00695c" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg></div>
        <div><div class="bb-stat__val"><asp:Literal ID="litTotalAmount" runat="server" Text="0" /></div><div class="bb-stat__label">Total Awarded</div></div>
    </div>
</div>

<!-- Main Grid Card -->
<div class="bb-card">
    <div class="bb-card__header">
        <div class="bb-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#05275C" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="23" y1="11" x2="17" y2="11"></line></svg>
            Bursary Beneficiaries
        </div>
        <div style="display:flex;gap:6px;align-items:center;">
            <asp:Label ID="lblRecordCount" runat="server" CssClass="bb-card__meta" Text="0 records" />
            <button type="button" class="bb-btn bb-btn--ghost bb-btn--sm" onclick="document.getElementById('<%= btnExportCsv.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                Export CSV
            </button>
        </div>
    </div>

    <!-- Filters -->
    <div class="bb-filters">
        <div class="bb-filters__top">
            <div class="bb-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="bb-search-box" placeholder="Search by reg no, student name, scheme name..." AutoPostBack="false" />
            </div>
            <button type="button" class="bb-btn bb-btn--primary bb-btn--sm" onclick="document.getElementById('<%= btnSearch.ClientID %>').click()">Search</button>
            <asp:Label ID="lblFilterInfo" runat="server" CssClass="bb-card__meta" />
        </div>
        <div class="bb-filters__row">
            <div class="bb-filter-grp">
                <label class="bb-filter-grp__label">Bursary Scheme</label>
                <asp:DropDownList ID="ddlScheme" runat="server" CssClass="bb-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlScheme_SelectedIndexChanged" style="min-width:160px;" />
            </div>
            <div class="bb-filter-grp">
                <label class="bb-filter-grp__label">Academic Year</label>
                <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="bb-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged" />
            </div>
            <div class="bb-filter-grp">
                <label class="bb-filter-grp__label">Semester</label>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="bb-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All Semesters" />
                    <asp:ListItem Value="1" Text="Semester 1" />
                    <asp:ListItem Value="2" Text="Semester 2" />
                    <asp:ListItem Value="3" Text="Semester 3" />
                </asp:DropDownList>
            </div>
            <div class="bb-filter-grp">
                <label class="bb-filter-grp__label">Per Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="bb-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="min-width:80px;">
                    <asp:ListItem Value="50" Text="50" Selected="True" />
                    <asp:ListItem Value="100" Text="100" />
                    <asp:ListItem Value="200" Text="200" />
                    <asp:ListItem Value="500" Text="500" />
                </asp:DropDownList>
            </div>
            <button type="button" class="bb-btn bb-btn--ghost bb-btn--sm" style="align-self:flex-end;" onclick="document.getElementById('<%= btnReset.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
                Reset
            </button>
            <span style="flex:1;"></span>
            <button type="button" class="bb-btn bb-btn--primary bb-btn--sm" style="align-self:flex-end;" onclick="openModal('modal-add-beneficiary')">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                Add Beneficiary
            </button>
        </div>
    </div>

    <!-- Grid -->
    <div style="overflow-x:auto;">
    <dx:ASPxGridView ID="gvBeneficiaries" runat="server" ClientInstanceName="gvBeneficiaries"
        Width="100%" KeyFieldName="stid"
        AutoGenerateColumns="False"
        EnableCallBacks="true"
        Theme="Glass"
        Settings-VerticalScrollBarMode="Visible"
        Settings-VerticalScrollableHeight="480"
        SettingsPager-Mode="ShowPager"
        SettingsPager-PageSize="50">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="stid" Caption="ID" Width="55px">
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="adm_no" Caption="Reg No" Width="125px">
                <CellStyle ForeColor="#05275C" Font-Bold="true" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student Name" Width="170px" />
            <dx:GridViewDataTextColumn FieldName="scholarshipName" Caption="Bursary Scheme" Width="145px" />
            <dx:GridViewDataTextColumn FieldName="scholarhipYear" Caption="Acad. Year" Width="90px" />
            <dx:GridViewDataTextColumn FieldName="study_year" Caption="Study Yr" Width="65px">
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="scholarhipTerm" Caption="Sem" Width="50px">
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="amount_offered" Caption="Amount" Width="110px">
                <Settings AllowAutoFilter="False" />
                <DataItemTemplate>
                    <span style="font-weight:700;font-variant-numeric:tabular-nums;"><%# FormatAmt(Eval("amount_offered")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="transaction_ref" Caption="TX Ref" Width="70px">
                <DataItemTemplate><%# FormatTxRef(Eval("transaction_ref")) %></DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="date_added" Caption="Date Added" Width="100px">
                <DataItemTemplate><%# FormatDate(Eval("date_added")) %></DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn Caption="" Width="42px">
                <Settings AllowSort="False" AllowAutoFilter="False" />
                <CellStyle HorizontalAlign="Center" Paddings-PaddingLeft="0px" Paddings-PaddingRight="0px" />
                <DataItemTemplate>
                    <button type="button" class="bb-row-action"
                        data-id='<%# Eval("stid") %>'
                        data-regno='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("adm_no"))) %>'
                        data-name='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("student_name"))) %>'
                        data-scheme='<%# Eval("scholarshipID") %>'
                        data-year='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("scholarhipYear"))) %>'
                        data-sem='<%# Eval("scholarhipTerm") %>'
                        data-amount='<%# Eval("amount_offered") %>'
                        data-txref='<%# SafeStr(Eval("transaction_ref")) %>'
                        data-notes='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("notes"))) %>'
                        data-schemename='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("scholarshipName"))) %>'
                        data-studyyear='<%# Eval("study_year") %>'
                        data-dateadded='<%# HttpUtility.HtmlAttributeEncode(FormatDate(Eval("date_added"))) %>'
                        onclick="showRowAction(event,this)">&#8942;</button>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
        </Columns>
    </dx:ASPxGridView>
    </div>

    <!-- Footer -->
    <div class="bb-grid-footer">
        <asp:Literal ID="litFooter" runat="server" />
    </div>
</div>

<!-- Hidden postback buttons -->
<asp:Button ID="btnSearch" runat="server" OnClick="btnSearch_Click" style="display:none" />
<asp:Button ID="btnReset" runat="server" OnClick="btnReset_Click" style="display:none" />
<asp:Button ID="btnSaveBeneficiary" runat="server" OnClick="btnSaveBeneficiary_Click" style="display:none" />
<asp:Button ID="btnEditBeneficiary" runat="server" OnClick="btnEditBeneficiary_Click" style="display:none" />
<asp:Button ID="btnDeleteBeneficiary" runat="server" OnClick="btnDeleteBeneficiary_Click" style="display:none" />
<asp:Button ID="btnExportCsv" runat="server" OnClick="btnExportCsv_Click" style="display:none" />

<!-- Hidden fields -->
<asp:HiddenField ID="hfEditID" runat="server" />
<asp:HiddenField ID="hfDeleteID" runat="server" />
<asp:HiddenField ID="hfAddRegNo" runat="server" />

<!-- Action Popover (position:fixed) -->
<div class="bb-action-pop" id="actionPop">
    <button type="button" class="bb-action-pop__item" onclick="viewBeneficiary()">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
        View Details
    </button>
    <div class="bb-action-pop__sep"></div>
    <button type="button" class="bb-action-pop__item" onclick="editBeneficiary()">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
        Edit Record
    </button>
    <div class="bb-action-pop__sep"></div>
    <button type="button" class="bb-action-pop__item bb-action-pop__item--danger" onclick="confirmDeleteBeneficiary()">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
        Remove Beneficiary
    </button>
</div>

<!-- Add Beneficiary Modal -->
<div id="modal-add-beneficiary" class="fs-modal-overlay" onclick="if(event.target===this)closeModal('modal-add-beneficiary')">
    <div class="fs-modal">
        <div class="fs-modal__header">
            <div class="fs-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                Add Bursary Beneficiary
            </div>
            <button type="button" class="fs-modal__close" onclick="closeModal('modal-add-beneficiary')">&times;</button>
        </div>
        <div class="fs-modal__body">
            <!-- Student lookup -->
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Student Reg No <span class="req">*</span></label>
                    <div class="bb-ac">
                        <asp:TextBox ID="txtAddRegNo" runat="server" CssClass="fs-form-input" placeholder="Type reg number to search..." autocomplete="off" />
                        <div id="acAddList" class="bb-ac__list"></div>
                    </div>
                </div>
            </div>
            <div id="addStudentInfo" class="bb-student-info"></div>
            <div id="addRegInfo" class="bb-student-info" style="display:none;background:#e6f4ea;border-color:#c3e6cb;">
                <div class="bb-student-info__name" style="color:#2e7d32;"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2.5" style="vertical-align:-1px;margin-right:4px;"><polyline points="20 6 9 17 4 12"></polyline></svg>Registration Found: <span id="addRegSummary">—</span></div>
            </div>
            <div id="addRegWarning" class="bb-student-info bb-student-info--error" style="display:none;">
                <div class="bb-student-info__name" style="color:#c62828;"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#c62828" stroke-width="2.5" style="vertical-align:-1px;margin-right:4px;"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg><span id="addRegWarnMsg">No registration found</span></div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Bursary Scheme <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddScheme" runat="server" CssClass="fs-form-input" onchange="onAddSchemeChange(this)" />
                </div>
            </div>
            <div id="addSchemeAmountInfo" class="bb-student-info" style="display:none;background:#e8f0fc;border-color:#d0daf0;">
                <div class="bb-student-info__name" style="color:#174DA4;">Bursary Amount: <span id="addSchemeAmountVal">—</span></div>
                <div class="bb-student-info__detail" style="color:#555;">This amount will be automatically applied as a fee payment.</div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Academic Year <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddAcadYear" runat="server" CssClass="fs-form-input" style="background:#f5f7fa;color:#888;" />
                </div>
                <div class="fs-form-group">
                    <label class="fs-form-label">Semester <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAddSemester" runat="server" CssClass="fs-form-input" style="background:#f5f7fa;color:#888;">
                        <asp:ListItem Value="1" Text="Semester 1" Selected="True" />
                        <asp:ListItem Value="2" Text="Semester 2" />
                        <asp:ListItem Value="3" Text="Semester 3" />
                    </asp:DropDownList>
                </div>
                <div class="fs-form-group" style="max-width:100px;">
                    <label class="fs-form-label">Study Year</label>
                    <input type="text" id="txtAddStudyYear" class="fs-form-input" readonly="readonly" style="background:#f5f7fa;color:#05275C;font-weight:700;text-align:center;" placeholder="—" />
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Notes</label>
                    <asp:TextBox ID="txtAddNotes" runat="server" CssClass="fs-form-input" TextMode="MultiLine" Rows="2" placeholder="Optional notes about this allocation..." MaxLength="500" />
                </div>
            </div>
        </div>
        <div class="fs-modal__footer">
            <button type="button" class="fs-btn fs-btn--ghost" onclick="closeModal('modal-add-beneficiary')">Cancel</button>
            <button type="button" id="btnModalSave" class="fs-btn fs-btn--primary" onclick="submitAdd(this)">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                Save Beneficiary
            </button>
        </div>
    </div>
</div>

<!-- Edit Beneficiary Modal -->
<div id="modal-edit-beneficiary" class="fs-modal-overlay" onclick="if(event.target===this)closeModal('modal-edit-beneficiary')">
    <div class="fs-modal">
        <div class="fs-modal__header">
            <div class="fs-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                Edit Beneficiary
            </div>
            <button type="button" class="fs-modal__close" onclick="closeModal('modal-edit-beneficiary')">&times;</button>
        </div>
        <div class="fs-modal__body">
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Student Reg No</label>
                    <asp:TextBox ID="txtEditRegNo" runat="server" CssClass="fs-form-input" ReadOnly="true" />
                </div>
                <div class="fs-form-group">
                    <label class="fs-form-label">Student Name</label>
                    <asp:TextBox ID="txtEditStudName" runat="server" CssClass="fs-form-input" ReadOnly="true" />
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Bursary Scheme <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditScheme" runat="server" CssClass="fs-form-input" />
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Academic Year <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditAcadYear" runat="server" CssClass="fs-form-input" />
                </div>
                <div class="fs-form-group">
                    <label class="fs-form-label">Semester <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEditSemester" runat="server" CssClass="fs-form-input">
                        <asp:ListItem Value="1" Text="Semester 1" />
                        <asp:ListItem Value="2" Text="Semester 2" />
                        <asp:ListItem Value="3" Text="Semester 3" />
                    </asp:DropDownList>
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Amount Offered (UGX) <span class="req">*</span></label>
                    <asp:TextBox ID="txtEditAmount" runat="server" CssClass="fs-form-input" />
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Transaction Reference (TID)</label>
                    <asp:TextBox ID="txtEditTxRef" runat="server" CssClass="fs-form-input" placeholder="Optional — linked fee transaction TID" />
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Notes</label>
                    <asp:TextBox ID="txtEditNotes" runat="server" CssClass="fs-form-input" TextMode="MultiLine" Rows="2" MaxLength="500" />
                </div>
            </div>
        </div>
        <div class="fs-modal__footer">
            <button type="button" class="fs-btn fs-btn--ghost" onclick="closeModal('modal-edit-beneficiary')">Cancel</button>
            <button type="button" id="btnModalEdit" class="fs-btn fs-btn--primary" onclick="this.disabled=true;this.innerText='Updating...';document.getElementById('<%= btnEditBeneficiary.ClientID %>').click();">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                Update Record
            </button>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="modal-delete-beneficiary" class="fs-modal-overlay" onclick="if(event.target===this)closeModal('modal-delete-beneficiary')">
    <div class="fs-modal" style="width:400px;">
        <div class="fs-modal__header" style="background:#c62828;">
            <div class="fs-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                Remove Beneficiary
            </div>
            <button type="button" class="fs-modal__close" onclick="closeModal('modal-delete-beneficiary')">&times;</button>
        </div>
        <div class="fs-modal__body" style="text-align:center;padding:20px;">
            <p style="font-size:13px;color:#333;margin:0 0 6px;">Are you sure you want to remove this beneficiary?</p>
            <p id="deleteBenInfo" style="font-size:12px;color:#c62828;font-weight:700;margin:0;"></p>
        </div>
        <div class="fs-modal__footer">
            <button type="button" class="fs-btn fs-btn--ghost" onclick="closeModal('modal-delete-beneficiary')">Cancel</button>
            <button type="button" class="fs-btn" style="background:#c62828;color:#fff;" onclick="this.disabled=true;this.innerText='Removing...';document.getElementById('<%= btnDeleteBeneficiary.ClientID %>').click();">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                Remove
            </button>
        </div>
    </div>
</div>

<!-- View Beneficiary Details Modal -->
<div id="modal-view-beneficiary" class="fs-modal-overlay" onclick="if(event.target===this)closeModal('modal-view-beneficiary')">
    <div class="fs-modal" style="width:520px;max-width:96vw;">
        <div class="fs-modal__header" style="background:#05275C;">
            <div class="fs-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                Beneficiary Details
            </div>
            <button type="button" class="fs-modal__close" onclick="closeModal('modal-view-beneficiary')">&times;</button>
        </div>
        <div class="fs-modal__body" style="padding:0;">
            <div id="viewBenContent"></div>
        </div>
        <div class="fs-modal__footer">
            <button type="button" class="fs-btn fs-btn--ghost" onclick="closeModal('modal-view-beneficiary')">Close</button>
            <button type="button" class="fs-btn" style="background:#174DA4;color:#fff;" onclick="closeModal('modal-view-beneficiary');setTimeout(editBeneficiary,80);">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                Edit Record
            </button>
        </div>
    </div>
</div>

<script type="text/javascript">
    // ---- Modal ----
    function openModal(id) { document.getElementById(id).classList.add('fs-modal-overlay--visible'); }
    function closeModal(id) { document.getElementById(id).classList.remove('fs-modal-overlay--visible'); }

    // ---- Student Autocomplete for Add modal ----
    var acTimer = null;
    (function () {
        var inp = document.getElementById('<%= txtAddRegNo.ClientID %>');
        var list = document.getElementById('acAddList');
        var info = document.getElementById('addStudentInfo');
        if (!inp) return;
        inp.addEventListener('input', function () {
            clearTimeout(acTimer);
            var v = inp.value.trim();
            if (v.length < 2) { list.classList.remove('bb-ac__list--visible'); info.className = 'bb-student-info'; return; }
            acTimer = setTimeout(function () {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', 'BursaryBeneficiaries.aspx?ajax=search&q=' + encodeURIComponent(v), true);
                xhr.onload = function () {
                    if (xhr.status === 200) {
                        try {
                            var data = JSON.parse(xhr.responseText);
                            if (data.length === 0) { list.innerHTML = '<div class="bb-ac__item" style="color:#888;">No students found</div>'; }
                            else {
                                var html = '';
                                for (var i = 0; i < data.length; i++) {
                                    html += '<div class="bb-ac__item" data-reg="' + esc(data[i].regno) + '" data-name="' + esc(data[i].name) + '" data-prog="' + esc(data[i].programme) + '">'
                                        + '<strong>' + esc(data[i].regno) + '</strong> — ' + esc(data[i].name) + '<br><small style="color:#888;">' + esc(data[i].programme) + '</small></div>';
                                }
                                list.innerHTML = html;
                            }
                            list.classList.add('bb-ac__list--visible');
                        } catch (e) { }
                    }
                };
                xhr.send();
            }, 300);
        });
        list.addEventListener('click', function (e) {
            var item = e.target.closest('.bb-ac__item');
            if (!item || !item.getAttribute('data-reg')) return;
            var regNo = item.getAttribute('data-reg');
            inp.value = regNo;
            document.getElementById('<%= hfAddRegNo.ClientID %>').value = regNo;
            info.className = 'bb-student-info bb-student-info--visible';
            info.innerHTML = '<div class="bb-student-info__name">' + esc(item.getAttribute('data-name')) + '</div><div class="bb-student-info__detail">' + esc(regNo) + ' &mdash; ' + esc(item.getAttribute('data-prog')) + '</div>';
            list.classList.remove('bb-ac__list--visible');
            // Fetch registration info for this student
            fetchRegistration(regNo);
        });
        document.addEventListener('click', function (ev) { if (!inp.contains(ev.target) && !list.contains(ev.target)) list.classList.remove('bb-ac__list--visible'); });
    })();

    // ---- Fetch Registration Info ----
    function fetchRegistration(regNo) {
        var ddlYear = document.getElementById('<%= ddlAddAcadYear.ClientID %>');
        var ddlSem = document.getElementById('<%= ddlAddSemester.ClientID %>');
        var studyYr = document.getElementById('txtAddStudyYear');
        var regInfo = document.getElementById('addRegInfo');
        var regSummary = document.getElementById('addRegSummary');
        var regWarn = document.getElementById('addRegWarning');
        var regWarnMsg = document.getElementById('addRegWarnMsg');

        // Reset
        regInfo.style.display = 'none';
        regWarn.style.display = 'none';
        studyYr.value = '';
        ddlYear.style.background = ''; ddlYear.style.color = '';
        ddlSem.style.background = ''; ddlSem.style.color = '';

        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'BursaryBeneficiaries.aspx?ajax=getreg&r=' + encodeURIComponent(regNo), true);
        xhr.onload = function () {
            if (xhr.status === 200) {
                try {
                    var d = JSON.parse(xhr.responseText);
                    if (d.found) {
                        // Auto-set Academic Year
                        for (var i = 0; i < ddlYear.options.length; i++) {
                            if (ddlYear.options[i].value === d.acad_year) { ddlYear.selectedIndex = i; break; }
                        }
                        // Auto-set Semester
                        for (var i = 0; i < ddlSem.options.length; i++) {
                            if (ddlSem.options[i].value === String(d.semester)) { ddlSem.selectedIndex = i; break; }
                        }
                        // Set study year
                        studyYr.value = 'Year ' + d.study_year;

                        // Style as auto-filled
                        ddlYear.style.background = '#f5f7fa'; ddlYear.style.color = '#05275C'; ddlYear.style.fontWeight = '700';
                        ddlSem.style.background = '#f5f7fa'; ddlSem.style.color = '#05275C'; ddlSem.style.fontWeight = '700';

                        if (d.regstatus === 'REGISTERED') {
                            regInfo.style.display = 'block';
                            regSummary.textContent = d.acad_year + ', Semester ' + d.semester + ', Study Year ' + d.study_year;
                            regWarn.style.display = 'none';
                        } else {
                            regInfo.style.display = 'none';
                            regWarn.style.display = 'block';
                            regWarnMsg.textContent = 'Student is ' + d.regstatus + ' for ' + d.acad_year + ' Sem ' + d.semester + '. Bursary may not be applied.';
                        }
                    } else {
                        regInfo.style.display = 'none';
                        regWarn.style.display = 'block';
                        regWarnMsg.textContent = 'No registration record found for this student. Please verify the student is registered.';
                    }
                } catch (e) { }
            }
        };
        xhr.send();
    }

    function submitAdd(btn) {
        var hf = document.getElementById('<%= hfAddRegNo.ClientID %>');
        var inp = document.getElementById('<%= txtAddRegNo.ClientID %>');
        if (hf.value === '' && inp.value.trim() !== '') hf.value = inp.value.trim();
        btn.disabled = true; btn.innerText = 'Saving...';
        document.getElementById('<%= btnSaveBeneficiary.ClientID %>').click();
    }

    // ---- Auto-fill scheme amount on Add modal ----
    function onAddSchemeChange(ddl) {
        var info = document.getElementById('addSchemeAmountInfo');
        var valSpan = document.getElementById('addSchemeAmountVal');
        var schemeId = ddl.value;
        if (schemeId && typeof _schemeAmounts !== 'undefined' && _schemeAmounts[schemeId]) {
            var amt = _schemeAmounts[schemeId];
            valSpan.textContent = 'UGX ' + Number(amt).toLocaleString();
            info.style.display = 'block';
            info.className = 'bb-student-info bb-student-info--visible';
            info.style.background = '#e8f0fc';
            info.style.borderColor = '#d0daf0';
        } else {
            info.style.display = 'none';
        }
    }

    /* ==== Row Action Popover ==== */
    var _activeRowData = null;

    function showRowAction(evt, btn) {
        evt.stopPropagation();
        evt.preventDefault();
        var pop = document.getElementById('actionPop');

        _activeRowData = {
            id:         btn.getAttribute('data-id'),
            regno:      btn.getAttribute('data-regno'),
            name:       btn.getAttribute('data-name'),
            scheme:     btn.getAttribute('data-scheme'),
            schemeName: btn.getAttribute('data-schemename'),
            year:       btn.getAttribute('data-year'),
            sem:        btn.getAttribute('data-sem'),
            studyYear:  btn.getAttribute('data-studyyear'),
            amount:     btn.getAttribute('data-amount'),
            txref:      btn.getAttribute('data-txref'),
            dateAdded:  btn.getAttribute('data-dateadded'),
            notes:      btn.getAttribute('data-notes')
        };

        var rect = btn.getBoundingClientRect();
        var popH = 130;
        var spaceBelow = window.innerHeight - rect.bottom;

        pop.style.left = Math.max(4, rect.left - 140) + 'px';
        if (spaceBelow < popH + 10) {
            pop.style.top = (rect.top - popH - 4) + 'px';
        } else {
            pop.style.top = (rect.bottom + 4) + 'px';
        }
        pop.classList.add('bb-action-pop--visible');
    }

    function hideRowAction() {
        var pop = document.getElementById('actionPop');
        if (pop) pop.classList.remove('bb-action-pop--visible');
    }

    // Close popover on outside click
    document.addEventListener('click', function(e) {
        var pop = document.getElementById('actionPop');
        if (pop && pop.classList.contains('bb-action-pop--visible')) {
            if (!pop.contains(e.target) && !e.target.classList.contains('bb-row-action')) {
                hideRowAction();
            }
        }
    });
    // Close popover on scroll
    window.addEventListener('scroll', hideRowAction, true);

    function editBeneficiary() {
        hideRowAction();
        if (!_activeRowData) return;
        var d = _activeRowData;
        document.getElementById('<%= hfEditID.ClientID %>').value = d.id;
        document.getElementById('<%= txtEditRegNo.ClientID %>').value = d.regno;
        document.getElementById('<%= txtEditStudName.ClientID %>').value = d.name;
        document.getElementById('<%= txtEditAmount.ClientID %>').value = d.amount;
        document.getElementById('<%= txtEditTxRef.ClientID %>').value = d.txref;
        document.getElementById('<%= txtEditNotes.ClientID %>').value = d.notes;

        // Select scheme
        var ddlS = document.getElementById('<%= ddlEditScheme.ClientID %>');
        for (var i = 0; i < ddlS.options.length; i++) { if (ddlS.options[i].value === d.scheme) ddlS.selectedIndex = i; }
        // Select year
        var ddlY = document.getElementById('<%= ddlEditAcadYear.ClientID %>');
        for (var i = 0; i < ddlY.options.length; i++) { if (ddlY.options[i].value === d.year) ddlY.selectedIndex = i; }
        // Select semester
        var ddlSm = document.getElementById('<%= ddlEditSemester.ClientID %>');
        for (var i = 0; i < ddlSm.options.length; i++) { if (ddlSm.options[i].value === d.sem) ddlSm.selectedIndex = i; }
        openModal('modal-edit-beneficiary');
    }

    function viewBeneficiary() {
        hideRowAction();
        if (!_activeRowData) return;
        var d = _activeRowData;
        var amtNum = parseFloat(d.amount) || 0;
        var amtFmt = 'UGX ' + amtNum.toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
        var hasTx = d.txref && d.txref.trim() !== '' && d.txref !== '0';
        var txBadge = hasTx
            ? '<a href="FeesTransactions.aspx?tid=' + esc(d.txref) + '" target="_blank" style="display:inline-flex;align-items:center;gap:5px;background:#e8f5e9;color:#2e7d32;border:1px solid #a5d6a7;border-radius:12px;padding:3px 12px;font-size:11px;font-weight:700;text-decoration:none;" title="Open fee transaction"><svg xmlns=\'http://www.w3.org/2000/svg\' width=\'11\' height=\'11\' viewBox=\'0 0 24 24\' fill=\'none\' stroke=\'currentColor\' stroke-width=\'2\'><path d=\'M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6\'/><polyline points=\'15 3 21 3 21 9\'/><line x1=\'10\' y1=\'14\' x2=\'21\' y2=\'3\'/></svg>#' + esc(d.txref) + '</a>'
            : '<span style="display:inline-block;background:#fff3e0;color:#e65100;border:1px solid #ffcc80;border-radius:12px;padding:2px 10px;font-size:11px;font-weight:600;">Not linked</span>';
        var notesHtml = (d.notes && d.notes.trim() !== '')
            ? '<div style="background:#f8f9ff;border-left:3px solid #05275C;border-radius:0 6px 6px 0;padding:10px 14px;font-size:12.5px;color:#333;line-height:1.6;white-space:pre-wrap;">' + esc(d.notes) + '</div>'
            : '<span style="color:#aaa;font-style:italic;font-size:12px;">No notes recorded.</span>';
        var sem = d.sem ? 'Semester ' + d.sem : '—';
        var studyYr = d.studyYear ? 'Year ' + d.studyYear : '—';
        var html =
            '<div style="padding:20px 22px;">' +
            '<div style="display:flex;align-items:center;gap:14px;margin-bottom:20px;">' +
            '<div style="width:46px;height:46px;background:#05275C;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;">' +
            '<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>' +
            '</div>' +
            '<div>' +
            '<div style="font-size:16px;font-weight:700;color:#05275C;">' + esc(d.name) + '</div>' +
            '<div style="font-size:12px;color:#666;margin-top:2px;">' + esc(d.regno) + ' &nbsp;&bull;&nbsp; Record ID: ' + esc(d.id) + '</div>' +
            '</div>' +
            '</div>' +
            '<table style="width:100%;border-collapse:collapse;font-size:13px;">' +
            '<tr style="border-bottom:1px solid #f0f0f0;"><td style="padding:9px 0 9px 0;color:#888;width:38%;">Bursary Scheme</td><td style="padding:9px 0;font-weight:600;color:#222;">' + esc(d.schemeName || '—') + '</td></tr>' +
            '<tr style="border-bottom:1px solid #f0f0f0;"><td style="padding:9px 0;color:#888;">Academic Year</td><td style="padding:9px 0;font-weight:600;color:#222;">' + esc(d.year || '—') + '</td></tr>' +
            '<tr style="border-bottom:1px solid #f0f0f0;"><td style="padding:9px 0;color:#888;">Semester</td><td style="padding:9px 0;font-weight:600;color:#222;">' + sem + '</td></tr>' +
            '<tr style="border-bottom:1px solid #f0f0f0;"><td style="padding:9px 0;color:#888;">Study Year</td><td style="padding:9px 0;font-weight:600;color:#222;">' + studyYr + '</td></tr>' +
            '<tr style="border-bottom:1px solid #f0f0f0;"><td style="padding:9px 0;color:#888;">Amount Offered</td><td style="padding:9px 0;font-weight:700;color:#00695c;font-size:14px;">' + amtFmt + '</td></tr>' +
            '<tr style="border-bottom:1px solid #f0f0f0;"><td style="padding:9px 0;color:#888;">TX Reference</td><td style="padding:9px 0;">' + txBadge + '</td></tr>' +
            '<tr style="border-bottom:1px solid #f0f0f0;"><td style="padding:9px 0;color:#888;">Date Added</td><td style="padding:9px 0;font-weight:600;color:#222;">' + esc(d.dateAdded || '—') + '</td></tr>' +
            '<tr><td style="padding:12px 0 4px;color:#888;vertical-align:top;">Notes</td><td style="padding:12px 0 4px;">' + notesHtml + '</td></tr>' +
            '</table>' +
            '</div>';
        document.getElementById('viewBenContent').innerHTML = html;
        openModal('modal-view-beneficiary');
    }

    function confirmDeleteBeneficiary() {
        hideRowAction();
        if (!_activeRowData) return;
        var d = _activeRowData;
        document.getElementById('<%= hfDeleteID.ClientID %>').value = d.id;
        document.getElementById('deleteBenInfo').textContent = d.regno + ' \u2014 ' + d.name;
        openModal('modal-delete-beneficiary');
    }

    function esc(s) { if (!s) return ''; var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }

    // Enter key search
    (function () {
        var box = document.getElementById('<%= txtSearch.ClientID %>');
        if (box) box.addEventListener('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); document.getElementById('<%= btnSearch.ClientID %>').click(); } });
    })();
</script>

</asp:Content>
