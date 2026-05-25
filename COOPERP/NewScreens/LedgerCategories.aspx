<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="LedgerCategories.aspx.cs" Inherits="COOPERP_NewScreens_LedgerCategories" Title="Ledger Categories - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box;}
.pm-admin-wrap{max-width:1320px;margin:0 auto;padding:8px 10px 12px;}
.pm-stats{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));gap:8px;margin-bottom:8px;}
.pm-stat{padding:8px 10px;border-radius:6px;border:1px solid #e3e9f2;background:#fff;min-height:60px;display:flex;flex-direction:column;justify-content:center;gap:3px;}
.pm-stat__lbl{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;line-height:1.25;}
.pm-stat__val{font-size:22px;line-height:1;font-weight:800;color:#05275C;letter-spacing:-.02em;}
.pm-stat--total .pm-stat__val{color:#05275C;}
.pm-stat--asset .pm-stat__val{color:#174DA4;}
.pm-stat--liability .pm-stat__val{color:#b45309;}
.pm-stat--income .pm-stat__val{color:#2e7d32;}
.pm-stat--expense .pm-stat__val{color:#b42318;}
.pm-stat--equity .pm-stat__val{color:#7b1fa2;}
.pm-card{background:#fff;border:1px solid #e3e9f2;border-radius:8px;overflow:visible;margin-bottom:10px;}
.pm-card__head{padding:8px 10px;border-bottom:1px solid #edf1f6;background:#fff;display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;}
.pm-card__title{font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.pm-muted{color:#6b7280;font-size:10px;}
.pm-chip{display:inline-flex;align-items:center;padding:3px 8px;border-radius:999px;background:#f1f5ff;border:1px solid #d8e2f6;color:#174DA4;font-size:9px;font-weight:800;letter-spacing:.35px;text-transform:uppercase;}
.pm-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;padding:5px 9px;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;border-radius:6px;min-height:30px;text-decoration:none;}
.pm-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff;}
.pm-btn--primary{background:#05275C;color:#fff;border-color:#05275C;}
.pm-btn--primary:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.pm-toolbar{padding:8px 10px;border-bottom:1px solid #eef2f6;background:#f8fafc;display:flex;justify-content:space-between;gap:8px;align-items:center;flex-wrap:wrap;}
.pm-table-wrap{overflow:auto;scrollbar-color:#b6c5db #f5f8fc;scrollbar-width:thin;background:#fff;}
.pm-table{width:100%;min-width:420px;border-collapse:collapse;table-layout:fixed;}
.pm-table th{position:sticky;top:0;background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;padding:6px 8px;text-align:left;white-space:nowrap;z-index:1;}
.pm-table td{border-bottom:1px solid #eef2f6;font-size:11px;color:#1f2937;padding:6px 8px;vertical-align:middle;background:#fff;}
.pm-table tbody tr:hover td{background:#fafcff;}
.pm-code{font-family:Consolas,monospace;font-size:11px;color:#174DA4;font-weight:700;}
.pm-pill{display:inline-block;padding:2px 7px;font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;border-radius:3px;}
.pm-pill--asset{background:#e8f0fc;color:#174DA4;}
.pm-pill--liability{background:#fff3cd;color:#92400e;}
.pm-pill--income{background:#e6f4ea;color:#2e7d32;}
.pm-pill--expense{background:#fde8e8;color:#b42318;}
.pm-pill--equity{background:#f3e8fd;color:#7b1fa2;}
.pm-pill--neutral{background:#f8fafc;color:#475569;border:1px solid #e2e8f0;}
.pm-empty{padding:20px;text-align:center;color:#6b7280;font-size:11px;}
.pm-row-wrap{position:relative;display:inline-flex;align-items:center;justify-content:center;}
.pm-row-trigger{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border:1px solid #d6deea;background:#fff;color:#475569;cursor:pointer;border-radius:5px;font-size:14px;line-height:1;padding:0;}
.pm-row-menu{display:none;position:absolute;right:0;top:calc(100% + 4px);min-width:170px;padding:6px;background:#fff;border:1px solid #dbe4ef;border-radius:8px;box-shadow:0 14px 34px rgba(15,23,42,.16);z-index:500;}
.pm-row-menu.open{display:block;}
.pm-row-menu__item{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border:0;background:transparent;color:#334155;font-size:11px;font-weight:700;text-align:left;border-radius:6px;cursor:pointer;white-space:nowrap;text-decoration:none;}
.pm-row-menu__item:hover{background:#f8fafc;color:#0f172a;}
.pm-row-menu__item--danger{color:#b42318;}
.pm-row-menu__item--danger:hover{background:#fef2f2;color:#991b1b;}
.pm-alert{padding:8px 10px;border:1px solid transparent;border-radius:6px;font-size:11px;font-weight:700;margin-bottom:8px;}
.pm-alert--ok{background:#f0fdf4;border-color:#bbf7d0;color:#15803d;}
.pm-alert--err{background:#fef2f2;border-color:#fecaca;color:#b91c1c;}
#lcOverlay.pm-overlay{display:none;position:fixed;inset:0;background:rgba(5,15,35,.5);backdrop-filter:blur(2px);z-index:9000;}
#lcOverlay.pm-overlay.show{display:block;}
#lcModal.pm-modal{display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background:#fff;border:1px solid #dde3ed;border-radius:10px;width:92%;max-width:480px;box-shadow:0 20px 60px rgba(5,15,35,.2);z-index:9001;max-height:90vh;overflow-y:auto;}
#lcModal.pm-modal.show{display:block;}
.pm-modal__head{padding:14px 16px;border-bottom:1px solid #e7ebf1;display:flex;justify-content:space-between;align-items:center;gap:8px;background:#f8fafc;}
.pm-modal__title{font-size:12px;font-weight:900;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.pm-modal__close{background:0;border:0;font-size:20px;color:#6b7280;cursor:pointer;line-height:1;padding:0;width:26px;height:26px;}
.pm-modal__body{padding:16px;display:flex;flex-direction:column;gap:12px;}
.pm-modal__foot{padding:10px 16px;border-top:1px solid #e7ebf1;background:#f8fafc;display:flex;justify-content:flex-end;gap:6px;}
.pm-fg{display:flex;flex-direction:column;gap:4px;}
.pm-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;}
.pm-input,.pm-select{height:32px;border:1px solid #cdd8e6;padding:4px 8px;font-size:11px;background:#fff;border-radius:6px;color:#1a1a2e;font-family:inherit;width:100%;}
.pm-input:focus,.pm-select:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12);}
.pm-card--table{overflow:visible;}
@media(max-width:768px){.pm-stats{grid-template-columns:repeat(3,minmax(0,1fr));}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="pm-admin-wrap">

    <%-- Hidden fields --%>
    <asp:HiddenField ID="hdnEditId" runat="server" Value="" />
    <asp:HiddenField ID="hdnModalOpen" runat="server" Value="" />

    <%-- Message --%>
    <asp:Panel ID="pnlMsg" runat="server" Visible="false">
        <div id="divMsg" runat="server" class="pm-alert pm-alert--ok">
            <asp:Literal ID="litMsg" runat="server" />
        </div>
    </asp:Panel>

    <%-- Modal overlay + modal --%>
    <div id="lcOverlay" class="pm-overlay" onclick="closeLcModal(); closeLcViewModal();"></div>
    <div id="lcModal" class="pm-modal">
        <div class="pm-modal__head">
            <div class="pm-modal__title" id="lcModalTitle">New Ledger Category</div>
            <button type="button" class="pm-modal__close" onclick="closeLcModal()">&times;</button>
        </div>
        <div class="pm-modal__body">
            <div class="pm-fg">
                <label>Category Name <span style="color:#b42318">*</span></label>
                <asp:TextBox ID="txtCategoryName" runat="server" CssClass="pm-input" placeholder="e.g. Current Assets" MaxLength="120" />
            </div>
            <div class="pm-fg">
                <label>General Category <span style="color:#b42318">*</span></label>
                <asp:DropDownList ID="ddlGeneralCategory" runat="server" CssClass="pm-select">
                    <asp:ListItem Value="Asset">Asset</asp:ListItem>
                    <asp:ListItem Value="Liability">Liability</asp:ListItem>
                    <asp:ListItem Value="Income">Income</asp:ListItem>
                    <asp:ListItem Value="Expense">Expense</asp:ListItem>
                    <asp:ListItem Value="Equity">Equity</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
        <div class="pm-modal__foot">
            <button type="button" class="pm-btn" onclick="closeLcModal()">Cancel</button>
            <asp:Button ID="btnSave" runat="server" Text="Save Category" CssClass="pm-btn pm-btn--primary" OnClick="btnSave_Click" />
        </div>
    </div>

    <div id="lcViewModal" class="pm-modal">
        <div class="pm-modal__head">
            <div class="pm-modal__title">Ledger Category Details</div>
            <button type="button" class="pm-modal__close" onclick="closeLcViewModal()">&times;</button>
        </div>
        <div class="pm-modal__body">
            <div class="pm-fg">
                <label>Category ID</label>
                <input type="text" id="viewCategoryId" class="pm-input" readonly="readonly" />
            </div>
            <div class="pm-fg">
                <label>Category Name</label>
                <input type="text" id="viewCategoryName" class="pm-input" readonly="readonly" />
            </div>
            <div class="pm-fg">
                <label>General Category</label>
                <input type="text" id="viewCategoryType" class="pm-input" readonly="readonly" />
            </div>
        </div>
        <div class="pm-modal__foot">
            <button type="button" class="pm-btn pm-btn--primary" onclick="closeLcViewModal()">Close</button>
        </div>
    </div>

    <%-- Stats --%>
    <div class="pm-stats">
        <div class="pm-stat pm-stat--total"><div class="pm-stat__lbl">Total</div><div class="pm-stat__val"><asp:Literal ID="litTotal" runat="server" Text="0" /></div></div>
        <div class="pm-stat pm-stat--asset"><div class="pm-stat__lbl">Asset</div><div class="pm-stat__val"><asp:Literal ID="litAsset" runat="server" Text="0" /></div></div>
        <div class="pm-stat pm-stat--liability"><div class="pm-stat__lbl">Liability</div><div class="pm-stat__val"><asp:Literal ID="litLiability" runat="server" Text="0" /></div></div>
        <div class="pm-stat pm-stat--income"><div class="pm-stat__lbl">Income</div><div class="pm-stat__val"><asp:Literal ID="litIncome" runat="server" Text="0" /></div></div>
        <div class="pm-stat pm-stat--expense"><div class="pm-stat__lbl">Expense</div><div class="pm-stat__val"><asp:Literal ID="litExpense" runat="server" Text="0" /></div></div>
        <div class="pm-stat pm-stat--equity"><div class="pm-stat__lbl">Equity</div><div class="pm-stat__val"><asp:Literal ID="litEquity" runat="server" Text="0" /></div></div>
    </div>

    <%-- Card --%>
    <div class="pm-card pm-card--table">
        <div class="pm-card__head">
            <div>
                <div class="pm-card__title">Ledger Categories</div>
                <div class="pm-muted">Classification types for sub-accounts (e.g. Current Assets, Operating Expenses)</div>
            </div>
            <asp:Literal ID="litBadge" runat="server" />
        </div>
        <div class="pm-toolbar">
            <span class="pm-muted">Group sub-accounts into Asset, Liability, Income, Expense or Equity classes.</span>
            <button type="button" class="pm-btn pm-btn--primary" onclick="openLcModal('add')">+ New Category</button>
        </div>
        <div class="pm-table-wrap">
            <table class="pm-table">
                <thead>
                    <tr>
                        <th style="width:60px">ID</th>
                        <th>Category Name</th>
                        <th style="width:150px">General Category</th>
                        <th style="width:80px;text-align:center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptCategories" runat="server" OnItemCommand="rptCategories_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td class="pm-code"><%# Eval("LedgerTypeID") %></td>
                                <td><strong><%# System.Web.HttpUtility.HtmlEncode(Eval("LedgerTypeName").ToString()) %></strong></td>
                                <td><span class='pm-pill <%# GetCategoryPillCss(Eval("LedgerTypeCategory")) %>'><%# System.Web.HttpUtility.HtmlEncode(Eval("LedgerTypeCategory").ToString()) %></span></td>
                                <td style="text-align:center">
                                    <div class="pm-row-wrap">
                                        <button type="button" class="pm-row-trigger" onclick="toggleRowMenu(this)">&#8943;</button>
                                        <div class="pm-row-menu">
                                            <button type="button"
                                                class="pm-row-menu__item"
                                                onclick='openLcViewModal("<%# Eval("LedgerTypeID") %>", "<%# System.Web.HttpUtility.JavaScriptStringEncode(Eval("LedgerTypeName").ToString()) %>", "<%# System.Web.HttpUtility.JavaScriptStringEncode(Eval("LedgerTypeCategory").ToString()) %>")'>
                                                &#128065;&nbsp; View Details
                                            </button>
                                            <asp:LinkButton runat="server" CommandName="Edit"
                                                CommandArgument='<%# Eval("LedgerTypeID") + "|" + Eval("LedgerTypeName") + "|" + Eval("LedgerTypeCategory") %>'
                                                CssClass="pm-row-menu__item">&#9998;&nbsp; Edit Category</asp:LinkButton>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
                        <tr><td colspan="4" class="pm-empty">No ledger categories found.</td></tr>
                    </asp:PlaceHolder>
                </tbody>
            </table>
        </div>
    </div>

</div>

<script type="text/javascript">
(function () {
    'use strict';
    function q(id) { return document.getElementById(id); }
    var overlay = q('lcOverlay');
    var modal   = q('lcModal');
    var viewModal = q('lcViewModal');
    var title   = q('lcModalTitle');
    var editId  = q('<%= hdnEditId.ClientID %>');
    var modalOpen = q('<%= hdnModalOpen.ClientID %>');

    function closeAllMenus() {
        document.querySelectorAll('.pm-row-menu.open').forEach(function (m) { m.classList.remove('open'); });
    }
    window.toggleRowMenu = function (btn) {
        var menu = btn.parentNode.querySelector('.pm-row-menu');
        var wasOpen = menu.classList.contains('open');
        closeAllMenus();
        if (!wasOpen) { menu.classList.add('open'); }
    };
    document.addEventListener('click', function (e) {
        if (!e.target.closest('.pm-row-wrap')) { closeAllMenus(); }
    });
    window.openLcModal = function (mode) {
        if (!overlay || !modal) { return; }
        if (viewModal) { viewModal.classList.remove('show'); }
        if (mode === 'add') {
            title.textContent = 'New Ledger Category';
            if (editId) { editId.value = ''; }
        } else {
            title.textContent = 'Edit Ledger Category';
        }
        if (modalOpen) { modalOpen.value = '1'; }
        overlay.classList.add('show');
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';
    };
    window.closeLcModal = function () {
        if (!overlay || !modal) { return; }
        overlay.classList.remove('show');
        modal.classList.remove('show');
        document.body.style.overflow = '';
        if (editId) { editId.value = ''; }
        if (modalOpen) { modalOpen.value = ''; }
    };

    window.openLcViewModal = function (id, name, type) {
        var idInput = q('viewCategoryId');
        var nameInput = q('viewCategoryName');
        var typeInput = q('viewCategoryType');
        closeAllMenus();
        if (modal) { modal.classList.remove('show'); }
        if (idInput) { idInput.value = id || ''; }
        if (nameInput) { nameInput.value = name || ''; }
        if (typeInput) { typeInput.value = type || ''; }
        if (modalOpen) { modalOpen.value = ''; }
        if (overlay) { overlay.classList.add('show'); }
        if (viewModal) { viewModal.classList.add('show'); }
        document.body.style.overflow = 'hidden';
    };

    window.closeLcViewModal = function () {
        if (overlay) { overlay.classList.remove('show'); }
        if (viewModal) { viewModal.classList.remove('show'); }
        document.body.style.overflow = '';
    };

    if (modalOpen && modalOpen.value !== '1') {
        closeLcModal();
    }
})();
</script>
</asp:Content>
