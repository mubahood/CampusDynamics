<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FeesTransactions.aspx.cs" Inherits="COOPERP_NewScreens_FeesTransactions" Title="Fee Transactions - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== FEE TRANSACTIONS ================================================ */

.fm-page-header { display: flex; align-items: center; justify-content: space-between; padding: 14px 0 12px; margin-bottom: 16px; border-bottom: 2px solid #174DA4; flex-wrap: wrap; gap: 10px; }
.fm-page-header__left { display: flex; align-items: center; gap: 12px; min-width: 0; }
.fm-page-header__icon { width: 42px; height: 42px; background: linear-gradient(135deg, #00695c 0%, #00897b 100%); display: flex; align-items: center; justify-content: center; border-radius: 10px; flex-shrink: 0; box-shadow: 0 2px 8px rgba(0,105,92,.2); }
.fm-page-header__title { font-size: 18px; font-weight: 800; color: #1a1a2e; }
.fm-page-header__sub   { font-size: 11px; color: #999; margin-top: 2px; }

/* Tabs */
.fm-tabs { display: flex; gap: 0; border-bottom: 2px solid #e4e8f0; margin-bottom: 16px; overflow-x: auto; }
.fm-tab { padding: 10px 20px; font-size: 12px; font-weight: 600; color: #777; cursor: pointer; border: none; background: none; border-bottom: 2px solid transparent; margin-bottom: -2px; white-space: nowrap; display: flex; align-items: center; gap: 6px; transition: all .15s; text-decoration: none; }
.fm-tab:hover { color: #174DA4; background: rgba(23,77,164,.03); }
.fm-tab--active { color: #174DA4; border-bottom-color: #174DA4; font-weight: 700; }

/* Stats Row */
.ft-stats { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; margin-bottom: 14px; }
.ft-stat { background: #fff; border: 1px solid #e4e8f0; border-radius: 8px; padding: 12px 14px; display: flex; align-items: center; gap: 10px; position: relative; overflow: hidden; }
.ft-stat::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--stat-c, #ccc); }
.ft-stat__icon { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border-radius: 8px; }
.ft-stat__val { font-size: 18px; font-weight: 800; line-height: 1.1; font-variant-numeric: tabular-nums; }
.ft-stat__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #888; margin-top: 2px; }
.ft-stat--bills   { --stat-c: #00897b; } .ft-stat--bills   .ft-stat__icon { background: #e0f2f1; } .ft-stat--bills .ft-stat__val { color: #00695c; }
.ft-stat--pays    { --stat-c: #2e7d32; } .ft-stat--pays    .ft-stat__icon { background: #e6f4ea; } .ft-stat--pays .ft-stat__val { color: #2e7d32; }
.ft-stat--total   { --stat-c: #174DA4; } .ft-stat--total   .ft-stat__icon { background: #e8f0fc; } .ft-stat--total .ft-stat__val { color: #174DA4; }
.ft-stat--bamt    { --stat-c: #e65100; } .ft-stat--bamt    .ft-stat__icon { background: #fff3e0; } .ft-stat--bamt .ft-stat__val { color: #e65100; }
.ft-stat--pamt    { --stat-c: #2e7d32; } .ft-stat--pamt    .ft-stat__icon { background: #e6f4ea; } .ft-stat--pamt .ft-stat__val { color: #2e7d32; }

/* Filters Card */
.ft-card { background: #fff; border: 1px solid #e4e8f0; border-radius: 10px; overflow: hidden; margin-bottom: 14px; box-shadow: 0 1px 4px rgba(0,0,0,.03); }
.ft-card__header { padding: 10px 16px; border-bottom: 1px solid #e4e8f0; background: #fafbfc; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 6px; }
.ft-card__title { font-size: 13px; font-weight: 700; color: #1a1a2e; display: flex; align-items: center; gap: 6px; }
.ft-card__meta { font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.06); padding: 3px 10px; border-radius: 10px; }

.ft-filters { background: #f8f9fb; border-bottom: 1px solid #e4e8f0; padding: 10px 14px; }
.ft-filters__top { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; flex-wrap: wrap; }
.ft-search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 380px; }
.ft-search-wrap svg { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #999; pointer-events: none; }
.ft-search-box { width: 100%; padding: 7px 12px 7px 32px; border: 1px solid #dde1e6; border-radius: 8px; font-size: 12px; background: #fff; box-sizing: border-box; }
.ft-search-box:focus { border-color: #174DA4; box-shadow: 0 0 0 3px rgba(23,77,164,.08); outline: none; }
.ft-filters__row { display: flex; gap: 8px; flex-wrap: wrap; align-items: flex-end; }
.ft-filter-grp { display: flex; flex-direction: column; gap: 3px; }
.ft-filter-grp__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #999; font-weight: 600; }
.ft-filter-select { border: 1px solid #dde1e6; border-radius: 8px; padding: 6px 10px; font-size: 11px; background: #fff; color: #333; cursor: pointer; min-width: 110px; }
.ft-filter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 3px rgba(23,77,164,.08); outline: none; }

/* Buttons */
.ft-btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; border-radius: 8px; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.ft-btn--primary { background: #174DA4; color: #fff; } .ft-btn--primary:hover { background: #0f3a7d; }
.ft-btn--ghost { background: transparent; border: 1px solid #dde1e6; color: #555; } .ft-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.ft-btn--sm { padding: 5px 11px; font-size: 10px; }

/* Grid Footer */
.ft-grid-footer { display: flex; justify-content: space-between; align-items: center; padding: 8px 14px; background: #fafbfc; border-top: 1px solid #e4e8f0; font-size: 11px; color: #666; flex-wrap: wrap; gap: 6px; }
.ft-grid-footer strong { color: #174DA4; }

/* Badges */
.ft-badge { display: inline-block; padding: 3px 9px; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; border-radius: 4px; }
.ft-badge--bill { background: #fff3cd; color: #856404; }
.ft-badge--pay  { background: #d4edda; color: #155724; }
.ft-badge--posted { background: #e8f0fc; color: #174DA4; }
.ft-badge--pending { background: #f8d7da; color: #721c24; }

/* DevExpress Grid overrides */
.dxgvControl_Glass { border: none !important; }
.dxgvHeader_Glass td { font-size: 10px !important; text-transform: uppercase !important; letter-spacing: .4px !important; background: #f5f7fa !important; color: #666 !important; border-bottom: 2px solid #e4e8f0 !important; padding: 9px 10px !important; font-weight: 600 !important; }
.dxgvDataRow_Glass td, .dxgvDataRowAlt_Glass td { font-size: 11px !important; padding: 8px 10px !important; border-bottom: 1px solid #f2f3f5 !important; vertical-align: middle !important; }
.dxgvDataRow_Glass:hover td, .dxgvDataRowAlt_Glass:hover td { background: #f0f4ff !important; }
.dxgvPagerBar_Glass { background: #fafbfc !important; border-top: 1px solid #e4e8f0 !important; font-size: 11px !important; }

/* Responsive */
@media (max-width: 1200px) { .ft-stats { grid-template-columns: repeat(3, 1fr); } }
@media (max-width: 800px) { .ft-stats { grid-template-columns: 1fr 1fr; } }
@media (max-width: 500px) { .ft-stats { grid-template-columns: 1fr; } .fm-tabs .fm-tab { padding: 8px 12px; font-size: 11px; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<asp:Button ID="btnExportCsv" runat="server" style="display:none;" OnClick="btnExportCsv_Click" />
<asp:Button ID="btnSearch" runat="server" style="display:none;" OnClick="btnSearch_Click" />
<asp:Button ID="btnReset" runat="server" style="display:none;" OnClick="btnReset_Click" />

<!-- Page Header -->
<div class="fm-page-header">
    <div class="fm-page-header__left">
        <div class="fm-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
        </div>
        <div>
            <div class="fm-page-header__title">Fee Transactions</div>
            <div class="fm-page-header__sub">Student billings, payments, receipts &amp; transaction tracking</div>
        </div>
    </div>
    <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center;">
        <asp:Literal ID="litAcadContext" runat="server" />
        <button type="button" class="ft-btn ft-btn--ghost ft-btn--sm" onclick="document.getElementById('<%= btnExportCsv.ClientID %>').click()">
            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
            Export CSV
        </button>
    </div>
</div>

<!-- Tab Nav -->
<div class="fm-tabs">
    <a class="fm-tab" href="FeesManagement.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
        Dashboard
    </a>
    <a class="fm-tab fm-tab--active" href="FeesTransactions.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
        Transactions
    </a>
    <a class="fm-tab" href="FeesStructure.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
        Fee Structure &amp; Settings
    </a>
    <a class="fm-tab" href="FeesRegistration.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        Registration
    </a>
</div>

<!-- Stats -->
<div class="ft-stats">
    <div class="ft-stat ft-stat--total">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litTotalTx" runat="server" Text="0" /></div><div class="ft-stat__label">Total Transactions</div></div>
    </div>
    <div class="ft-stat ft-stat--bills">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00695c" stroke-width="2"><path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1-2-1z"></path></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litBillTx" runat="server" Text="0" /></div><div class="ft-stat__label">Bills</div></div>
    </div>
    <div class="ft-stat ft-stat--pays">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litPayTx" runat="server" Text="0" /></div><div class="ft-stat__label">Payments</div></div>
    </div>
    <div class="ft-stat ft-stat--bamt">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e65100" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litBillAmt" runat="server" Text="0" /></div><div class="ft-stat__label">Total Billed</div></div>
    </div>
    <div class="ft-stat ft-stat--pamt">
        <div class="ft-stat__icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg></div>
        <div><div class="ft-stat__val"><asp:Literal ID="litPayAmt" runat="server" Text="0" /></div><div class="ft-stat__label">Total Paid</div></div>
    </div>
</div>

<!-- Main Grid Card -->
<div class="ft-card">
    <!-- Filters -->
    <div class="ft-filters">
        <div class="ft-filters__top">
            <div class="ft-search-wrap">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="ft-search-box" placeholder="Search by reg no, student name, description..." AutoPostBack="false" />
            </div>
            <button type="button" class="ft-btn ft-btn--primary ft-btn--sm" onclick="document.getElementById('<%= btnSearch.ClientID %>').click()">Search</button>
            <asp:Label ID="lblRecordCount" runat="server" CssClass="ft-card__meta" Text="0 records" />
        </div>
        <div class="ft-filters__row">
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Academic Year</label>
                <asp:DropDownList ID="ddlAcadYear" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAcadYear_SelectedIndexChanged" />
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Semester</label>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All Semesters" />
                    <asp:ListItem Value="1" Text="Semester 1" />
                    <asp:ListItem Value="2" Text="Semester 2" />
                    <asp:ListItem Value="3" Text="Semester 3" />
                </asp:DropDownList>
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Type</label>
                <asp:DropDownList ID="ddlTransType" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTransType_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All Types" />
                    <asp:ListItem Value="Bill" Text="Bills" />
                    <asp:ListItem Value="Payment" Text="Payments" />
                </asp:DropDownList>
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Billing Item</label>
                <asp:DropDownList ID="ddlBillItem" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlBillItem_SelectedIndexChanged" style="min-width:160px;" />
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Status</label>
                <asp:DropDownList ID="ddlPostStatus" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPostStatus_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="All" />
                    <asp:ListItem Value="Posted" Text="Posted" />
                    <asp:ListItem Value="Pending" Text="Pending" />
                </asp:DropDownList>
            </div>
            <div class="ft-filter-grp">
                <label class="ft-filter-grp__label">Per Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="ft-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed" style="min-width:80px;">
                    <asp:ListItem Value="50" Text="50" Selected="True" />
                    <asp:ListItem Value="100" Text="100" />
                    <asp:ListItem Value="200" Text="200" />
                    <asp:ListItem Value="500" Text="500" />
                </asp:DropDownList>
            </div>
            <button type="button" class="ft-btn ft-btn--ghost ft-btn--sm" style="align-self:flex-end;" onclick="document.getElementById('<%= btnReset.ClientID %>').click()">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"></polyline><path d="M3.51 15a9 9 0 1 0 .49-3.5"></path></svg>
                Reset
            </button>
        </div>
    </div>

    <!-- Grid -->
    <dx:ASPxGridView ID="gvTransactions" runat="server" ClientInstanceName="gvTransactions"
        Width="100%" KeyFieldName="TID"
        AutoGenerateColumns="False"
        Theme="Glass"
        Settings-VerticalScrollBarMode="Visible"
        Settings-VerticalScrollableHeight="520"
        SettingsPager-Mode="ShowPager"
        SettingsPager-PageSize="50">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="TID" Caption="ID" Width="60px" />
            <dx:GridViewDataTextColumn FieldName="regno" Caption="Reg No" Width="130px" />
            <dx:GridViewDataTextColumn FieldName="student_name" Caption="Student" Width="180px" />
            <dx:GridViewDataTextColumn FieldName="trans_type" Caption="Type" Width="80px">
                <DataItemTemplate>
                    <span class='ft-badge <%# GetTypeClass(Eval("trans_type")) %>'><%# Eval("trans_type") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="item_name" Caption="Billing Item" Width="140px" />
            <dx:GridViewDataTextColumn FieldName="amount" Caption="Amount" Width="110px">
                <DataItemTemplate>
                    <span style="font-weight:700;font-variant-numeric:tabular-nums;"><%# FormatAmt(Eval("amount")) %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="detail" Caption="Description" Width="180px" />
            <dx:GridViewDataTextColumn FieldName="post_status" Caption="Status" Width="80px">
                <DataItemTemplate>
                    <span class='ft-badge <%# GetStatusClass(Eval("post_status")) %>'><%# Eval("post_status") %></span>
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="trans_date" Caption="Date" Width="100px" />
            <dx:GridViewDataTextColumn FieldName="acadyear" Caption="Year" Width="90px" />
            <dx:GridViewDataTextColumn FieldName="semester" Caption="Sem" Width="50px" />
        </Columns>
        <SettingsBehavior AllowSort="true" AllowDragDrop="false" />
    </dx:ASPxGridView>

    <!-- Footer -->
    <div class="ft-grid-footer">
        <asp:Label ID="lblGridFooter" runat="server" Text="Showing 0 transactions" />
    </div>
</div>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function() {
    var tb = document.getElementById('<%= txtSearch.ClientID %>');
    if (tb) {
        tb.addEventListener('keydown', function(e) {
            if (e.keyCode === 13) {
                e.preventDefault();
                document.getElementById('<%= btnSearch.ClientID %>').click();
            }
        });
    }
});
</script>

</asp:Content>
