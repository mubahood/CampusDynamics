<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="BudgetManager.aspx.cs" Inherits="COOPERP_NewScreens_BudgetManager" Title="Budget Manager - Campus Dynamics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
/* =====================================================================
   BUDGET MANAGER — New Screen 2026-04
   Prefix: bm- (budget manager) | fm- (page header/nav) | fs- (shared)
   ===================================================================== */

/* ---- Page header ---- */
.fm-page-header {
    display: flex; align-items: center; justify-content: space-between;
    background: linear-gradient(135deg,#1a237e 0%,#283593 100%); color: #fff;
    padding: 14px 20px; border-bottom: 3px solid #041d45;
}
.fm-page-header__left { display: flex; align-items: center; gap: 12px; }
.fm-page-header__icon {
    width: 40px; height: 40px; background: rgba(255,255,255,.12);
    border-radius: 4px; display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}
.fm-page-header__title { font-size: 16px; font-weight: 700; }
.fm-page-header__sub   { font-size: 12px; opacity: .75; margin-top: 2px; }

/* ---- Tab navigation ---- */
.fm-tabs { display: flex; gap: 2px; background: #f0f2f5; border-bottom: 2px solid #e0e5ed; padding: 0 20px; }
.fm-tab {
    padding: 9px 16px; font-size: 12px; font-weight: 500; color: #555;
    text-decoration: none; border-bottom: 2px solid transparent; margin-bottom: -2px;
    white-space: nowrap; display: flex; align-items: center; gap: 5px;
}
.fm-tab:hover { color: #1a237e; }
.fm-tab--active { color: #1a237e; border-bottom-color: #1a237e; font-weight: 600; }

/* ---- Content ---- */
.bm-content { padding: 16px 20px 20px; }

/* ---- KPI row ---- */
.bm-kpi-row { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; margin-bottom: 18px; }
.bm-kpi {
    background: #fff; border: 1px solid #e0e5ed; padding: 14px 16px;
    position: relative; overflow: hidden;
}
.bm-kpi::before { content: ''; position: absolute; left: 0; top: 0; width: 3px; height: 100%; }
.bm-kpi--planned::before { background: #174DA4; }
.bm-kpi--actual::before  { background: #16a34a; }
.bm-kpi--variance::before { background: #e67e22; }
.bm-kpi--items::before    { background: #6c5ce7; }
.bm-kpi__label { font-size: 10px; text-transform: uppercase; letter-spacing: .6px; color: #999; margin-bottom: 4px; }
.bm-kpi__value { font-size: 20px; font-weight: 700; color: #1a2942; font-family: Consolas, monospace; }

/* ---- Toolbar ---- */
.bm-toolbar {
    display: flex; flex-wrap: wrap; align-items: center; gap: 8px;
    padding: 10px 14px; background: #f9fafb; border: 1px solid #e0e5ed;
    margin-bottom: 14px;
}
.bm-toolbar label { font-size: 11px; font-weight: 600; color: #555; }
.bm-toolbar select, .bm-toolbar input[type="text"] {
    padding: 5px 8px; border: 1px solid #d0d5dd; font-size: 11px;
    background: #fff; min-width: 120px;
}

/* ---- Card ---- */
.ft-card { background: #fff; border: 1px solid #e0e5ed; margin-bottom: 16px; }
.ft-card__head {
    display: flex; align-items: center; justify-content: space-between;
    padding: 10px 14px; border-bottom: 1px solid #e0e5ed;
    background: linear-gradient(135deg,#fafbfc,#f3f5f8);
}
.ft-card__title { font-size: 13px; font-weight: 600; color: #1a2942; }
.ft-card__meta { font-size: 10px; color: #888; }
.ft-card__body { padding: 0; }
.ft-card__foot {
    padding: 8px 14px; background: #fafbfc; border-top: 1px solid #e0e5ed;
    font-size: 10px; color: #888;
}

/* ---- Table ---- */
.bm-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.bm-table th {
    background: #f5f7fa; color: #555; font-weight: 600; text-transform: uppercase;
    padding: 7px 10px; letter-spacing: .5px; font-size: 10px;
    border-bottom: 2px solid #e0e5ed; text-align: left;
}
.bm-table td {
    padding: 7px 10px; border-bottom: 1px solid #f0f2f5;
    white-space: nowrap;
}
.bm-table tr:hover td { background: #f8faff; }
.bm-money { text-align: right; font-family: Consolas, monospace; font-size: 10px; }
.bm-status--over { color: #dc3545; font-weight: 600; }
.bm-status--under { color: #16a34a; font-weight: 600; }
.bm-status--normal { color: #555; }

/* ---- Buttons ---- */
.fs-btn {
    padding: 5px 14px; font-size: 11px; font-weight: 600;
    border: 1px solid #d0d5dd; cursor: pointer; display: inline-flex;
    align-items: center; gap: 5px; background: #fff; color: #333;
}
.fs-btn:hover { background: #f5f7fa; }
.fs-btn--primary { background: #174DA4; color: #fff; border-color: #174DA4; }
.fs-btn--primary:hover { background: #0d3a80; }
.fs-btn--success { background: #16a34a; color: #fff; border-color: #16a34a; }
.fs-btn--success:hover { background: #128a3e; }

/* ---- Add form ---- */
.bm-form { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 10px; padding: 14px; }
.bm-form label { display: block; font-size: 10px; font-weight: 600; color: #555; margin-bottom: 3px; text-transform: uppercase; letter-spacing: .4px; }
.bm-form input, .bm-form select {
    width: 100%; padding: 6px 8px; border: 1px solid #d0d5dd; font-size: 11px;
    background: #fff;
}

/* ---- Messages ---- */
.bm-msg { padding: 8px 14px; font-size: 11px; margin: 10px 20px; border-left: 3px solid; }
.bm-msg-ok { background: #f0fdf4; border-color: #16a34a; color: #166534; }
.bm-msg-err { background: #fef2f2; border-color: #dc3545; color: #991b1b; }

/* ---- Variance bar ---- */
.bm-var-bar { width: 60px; height: 6px; background: #e0e5ed; display: inline-block; vertical-align: middle; margin-left: 6px; }
.bm-var-fill { height: 100%; transition: width .2s; }
.bm-var-fill--ok { background: #16a34a; }
.bm-var-fill--warn { background: #e67e22; }
.bm-var-fill--over { background: #dc3545; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- PAGE HEADER -->
<div class="fm-page-header">
    <div class="fm-page-header__left">
        <div class="fm-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
        </div>
        <div>
            <div class="fm-page-header__title">Budget Manager</div>
            <div class="fm-page-header__sub">Plan, track and control departmental budgets</div>
        </div>
    </div>
    <asp:Literal ID="litPeriodBadge" runat="server" />
</div>

<!-- TAB NAVIGATION -->
<div class="fm-tabs">
    <a href="FinanceDashboard.aspx" class="fm-tab">Dashboard</a>
    <a href="GeneralLedger.aspx" class="fm-tab">General Ledger</a>
    <a href="JournalEntries.aspx" class="fm-tab">Journals</a>
    <a href="PaymentVouchers.aspx" class="fm-tab">Payment Vouchers</a>
    <a href="ContraVouchers.aspx" class="fm-tab">Contra Vouchers</a>
    <a href="BudgetManager.aspx" class="fm-tab fm-tab--active">Budget</a>
    <a href="CashBook.aspx" class="fm-tab">Cash Book</a>
    <a href="BankReconciliation.aspx" class="fm-tab">Bank Reco</a>
    <a href="TrialBalance.aspx" class="fm-tab">Trial Balance</a>
    <a href="BalanceSheet.aspx" class="fm-tab">Balance Sheet</a>
    <a href="IncomeStatement.aspx" class="fm-tab">Income Statement</a>
    <a href="FinancialPeriods.aspx" class="fm-tab">Periods</a>
    <a href="FinanceAuditTrail.aspx" class="fm-tab">Audit Trail</a>
</div>

<div class="bm-content">

    <!-- KPI ROW -->
    <div class="bm-kpi-row">
        <div class="bm-kpi bm-kpi--planned">
            <div class="bm-kpi__label">Total Planned</div>
            <div class="bm-kpi__value"><asp:Literal ID="litPlanned" runat="server" Text="0" /></div>
        </div>
        <div class="bm-kpi bm-kpi--actual">
            <div class="bm-kpi__label">Total Actual</div>
            <div class="bm-kpi__value"><asp:Literal ID="litActual" runat="server" Text="0" /></div>
        </div>
        <div class="bm-kpi bm-kpi--variance">
            <div class="bm-kpi__label">Variance</div>
            <div class="bm-kpi__value"><asp:Literal ID="litVariance" runat="server" Text="0" /></div>
        </div>
        <div class="bm-kpi bm-kpi--items">
            <div class="bm-kpi__label">Budget Items</div>
            <div class="bm-kpi__value"><asp:Literal ID="litItemCount" runat="server" Text="0" /></div>
        </div>
    </div>

    <!-- MESSAGE -->
    <asp:Panel ID="pnlMsg" runat="server" Visible="false">
        <asp:Literal ID="litMsg" runat="server" />
    </asp:Panel>

    <!-- TOOLBAR -->
    <div class="bm-toolbar">
        <label>Budget Year:</label>
        <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlYear_Changed" />
        <label style="margin-left:12px;">Category:</label>
        <asp:DropDownList ID="ddlCategory" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_Changed">
            <asp:ListItem Text="All Categories" Value="" />
            <asp:ListItem Text="Income" Value="Income" />
            <asp:ListItem Text="Expenditure" Value="Expenditure" />
        </asp:DropDownList>
        <div style="margin-left:auto; display:flex; gap:6px;">
            <asp:Button ID="btnInitBudget" runat="server" Text="+ Initialize Budget" CssClass="fs-btn fs-btn--primary" OnClick="btnInitBudget_Click" />
            <asp:Button ID="btnExport" runat="server" Text="Export CSV" CssClass="fs-btn" OnClick="btnExport_Click" />
        </div>
    </div>

    <!-- ADD/EDIT FORM -->
    <div class="ft-card">
        <div class="ft-card__head">
            <span class="ft-card__title">Add / Edit Budget Item</span>
        </div>
        <div class="bm-form">
            <div>
                <label>Account Code</label>
                <asp:DropDownList ID="ddlAccount" runat="server" />
            </div>
            <div>
                <label>Category</label>
                <asp:DropDownList ID="ddlItemCategory" runat="server">
                    <asp:ListItem Text="Expenditure" Value="Expenditure" />
                    <asp:ListItem Text="Income" Value="Income" />
                </asp:DropDownList>
            </div>
            <div>
                <label>Planned Amount</label>
                <asp:TextBox ID="txtPlannedAmount" runat="server" placeholder="0" />
            </div>
            <div>
                <label>Details / Notes</label>
                <asp:TextBox ID="txtDetails" runat="server" placeholder="Budget line description" />
            </div>
            <div style="align-self:end;">
                <asp:HiddenField ID="hdnEditId" runat="server" />
                <asp:Button ID="btnSaveItem" runat="server" Text="+ Add Item" CssClass="fs-btn fs-btn--success" OnClick="btnSaveItem_Click" />
                <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="fs-btn" Visible="false" OnClick="btnCancelEdit_Click" />
            </div>
        </div>
    </div>

    <!-- BUDGET TABLE -->
    <div class="ft-card">
        <div class="ft-card__head">
            <span class="ft-card__title">Budget Items</span>
            <asp:Literal ID="litBadge" runat="server" />
        </div>
        <div class="ft-card__body">
            <table class="bm-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Account Code</th>
                        <th>Details</th>
                        <th>Category</th>
                        <th style="text-align:right;">Planned</th>
                        <th style="text-align:right;">Actual</th>
                        <th style="text-align:right;">Variance</th>
                        <th>Status</th>
                        <th>Utilization</th>
                        <th style="text-align:center;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptBudget" runat="server" OnItemCommand="rptBudget_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td><%# Container.ItemIndex + 1 %></td>
                                <td style="font-weight:600; color:#05275C;"><%# Eval("item_code") %></td>
                                <td><%# Eval("details") %></td>
                                <td><%# Eval("item_category") %></td>
                                <td class="bm-money"><%# Convert.ToDecimal(Eval("planned_amount")).ToString("N0") %></td>
                                <td class="bm-money"><%# Convert.ToDecimal(Eval("actual_amount")).ToString("N0") %></td>
                                <td class="bm-money"><%# (Convert.ToDecimal(Eval("planned_amount")) - Convert.ToDecimal(Eval("actual_amount"))).ToString("N0") %></td>
                                <td>
                                    <%# Eval("vote_status") %>
                                </td>
                                <td>
                                    <%# GetUtilBar(Eval("planned_amount"), Eval("actual_amount")) %>
                                </td>
                                <td style="text-align:center; white-space:nowrap;">
                                    <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditItem"
                                        CommandArgument='<%# Eval("ID") + "|" + Eval("item_code") + "|" + Eval("details") + "|" + Eval("planned_amount") + "|" + Eval("item_category") %>'
                                        CssClass="fs-btn" style="padding:2px 8px; font-size:10px;">Edit</asp:LinkButton>
                                    <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteItem"
                                        CommandArgument='<%# Eval("ID") %>'
                                        CssClass="fs-btn" style="padding:2px 8px; font-size:10px; color:#dc3545;"
                                        OnClientClick="return confirm('Delete this budget item?');">Del</asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
                <tfoot>
                    <tr style="background:#f5f7fa; font-weight:700;">
                        <td colspan="4" style="text-align:right; font-size:10px; text-transform:uppercase; letter-spacing:.5px; color:#555;">Totals:</td>
                        <td class="bm-money"><asp:Literal ID="litTotalPlanned" runat="server" /></td>
                        <td class="bm-money"><asp:Literal ID="litTotalActual" runat="server" /></td>
                        <td class="bm-money"><asp:Literal ID="litTotalVariance" runat="server" /></td>
                        <td colspan="3"></td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <div class="ft-card__foot">
            <asp:Literal ID="litFooter" runat="server" />
        </div>
    </div>

</div>
</asp:Content>
