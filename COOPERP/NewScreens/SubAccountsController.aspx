<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="SubAccountsController.aspx.cs" Inherits="COOPERP_NewScreens_SubAccountsController" Title="Sub Accounts Controller - Campus Dynamics" %>

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
.pm-top-controls{padding:8px 10px;border-bottom:1px solid #eef2f6;background:#f8fafc;display:flex;gap:8px;align-items:center;flex-wrap:wrap;justify-content:space-between;}
.pm-filters{padding:8px 10px;border-bottom:1px solid #eef2f6;background:#fff;display:grid;grid-template-columns:minmax(170px,.8fr) minmax(220px,1fr) minmax(170px,.8fr) minmax(230px,1.2fr) minmax(110px,.6fr) auto;gap:6px;align-items:flex-end;}
.pm-fg{display:flex;flex-direction:column;gap:2px;min-width:0;}
.pm-fg label{font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;}
.pm-input,.pm-select{height:30px;border:1px solid #cdd8e6;padding:4px 8px;font-size:11px;background:#fff;border-radius:6px;color:#1a1a2e;font-family:inherit;}
.pm-input:focus,.pm-select:focus{outline:none;border-color:#174DA4;box-shadow:0 0 0 3px rgba(23,77,164,.12);background:#fcfdff;}
.pm-btn{display:inline-flex;align-items:center;justify-content:center;gap:4px;padding:5px 9px;border:1px solid #d2dae6;background:#fff;color:#05275C;font-size:10px;font-weight:800;cursor:pointer;border-radius:6px;min-height:30px;text-decoration:none;}
.pm-btn:hover{color:#174DA4;border-color:#174DA4;background:#f4f8ff;}
.pm-btn--primary{background:#05275C;color:#fff;border-color:#05275C;}
.pm-btn--primary:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
.pm-btn--danger{background:#c62828;color:#fff;border-color:#c62828;}
.pm-btn--danger:hover{background:#b42318;border-color:#b42318;color:#fff;}
.pm-btn--ghost{padding:0;border:none;background:transparent;min-height:0;color:#174DA4;font-size:10px;font-weight:700;}
.pm-btn--ghost:hover{background:transparent;border:none;color:#0f3f8c;text-decoration:underline;}
.pm-meta{padding:6px 10px;border-bottom:1px solid #eef2f6;font-size:10px;color:#64748b;display:flex;justify-content:space-between;gap:8px;flex-wrap:wrap;background:#fff;align-items:center;}
.pm-pager{display:flex;gap:4px;flex-wrap:wrap;}
.pm-pager a,.pm-pager span{border:1px solid #d4dbe8;background:#fff;color:#334155;font-size:9px;text-decoration:none;padding:4px 7px;border-radius:6px;}
.pm-pager .active{background:#05275C;border-color:#05275C;color:#fff;}
.pm-table-wrap{overflow-x:auto;overflow-y:visible;scrollbar-color:#b6c5db #f5f8fc;scrollbar-width:thin;background:#fff;position:relative;padding:0;max-height:none;min-height:0;border-top:1px solid #eef2f6;border-bottom:1px solid #eef2f6;}
.pm-table-wrap::-webkit-scrollbar{height:10px;width:10px;}
.pm-table-wrap::-webkit-scrollbar-thumb{background:#b6c5db;border-radius:999px;}
.pm-table-wrap::-webkit-scrollbar-track{background:#f5f8fc;}
.pm-table{width:100%;min-width:980px;border-collapse:collapse;table-layout:fixed;}
.pm-table th{background:#f8fafc;border-bottom:1px solid #e0e5ed;font-size:9px;text-transform:uppercase;letter-spacing:.45px;color:#64748b;font-weight:800;padding:6px 6px;text-align:left;white-space:nowrap;z-index:1;}
.pm-table td{border-bottom:1px solid #eef2f6;font-size:11px;color:#1f2937;padding:6px 6px;vertical-align:middle;background:#fff;}
.pm-table tbody tr:hover td{background:#fafcff;}
.pm-col-code{width:100px;}
.pm-col-name{width:220px;}
.pm-col-main{width:130px;}
.pm-col-details{width:250px;}
.pm-col-type{width:120px;}
.pm-col-ledger{width:140px;}
.pm-col-money{width:110px;text-align:right;}
.pm-col-actions{width:120px;text-align:center;}
.pm-col-hidden{display:none;}
.pm-code{font-family:Consolas,monospace;font-size:11px;color:#174DA4;font-weight:700;white-space:nowrap;}
.pm-ellipsis{display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.pm-money{font-variant-numeric:tabular-nums;text-align:right;display:block;}
.pm-money--dr{color:#b42318;font-weight:700;}
.pm-money--cr{color:#15803d;font-weight:700;}
.pm-money--bal{color:#b42318;font-weight:800;}
.pm-table td.pm-col-money--dr,.pm-table td.pm-col-money--dr .pm-money{color:#b42318 !important;font-weight:700;}
.pm-table td.pm-col-money--cr,.pm-table td.pm-col-money--cr .pm-money{color:#15803d !important;font-weight:700;}
.pm-table td.pm-col-money--bal,.pm-table td.pm-col-money--bal .pm-money{color:#b42318 !important;font-weight:800;}
.pm-empty{padding:20px;text-align:center;color:#6b7280;font-size:11px;}
.pm-row-wrap{position:relative;display:inline-flex;align-items:center;justify-content:center;z-index:20;}
.pm-row-trigger{display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border:1px solid #d6deea;background:#fff;color:#475569;cursor:pointer;border-radius:5px;font-size:14px;line-height:1;padding:0;}
.pm-row-menu{display:none;position:absolute;right:0;top:calc(100% + 4px);min-width:165px;padding:6px;background:#fff;border:1px solid #dbe4ef;border-radius:8px;box-shadow:0 14px 34px rgba(15,23,42,.16);z-index:200;}
.pm-row-menu.open{display:block;}
.pm-row-menu__item{display:flex;align-items:center;gap:8px;width:100%;padding:8px 10px;border:0;background:transparent;color:#334155;font-size:11px;font-weight:700;text-align:left;border-radius:6px;cursor:pointer;white-space:nowrap;}
.pm-row-menu__item:hover{background:#f8fafc;color:#0f172a;}
.pm-row-menu__item--danger{color:#b42318;}
.pm-row-menu__item--danger:hover{background:#fef2f2;color:#991b1b;}
.pm-overlay{display:none;position:fixed;inset:0;background:rgba(5,15,35,.45);z-index:9000;}
.pm-overlay.show{display:block;}
.pm-modal{display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background:#fff;border:1px solid #dde3ed;border-radius:10px;width:92%;max-width:560px;box-shadow:0 20px 60px rgba(5,15,35,.2);z-index:9001;max-height:90vh;overflow-y:auto;}
.pm-modal.show{display:block;}
.pm-modal__head{padding:12px 14px;border-bottom:1px solid #e7ebf1;display:flex;justify-content:space-between;align-items:center;background:#f8fafc;}
.pm-modal__title{font-size:12px;font-weight:900;text-transform:uppercase;letter-spacing:.5px;color:#05275C;}
.pm-modal__close{background:0;border:0;font-size:20px;color:#6b7280;cursor:pointer;line-height:1;padding:0;width:26px;height:26px;}
.pm-modal__body{padding:14px;}
.pm-dl{display:grid;grid-template-columns:1fr 1fr;gap:8px 14px;}
.pm-dl dt{font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#6b7280;font-weight:800;margin:0;}
.pm-dl dd{font-size:11px;font-weight:700;color:#1f2937;margin:0 0 2px;}
.pm-alert{padding:8px 10px;border:1px solid transparent;border-radius:6px;font-size:11px;font-weight:700;margin-bottom:8px;}
.pm-alert--ok{background:#f0fdf4;border-color:#bbf7d0;color:#15803d;}
.pm-alert--err{background:#fef2f2;border-color:#fecaca;color:#b91c1c;}
.pm-add-wrap{padding:8px 10px;border-top:1px solid #eef2f6;background:#fff;display:grid;grid-template-columns:minmax(230px,1fr) minmax(230px,1fr) minmax(160px,.9fr) minmax(140px,.8fr) minmax(130px,.7fr) minmax(150px,.8fr) auto;gap:6px;align-items:flex-end;}
@media (max-width:1200px){.pm-filters,.pm-add-wrap{grid-template-columns:repeat(2,minmax(0,1fr));}}
@media (max-width:768px){.pm-stats{grid-template-columns:repeat(2,minmax(0,1fr));}.pm-filters,.pm-add-wrap{grid-template-columns:1fr;}}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="pm-admin-wrap">
    <asp:Label ID="lblMessage" runat="server" Visible="false" />
    <asp:HiddenField ID="hdnEditSubCode" runat="server" Value="" />
    <div id="pmOverlay" class="pm-overlay" onclick="closeViewModal()"></div>
    <div id="viewModal" class="pm-modal">
        <div class="pm-modal__head">
            <span class="pm-modal__title">Sub Account Summary</span>
            <button type="button" class="pm-modal__close" onclick="closeViewModal()">&times;</button>
        </div>
        <div class="pm-modal__body">
            <dl class="pm-dl" id="viewDetails"></dl>
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
                <div class="pm-card__title">Sub Accounts Controller</div>
                <div class="pm-muted">GET-driven search and pagination with stable scrolling</div>
            </div>
            <asp:Literal ID="litSubBadge" runat="server" />
        </div>

        <div class="pm-top-controls">
            <div class="pm-muted">Filter, paginate, and share URL state without postbacks.</div>
            <a href="MainAccountsController.aspx" class="pm-btn">Open Main Accounts Controller</a>
        </div>

        <div class="pm-filters">
            <div class="pm-fg">
                <label>Financial Year</label>
                <asp:DropDownList ID="ddlFinancialYear" runat="server" CssClass="pm-select" />
            </div>
            <div class="pm-fg">
                <label>Main Account</label>
                <asp:DropDownList ID="ddlFilterMainAcc" runat="server" CssClass="pm-select" />
            </div>
            <div class="pm-fg">
                <label>Ledger Type</label>
                <asp:DropDownList ID="ddlFilterLedger" runat="server" CssClass="pm-select" />
            </div>
            <div class="pm-fg">
                <label>Search</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="pm-input" MaxLength="80" placeholder="code, name, details, type" onkeydown="if(event.key==='Enter'){event.preventDefault();applyFilters();}" />
            </div>
            <div class="pm-fg">
                <label>Per Page</label>
                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="pm-select">
                    <asp:ListItem Value="25">25</asp:ListItem>
                    <asp:ListItem Value="50">50</asp:ListItem>
                    <asp:ListItem Value="100">100</asp:ListItem>
                    <asp:ListItem Value="200">200</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="pm-fg" style="justify-content:flex-end;">
                <label>&nbsp;</label>
                <div style="display:flex;gap:6px;">
                    <button type="button" class="pm-btn pm-btn--primary" onclick="applyFilters()">Apply</button>
                    <button type="button" class="pm-btn" onclick="resetFilters()">Reset</button>
                </div>
            </div>
        </div>

        <div class="pm-meta">
            <span>Showing <strong><asp:Literal ID="litFrom" runat="server">0</asp:Literal></strong>–<strong><asp:Literal ID="litTo" runat="server">0</asp:Literal></strong> of <strong><asp:Literal ID="litTotal" runat="server">0</asp:Literal></strong> records | Page <asp:Literal ID="litPage" runat="server">1</asp:Literal> of <asp:Literal ID="litPageCount" runat="server">1</asp:Literal></span>
            <div class="pm-pager"><asp:Literal ID="litPagerTop" runat="server" /></div>
        </div>

        <div class="pm-table-wrap">
            <table class="pm-table">
                <thead>
                    <tr>
                        <th class="pm-col-code">Code</th>
                        <th class="pm-col-name">Account Name</th>
                        <th class="pm-col-main pm-col-hidden">Main Acc</th>
                        <th class="pm-col-details pm-col-hidden">Details</th>
                        <th class="pm-col-type pm-col-hidden">Type</th>
                        <th class="pm-col-ledger pm-col-hidden">Ledger</th>
                                                <th class="pm-col-money">Debit</th>
                                                <th class="pm-col-money">Credit</th>
                                                <th class="pm-col-money">Balance</th>
                        <th class="pm-col-actions">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptSubAccounts" runat="server" OnItemCommand="rptSubAccounts_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td class="pm-code"><%# Eval("AccountCode") %></td>
                                <td><span class="pm-ellipsis"><%# Eval("AccountName") %></span></td>
                                <td class="pm-col-hidden"><span class="pm-code"><%# Eval("MainAccountCode") %></span></td>
                                <td class="pm-col-hidden"><span class="pm-ellipsis" title='<%# Eval("Details") %>'><%# Eval("Details") %></span></td>
                                <td class="pm-col-hidden"><span class="pm-ellipsis"><%# Eval("accounttype") %></span></td>
                                <td class="pm-col-hidden"><span class="pm-ellipsis"><%# Eval("collectionLedgerType") %></span></td>
                                <td class="pm-col-money pm-col-money--dr"><%# RenderMoneyCell(Eval("TotalDebit"), "debit") %></td>
                                <td class="pm-col-money pm-col-money--cr"><%# RenderMoneyCell(Eval("TotalCredit"), "credit") %></td>
                                <td class="pm-col-money pm-col-money--bal"><%# RenderMoneyCell(Eval("Balance"), "balance") %></td>
                                <td class="pm-col-actions">
                                    <div class="pm-row-wrap">
                                        <button type="button" class="pm-row-trigger" onclick="toggleRowMenu(this)">⋯</button>
                                        <div class="pm-row-menu">
                                            <button type="button" class="pm-row-menu__item" 
                                                data-code='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("AccountCode"))) %>'
                                                data-name='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("AccountName"))) %>'
                                                data-main='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("MainAccountCode"))) %>'
                                                data-details='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("Details"))) %>'
                                                data-type='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("accounttype"))) %>'
                                                data-ledger='<%# System.Web.HttpUtility.HtmlAttributeEncode(Convert.ToString(Eval("collectionLedgerType"))) %>'
                                                data-debit='<%# string.Format("{0:N2}", Eval("TotalDebit")) %>'
                                                data-credit='<%# string.Format("{0:N2}", Eval("TotalCredit")) %>'
                                                data-balance='<%# string.Format("{0:N2}", Eval("Balance")) %>'
                                                onclick="openViewModal(this)">
                                                View
                                            </button>
                                            <asp:LinkButton ID="lnkEditSub" runat="server" CommandName="EditSub" CommandArgument='<%# Eval("AccountCode") %>' CssClass="pm-row-menu__item">
                                                Edit Sub Account
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:PlaceHolder ID="phNoSub" runat="server" Visible="false">
                        <tr><td colspan="10" class="pm-empty">No sub accounts found for the current filters.</td></tr>
                    </asp:PlaceHolder>
                </tbody>
            </table>
        </div>

        <div class="pm-meta" style="border-top:1px solid #e0e5ed;border-bottom:none;">
            <span><asp:Literal ID="litSubFooter" runat="server" /></span>
            <div class="pm-pager"><asp:Literal ID="litPagerBottom" runat="server" /></div>
        </div>

        <div class="pm-add-wrap">
            <div class="pm-fg">
                <label>Main Account (for Add)</label>
                <asp:DropDownList ID="ddlMainAccountForSub" runat="server" CssClass="pm-select" />
            </div>
            <div class="pm-fg">
                <label>Account Name</label>
                <asp:TextBox ID="txtSubAccName" runat="server" MaxLength="45" CssClass="pm-input" />
            </div>
            <div class="pm-fg">
                <label>Details</label>
                <asp:TextBox ID="txtSubAccDetails" runat="server" MaxLength="150" CssClass="pm-input" />
            </div>
            <div class="pm-fg">
                <label>Account Type</label>
                <asp:TextBox ID="txtSubAccType" runat="server" MaxLength="45" CssClass="pm-input" />
            </div>
            <div class="pm-fg">
                <label>Ledger Type</label>
                <asp:DropDownList ID="ddlLedgerTypeForSub" runat="server" CssClass="pm-select" />
            </div>
            <div class="pm-fg" style="justify-content:flex-end;">
                <label>&nbsp;</label>
                <div style="display:flex;gap:6px;">
                    <asp:Button ID="btnAddSubAccount" runat="server" Text="Add Sub Account" CssClass="pm-btn pm-btn--primary" OnClick="btnAddSubAccount_Click" />
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel Edit" CssClass="pm-btn" OnClick="btnCancelEdit_Click" Visible="false" />
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
(function(){
'use strict';
function qs(id){ return document.getElementById(id); }
function closeAllMenus(){document.querySelectorAll('.pm-row-menu.open').forEach(function(menu){menu.classList.remove('open');});}
window.toggleRowMenu=function(btn){var menu=btn.parentNode.querySelector('.pm-row-menu');var wasOpen=menu.classList.contains('open');closeAllMenus();if(!wasOpen){menu.classList.add('open');}};
document.addEventListener('click', function(e){if(!e.target.closest('.pm-row-wrap')) closeAllMenus();});

window.openViewModal = function(btn){
    closeAllMenus();
    var details = qs('viewDetails');
    if(!details) return;
    var html = '';
    function row(label,val){ return '<dt>'+label+'</dt><dd>'+(val || '—')+'</dd>'; }
    html += row('Account Code', btn.getAttribute('data-code'));
    html += row('Account Name', btn.getAttribute('data-name'));
    html += row('Main Account', btn.getAttribute('data-main'));
    html += row('Type', btn.getAttribute('data-type'));
    html += row('Ledger', btn.getAttribute('data-ledger'));
    html += row('Details', btn.getAttribute('data-details'));
    html += row('Debit (Active FY)', btn.getAttribute('data-debit'));
    html += row('Credit (Active FY)', btn.getAttribute('data-credit'));
    html += row('Balance (Active FY)', btn.getAttribute('data-balance'));
    details.innerHTML = html;

    qs('pmOverlay').classList.add('show');
    qs('viewModal').classList.add('show');
    document.body.style.overflow = 'hidden';
};

window.closeViewModal = function(){
    qs('pmOverlay').classList.remove('show');
    qs('viewModal').classList.remove('show');
    document.body.style.overflow = '';
};

function getVal(id){ var el = qs(id); return el ? (el.value || '').trim() : ''; }
window.applyFilters = function(){
    var params = new URLSearchParams();
    var fy = getVal('<%= ddlFinancialYear.ClientID %>');
    var main = getVal('<%= ddlFilterMainAcc.ClientID %>');
    var ledger = getVal('<%= ddlFilterLedger.ClientID %>');
    var q = getVal('<%= txtSearch.ClientID %>');
    var ps = getVal('<%= ddlPageSize.ClientID %>');

    params.set('pg','1');
    if(fy) params.set('fy', fy);
    if(main) params.set('main', main);
    if(ledger) params.set('ledger', ledger);
    if(q) params.set('q', q);
    if(ps) params.set('ps', ps);

    var target = 'SubAccountsController.aspx?' + params.toString();
    window.location.assign(target);
};

window.resetFilters = function(){
    window.location.assign('SubAccountsController.aspx');
};

var financialYearEl = qs('<%= ddlFinancialYear.ClientID %>');
var mainFilterEl = qs('<%= ddlFilterMainAcc.ClientID %>');
var ledgerFilterEl = qs('<%= ddlFilterLedger.ClientID %>');
var pageSizeEl = qs('<%= ddlPageSize.ClientID %>');
if(financialYearEl){ financialYearEl.addEventListener('change', applyFilters); }
if(mainFilterEl){ mainFilterEl.addEventListener('change', applyFilters); }
if(ledgerFilterEl){ ledgerFilterEl.addEventListener('change', applyFilters); }
if(pageSizeEl){ pageSizeEl.addEventListener('change', applyFilters); }

})();
</script>
</asp:Content>
