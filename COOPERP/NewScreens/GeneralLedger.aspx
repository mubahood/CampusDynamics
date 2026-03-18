<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="GeneralLedger.aspx.cs" Inherits="COOPERP_NewScreens_GeneralLedger" Title="General Ledger - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .gl-filter-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .gl-filter-group { display: flex; flex-direction: column; gap: 4px; }
        .gl-filter-group label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .gl-filter-group input, .gl-filter-group select {
            padding: 5px 8px; border: 1px solid #ccc; font-size: 12px;
        }
        .gl-btn {
            padding: 6px 14px; font-size: 11px; font-weight: 600;
            border: 1px solid #1976d2; color: #fff; background: #1976d2; cursor: pointer;
        }
        .gl-btn:hover { background: #1565c0; }
        .gl-section { background: #fff; border: 1px solid #e0e0e0; }
        .gl-section__header {
            padding: 10px 16px; border-bottom: 1px solid #e0e0e0;
            font-size: 13px; font-weight: 600; color: #333;
            display: flex; align-items: center; gap: 8px;
        }
        .gl-section__header svg { width: 16px; height: 16px; color: #666; }
        .gl-summary {
            display: flex; gap: 20px; padding: 10px 16px; background: #f8f9fa;
            border-bottom: 1px solid #e0e0e0; font-size: 12px;
        }
        .gl-summary__item { display: flex; gap: 4px; }
        .gl-summary__item strong { color: #333; }
        .gl-summary__item span { color: #666; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <!-- Filter Bar -->
    <div class="gl-filter-bar">
        <div class="gl-filter-group">
            <label>Start Date</label>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
        </div>
        <div class="gl-filter-group">
            <label>End Date</label>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
        </div>
        <div class="gl-filter-group">
            <label>Account</label>
            <dx:ASPxComboBox ID="cboAccount" runat="server" Width="250" 
                IncrementalFilteringMode="Contains" 
                TextFormatString="{0} - {1}"
                ValueField="AccountCode" 
                ClientInstanceName="cboAccount">
                <Columns>
                    <dx:ListBoxColumn FieldName="AccountCode" Caption="Code" Width="80" />
                    <dx:ListBoxColumn FieldName="AccountName" Caption="Name" Width="200" />
                </Columns>
            </dx:ASPxComboBox>
        </div>
        <div class="gl-filter-group">
            <label>Type</label>
            <asp:DropDownList ID="ddlType" runat="server">
                <asp:ListItem Text="All Types" Value="" />
                <asp:ListItem Text="DR - Debit" Value="DR" />
                <asp:ListItem Text="CR - Credit" Value="CR" />
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnFilter" runat="server" Text="Load Ledger" CssClass="gl-btn" OnClick="btnFilter_Click" />
    </div>

    <!-- Ledger Grid -->
    <div class="gl-section">
        <div class="gl-section__header">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
            General Ledger
            <asp:Label ID="lblLedgerTitle" runat="server" style="font-weight:400;color:#888;font-size:11px;margin-left:8px;" />
        </div>
        <div class="gl-summary">
            <div class="gl-summary__item"><span>Total DR:</span> <strong><asp:Label ID="lblSumDR" runat="server" Text="0" /></strong></div>
            <div class="gl-summary__item"><span>Total CR:</span> <strong><asp:Label ID="lblSumCR" runat="server" Text="0" /></strong></div>
            <div class="gl-summary__item"><span>Records:</span> <strong><asp:Label ID="lblRecordCount" runat="server" Text="0" /></strong></div>
        </div>
        <dx:ASPxGridView ID="gvLedger" runat="server" Width="100%" KeyFieldName="TID"
            ClientInstanceName="gvLedger"
            SettingsPager-PageSize="30">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="TID" Caption="ID" Width="60" />
                <dx:GridViewDataDateColumn FieldName="transactionDate" Caption="Date" Width="90">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn FieldName="accountcode" Caption="Account" Width="100" />
                <dx:GridViewDataTextColumn FieldName="account_type" Caption="Acc Type" Width="90" />
                <dx:GridViewDataTextColumn FieldName="particulars" Caption="Particulars" />
                <dx:GridViewDataTextColumn FieldName="transactionType" Caption="DR/CR" Width="50" />
                <dx:GridViewDataTextColumn FieldName="transaction_amount" Caption="Amount" Width="100">
                    <PropertiesTextEdit DisplayFormatString="N0" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="voucherNo" Caption="Voucher" Width="70" />
                <dx:GridViewDataTextColumn FieldName="teller" Caption="User" Width="90" />
            </Columns>
            <Settings ShowFilterRow="true" />
            <SettingsPager PageSize="30" />
            <TotalSummary>
                <dx:ASPxSummaryItem FieldName="transaction_amount" SummaryType="Sum" DisplayFormat="N0" />
            </TotalSummary>
            <Settings ShowFooter="true" />
            <Styles>
                <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                <Row Font-Size="12px" />
                <AlternatingRow BackColor="#fafbfc" />
                <FocusedRow BackColor="#e3f2fd" />
                <Footer BackColor="#f0f0f0" Font-Bold="true" Font-Size="11px" />
            </Styles>
        </dx:ASPxGridView>
    </div>
</asp:Content>
