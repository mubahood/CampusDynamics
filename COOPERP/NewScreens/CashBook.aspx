<%@ Page Language="C#" MasterPageFile="~/COOPERP/SidebarMaster.master" AutoEventWireup="true"
    CodeFile="CashBook.aspx.cs" Inherits="COOPERP_NewScreens_CashBook" Title="Cash Book" %>

<asp:Content ID="Head" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Cash Book custom styles ───────────────────────────────── */
.cb-msg      { padding:10px 14px; border-radius:4px; margin-bottom:14px; font-size:12px; }
.cb-msg-ok   { background:#e8f5e9; color:#2e7d32; border:1px solid #a5d6a7; }
.cb-msg-err  { background:#fbe9e7; color:#c62828; border:1px solid #ef9a9a; }

/* KPI strip */
.cb-kpi-row  { display:flex; gap:14px; margin-bottom:18px; flex-wrap:wrap; }
.cb-kpi      { flex:1; min-width:160px; background:#fff; border:1px solid #e0e0e0;
               border-radius:6px; padding:14px 18px; }
.cb-kpi__label { font-size:10px; text-transform:uppercase; letter-spacing:.5px; color:#888; margin-bottom:4px; }
.cb-kpi__value { font-size:20px; font-weight:700; font-family:Consolas,monospace; color:#333; }
.cb-kpi__value--dr  { color:#c62828; }
.cb-kpi__value--cr  { color:#2e7d32; }
.cb-kpi__value--bal { color:#1565c0; }

/* Toolbar */
.cb-toolbar  { display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap; margin-bottom:16px;
               background:#fafafa; padding:14px 16px; border-radius:6px; border:1px solid #eee; }
.cb-toolbar label { display:block; font-size:10px; text-transform:uppercase; color:#888;
                    margin-bottom:3px; letter-spacing:.4px; }
.cb-toolbar select,
.cb-toolbar input[type=text] {
    border:1px solid #ccc; border-radius:4px; padding:6px 10px; font-size:12px;
    height:32px; min-width:140px;
}

/* Table */
.cb-table    { width:100%; border-collapse:collapse; font-size:12px; margin-bottom:14px; }
.cb-table th { background:#f5f5f5; border:1px solid #e0e0e0; padding:8px 10px;
               text-align:left; font-size:10px; text-transform:uppercase; color:#666;
               letter-spacing:.4px; position:sticky; top:0; }
.cb-table td { border:1px solid #eee; padding:7px 10px; }
.cb-table tr:hover td { background:#f9fbff; }
.cb-table .cb-dr  { color:#c62828; font-family:Consolas,monospace; text-align:right; }
.cb-table .cb-cr  { color:#2e7d32; font-family:Consolas,monospace; text-align:right; }
.cb-table .cb-bal { font-family:Consolas,monospace; text-align:right; font-weight:600; }

/* Summary row */
.cb-table tr.cb-totals td { background:#f5f5f5; font-weight:700; border-top:2px solid #ccc; }

/* Footer */
.cb-footer   { display:flex; justify-content:space-between; align-items:center; font-size:11px; color:#888; }

/* Print btn */
.fs-btn--print { background:transparent; border:1px solid #ccc; color:#555; }
.fs-btn--print:hover { background:#f5f5f5; }
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ── Page header ──────────────────────────────────────────── -->
<div class="fm-page-header" style="background:linear-gradient(135deg,#1a237e 0%,#283593 100%);
     color:#fff; padding:18px 24px; border-radius:8px 8px 0 0; margin:-10px -10px 18px -10px;">
    <div style="display:flex; justify-content:space-between; align-items:center;">
        <div>
            <h2 style="margin:0 0 2px; font-size:18px; font-weight:600;">Cash Book</h2>
            <span style="font-size:11px; opacity:.8;">Bank &amp; cash account transaction register</span>
        </div>
        <asp:Literal ID="litPeriodBadge" runat="server" />
    </div>
</div>

<!-- ── Tab navigation ───────────────────────────────────────── -->
<div class="fm-tabs" style="display:flex;gap:0;border-bottom:2px solid #e0e0e0;margin-bottom:18px;overflow-x:auto;">
    <a href="FinanceDashboard.aspx" class="fm-tab">Dashboard</a>
    <a href="GeneralLedger.aspx" class="fm-tab">General Ledger</a>
    <a href="JournalEntries.aspx" class="fm-tab">Journals</a>
    <a href="PaymentVouchers.aspx" class="fm-tab">Payment Vouchers</a>
    <a href="ContraVouchers.aspx" class="fm-tab">Contra Vouchers</a>
    <a href="BudgetManager.aspx" class="fm-tab">Budget</a>
    <a href="CashBook.aspx" class="fm-tab fm-tab--active" style="color:#1a237e;border-bottom:2px solid #1a237e;font-weight:600;">Cash Book</a>
    <a href="BankReconciliation.aspx" class="fm-tab">Bank Reco</a>
    <a href="TrialBalance.aspx" class="fm-tab">Trial Balance</a>
    <a href="BalanceSheet.aspx" class="fm-tab">Balance Sheet</a>
    <a href="IncomeStatement.aspx" class="fm-tab">Income Statement</a>
    <a href="FinancialPeriods.aspx" class="fm-tab">Periods</a>
    <a href="FinanceAuditTrail.aspx" class="fm-tab">Audit Trail</a>
</div>

<!-- ── Message panel ────────────────────────────────────────── -->
<asp:Panel ID="pnlMsg" runat="server" Visible="false">
    <div class="cb-msg"><asp:Literal ID="litMsg" runat="server" /></div>
</asp:Panel>

<!-- ── KPI strip ────────────────────────────────────────────── -->
<div class="cb-kpi-row">
    <div class="cb-kpi">
        <div class="cb-kpi__label">Opening Balance</div>
        <div class="cb-kpi__value cb-kpi__value--bal"><asp:Literal ID="litOpening" runat="server" Text="0" /></div>
    </div>
    <div class="cb-kpi">
        <div class="cb-kpi__label">Total Debits</div>
        <div class="cb-kpi__value cb-kpi__value--dr"><asp:Literal ID="litTotalDR" runat="server" Text="0" /></div>
    </div>
    <div class="cb-kpi">
        <div class="cb-kpi__label">Total Credits</div>
        <div class="cb-kpi__value cb-kpi__value--cr"><asp:Literal ID="litTotalCR" runat="server" Text="0" /></div>
    </div>
    <div class="cb-kpi">
        <div class="cb-kpi__label">Closing Balance</div>
        <div class="cb-kpi__value cb-kpi__value--bal"><asp:Literal ID="litClosing" runat="server" Text="0" /></div>
    </div>
</div>

<!-- ── Toolbar ──────────────────────────────────────────────── -->
<div class="cb-toolbar">
    <div>
        <label>Bank / Cash Account</label>
        <asp:DropDownList ID="ddlAccount" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlAccount_Changed" />
    </div>
    <div>
        <label>Start Date</label>
        <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
    </div>
    <div>
        <label>End Date</label>
        <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
    </div>
    <div style="padding-top:14px;">
        <asp:Button ID="btnLoad" runat="server" Text="Load" OnClick="btnLoad_Click"
            CssClass="fs-btn fs-btn--primary" style="height:32px;" />
    </div>
    <div style="padding-top:14px;">
        <asp:Button ID="btnExport" runat="server" Text="&#x2B07; Export CSV" OnClick="btnExport_Click"
            CssClass="fs-btn fs-btn--print" style="height:32px;" />
    </div>
    <div style="padding-top:14px;">
        <asp:Button ID="btnPrint" runat="server" Text="&#x1F5A8; Print" OnClientClick="window.print(); return false;"
            CssClass="fs-btn fs-btn--print" style="height:32px;" />
    </div>
</div>

<!-- ── Ledger table ─────────────────────────────────────────── -->
<div style="overflow-x:auto; max-height:600px; overflow-y:auto; border:1px solid #e0e0e0; border-radius:6px;">
<table class="cb-table">
    <thead>
        <tr>
            <th style="width:30px;">#</th>
            <th style="width:85px;">Date</th>
            <th style="width:80px;">Voucher No</th>
            <th>Particulars</th>
            <th style="width:100px;">Folio</th>
            <th style="width:110px; text-align:right;">Debit (DR)</th>
            <th style="width:110px; text-align:right;">Credit (CR)</th>
            <th style="width:120px; text-align:right;">Balance</th>
        </tr>
    </thead>
    <tbody>
        <asp:Repeater ID="rptLedger" runat="server">
            <ItemTemplate>
                <tr>
                    <td style="color:#999;"><%# Container.ItemIndex + 1 %></td>
                    <td><%# Eval("transactionDate","{0:dd/MM/yyyy}") %></td>
                    <td><%# Eval("voucherNo") %></td>
                    <td><%# Eval("particulars") %></td>
                    <td style="font-size:10px; color:#777;"><%# Eval("folio") %></td>
                    <td class="cb-dr"><%# FormatDR(Eval("transactionType"), Eval("transaction_amount")) %></td>
                    <td class="cb-cr"><%# FormatCR(Eval("transactionType"), Eval("transaction_amount")) %></td>
                    <td class="cb-bal"><%# Eval("running_balance") %></td>
                </tr>
            </ItemTemplate>
        </asp:Repeater>
    </tbody>
    <tfoot>
        <tr class="cb-totals">
            <td colspan="5" style="text-align:right;">Totals</td>
            <td class="cb-dr"><asp:Literal ID="litFootDR" runat="server" /></td>
            <td class="cb-cr"><asp:Literal ID="litFootCR" runat="server" /></td>
            <td class="cb-bal"><asp:Literal ID="litFootBal" runat="server" /></td>
        </tr>
    </tfoot>
</table>
</div>

<!-- ── Footer ───────────────────────────────────────────────── -->
<div class="cb-footer" style="margin-top:10px;">
    <asp:Literal ID="litFooter" runat="server" />
    <span style="font-size:10px;">Campus Dynamics &bull; Cash Book</span>
</div>

</asp:Content>
