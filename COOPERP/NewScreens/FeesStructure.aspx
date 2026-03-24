<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FeesStructure.aspx.cs" Inherits="COOPERP_NewScreens_FeesStructure" Title="Fee Structure & Settings - Campus Dynamics" %>
<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== FEE STRUCTURE & SETTINGS ======================================== */

.fm-page-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 14px 0 12px; margin-bottom: 16px;
    border-bottom: 2px solid #174DA4;
    flex-wrap: wrap; gap: 10px;
}
.fm-page-header__left { display: flex; align-items: center; gap: 12px; min-width: 0; }
.fm-page-header__icon {
    width: 42px; height: 42px;
    background: linear-gradient(135deg, #00695c 0%, #00897b 100%);
    display: flex; align-items: center; justify-content: center;
    border-radius: 10px; flex-shrink: 0;
    box-shadow: 0 2px 8px rgba(0,105,92,.2);
}
.fm-page-header__title { font-size: 18px; font-weight: 800; color: #1a1a2e; }
.fm-page-header__sub   { font-size: 11px; color: #999; margin-top: 2px; }

/* Tab Nav */
.fm-tabs { display: flex; gap: 0; border-bottom: 2px solid #e4e8f0; margin-bottom: 16px; overflow-x: auto; }
.fm-tab { padding: 10px 20px; font-size: 12px; font-weight: 600; color: #777; cursor: pointer; border: none; background: none; border-bottom: 2px solid transparent; margin-bottom: -2px; white-space: nowrap; display: flex; align-items: center; gap: 6px; transition: all .15s; text-decoration: none; }
.fm-tab:hover { color: #174DA4; background: rgba(23,77,164,.03); }
.fm-tab--active { color: #174DA4; border-bottom-color: #174DA4; font-weight: 700; }

/* Section Tabs */
.fs-section-tabs { display: flex; gap: 6px; margin-bottom: 14px; flex-wrap: wrap; }
.fs-section-tab {
    padding: 7px 16px; font-size: 11px; font-weight: 600;
    border: 1px solid #dde1e6; border-radius: 8px;
    background: #fff; color: #555; cursor: pointer;
    display: flex; align-items: center; gap: 5px;
    transition: all .15s;
}
.fs-section-tab:hover { border-color: #174DA4; color: #174DA4; }
.fs-section-tab--active { background: #174DA4; color: #fff; border-color: #174DA4; }

/* Panels */
.fs-panel { display: none; }
.fs-panel--active { display: block; }

/* Card */
.fs-card { background: #fff; border: 1px solid #e4e8f0; border-radius: 10px; overflow: hidden; margin-bottom: 14px; box-shadow: 0 1px 4px rgba(0,0,0,.03); }
.fs-card__header { padding: 12px 16px; border-bottom: 1px solid #e4e8f0; background: #fafbfc; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px; }
.fs-card__title { font-size: 13px; font-weight: 700; color: #1a1a2e; display: flex; align-items: center; gap: 6px; }
.fs-card__meta { font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.06); padding: 3px 10px; border-radius: 10px; }
.fs-card__body { padding: 14px 16px; }

/* Table */
.fs-table { width: 100%; border-collapse: collapse; }
.fs-table th { font-size: 10px; text-transform: uppercase; letter-spacing: .4px; color: #888; font-weight: 600; padding: 10px 14px; text-align: left; border-bottom: 2px solid #e8ecf2; background: #f8f9fb; }
.fs-table td { font-size: 11px; padding: 9px 14px; color: #333; border-bottom: 1px solid #f2f3f5; vertical-align: middle; }
.fs-table tbody tr:hover td { background: #f5f8ff; }
.fs-code { font-family: 'Courier New', monospace; font-size: 10px; color: #174DA4; font-weight: 600; background: rgba(23,77,164,.06); padding: 2px 6px; border-radius: 3px; }
.fs-badge { display: inline-block; padding: 2px 8px; font-size: 9px; font-weight: 700; text-transform: uppercase; border-radius: 4px; }
.fs-badge--primary { background: #e8f0fc; color: #174DA4; }
.fs-badge--green { background: #e6f4ea; color: #155724; }
.fs-badge--amber { background: #fff8e1; color: #e67e00; }
.fs-amount { font-variant-numeric: tabular-nums; font-weight: 600; }

/* Filters */
.fs-filter-bar { display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap; margin-bottom: 10px; }
.fs-filter-grp { display: flex; flex-direction: column; gap: 3px; }
.fs-filter-grp__label { font-size: 9px; text-transform: uppercase; letter-spacing: .5px; color: #999; font-weight: 600; }
.fs-filter-select { border: 1px solid #dde1e6; border-radius: 8px; padding: 6px 10px; font-size: 11px; background: #fff; color: #333; cursor: pointer; min-width: 130px; }
.fs-filter-select:focus { border-color: #174DA4; box-shadow: 0 0 0 3px rgba(23,77,164,.08); outline: none; }

/* Buttons */
.fs-btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: none; cursor: pointer; border-radius: 8px; display: inline-flex; align-items: center; gap: 5px; white-space: nowrap; transition: all .15s; }
.fs-btn--primary { background: #174DA4; color: #fff; } .fs-btn--primary:hover { background: #0f3a7d; }
.fs-btn--ghost { background: transparent; border: 1px solid #dde1e6; color: #555; } .fs-btn--ghost:hover { border-color: #174DA4; color: #174DA4; }
.fs-btn--sm { padding: 5px 11px; font-size: 10px; }

/* Responsive */
@media (max-width: 900px) { .fs-section-tabs { gap: 4px; } .fs-section-tab { padding: 6px 12px; font-size: 10px; } }
@media (max-width: 700px) { .fm-tabs .fm-tab { padding: 8px 12px; font-size: 11px; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- Page Header -->
<div class="fm-page-header">
    <div class="fm-page-header__left">
        <div class="fm-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
        </div>
        <div>
            <div class="fm-page-header__title">Fee Structure &amp; Settings</div>
            <div class="fm-page-header__sub">Billing items, fee structures, payment schedules &amp; billing systems</div>
        </div>
    </div>
</div>

<!-- Tab Navigation -->
<div class="fm-tabs">
    <a class="fm-tab" href="FeesManagement.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
        Dashboard
    </a>
    <a class="fm-tab" href="FeesTransactions.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
        Transactions
    </a>
    <a class="fm-tab fm-tab--active" href="FeesStructure.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
        Fee Structure &amp; Settings
    </a>
    <a class="fm-tab" href="FeesRegistration.aspx">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        Registration
    </a>
</div>

<!-- Section Tabs -->
<div class="fs-section-tabs">
    <button type="button" class="fs-section-tab fs-section-tab--active" onclick="showPanel('billing-items',this)">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
        Billing Items
    </button>
    <button type="button" class="fs-section-tab" onclick="showPanel('fee-structure',this)">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
        Fee Structures
    </button>
    <button type="button" class="fs-section-tab" onclick="showPanel('pay-schedule',this)">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
        Payment Schedule
    </button>
    <button type="button" class="fs-section-tab" onclick="showPanel('billing-systems',this)">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>
        Billing Systems
    </button>
</div>

<!-- ═══════ PANEL: Billing Items ═══════════════════════════════════ -->
<div id="panel-billing-items" class="fs-panel fs-panel--active">
    <div class="fs-card">
        <div class="fs-card__header">
            <div class="fs-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
                Academic Billing Items
            </div>
            <div class="fs-card__meta"><asp:Literal ID="litBillingItemCount" runat="server" Text="0 items" /></div>
        </div>
        <div style="overflow-x:auto;">
            <table class="fs-table">
                <thead><tr><th>Code</th><th>Item Name</th><th>GL Account</th><th>Priority</th></tr></thead>
                <tbody><asp:Literal ID="litBillingItems" runat="server" /></tbody>
            </table>
        </div>
    </div>
</div>

<!-- ═══════ PANEL: Fee Structures ═══════════════════════════════════ -->
<div id="panel-fee-structure" class="fs-panel">
    <div class="fs-filter-bar">
        <div class="fs-filter-grp">
            <label class="fs-filter-grp__label">Programme</label>
            <asp:DropDownList ID="ddlFSProg" runat="server" CssClass="fs-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFSProg_SelectedIndexChanged" style="min-width:200px;" />
        </div>
        <div class="fs-filter-grp">
            <label class="fs-filter-grp__label">Academic Year</label>
            <asp:DropDownList ID="ddlFSYear" runat="server" CssClass="fs-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFSYear_SelectedIndexChanged" />
        </div>
    </div>
    <div class="fs-card">
        <div class="fs-card__header">
            <div class="fs-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                Programme Fee Structure
            </div>
            <div class="fs-card__meta"><asp:Literal ID="litStructureCount" runat="server" Text="0 entries" /></div>
        </div>
        <div style="overflow-x:auto;">
            <table class="fs-table">
                <thead><tr><th>Billing Item</th><th>Programme</th><th>Session</th><th>Study Year</th><th>Semester</th><th>Billing System</th><th style="text-align:right">Amount</th></tr></thead>
                <tbody><asp:Literal ID="litStructureRows" runat="server" /></tbody>
            </table>
        </div>
    </div>
</div>

<!-- ═══════ PANEL: Payment Schedule ════════════════════════════════ -->
<div id="panel-pay-schedule" class="fs-panel">
    <div class="fs-filter-bar">
        <div class="fs-filter-grp">
            <label class="fs-filter-grp__label">Programme</label>
            <asp:DropDownList ID="ddlPSProg" runat="server" CssClass="fs-filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPSProg_SelectedIndexChanged" style="min-width:200px;" />
        </div>
    </div>
    <div class="fs-card">
        <div class="fs-card__header">
            <div class="fs-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                Payment Schedule
            </div>
            <div class="fs-card__meta"><asp:Literal ID="litScheduleCount" runat="server" Text="0 entries" /></div>
        </div>
        <div style="overflow-x:auto;">
            <table class="fs-table">
                <thead><tr><th>Billing Item</th><th>Programme</th><th>Session</th><th>Study Year</th><th>Semester</th><th>Billing System</th><th style="text-align:right">Amount</th></tr></thead>
                <tbody><asp:Literal ID="litScheduleRows" runat="server" /></tbody>
            </table>
        </div>
    </div>
</div>

<!-- ═══════ PANEL: Billing Systems ═════════════════════════════════ -->
<div id="panel-billing-systems" class="fs-panel">
    <div class="fs-card">
        <div class="fs-card__header">
            <div class="fs-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>
                Billing Systems
            </div>
            <div class="fs-card__meta"><asp:Literal ID="litSystemCount" runat="server" Text="0 systems" /></div>
        </div>
        <div style="overflow-x:auto;">
            <table class="fs-table">
                <thead><tr><th>ID</th><th>System Name</th><th>Description</th><th>Currency</th></tr></thead>
                <tbody><asp:Literal ID="litSystemRows" runat="server" /></tbody>
            </table>
        </div>
    </div>
</div>

<script type="text/javascript">
function showPanel(id, btn) {
    var panels = document.querySelectorAll('.fs-panel');
    var tabs = document.querySelectorAll('.fs-section-tab');
    for (var i = 0; i < panels.length; i++) panels[i].className = 'fs-panel';
    for (var j = 0; j < tabs.length; j++) tabs[j].className = 'fs-section-tab';
    document.getElementById('panel-' + id).className = 'fs-panel fs-panel--active';
    btn.className = 'fs-section-tab fs-section-tab--active';
}
</script>

</asp:Content>
