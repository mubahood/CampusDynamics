<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="BalanceSheet.aspx.cs" Inherits="COOPERP_NewScreens_BalanceSheet" Title="Balance Sheet - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .bs-filter-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .bs-filter-group { display: flex; flex-direction: column; gap: 4px; }
        .bs-filter-group label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .bs-filter-group input { padding: 5px 8px; border: 1px solid #ccc; font-size: 12px; }
        .bs-btn {
            padding: 6px 16px; background: #1976d2; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .bs-btn:hover { background: #1565c0; }
        .bs-btn-print {
            padding: 6px 16px; background: #388e3c; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .bs-btn-print:hover { background: #2e7d32; }

        .bs-report-header {
            text-align: center; margin-bottom: 16px; padding: 14px;
            background: #fff; border: 1px solid #e0e0e0;
        }
        .bs-report-header h2 { margin: 0 0 4px 0; font-size: 18px; color: #333; }
        .bs-report-header .bs-doc-header { font-size: 14px; font-weight: 600; color: #1565c0; margin-bottom: 4px; }
        .bs-report-header p { margin: 0; font-size: 12px; color: #666; }

        .bs-section { margin-bottom: 20px; }
        .bs-section-header {
            background: #f5f5f5; border: 1px solid #e0e0e0; padding: 8px 16px;
            font-size: 14px; font-weight: 700; color: #333; margin-bottom: 0;
        }
        .bs-section-header.bs-assets-hdr { border-left: 4px solid #1976d2; }
        .bs-section-header.bs-liabilities-hdr { border-left: 4px solid #e65100; }
        .bs-section-header.bs-equity-hdr { border-left: 4px solid #388e3c; }

        .bs-table {
            width: 100%; border-collapse: collapse; background: #fff;
            border: 1px solid #e0e0e0; font-size: 13px;
        }
        .bs-table th {
            background: #fafafa; padding: 6px 12px; text-align: left;
            border-bottom: 2px solid #e0e0e0; font-weight: 600; color: #555;
            font-size: 11px; text-transform: uppercase;
        }
        .bs-table td { padding: 5px 12px; border-bottom: 1px solid #f0f0f0; }
        .bs-table td.bs-amount { text-align: right; font-family: 'Consolas', monospace; }
        .bs-table tr.bs-subtotal { background: #e8f5e9; font-weight: 700; }
        .bs-table tr.bs-subtotal td { border-top: 2px solid #a5d6a7; }

        .bs-equation-bar {
            background: #fff3e0; border: 2px solid #ffcc80; padding: 12px 16px; margin-top: 16px;
            text-align: center; font-size: 15px; font-weight: 700; color: #333;
        }
        .bs-equation-bar .bs-eq-val { color: #1565c0; }

        .bs-status-banner {
            padding: 10px 16px; margin-bottom: 12px; font-size: 14px; font-weight: 600;
            text-align: center; border-radius: 4px;
        }
        .bs-status-ok { background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; }
        .bs-status-err { background: #fce4ec; border: 1px solid #ef9a9a; color: #c62828; }

        @media print {
            .bs-filter-bar, .bs-btn, .bs-btn-print, .cd-sidebar, .cd-topbar { display: none !important; }
            .bs-report-header { border: none; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <!-- Filter Bar -->
    <div class="bs-filter-bar">
        <div class="bs-filter-group">
            <label>As at Date</label>
            <asp:TextBox ID="txtAsAtDate" runat="server" TextMode="Date" />
        </div>
        <asp:Button ID="btnGenerate" runat="server" Text="Generate" CssClass="bs-btn" OnClick="btnGenerate_Click" />
        <button type="button" class="bs-btn-print" onclick="window.print();">&#128424; Print</button>
    </div>

    <asp:Panel ID="pnlReport" runat="server" Visible="false">
        <div class="bs-report-header">
            <div class="bs-doc-header"><asp:Literal ID="litDocHeader" runat="server" /></div>
            <h2>Balance Sheet</h2>
            <p>
                As at: <asp:Literal ID="litAsAtDate" runat="server" />
                &nbsp;|&nbsp; Generated: <asp:Literal ID="litGenDate" runat="server" />
            </p>
        </div>

        <!-- Balance Status -->
        <asp:Panel ID="pnlBalanceStatus" runat="server" CssClass="bs-status-banner bs-status-ok">
            <asp:Literal ID="litBalanceStatus" runat="server" />
        </asp:Panel>

        <!-- Assets Section -->
        <div class="bs-section">
            <div class="bs-section-header bs-assets-hdr">Assets</div>
            <asp:Repeater ID="rptAssets" runat="server" OnItemDataBound="rptAssets_ItemDataBound">
                <HeaderTemplate>
                    <table class="bs-table">
                        <thead><tr><th>Code</th><th>Account Name</th><th style="text-align:right">Amount</th></tr></thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("accountcode") %></td>
                        <td><%# Eval("accountname") %></td>
                        <td class="bs-amount"><%# Eval("Amount", "{0:N2}") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr class="bs-subtotal">
                            <td colspan="2">Total Assets</td>
                            <td class="bs-amount"><asp:Literal ID="litTotalAssets" runat="server" /></td>
                        </tr>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <!-- Liabilities Section -->
        <div class="bs-section">
            <div class="bs-section-header bs-liabilities-hdr">Liabilities</div>
            <asp:Repeater ID="rptLiabilities" runat="server" OnItemDataBound="rptLiabilities_ItemDataBound">
                <HeaderTemplate>
                    <table class="bs-table">
                        <thead><tr><th>Code</th><th>Account Name</th><th style="text-align:right">Amount</th></tr></thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("accountcode") %></td>
                        <td><%# Eval("accountname") %></td>
                        <td class="bs-amount"><%# Eval("Amount", "{0:N2}") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr class="bs-subtotal">
                            <td colspan="2">Total Liabilities</td>
                            <td class="bs-amount"><asp:Literal ID="litTotalLiabilities" runat="server" /></td>
                        </tr>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <!-- Equity Section -->
        <div class="bs-section">
            <div class="bs-section-header bs-equity-hdr">Equity</div>
            <asp:Repeater ID="rptEquity" runat="server" OnItemDataBound="rptEquity_ItemDataBound">
                <HeaderTemplate>
                    <table class="bs-table">
                        <thead><tr><th>Code</th><th>Account Name</th><th style="text-align:right">Amount</th></tr></thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("accountcode") %></td>
                        <td><%# Eval("accountname") %></td>
                        <td class="bs-amount"><%# Eval("Amount", "{0:N2}") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr class="bs-subtotal">
                            <td colspan="2">Total Equity</td>
                            <td class="bs-amount"><asp:Literal ID="litTotalEquity" runat="server" /></td>
                        </tr>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <!-- Accounting Equation Bar -->
        <div class="bs-equation-bar">
            Assets (<span class="bs-eq-val"><asp:Literal ID="litEqAssets" runat="server" /></span>)
            = Liabilities (<span class="bs-eq-val"><asp:Literal ID="litEqLiabilities" runat="server" /></span>)
            + Equity (<span class="bs-eq-val"><asp:Literal ID="litEqEquity" runat="server" /></span>)
        </div>
    </asp:Panel>
</asp:Content>
