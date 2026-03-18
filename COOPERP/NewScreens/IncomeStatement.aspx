<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="IncomeStatement.aspx.cs" Inherits="COOPERP_NewScreens_IncomeStatement" Title="Income Statement - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .is-filter-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .is-filter-group { display: flex; flex-direction: column; gap: 4px; }
        .is-filter-group label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .is-filter-group input {
            padding: 5px 8px; border: 1px solid #ccc; font-size: 12px;
        }
        .is-btn {
            padding: 6px 16px; background: #1976d2; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .is-btn:hover { background: #1565c0; }
        .is-btn-print {
            padding: 6px 16px; background: #388e3c; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .is-btn-print:hover { background: #2e7d32; }

        .is-report-header {
            text-align: center; margin-bottom: 16px; padding: 14px;
            background: #fff; border: 1px solid #e0e0e0;
        }
        .is-report-header h2 { margin: 0 0 4px 0; font-size: 18px; color: #333; }
        .is-report-header .is-doc-header { font-size: 14px; font-weight: 600; color: #1565c0; margin-bottom: 4px; }
        .is-report-header p { margin: 0; font-size: 12px; color: #666; }

        .is-section { margin-bottom: 20px; }
        .is-section-header {
            background: #f5f5f5; border: 1px solid #e0e0e0; padding: 8px 16px;
            font-size: 14px; font-weight: 700; color: #333; margin-bottom: 0;
        }

        .is-table {
            width: 100%; border-collapse: collapse; background: #fff;
            border: 1px solid #e0e0e0; font-size: 13px;
        }
        .is-table th {
            background: #fafafa; padding: 6px 12px; text-align: left;
            border-bottom: 2px solid #e0e0e0; font-weight: 600; color: #555; font-size: 11px;
            text-transform: uppercase;
        }
        .is-table td { padding: 5px 12px; border-bottom: 1px solid #f0f0f0; }
        .is-table td.is-amount { text-align: right; font-family: 'Consolas', monospace; }
        .is-table tr.is-subtotal { background: #e8f5e9; font-weight: 700; }
        .is-table tr.is-subtotal td { border-top: 2px solid #a5d6a7; }
        .is-table tr.is-net-income { background: #e3f2fd; font-weight: 700; font-size: 14px; }
        .is-table tr.is-net-income td { border-top: 2px solid #64b5f6; padding: 8px 12px; }
        .is-net-positive { color: #2e7d32; }
        .is-net-negative { color: #c62828; }

        .is-summary-bar {
            background: #e3f2fd; border: 1px solid #90caf9; padding: 10px 16px; margin-top: 12px;
            display: flex; gap: 24px; flex-wrap: wrap; font-size: 13px;
        }
        .is-summary-item { display: flex; gap: 6px; align-items: center; }
        .is-summary-label { font-weight: 600; color: #555; }
        .is-summary-value { font-weight: 700; color: #1565c0; }

        @media print {
            .is-filter-bar, .is-btn, .is-btn-print, .cd-sidebar, .cd-topbar { display: none !important; }
            .is-report-header { border: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <!-- Filter Bar -->
    <div class="is-filter-bar">
        <div class="is-filter-group">
            <label>Start Date</label>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
        </div>
        <div class="is-filter-group">
            <label>End Date</label>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
        </div>
        <asp:Button ID="btnGenerate" runat="server" Text="Generate" CssClass="is-btn" OnClick="btnGenerate_Click" />
        <button type="button" class="is-btn-print" onclick="window.print();">&#128424; Print</button>
    </div>

    <!-- Report Content -->
    <asp:Panel ID="pnlReport" runat="server" Visible="false">
        <div class="is-report-header">
            <div class="is-doc-header"><asp:Literal ID="litDocHeader" runat="server" /></div>
            <h2>Income Statement</h2>
            <p>
                Period: <asp:Literal ID="litPeriodStart" runat="server" /> to <asp:Literal ID="litPeriodEnd" runat="server" />
                &nbsp;|&nbsp; Generated: <asp:Literal ID="litGenDate" runat="server" />
            </p>
        </div>

        <!-- Income Section -->
        <div class="is-section">
            <div class="is-section-header">Revenue / Income</div>
            <asp:Repeater ID="rptIncome" runat="server" OnItemDataBound="rptIncome_ItemDataBound">
                <HeaderTemplate>
                    <table class="is-table">
                        <thead><tr><th>Code</th><th>Account Name</th><th style="text-align:right">Amount</th></tr></thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("accountcode") %></td>
                        <td><%# Eval("accountname") %></td>
                        <td class="is-amount"><%# Eval("Amount", "{0:N2}") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr class="is-subtotal">
                            <td colspan="2">Total Income</td>
                            <td class="is-amount"><asp:Literal ID="litTotalIncome" runat="server" /></td>
                        </tr>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <!-- Expense Section -->
        <div class="is-section">
            <div class="is-section-header">Expenses</div>
            <asp:Repeater ID="rptExpense" runat="server" OnItemDataBound="rptExpense_ItemDataBound">
                <HeaderTemplate>
                    <table class="is-table">
                        <thead><tr><th>Code</th><th>Account Name</th><th style="text-align:right">Amount</th></tr></thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("accountcode") %></td>
                        <td><%# Eval("accountname") %></td>
                        <td class="is-amount"><%# Eval("Amount", "{0:N2}") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr class="is-subtotal">
                            <td colspan="2">Total Expenses</td>
                            <td class="is-amount"><asp:Literal ID="litTotalExpense" runat="server" /></td>
                        </tr>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <!-- Net Income -->
        <table class="is-table">
            <tr class="is-net-income">
                <td colspan="2">Net Income (Loss)</td>
                <td class="is-amount"><asp:Literal ID="litNetIncome" runat="server" /></td>
            </tr>
        </table>

        <!-- Summary Bar -->
        <div class="is-summary-bar">
            <div class="is-summary-item">
                <span class="is-summary-label">Total Income:</span>
                <span class="is-summary-value"><asp:Literal ID="litSumIncome" runat="server" /></span>
            </div>
            <div class="is-summary-item">
                <span class="is-summary-label">Total Expenses:</span>
                <span class="is-summary-value"><asp:Literal ID="litSumExpense" runat="server" /></span>
            </div>
            <div class="is-summary-item">
                <span class="is-summary-label">Net Result:</span>
                <span id="spanNetResult" runat="server" class="is-summary-value"><asp:Literal ID="litSumNet" runat="server" /></span>
            </div>
        </div>
    </asp:Panel>
</asp:Content>
