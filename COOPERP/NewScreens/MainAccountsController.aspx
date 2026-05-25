<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="MainAccountsController.aspx.cs" Inherits="COOPERP_NewScreens_MainAccountsController" Title="Main Accounts Controller - Campus Dynamics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
*{box-sizing:border-box;}
.pm-admin-wrap{max-width:1320px;margin:0 auto;padding:8px 10px 12px;}
.pm-stats{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:8px;margin-bottom:8px;}
.pm-stat{padding:8px 10px;border-radius:6px;border:1px solid #e3e9f2;background:#fff;min-height:60px;display:flex;flex-direction:column;justify-content:center;gap:3px;}
.pm-stat__lbl{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;line-height:1.25;}
.pm-stat__val{font-size:22px;line-height:1;font-weight:800;color:#05275C;letter-spacing:-.02em;}
.pm-stat--main .pm-stat__val{color:#05275C;}
.pm-stat--sub .pm-stat__val{color:#174DA4;}
.pm-stat--cat .pm-stat__val{color:#2e7d32;}
.pm-stat--ledger .pm-stat__val{color:#b45309;}
.pm-card{background:#fff;border:1px solid #e3e9f2;border-radius:8px;overflow:visible;margin-bottom:10px;}
.pm-card__head{padding:8px 10px;border-bottom:1px solid #edf1f6;background:#fff;display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;}
.pm-card__title{font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.pm-muted{color:#6b7280;font-size:10px;}
.pm-chip{display:inline-flex;align-items:center;padding:3px 8px;border-radius:999px;background:#f1f5ff;border:1px solid #d8e2f6;color:#174DA4;font-size:9px;font-weight:800;letter-spacing:.35px;text-transform:uppercase;}
.pm-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;padding:5px 9px;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;border-radius:6px;min-height:30px;text-decoration:none;}
.pm-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff;}
.pm-btn--primary{background:#05275C;color:#fff;border-color:#05275C;}
.pm-btn--primary:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.pm-btn--danger{background:#c62828;color:#fff;border-color:#c62828;}
.pm-btn--danger:hover{background:#b42318;border-color:#b42318;color:#fff;}
.pm-btn--ghost{padding:0;border:none;background:transparent;min-height:0;color:#174DA4;font-size:10px;font-weight:700;}
.pm-btn--ghost:hover{background:transparent;border:none;color:#0f3f8c;text-decoration:underline;}
.pm-toolbar{padding:8px 10px;border-bottom:1px solid #eef2f6;background:#f8fafc;display:flex;justify-content:space-between;gap:8px;align-items:center;flex-wrap:wrap;}
.pm-meta{padding:6px 10px;border-bottom:1px solid #eef2f6;font-size:10px;color:#64748b;display:flex;justify-content:space-between;gap:8px;flex-wrap:wrap;background:#fff;align-items:center;}
.pm-table-wrap{overflow:auto;scrollbar-color:#b6c5db #f5f8fc;scrollbar-width:thin;background:#fff;position:relative;padding:0;max-height:500px;}
.pm-table{width:100%;min-width:780px;border-collapse:collapse;table-layout:fixed;}
.pm-table th{position:sticky;top:0;background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;padding:6px 6px;text-align:left;white-space:nowrap;z-index:1;}
.pm-table td{border-bottom:1px solid #eef2f6;font-size:11px;color:#1f2937;padding:6px 6px;vertical-align:middle;background:#fff;}
.pm-table tbody tr:hover td{background:#fafcff;}
.pm-col-code{width:120px;}
.pm-col-name{width:240px;}
.pm-col-actions{width:170px;text-align:center;}
.pm-code{font-family:Consolas,monospace;font-size:11px;color:#174DA4;font-weight:700;white-space:nowrap;}
.pm-ellipsis{display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.pm-pill{display:inline-block;padding:2px 7px;font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;border-radius:3px;}
.pm-pill--asset{background:#e8f0fc;color:#174DA4;}
.pm-pill--liability{background:#fff3cd;color:#92400e;}
.pm-pill--income{background:#e6f4ea;color:#2e7d32;}
.pm-pill--expense{background:#fde8e8;color:#b42318;}
.pm-pill--equity{background:#f3e8fd;color:#7b1fa2;}
.pm-empty{padding:20px;text-align:center;color:#6b7280;font-size:11px;}
.pm-row-wrap{position:relative;display:inline-flex;align-items:center;justify-content:center;z-index:20;}
.pm-row-trigger{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border:1px solid #d6deea;background:#fff;color:#475569;cursor:pointer;border-radius:5px;font-size:14px;line-height:1;padding:0;}
.pm-row-menu{display:none;position:absolute;right:0;top:calc(100% + 4px);min-width:190px;padding:6px;background:#fff;border:1px solid #dbe4ef;border-radius:8px;box-shadow:0 14px 34px rgba(15,23,42,.16);z-index:200;}
.pm-row-menu.open{display:block;}
.pm-row-menu__item{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border:0;background:transparent;color:#334155;font-size:11px;font-weight:700;text-align:left;border-radius:6px;cursor:pointer;white-space:nowrap;}
.pm-row-menu__item:hover{background:#f8fafc;color:#0f172a;}
.pm-row-menu__item--danger{color:#b42318;}
.pm-row-menu__item--danger:hover{background:#fef2f2;color:#991b1b;}
.pm-alert{padding:8px 10px;border:1px solid transparent;border-radius:6px;font-size:11px;font-weight:700;margin-bottom:8px;}
.pm-alert--ok{background:#f0fdf4;border-color:#bbf7d0;color:#15803d;}
.pm-alert--err{background:#fef2f2;border-color:#fecaca;color:#b91c1c;}
.pm-overlay{display:none;position:fixed;inset:0;background:rgba(5,15,35,.5);backdrop-filter:blur(2px);z-index:9000;}
.pm-overlay.show{display:block;}
.pm-modal{display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background:#fff;border:1px solid #dde3ed;border-radius:10px;width:92%;max-width:620px;box-shadow:0 20px 60px rgba(5,15,35,.2);z-index:9001;max-height:90vh;overflow-y:auto;}
.pm-modal.show{display:block;}
.pm-modal__head{padding:14px 16px;border-bottom:1px solid #e7ebf1;display:flex;justify-content:space-between;align-items:center;gap:8px;background:#f8fafc;}
.pm-modal__title{font-size:12px;font-weight:900;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.pm-modal__close{background:0;border:0;font-size:20px;color:#6b7280;cursor:pointer;line-height:1;padding:0;width:26px;height:26px;}
.pm-modal__body{padding:16px;}
.pm-modal__foot{padding:10px 16px;border-top:1px solid #e7ebf1;background:#f8fafc;display:flex;justify-content:flex-end;gap:6px;}
.pm-form-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;}
.pm-fg{display:flex;flex-direction:column;gap:2px;min-width:0;}
.pm-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;}
.pm-input,.pm-select{height:32px;border:1px solid #cdd8e6;padding:4px 8px;font-size:11px;background:#fff;border-radius:6px;color:#1a1a2e;font-family:inherit;}
.pm-input:focus,.pm-select:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12);background:#fcfdff;}
.pm-fg--full{grid-column:1/-1;}
@media (max-width:768px){
    .pm-stats{grid-template-columns:repeat(2,minmax(0,1fr));}
    .pm-form-grid{grid-template-columns:1fr;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="pm-admin-wrap">
    <asp:Label ID="lblMessage" runat="server" Visible="false" />
    <asp:HiddenField ID="hdnMainMode" runat="server" Value="add" />
    <asp:HiddenField ID="hdnMainOriginalCode" runat="server" Value="" />

    <div id="pmOverlay" class="pm-overlay" onclick="closeMainModal()"></div>

    <div id="mainAccountModal" class="pm-modal">
        <div class="pm-modal__head">
            <div>
                <div class="pm-modal__title" id="mainModalTitle">New Main Account</div>
                <div class="pm-muted" id="mainModalSub">Create a new top-level account category</div>
            </div>
            <button type="button" class="pm-modal__close" onclick="closeMainModal()">&times;</button>
        </div>
        <div class="pm-modal__body">
            <div class="pm-form-grid">
                <div class="pm-fg">
                    <label>Account Code</label>
                    <asp:TextBox ID="txtMainAccCode" runat="server" MaxLength="15" CssClass="pm-input" />
                </div>
                <div class="pm-fg">
                    <label>Account Name</label>
                    <asp:TextBox ID="txtMainAccName" runat="server" MaxLength="45" CssClass="pm-input" />
                </div>
                <div class="pm-fg">
                    <label>General Category</label>
                    <asp:DropDownList ID="ddlGeneralCategory" runat="server" CssClass="pm-select">
                        <asp:ListItem Text="-- Select --" Value="" />
                        <asp:ListItem Text="Asset" Value="Asset" />
                        <asp:ListItem Text="Liability" Value="Liability" />
                        <asp:ListItem Text="Income" Value="Income" />
                        <asp:ListItem Text="Expense" Value="Expense" />
                        <asp:ListItem Text="Equity" Value="Equity" />
                    </asp:DropDownList>
                </div>
                <div class="pm-fg">
                    <label>Sub Category</label>
                    <asp:TextBox ID="txtSubCategory" runat="server" MaxLength="45" CssClass="pm-input" />
                </div>
                <div class="pm-fg pm-fg--full">
                    <div class="pm-muted">Edit mode locks Account Code to preserve accounting integrity.</div>
                </div>
            </div>
        </div>
        <div class="pm-modal__foot">
            <button type="button" class="pm-btn" onclick="closeMainModal()">Cancel</button>
            <asp:Button ID="btnSaveMainAccount" runat="server" Text="Save Main Account" CssClass="pm-btn pm-btn--primary" OnClick="btnSaveMainAccount_Click" />
        </div>
    </div>

    <div class="pm-stats">
        <div class="pm-stat pm-stat--main"><div class="pm-stat__lbl">Main Accounts</div><div class="pm-stat__val"><asp:Literal ID="litMainCount" runat="server" Text="0" /></div></div>
        <div class="pm-stat pm-stat--sub"><div class="pm-stat__lbl">Sub Accounts</div><div class="pm-stat__val"><asp:Literal ID="litSubCount" runat="server" Text="0" /></div></div>
        <div class="pm-stat pm-stat--cat"><div class="pm-stat__lbl">General Categories</div><div class="pm-stat__val"><asp:Literal ID="litCatCount" runat="server" Text="0" /></div></div>
        <div class="pm-stat pm-stat--ledger"><div class="pm-stat__lbl">Ledger Types</div><div class="pm-stat__val"><asp:Literal ID="litLedgerTypes" runat="server" Text="0" /></div></div>
    </div>

    <div class="pm-card">
        <div class="pm-card__head">
            <div>
                <div class="pm-card__title">Main Accounts Controller</div>
                <div class="pm-muted">Manage top-level chart accounts and route to sub-account management</div>
            </div>
            <asp:Literal ID="litMainBadge" runat="server" />
        </div>

        <div class="pm-toolbar">
            <div class="pm-muted">Use one modal form for create and edit actions.</div>
            <button type="button" class="pm-btn pm-btn--primary" onclick="openMainModal('add')">+ New Main Account</button>
        </div>

        <div class="pm-meta">
            <span><asp:Literal ID="litMainFooter" runat="server" /></span>
            <a href="SubAccountsController.aspx" class="pm-btn">Open Sub Accounts Controller</a>
        </div>

        <div class="pm-table-wrap">
            <table class="pm-table">
                <thead>
                    <tr>
                        <th class="pm-col-code">Code</th>
                        <th class="pm-col-name">Account Name</th>
                        <th>Main Category</th>
                        <th>Sub Category</th>
                        <th class="pm-col-actions">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptMainAccounts" runat="server" OnItemCommand="rptMainAccounts_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td class="pm-code"><%# Eval("AccountCode") %></td>
                                <td><span class="pm-ellipsis"><%# Eval("AccountName") %></span></td>
                                <td><span class='pm-pill pm-pill--<%# Eval("GeneralCategory").ToString().ToLower() %>'><%# Eval("GeneralCategory") %></span></td>
                                <td><span class="pm-ellipsis"><%# Eval("SubCategory") %></span></td>
                                <td class="pm-col-actions">
                                    <div class="pm-row-wrap">
                                        <button type="button" class="pm-row-trigger" onclick="toggleRowMenu(this)">⋯</button>
                                        <div class="pm-row-menu">
                                            <asp:LinkButton ID="lnkEditMain" runat="server" CommandName="EditMain" CommandArgument='<%# Eval("AccountCode") %>' CssClass="pm-row-menu__item">
                                                Edit Main Account
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="lnkViewSubs" runat="server" CommandName="ViewSubs" CommandArgument='<%# Eval("AccountCode") %>' CssClass="pm-row-menu__item">
                                                Open Sub Accounts
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="lnkDeleteMain" runat="server" CommandName="DeleteMain" CommandArgument='<%# Eval("AccountCode") %>' CssClass="pm-row-menu__item pm-row-menu__item--danger" OnClientClick="return confirm('Delete this main account?');">
                                                Delete Main Account
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:PlaceHolder ID="phNoMain" runat="server" Visible="false">
                        <tr><td colspan="5" class="pm-empty">No main accounts found.</td></tr>
                    </asp:PlaceHolder>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script type="text/javascript">
(function(){
'use strict';
function q(id){return document.getElementById(id);}
var overlay = q('pmOverlay');
var modal = q('mainAccountModal');
var title = q('mainModalTitle');
var subtitle = q('mainModalSub');
var modeField = q('<%= hdnMainMode.ClientID %>');
var codeInput = q('<%= txtMainAccCode.ClientID %>');
var saveBtn = q('<%= btnSaveMainAccount.ClientID %>');

function closeAllMenus(){document.querySelectorAll('.pm-row-menu.open').forEach(function(menu){menu.classList.remove('open');});}
window.toggleRowMenu=function(btn){var menu=btn.parentNode.querySelector('.pm-row-menu');var wasOpen=menu.classList.contains('open');closeAllMenus();if(!wasOpen){menu.classList.add('open');}};
document.addEventListener('click', function(e){if(!e.target.closest('.pm-row-wrap')) closeAllMenus();});

window.openMainModal = function(mode){
    var isEdit = mode === 'edit';
    if(modeField){ modeField.value = isEdit ? 'edit' : 'add'; }
    if(title){ title.textContent = isEdit ? 'Edit Main Account' : 'New Main Account'; }
    if(subtitle){ subtitle.textContent = isEdit ? 'Update account details and save changes' : 'Create a new top-level account category'; }
    if(saveBtn){ saveBtn.value = isEdit ? 'Update Main Account' : 'Save Main Account'; }
    if(codeInput){ codeInput.readOnly = isEdit; }

    if(!isEdit){
        var name = q('<%= txtMainAccName.ClientID %>');
        var category = q('<%= ddlGeneralCategory.ClientID %>');
        var subCat = q('<%= txtSubCategory.ClientID %>');
        var originalCode = q('<%= hdnMainOriginalCode.ClientID %>');
        if(codeInput){ codeInput.value = ''; }
        if(name){ name.value = ''; }
        if(category){ category.value = ''; }
        if(subCat){ subCat.value = ''; }
        if(originalCode){ originalCode.value = ''; }
    }

    if(overlay){ overlay.classList.add('show'); }
    if(modal){ modal.classList.add('show'); }
    document.body.style.overflow = 'hidden';
};

window.closeMainModal = function(){
    if(overlay){ overlay.classList.remove('show'); }
    if(modal){ modal.classList.remove('show'); }
    document.body.style.overflow = '';
};
})();
</script>
</asp:Content>
