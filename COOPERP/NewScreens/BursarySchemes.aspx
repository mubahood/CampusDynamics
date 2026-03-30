<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="BursarySchemes.aspx.cs" Inherits="COOPERP_NewScreens_BursarySchemes" Title="Bursary Schemes - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== BURSARY SCHEMES ================================================= */

/* Stats Row */
.bs-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 14px; }
.bs-stat { background: #fff; border: 1px solid #e0e5ed; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.bs-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.bs-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.bs-stat__val { font-size: 15px; font-weight: 700; line-height: 1.2; font-variant-numeric: tabular-nums; }
.bs-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.bs-stat--total   { --stat-c: #174DA4; } .bs-stat--total   .bs-stat__icon { background: #e8f0fc; } .bs-stat--total .bs-stat__val { color: #174DA4; }
.bs-stat--active  { --stat-c: #2e7d32; } .bs-stat--active  .bs-stat__icon { background: #e6f4ea; } .bs-stat--active .bs-stat__val { color: #2e7d32; }
.bs-stat--inactive { --stat-c: #c62828; } .bs-stat--inactive .bs-stat__icon { background: #fde8e8; } .bs-stat--inactive .bs-stat__val { color: #c62828; }
.bs-stat--beneficiaries { --stat-c: #e65100; } .bs-stat--beneficiaries .bs-stat__icon { background: #fff3e0; } .bs-stat--beneficiaries .bs-stat__val { color: #e65100; }

/* Card */
.bs-card { background: #fff; border: 1px solid #e0e5ed; overflow: hidden; margin-bottom: 14px; }
.bs-card__header { padding: 10px 14px; border-bottom: 1px solid #e0e5ed; background: #f8f9fb; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 6px; }
.bs-card__title { font-size: 12px; font-weight: 700; color: #05275C; display: flex; align-items: center; gap: 6px; }
.bs-card__meta { font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.07); padding: 2px 8px; border: 1px solid rgba(23,77,164,.15); }

/* Filters */
.bs-filters { background: #f8f9fb; border-bottom: 1px solid #e0e5ed; padding: 10px 14px; }
.bs-filters__row { display: flex; gap: 8px; flex-wrap: wrap; align-items: flex-end; }
.bs-search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 380px; }
.bs-search-wrap svg { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #999; pointer-events: none; }
.bs-search-box { width: 100%; padding: 7px 12px 7px 32px; border: 1px solid #e0e5ed; font-size: 12px; background: #fff; box-sizing: border-box; }
.bs-search-box:focus { border-color: #174DA4; outline: none; }
.bs-filter-grp { display: flex; flex-direction: column; gap: 3px; }
.bs-filter-grp__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #999; font-weight: 600; }
.bs-filter-select { border: 1px solid #e0e5ed; padding: 6px 10px; font-size: 11px; background: #fff; color: #333; cursor: pointer; min-width: 110px; }
.bs-filter-select:focus { border-color: #174DA4; outline: none; }

/* Buttons */
.bs-btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.bs-btn--primary { background: #05275C; color: #fff; } .bs-btn--primary:hover { background: #174DA4; }
.bs-btn--ghost { background: transparent; border: 1px solid #e0e5ed; color: #555; } .bs-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.bs-btn--success { background: #2e7d32; color: #fff; } .bs-btn--success:hover { background: #1b5e20; }
.bs-btn--danger { background: #c62828; color: #fff; } .bs-btn--danger:hover { background: #b71c1c; }
.bs-btn--sm { padding: 5px 11px; font-size: 10px; }

/* Badges */
.bs-badge { display: inline-block; padding: 3px 9px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; }
.bs-badge--active { background: #e6f4ea; color: #2e7d32; }
.bs-badge--inactive { background: #fde8e8; color: #c62828; }

/* Grid Footer */
.bs-grid-footer { display: flex; justify-content: space-between; align-items: center; padding: 8px 14px; background: #f8f9fb; border-top: 1px solid #e0e5ed; font-size: 11px; color: #666; flex-wrap: wrap; gap: 6px; }
.bs-grid-footer strong { color: #05275C; }

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
.fs-modal { background: #fff; width: 520px; max-width: 96vw; max-height: 92vh; overflow-y: auto; box-shadow: 0 12px 40px rgba(0,0,0,.18); }
.fs-modal__header { background: #05275C; padding: 12px 18px; display: flex; align-items: center; justify-content: space-between; }
.fs-modal__title  { font-size: 13px; font-weight: 700; color: #fff; }
.fs-modal__close  { width: 24px; height: 24px; border: none; background: rgba(255,255,255,.15); cursor: pointer; color: #fff; font-size: 16px; line-height: 1; display: flex; align-items: center; justify-content: center; }
.fs-modal__close:hover { background: rgba(255,255,255,.3); }
.fs-modal__body   { padding: 16px 18px; }
.fs-modal__footer { padding: 11px 18px; border-top: 1px solid #e0e5ed; display: flex; gap: 8px; justify-content: flex-end; background: #f8f9fb; }

/* Form controls */
.fs-form-row { display: flex; gap: 10px; margin-bottom: 10px; flex-wrap: wrap; }
.fs-form-group { display: flex; flex-direction: column; gap: 3px; flex: 1; min-width: 130px; }
.fs-form-label { font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #666; font-weight: 700; }
.fs-form-label .req { color: #dc3545; }
.fs-form-input { border: 1px solid #cdd3de; padding: 6px 9px; font-size: 12px; color: #1a1a2e; background: #fff; width: 100%; box-sizing: border-box; }
.fs-form-input:focus { border-color: #174DA4; outline: none; box-shadow: 0 0 0 2px rgba(23,77,164,.12); }

.fs-btn { padding: 5px 13px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: background .15s; line-height: 1.5; }
.fs-btn--primary { background: #05275C; color: #fff; } .fs-btn--primary:hover { background: #041d45; }
.fs-btn--ghost   { background: #fff; color: #444; border: 1px solid #cdd3de; } .fs-btn--ghost:hover { border-color: #05275C; color: #05275C; }

/* Toast */
.fs-toast { display: none; padding: 9px 14px; font-size: 12px; font-weight: 600; margin-bottom: 12px; border: 1px solid transparent; }
.fs-toast--success { display: block; background: #e6f4ea; color: #155724; border-color: #c3e6cb; }
.fs-toast--error   { display: block; background: #fde8e8; color: #c62828; border-color: #f5c6cb; }

/* Row Action Button */
.bs-row-action { width:28px; height:28px; border:1px solid transparent; background:none; color:#666; font-size:18px; line-height:1; cursor:pointer; border-radius:4px; display:inline-flex; align-items:center; justify-content:center; transition:all .15s; }
.bs-row-action:hover { background:#eef1f6; border-color:#d0d5dd; color:#05275C; }

/* Action Popover (position:fixed to avoid clipping) */
.bs-action-pop { position:fixed; z-index:99999; background:#fff; border-radius:8px; box-shadow:0 8px 24px rgba(0,0,0,.16),0 2px 8px rgba(0,0,0,.08); border:1px solid #e0e5ed; min-width:170px; padding:4px 0; display:none; }
.bs-action-pop--visible { display:block; }
.bs-action-pop__item { display:flex; align-items:center; gap:8px; padding:9px 16px; font-size:13px; color:#333; cursor:pointer; border:none; background:none; width:100%; text-align:left; transition:background .12s; font-family:inherit; }
.bs-action-pop__item:hover { background:#f0f4ff; color:#05275C; }
.bs-action-pop__item--danger { color:#dc3545; }
.bs-action-pop__item--danger:hover { background:#fde8e8; color:#b91c1c; }
.bs-action-pop__sep { height:1px; background:#e5e7eb; margin:4px 0; }

/* Amount display */
.bs-amount { font-weight: 700; font-variant-numeric: tabular-nums; font-size: 11px; color: #05275C; }
.bs-amount__currency { font-size: 10px; color: #888; font-weight: 600; margin-right: 2px; }

/* Responsive */
@media (max-width: 900px) { .bs-stats { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 600px) { .bs-stats { grid-template-columns: 1fr; } }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Toast -->
<asp:Panel ID="pnlToast" runat="server" Visible="false">
    <div runat="server" id="divToast" class="fs-toast"></div>
</asp:Panel>

<!-- Stats -->
<div class="bs-stats">
    <div class="bs-stat bs-stat--total">
        <div class="bs-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><path d="M20 7h-9"/><path d="M14 17H5"/><circle cx="17" cy="17" r="3"/><circle cx="7" cy="7" r="3"/></svg></div>
        <div><div class="bs-stat__val"><asp:Literal ID="litTotalSchemes" runat="server" Text="0" /></div><div class="bs-stat__label">Total Schemes</div></div>
    </div>
    <div class="bs-stat bs-stat--active">
        <div class="bs-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg></div>
        <div><div class="bs-stat__val"><asp:Literal ID="litActiveSchemes" runat="server" Text="0" /></div><div class="bs-stat__label">Active</div></div>
    </div>
    <div class="bs-stat bs-stat--inactive">
        <div class="bs-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#c62828" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg></div>
        <div><div class="bs-stat__val"><asp:Literal ID="litInactiveSchemes" runat="server" Text="0" /></div><div class="bs-stat__label">Inactive</div></div>
    </div>
    <div class="bs-stat bs-stat--beneficiaries">
        <div class="bs-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg></div>
        <div><div class="bs-stat__val"><asp:Literal ID="litTotalBeneficiaries" runat="server" Text="0" /></div><div class="bs-stat__label">Total Beneficiaries</div></div>
    </div>
</div>

<!-- Main Grid Card -->
<div class="bs-card">
    <div class="bs-card__header">
        <div class="bs-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#05275C" stroke-width="2"><path d="M20 7h-9"/><path d="M14 17H5"/><circle cx="17" cy="17" r="3"/><circle cx="7" cy="7" r="3"/></svg>
            Bursary Schemes
        </div>
        <asp:Label ID="lblRecordCount" runat="server" CssClass="bs-card__meta" Text="0 records" />
    </div>

    <!-- Filters -->
    <div class="bs-filters">
        <div class="bs-filters__row">
            <div class="bs-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="bs-search-box" placeholder="Search by scheme name or details..." AutoPostBack="false" />
            </div>
            <button type="button" class="bs-btn bs-btn--primary bs-btn--sm" onclick="document.getElementById('<%= btnSearch.ClientID %>').click()">Search</button>
            <div class="bs-filter-grp">
                <label class="bs-filter-grp__label">Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="bs-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All Statuses" />
                    <asp:ListItem Value="Active" Text="Active" />
                    <asp:ListItem Value="Inactive" Text="Inactive" />
                </asp:DropDownList>
            </div>
            <button type="button" class="bs-btn bs-btn--ghost bs-btn--sm" onclick="document.getElementById('<%= btnReset.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
                Reset
            </button>
            <span style="flex:1;"></span>
            <button type="button" class="bs-btn bs-btn--primary bs-btn--sm" onclick="openModal('modal-add-scheme')">
                <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                Add Scheme
            </button>
        </div>
    </div>

    <!-- Grid -->
    <div style="overflow-x:auto;">
    <dx:ASPxGridView ID="gvSchemes" runat="server" ClientInstanceName="gvSchemes"
        Width="100%" KeyFieldName="scholarshipID"
        AutoGenerateColumns="False"
        EnableCallBacks="true"
        Theme="Glass"
        Settings-VerticalScrollBarMode="Visible"
        Settings-VerticalScrollableHeight="480"
        SettingsPager-Mode="ShowPager"
        SettingsPager-PageSize="20">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="scholarshipID" Caption="ID" Width="55px">
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="scholarshipName" Caption="Scheme Name" Width="180px">
                <CellStyle ForeColor="#05275C" Font-Bold="true" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="scholarshipdetails" Caption="Details" Width="220px" />
            <dx:GridViewDataTextColumn FieldName="bursary_amount" Caption="Amount" Width="130px">
                <Settings AllowAutoFilter="False" />
                <DataItemTemplate>
                    <span class="bs-amount"><span class="bs-amount__currency">UGX</span><%# FormatAmount(Eval("bursary_amount")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="status" Caption="Status" Width="90px">
                <Settings AllowAutoFilter="False" />
                <DataItemTemplate>
                    <span class='bs-badge <%# GetStatusClass(Eval("status")) %>'><%# Eval("status") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="beneficiary_count" Caption="Beneficiaries" Width="100px">
                <Settings AllowAutoFilter="False" />
                <CellStyle HorizontalAlign="Center" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="created_at" Caption="Created" Width="100px">
                <DataItemTemplate><%# FormatDate(Eval("created_at")) %></DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn Caption="" Width="42px">
                <Settings AllowSort="False" AllowAutoFilter="False" />
                <CellStyle HorizontalAlign="Center" Paddings-PaddingLeft="0px" Paddings-PaddingRight="0px" />
                <DataItemTemplate>
                    <button type="button" class="bs-row-action"
                        data-id='<%# Eval("scholarshipID") %>'
                        data-name='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("scholarshipName"))) %>'
                        data-details='<%# HttpUtility.HtmlAttributeEncode(SafeStr(Eval("scholarshipdetails"))) %>'
                        data-amount='<%# Eval("bursary_amount") %>'
                        data-status='<%# Eval("status") %>'
                        onclick="showRowAction(event,this)">&#8942;</button>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
        </Columns>
    </dx:ASPxGridView>
    </div>

    <!-- Footer -->
    <div class="bs-grid-footer">
        <asp:Literal ID="litFooter" runat="server" />
    </div>
</div>

<!-- Hidden postback buttons -->
<asp:Button ID="btnSearch" runat="server" OnClick="btnSearch_Click" style="display:none" />
<asp:Button ID="btnReset" runat="server" OnClick="btnReset_Click" style="display:none" />
<asp:Button ID="btnSaveScheme" runat="server" OnClick="btnSaveScheme_Click" style="display:none" />
<asp:Button ID="btnEditScheme" runat="server" OnClick="btnEditScheme_Click" style="display:none" />
<asp:Button ID="btnDeleteScheme" runat="server" OnClick="btnDeleteScheme_Click" style="display:none" />

<!-- Hidden fields -->
<asp:HiddenField ID="hfEditID" runat="server" />
<asp:HiddenField ID="hfDeleteID" runat="server" />

<!-- Action Popover (position:fixed) -->
<div class="bs-action-pop" id="actionPop">
    <button type="button" class="bs-action-pop__item" onclick="openEditScheme()">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>
        Edit Scheme
    </button>
    <button type="button" class="bs-action-pop__item" onclick="goToBeneficiaries()">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
        View Beneficiaries
    </button>
    <div class="bs-action-pop__sep"></div>
    <button type="button" class="bs-action-pop__item bs-action-pop__item--danger" onclick="confirmDeleteScheme()">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
        Delete Scheme
    </button>
</div>

<!-- Add Scheme Modal -->
<div id="modal-add-scheme" class="fs-modal-overlay" onclick="if(event.target===this)closeModal('modal-add-scheme')">
    <div class="fs-modal">
        <div class="fs-modal__header">
            <div class="fs-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                Add Bursary Scheme
            </div>
            <button type="button" class="fs-modal__close" onclick="closeModal('modal-add-scheme')">&times;</button>
        </div>
        <div class="fs-modal__body">
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Scheme Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtAddName" runat="server" CssClass="fs-form-input" placeholder="e.g. KEF 100%" MaxLength="45" />
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Details / Description <span class="req">*</span></label>
                    <asp:TextBox ID="txtAddDetails" runat="server" CssClass="fs-form-input" placeholder="Brief description of the bursary scheme" MaxLength="45" />
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Bursary Amount (UGX) <span class="req">*</span></label>
                    <asp:TextBox ID="txtAddAmt" runat="server" CssClass="fs-form-input" placeholder="e.g. 500000" />
                </div>
                <div class="fs-form-group">
                    <label class="fs-form-label">Status</label>
                    <asp:DropDownList ID="ddlAddStatus" runat="server" CssClass="fs-form-input">
                        <asp:ListItem Value="Active" Text="Active" Selected="True" />
                        <asp:ListItem Value="Inactive" Text="Inactive" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>
        <div class="fs-modal__footer">
            <button type="button" class="fs-btn fs-btn--ghost" onclick="closeModal('modal-add-scheme')">Cancel</button>
            <button type="button" id="btnModalSave" class="fs-btn fs-btn--primary" onclick="this.disabled=true;this.innerText='Saving...';document.getElementById('<%= btnSaveScheme.ClientID %>').click();">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                Save Scheme
            </button>
        </div>
    </div>
</div>

<!-- Edit Scheme Modal -->
<div id="modal-edit-scheme" class="fs-modal-overlay" onclick="if(event.target===this)closeModal('modal-edit-scheme')">
    <div class="fs-modal">
        <div class="fs-modal__header">
            <div class="fs-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                Edit Bursary Scheme
            </div>
            <button type="button" class="fs-modal__close" onclick="closeModal('modal-edit-scheme')">&times;</button>
        </div>
        <div class="fs-modal__body">
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Scheme Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtEditName" runat="server" CssClass="fs-form-input" MaxLength="45" />
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Details / Description <span class="req">*</span></label>
                    <asp:TextBox ID="txtEditDetails" runat="server" CssClass="fs-form-input" MaxLength="45" />
                </div>
            </div>
            <div class="fs-form-row">
                <div class="fs-form-group">
                    <label class="fs-form-label">Bursary Amount (UGX) <span class="req">*</span></label>
                    <asp:TextBox ID="txtEditAmt" runat="server" CssClass="fs-form-input" placeholder="e.g. 500000" />
                </div>
                <div class="fs-form-group">
                    <label class="fs-form-label">Status</label>
                    <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="fs-form-input">
                        <asp:ListItem Value="Active" Text="Active" />
                        <asp:ListItem Value="Inactive" Text="Inactive" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>
        <div class="fs-modal__footer">
            <button type="button" class="fs-btn fs-btn--ghost" onclick="closeModal('modal-edit-scheme')">Cancel</button>
            <button type="button" id="btnModalEdit" class="fs-btn fs-btn--primary" onclick="this.disabled=true;this.innerText='Updating...';document.getElementById('<%= btnEditScheme.ClientID %>').click();">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                Update Scheme
            </button>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="modal-delete-scheme" class="fs-modal-overlay" onclick="if(event.target===this)closeModal('modal-delete-scheme')">
    <div class="fs-modal" style="width:400px;">
        <div class="fs-modal__header" style="background:#c62828;">
            <div class="fs-modal__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                Confirm Delete
            </div>
            <button type="button" class="fs-modal__close" onclick="closeModal('modal-delete-scheme')">&times;</button>
        </div>
        <div class="fs-modal__body" style="text-align:center;padding:20px;">
            <p style="font-size:13px;color:#333;margin:0 0 6px;">Are you sure you want to delete this bursary scheme?</p>
            <p id="deleteSchemeInfo" style="font-size:12px;color:#c62828;font-weight:700;margin:0;"></p>
            <p style="font-size:11px;color:#888;margin:8px 0 0;">This action cannot be undone. Beneficiaries linked to this scheme will be affected.</p>
        </div>
        <div class="fs-modal__footer">
            <button type="button" class="fs-btn fs-btn--ghost" onclick="closeModal('modal-delete-scheme')">Cancel</button>
            <button type="button" class="fs-btn" style="background:#c62828;color:#fff;" onclick="this.disabled=true;this.innerText='Deleting...';document.getElementById('<%= btnDeleteScheme.ClientID %>').click();">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                Delete Scheme
            </button>
        </div>
    </div>
</div>

<script type="text/javascript">
    // ---- Modal ----
    function openModal(id) { document.getElementById(id).classList.add('fs-modal-overlay--visible'); }
    function closeModal(id) { document.getElementById(id).classList.remove('fs-modal-overlay--visible'); }

    /* ==== Row Action Popover ==== */
    var _activeRow = null;

    function showRowAction(evt, btn) {
        evt.stopPropagation();
        evt.preventDefault();
        var pop = document.getElementById('actionPop');

        _activeRow = {
            id: btn.getAttribute('data-id'),
            name: btn.getAttribute('data-name'),
            details: btn.getAttribute('data-details'),
            amount: btn.getAttribute('data-amount'),
            status: btn.getAttribute('data-status')
        };

        var rect = btn.getBoundingClientRect();
        var popH = 120;
        var spaceBelow = window.innerHeight - rect.bottom;

        pop.style.left = Math.max(4, rect.left - 140) + 'px';
        if (spaceBelow < popH + 10) {
            pop.style.top = (rect.top - popH - 4) + 'px';
        } else {
            pop.style.top = (rect.bottom + 4) + 'px';
        }
        pop.classList.add('bs-action-pop--visible');
    }

    function hideRowAction() {
        var pop = document.getElementById('actionPop');
        if (pop) pop.classList.remove('bs-action-pop--visible');
    }

    // Close popover on outside click
    document.addEventListener('click', function(e) {
        var pop = document.getElementById('actionPop');
        if (pop && pop.classList.contains('bs-action-pop--visible')) {
            if (!pop.contains(e.target) && !e.target.classList.contains('bs-row-action')) {
                hideRowAction();
            }
        }
    });
    // Close popover on scroll
    window.addEventListener('scroll', hideRowAction, true);

    /* ==== Edit Scheme ==== */
    function openEditScheme() {
        hideRowAction();
        if (!_activeRow) return;
        var d = _activeRow;
        document.getElementById('<%= hfEditID.ClientID %>').value = d.id;
        document.getElementById('<%= txtEditName.ClientID %>').value = d.name;
        document.getElementById('<%= txtEditDetails.ClientID %>').value = d.details;
        document.getElementById('<%= txtEditAmt.ClientID %>').value = d.amount;
        var ddl = document.getElementById('<%= ddlEditStatus.ClientID %>');
        for (var i = 0; i < ddl.options.length; i++) { if (ddl.options[i].value === d.status) ddl.selectedIndex = i; }
        openModal('modal-edit-scheme');
    }

    /* ==== View Beneficiaries ==== */
    function goToBeneficiaries() {
        hideRowAction();
        if (!_activeRow) return;
        window.location.href = 'BursaryBeneficiaries.aspx?scheme=' + _activeRow.id;
    }

    /* ==== Delete Scheme ==== */
    function confirmDeleteScheme() {
        hideRowAction();
        if (!_activeRow) return;
        var d = _activeRow;
        document.getElementById('<%= hfDeleteID.ClientID %>').value = d.id;
        document.getElementById('deleteSchemeInfo').textContent = d.name + ' \u2014 ' + d.details;
        openModal('modal-delete-scheme');
    }

    // Enter key search
    (function () {
        var box = document.getElementById('<%= txtSearch.ClientID %>');
        if (box) box.addEventListener('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); document.getElementById('<%= btnSearch.ClientID %>').click(); } });
    })();
</script>

</asp:Content>
