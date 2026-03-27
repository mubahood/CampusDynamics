<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="PaymentVouchers.aspx.cs" Inherits="COOPERP_NewScreens_PaymentVouchers" Title="Payment Vouchers - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .pv-filter-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .pv-fg { display: flex; flex-direction: column; gap: 4px; }
        .pv-fg label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .pv-fg input, .pv-fg select { padding: 5px 8px; border: 1px solid #ccc; font-size: 12px; }
        .pv-btn { padding: 6px 14px; font-size: 11px; font-weight: 600; border: 1px solid #1976d2; color: #fff; background: #1976d2; cursor: pointer; }
        .pv-btn:hover { background: #1565c0; }
        .pv-btn--success { background: #388e3c; border-color: #388e3c; }
        .pv-btn--success:hover { background: #2e7d32; }
        .pv-btn--outline { background: #fff; color: #1976d2; }
        .pv-btn--outline:hover { background: #e3f2fd; }

        .pv-section { background: #fff; border: 1px solid #e0e0e0; margin-bottom: 16px; }
        .pv-section__header { padding: 10px 16px; border-bottom: 1px solid #e0e0e0; font-size: 13px; font-weight: 600; color: #333; display: flex; align-items: center; gap: 8px; }
        .pv-section__header svg { width: 16px; height: 16px; color: #666; }

        .pv-create-form { background: #f8f9fa; border: 1px solid #e0e0e0; padding: 14px 16px; margin-bottom: 16px; }
        .pv-create-form__row { display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap; margin-bottom: 10px; }
        
        .pv-msg { padding: 8px 14px; margin-bottom: 10px; font-size: 12px; border-left: 3px solid; }
        .pv-msg--success { border-color: #388e3c; background: #e8f5e9; color: #2e7d32; }
        .pv-msg--error { border-color: #d32f2f; background: #ffebee; color: #c62828; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:Label ID="lblMessage" runat="server" />

    <!-- Filter -->
    <div class="pv-filter-bar">
        <div class="pv-fg">
            <label>Start Date</label>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
        </div>
        <div class="pv-fg">
            <label>End Date</label>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
        </div>
        <div class="pv-fg">
            <label>Voucher Type</label>
            <asp:DropDownList ID="ddlVoucherType" runat="server">
                <asp:ListItem Text="All" Value="" />
                <asp:ListItem Text="Payment" Value="Payment" />
                <asp:ListItem Text="Receipt" Value="Receipt" />
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="pv-btn" OnClick="btnFilter_Click" />
        <asp:Button ID="btnNewVoucher" runat="server" Text="+ New Payment Voucher" CssClass="pv-btn pv-btn--success" OnClick="btnNewVoucher_Click" />
    </div>

    <!-- Create Voucher Form -->
    <asp:Panel ID="pnlCreate" runat="server" Visible="false">
        <div class="pv-create-form">
            <div style="font-size:13px;font-weight:600;color:#333;margin-bottom:10px;">Create Payment Voucher</div>
            <div class="pv-create-form__row">
                <div class="pv-fg">
                    <label>Debit Account (Expense/Asset)</label>
                    <dx:ASPxComboBox ID="cboDRAccount" runat="server" Width="280" IncrementalFilteringMode="Contains"
                        TextFormatString="{0} - {1}" ValueField="AccountCode" ClientInstanceName="cboDRAccount">
                        <Columns>
                            <dx:ListBoxColumn FieldName="AccountCode" Caption="Code" Width="80" />
                            <dx:ListBoxColumn FieldName="AccountName" Caption="Name" Width="200" />
                        </Columns>
                    </dx:ASPxComboBox>
                </div>
                <div class="pv-fg">
                    <label>Credit Account (Bank/Cash)</label>
                    <dx:ASPxComboBox ID="cboCRAccount" runat="server" Width="280" IncrementalFilteringMode="Contains"
                        TextFormatString="{0} - {1}" ValueField="AccountCode" ClientInstanceName="cboCRAccount">
                        <Columns>
                            <dx:ListBoxColumn FieldName="AccountCode" Caption="Code" Width="80" />
                            <dx:ListBoxColumn FieldName="AccountName" Caption="Name" Width="200" />
                        </Columns>
                    </dx:ASPxComboBox>
                </div>
            </div>
            <div class="pv-create-form__row">
                <div class="pv-fg">
                    <label>Amount</label>
                    <asp:TextBox ID="txtAmount" runat="server" TextMode="Number" Width="150" />
                </div>
                <div class="pv-fg">
                    <label>DR Particulars</label>
                    <asp:TextBox ID="txtDRParticulars" runat="server" MaxLength="350" Width="200" />
                </div>
                <div class="pv-fg">
                    <label>CR Particulars</label>
                    <asp:TextBox ID="txtCRParticulars" runat="server" MaxLength="350" Width="200" />
                </div>
                <div class="pv-fg">
                    <label>Date</label>
                    <asp:TextBox ID="txtVoucherDate" runat="server" TextMode="Date" />
                </div>
            </div>
            <div style="margin-top:8px;display:flex;gap:8px;">
                <asp:Button ID="btnConfirmCreate" runat="server" Text="Create & Post Voucher" CssClass="pv-btn pv-btn--success" OnClick="btnConfirmCreate_Click" />
                <asp:Button ID="btnCancelCreate" runat="server" Text="Cancel" CssClass="pv-btn pv-btn--outline" OnClick="btnCancelCreate_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- Voucher Detail -->
    <asp:Panel ID="pnlDetail" runat="server" Visible="false">
        <div class="pv-section">
            <div class="pv-section__header">
                Voucher #<asp:Label ID="lblVoucherNo" runat="server" /> - 
                Status: <asp:Label ID="lblVoucherStatus" runat="server" />
            </div>
            <div style="padding:0;">
                <dx:ASPxGridView ID="gvVoucherTrans" runat="server" Width="100%" KeyFieldName="TID"
                    ClientInstanceName="gvVoucherTrans">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="accountcode" Caption="Account" Width="100" />
                        <dx:GridViewDataTextColumn FieldName="account_type" Caption="Type" Width="100" />
                        <dx:GridViewDataTextColumn FieldName="transactionType" Caption="DR/CR" Width="50" />
                        <dx:GridViewDataTextColumn FieldName="transaction_amount" Caption="Amount" Width="120">
                            <PropertiesTextEdit DisplayFormatString="N0" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="particulars" Caption="Particulars" />
                        <dx:GridViewDataDateColumn FieldName="transactionDate" Caption="Date" Width="90">
                            <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                        </dx:GridViewDataDateColumn>
                    </Columns>
                    <Styles>
                        <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                        <Row Font-Size="12px" />
                    </Styles>
                </dx:ASPxGridView>
            </div>
            <div style="padding:10px 16px;display:flex;gap:8px;">
                <asp:Button ID="btnApproveVoucher" runat="server" Text="Approve Voucher" CssClass="pv-btn pv-btn--success" OnClick="btnApproveVoucher_Click" />
                <asp:Button ID="btnCloseDetail" runat="server" Text="Close" CssClass="pv-btn pv-btn--outline" OnClick="btnCloseDetail_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- Vouchers List -->
    <div class="pv-section">
        <div class="pv-section__header">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
            Payment Vouchers
        </div>
        <dx:ASPxGridView ID="gvVouchers" runat="server" Width="100%" KeyFieldName="VoucherNo"
            ClientInstanceName="gvVouchers"
            SettingsBehavior-AllowFocusedRow="true"
            OnFocusedRowChanged="gvVouchers_FocusedRowChanged"
            SettingsPager-PageSize="20">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="VoucherNo" Caption="V.No" Width="70" />
                <dx:GridViewDataTextColumn FieldName="Vouchertype" Caption="Type" Width="80" />
                <dx:GridViewDataDateColumn FieldName="voucherDate" Caption="Date" Width="90">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn FieldName="Teller" Caption="Created By" Width="100" />
                <dx:GridViewDataTextColumn FieldName="PostStatus" Caption="Status" Width="80" />
            </Columns>
            <Settings ShowFilterRow="true" />
            <SettingsPager PageSize="20" />
            <Styles>
                <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                <Row Font-Size="12px" />
                <AlternatingRow BackColor="#fafbfc" />
                <FocusedRow BackColor="#e3f2fd" />
            </Styles>
        </dx:ASPxGridView>
    </div>
</asp:Content>
