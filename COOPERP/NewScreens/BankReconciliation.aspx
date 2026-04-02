<%@ Page Language="C#" MasterPageFile="~/COOPERP/SidebarMaster.master" AutoEventWireup="true"
    CodeFile="BankReconciliation.aspx.cs" Inherits="COOPERP_NewScreens_BankReconciliation" Title="Bank Reconciliation" %>

<asp:Content ID="Head" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ── Bank Reconciliation styles ────────────────────────────── */
.br-msg      { padding:10px 14px; border-radius:4px; margin-bottom:14px; font-size:12px; }
.br-msg-ok   { background:#e8f5e9; color:#2e7d32; border:1px solid #a5d6a7; }
.br-msg-err  { background:#fbe9e7; color:#c62828; border:1px solid #ef9a9a; }

/* KPI strip */
.br-kpi-row  { display:flex; gap:14px; margin-bottom:18px; flex-wrap:wrap; }
.br-kpi      { flex:1; min-width:140px; background:#fff; border:1px solid #e0e0e0;
               border-radius:6px; padding:12px 16px; }
.br-kpi__label { font-size:10px; text-transform:uppercase; letter-spacing:.5px; color:#888; margin-bottom:3px; }
.br-kpi__value { font-size:18px; font-weight:700; font-family:Consolas,monospace; color:#333; }
.br-kpi__value--ok  { color:#2e7d32; }
.br-kpi__value--pend { color:#e65100; }

/* Toolbar */
.br-toolbar { display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap; margin-bottom:16px;
              background:#fafafa; padding:14px 16px; border-radius:6px; border:1px solid #eee; }
.br-toolbar label { display:block; font-size:10px; text-transform:uppercase; color:#888;
                    margin-bottom:3px; letter-spacing:.4px; }
.br-toolbar select,
.br-toolbar input[type=text] {
    border:1px solid #ccc; border-radius:4px; padding:6px 10px; font-size:12px;
    height:32px; min-width:120px;
}

/* Two-panel layout */
.br-panels   { display:flex; gap:16px; margin-bottom:18px; flex-wrap:wrap; }
.br-panel    { flex:1; min-width:400px; border:1px solid #e0e0e0; border-radius:6px; overflow:hidden; }
.br-panel__hdr { background:#f5f5f5; padding:10px 14px; font-size:12px; font-weight:600;
                 display:flex; justify-content:space-between; align-items:center;
                 border-bottom:1px solid #e0e0e0; }
.br-panel__count { font-size:10px; color:#888; font-weight:400; }
.br-panel__body { max-height:450px; overflow-y:auto; }

/* Table shared */
.br-tbl      { width:100%; border-collapse:collapse; font-size:11px; }
.br-tbl th   { background:#fafafa; border-bottom:1px solid #e0e0e0; padding:6px 8px;
               text-align:left; font-size:9px; text-transform:uppercase; color:#888;
               letter-spacing:.3px; position:sticky; top:0; }
.br-tbl td   { border-bottom:1px solid #f0f0f0; padding:5px 8px; }
.br-tbl tr:hover td { background:#f9fbff; }
.br-tbl .amt { font-family:Consolas,monospace; text-align:right; }
.br-tbl .matched   { background:#e8f5e9; }
.br-tbl .unmatched { }
.br-tbl .sel-radio { width:16px; height:16px; cursor:pointer; }

/* Action bar */
.br-actions  { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:18px; padding:12px 16px;
               background:#fff; border:1px solid #e0e0e0; border-radius:6px; }

/* Summary section */
.br-summary  { border:1px solid #e0e0e0; border-radius:6px; margin-bottom:18px; overflow:hidden; }
.br-summary__hdr { background:#f5f5f5; padding:10px 14px; font-size:12px; font-weight:600;
                   border-bottom:1px solid #e0e0e0; }
.br-summary__body { padding:16px; }
.br-summary-tbl { width:100%; border-collapse:collapse; font-size:12px; }
.br-summary-tbl td { padding:6px 10px; border-bottom:1px solid #f0f0f0; }
.br-summary-tbl .lbl { color:#666; width:60%; }
.br-summary-tbl .val { font-family:Consolas,monospace; text-align:right; font-weight:600; }

/* Footer */
.br-footer   { display:flex; justify-content:space-between; align-items:center; font-size:11px; color:#888; }

/* New statement form */
.br-newstmt  { background:#f9f9f9; border:1px solid #e0e0e0; border-radius:6px; padding:16px;
               margin-bottom:16px; }
.br-newstmt label { font-size:10px; text-transform:uppercase; color:#888; letter-spacing:.4px;
                    display:block; margin-bottom:3px; }
.br-newstmt input, .br-newstmt select { border:1px solid #ccc; border-radius:4px;
    padding:6px 10px; font-size:12px; height:32px; }
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ── Page header ──────────────────────────────────────────── -->
<div class="fm-page-header" style="background:linear-gradient(135deg,#1a237e 0%,#283593 100%);
     color:#fff; padding:18px 24px; border-radius:8px 8px 0 0; margin:-10px -10px 18px -10px;">
    <div style="display:flex; justify-content:space-between; align-items:center;">
        <div>
            <h2 style="margin:0 0 2px; font-size:18px; font-weight:600;">Bank Reconciliation</h2>
            <span style="font-size:11px; opacity:.8;">Match bank statement entries with ledger transactions</span>
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
    <a href="CashBook.aspx" class="fm-tab">Cash Book</a>
    <a href="BankReconciliation.aspx" class="fm-tab fm-tab--active" style="color:#1a237e;border-bottom:2px solid #1a237e;font-weight:600;">Bank Reco</a>
    <a href="TrialBalance.aspx" class="fm-tab">Trial Balance</a>
    <a href="BalanceSheet.aspx" class="fm-tab">Balance Sheet</a>
    <a href="IncomeStatement.aspx" class="fm-tab">Income Statement</a>
    <a href="FinancialPeriods.aspx" class="fm-tab">Periods</a>
    <a href="FinanceAuditTrail.aspx" class="fm-tab">Audit Trail</a>
</div>

<!-- ── Message panel ────────────────────────────────────────── -->
<asp:Panel ID="pnlMsg" runat="server" Visible="false">
    <div class="br-msg"><asp:Literal ID="litMsg" runat="server" /></div>
</asp:Panel>

<!-- ── Toolbar: Bank + Statement selection ──────────────────── -->
<div class="br-toolbar">
    <div>
        <label>Bank Account</label>
        <asp:DropDownList ID="ddlBank" runat="server" AutoPostBack="true"
            OnSelectedIndexChanged="ddlBank_Changed" style="min-width:220px;" />
    </div>
    <div>
        <label>Reconciliation Statement</label>
        <asp:DropDownList ID="ddlStatement" runat="server" AutoPostBack="true"
            OnSelectedIndexChanged="ddlStatement_Changed" style="min-width:260px;" />
    </div>
    <div>
        <label>Date Range</label>
        <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" style="width:130px;" />
    </div>
    <div>
        <label>&nbsp;</label>
        <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" style="width:130px;" />
    </div>
    <div>
        <label>Filter</label>
        <asp:DropDownList ID="ddlFilter" runat="server" AutoPostBack="true"
            OnSelectedIndexChanged="ddlFilter_Changed">
            <asp:ListItem Value="ALL" Text="All Entries" />
            <asp:ListItem Value="Pending" Text="Unmatched Only" />
            <asp:ListItem Value="Matched" Text="Matched Only" />
        </asp:DropDownList>
    </div>
    <div style="padding-top:14px;">
        <asp:Button ID="btnRefresh" runat="server" Text="&#x21BB; Refresh" OnClick="btnRefresh_Click"
            CssClass="fs-btn fs-btn--primary" style="height:32px;" />
    </div>
</div>

<!-- ── KPI strip ────────────────────────────────────────────── -->
<div class="br-kpi-row">
    <div class="br-kpi">
        <div class="br-kpi__label">Statement Balance</div>
        <div class="br-kpi__value"><asp:Literal ID="litStmtBal" runat="server" Text="--" /></div>
    </div>
    <div class="br-kpi">
        <div class="br-kpi__label">Ledger Balance</div>
        <div class="br-kpi__value"><asp:Literal ID="litLedgerBal" runat="server" Text="--" /></div>
    </div>
    <div class="br-kpi">
        <div class="br-kpi__label">Matched Items</div>
        <div class="br-kpi__value br-kpi__value--ok"><asp:Literal ID="litMatched" runat="server" Text="0" /></div>
    </div>
    <div class="br-kpi">
        <div class="br-kpi__label">Unmatched Items</div>
        <div class="br-kpi__value br-kpi__value--pend"><asp:Literal ID="litUnmatched" runat="server" Text="0" /></div>
    </div>
</div>

<!-- ── Action buttons ───────────────────────────────────────── -->
<div class="br-actions">
    <asp:Button ID="btnNewStatement" runat="server" Text="+ New Statement" OnClick="btnNewStatement_Click"
        CssClass="fs-btn fs-btn--primary" style="height:30px; font-size:11px;" />
    <asp:Button ID="btnAutoReco" runat="server" Text="&#x26A1; Auto Reconcile" OnClick="btnAutoReco_Click"
        CssClass="fs-btn" style="height:30px; font-size:11px; background:#1565c0; color:#fff; border:none; border-radius:4px;" />
    <asp:Button ID="btnManualMatch" runat="server" Text="&#x1F517; Manual Match" OnClick="btnManualMatch_Click"
        CssClass="fs-btn" style="height:30px; font-size:11px; background:#2e7d32; color:#fff; border:none; border-radius:4px;" />
    <asp:Button ID="btnUnmatch" runat="server" Text="&#x2716; Unmatch Selected" OnClick="btnUnmatch_Click"
        CssClass="fs-btn" style="height:30px; font-size:11px; background:#e65100; color:#fff; border:none; border-radius:4px;" />
    <asp:Button ID="btnViewSummary" runat="server" Text="&#x1F4CB; Reco Summary" OnClick="btnViewSummary_Click"
        CssClass="fs-btn" style="height:30px; font-size:11px; background:#6a1b9a; color:#fff; border:none; border-radius:4px;" />
    <asp:Button ID="btnPrint" runat="server" Text="&#x1F5A8; Print" OnClientClick="window.print(); return false;"
        CssClass="fs-btn" style="height:30px; font-size:11px; background:transparent; color:#555; border:1px solid #ccc; border-radius:4px;" />

    <!-- Hidden fields for selected IDs -->
    <asp:HiddenField ID="hdnSelectedBank" runat="server" />
    <asp:HiddenField ID="hdnSelectedLedger" runat="server" />
</div>

<!-- ── Two-panel layout ─────────────────────────────────────── -->
<div class="br-panels">

    <!-- LEFT: Bank Statement Entries -->
    <div class="br-panel">
        <div class="br-panel__hdr">
            Bank Statement Entries
            <span class="br-panel__count"><asp:Literal ID="litBankCount" runat="server" Text="0 entries" /></span>
        </div>
        <div class="br-panel__body">
            <table class="br-tbl">
                <thead>
                    <tr>
                        <th style="width:20px;"></th>
                        <th>Date</th>
                        <th>Track No</th>
                        <th>Details</th>
                        <th>Type</th>
                        <th style="text-align:right;">Amount</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptBankEntries" runat="server">
                        <ItemTemplate>
                            <tr class='<%# Convert.ToInt32(Eval("match_TID")) != 0 ? "matched" : "unmatched" %>'>
                                <td><input type="radio" name="bankEntry" value='<%# Eval("ID") %>'
                                    class="sel-radio" onclick="document.getElementById('<%# hdnSelectedBank.ClientID %>').value=this.value;" /></td>
                                <td><%# Eval("trans_date") %></td>
                                <td><%# Eval("track_no") %></td>
                                <td style="max-width:180px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                                    title='<%# Eval("details") %>'><%# Eval("details") %></td>
                                <td><%# Eval("trans_typ") %></td>
                                <td class="amt"><%# FormatAmount(Eval("amount")) %></td>
                                <td><%# GetMatchBadge(Eval("match_TID")) %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <!-- RIGHT: Ledger Entries -->
    <div class="br-panel">
        <div class="br-panel__hdr">
            Ledger Entries
            <span class="br-panel__count"><asp:Literal ID="litLedgerCount" runat="server" Text="0 entries" /></span>
        </div>
        <div class="br-panel__body">
            <table class="br-tbl">
                <thead>
                    <tr>
                        <th style="width:20px;"></th>
                        <th>Date</th>
                        <th>Voucher</th>
                        <th>Particulars</th>
                        <th style="text-align:right;">DR</th>
                        <th style="text-align:right;">CR</th>
                        <th>TID</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptLedger" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><input type="radio" name="ledgerEntry" value='<%# Eval("TID") %>'
                                    class="sel-radio" onclick="document.getElementById('<%# hdnSelectedLedger.ClientID %>').value=this.value;" /></td>
                                <td><%# Eval("transactionDate","{0:dd/MM/yyyy}") %></td>
                                <td><%# Eval("voucherNo") %></td>
                                <td style="max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                                    title='<%# Eval("particulars") %>'><%# Eval("particulars") %></td>
                                <td class="amt"><%# FormatDR(Eval("transactionType"), Eval("transaction_amount")) %></td>
                                <td class="amt"><%# FormatCR(Eval("transactionType"), Eval("transaction_amount")) %></td>
                                <td style="font-size:10px; color:#999;"><%# Eval("TID") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- ── Reconciliation Summary (toggled) ─────────────────────── -->
<asp:Panel ID="pnlSummary" runat="server" Visible="false">
    <div class="br-summary">
        <div class="br-summary__hdr">Reconciliation Summary</div>
        <div class="br-summary__body">
            <asp:Repeater ID="rptSummary" runat="server">
                <HeaderTemplate>
                    <table class="br-summary-tbl">
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="lbl"><%# Eval("adj_account") %></td>
                        <td style="font-size:10px; color:#888;"><%# Eval("trans_type") %></td>
                        <td class="val"><%# FormatAmount(Eval("amount")) %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>
</asp:Panel>

<!-- ── New Statement Form (toggled) ─────────────────────────── -->
<asp:Panel ID="pnlNewStatement" runat="server" Visible="false">
    <div class="br-newstmt">
        <h4 style="margin:0 0 12px; font-size:14px;">Create New Reconciliation Statement</h4>
        <div style="display:flex; gap:14px; align-items:flex-end; flex-wrap:wrap;">
            <div>
                <label>Statement Date</label>
                <asp:TextBox ID="txtStmtDate" runat="server" TextMode="Date" />
            </div>
            <div>
                <label>Statement Balance</label>
                <asp:TextBox ID="txtStmtBalance" runat="server" placeholder="0" style="width:150px;" />
            </div>
            <div>
                <label>Title (optional)</label>
                <asp:TextBox ID="txtStmtTitle" runat="server" style="width:280px;" />
            </div>
            <div style="padding-top:14px;">
                <asp:Button ID="btnCreateStatement" runat="server" Text="Create" OnClick="btnCreateStatement_Click"
                    CssClass="fs-btn fs-btn--primary" style="height:32px;" />
                <asp:Button ID="btnCancelNew" runat="server" Text="Cancel" OnClick="btnCancelNew_Click"
                    CssClass="fs-btn" style="height:32px; background:transparent; border:1px solid #ccc; color:#555;" />
            </div>
        </div>
    </div>
</asp:Panel>

<!-- ── Footer ───────────────────────────────────────────────── -->
<div class="br-footer" style="margin-top:10px;">
    <asp:Literal ID="litFooter" runat="server" />
    <span style="font-size:10px;">Campus Dynamics &bull; Bank Reconciliation</span>
</div>

</asp:Content>
