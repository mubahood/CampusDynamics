<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="ChartOfAccounts.aspx.cs" Inherits="COOPERP_NewScreens_ChartOfAccounts" Title="Chart of Accounts - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .coa-section { background: #fff; border: 1px solid #e0e0e0; margin-bottom: 16px; }
        .coa-section__header {
            padding: 12px 16px; border-bottom: 1px solid #e0e0e0;
            font-size: 13px; font-weight: 600; color: #333;
            display: flex; align-items: center; justify-content: space-between;
        }
        .coa-section__header-left { display: flex; align-items: center; gap: 8px; }
        .coa-section__header svg { width: 16px; height: 16px; color: #666; }
        .coa-label { font-size: 12px; color: #666; margin-bottom: 6px; }
        .coa-info { font-size: 11px; color: #888; padding: 6px 0; }
        .coa-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 5px 12px; font-size: 11px; font-weight: 600;
            border: 1px solid #1976d2; color: #1976d2; background: #fff;
            cursor: pointer; text-decoration: none;
        }
        .coa-btn:hover { background: #e3f2fd; }
        .coa-btn--primary { background: #1976d2; color: #fff; }
        .coa-btn--primary:hover { background: #1565c0; }
        .coa-btn--danger { border-color: #d32f2f; color: #d32f2f; }
        .coa-btn--danger:hover { background: #ffebee; }
        .coa-form-row { display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap; padding: 12px 16px; background: #f8f9fa; border-bottom: 1px solid #e0e0e0; }
        .coa-form-group { display: flex; flex-direction: column; gap: 4px; }
        .coa-form-group label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .coa-form-group input, .coa-form-group select {
            padding: 5px 8px; border: 1px solid #ccc; font-size: 12px; min-width: 140px;
        }
        .coa-msg { padding: 8px 14px; margin: 8px 16px; font-size: 12px; border-left: 3px solid; }
        .coa-msg--success { border-color: #388e3c; background: #e8f5e9; color: #2e7d32; }
        .coa-msg--error { border-color: #d32f2f; background: #ffebee; color: #c62828; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:Label ID="lblMessage" runat="server" Visible="false" />

    <!-- Main Accounts Section -->
    <div class="coa-section">
        <div class="coa-section__header">
            <div class="coa-section__header-left">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
                Main Account Categories
            </div>
        </div>
        <!-- Add Main Account Form -->
        <div class="coa-form-row">
            <div class="coa-form-group">
                <label>Account Code</label>
                <asp:TextBox ID="txtMainAccCode" runat="server" MaxLength="15" />
            </div>
            <div class="coa-form-group">
                <label>Account Name</label>
                <asp:TextBox ID="txtMainAccName" runat="server" MaxLength="45" />
            </div>
            <div class="coa-form-group">
                <label>General Category</label>
                <asp:DropDownList ID="ddlGeneralCategory" runat="server">
                    <asp:ListItem Text="-- Select --" Value="" />
                    <asp:ListItem Text="Asset" Value="Asset" />
                    <asp:ListItem Text="Liability" Value="Liability" />
                    <asp:ListItem Text="Income" Value="Income" />
                    <asp:ListItem Text="Expense" Value="Expense" />
                    <asp:ListItem Text="Equity" Value="Equity" />
                </asp:DropDownList>
            </div>
            <div class="coa-form-group">
                <label>Sub Category</label>
                <asp:TextBox ID="txtSubCategory" runat="server" MaxLength="45" />
            </div>
            <asp:Button ID="btnAddMainAccount" runat="server" Text="Add Main Account" CssClass="coa-btn coa-btn--primary" OnClick="btnAddMainAccount_Click" />
        </div>
        <dx:ASPxGridView ID="gvMainAccounts" runat="server" Width="100%" KeyFieldName="AccountCode"
            ClientInstanceName="gvMainAccounts"
            OnRowDeleting="gvMainAccounts_RowDeleting"
            OnCustomCallback="gvMainAccounts_CustomCallback"
            SettingsBehavior-AllowFocusedRow="true"
            SettingsBehavior-ProcessSelectionChangedOnServer="true">
            <ClientSideEvents FocusedRowChanged="function(s, e) { gvSubAccounts.PerformCallback(s.GetRowKey(s.GetFocusedRowIndex())); }" />
            <Columns>
                <dx:GridViewDataTextColumn FieldName="AccountCode" Caption="Code" Width="100" />
                <dx:GridViewDataTextColumn FieldName="AccountName" Caption="Account Name" />
                <dx:GridViewDataTextColumn FieldName="GeneralCategory" Caption="Category" Width="100" />
                <dx:GridViewDataTextColumn FieldName="SubCategory" Caption="Sub Category" Width="120" />
                <dx:GridViewCommandColumn Width="60" Caption=" " ShowDeleteButton="true" />
            </Columns>
            <SettingsBehavior AllowFocusedRow="true" />
            <Settings ShowFilterRow="true" />
            <SettingsPager PageSize="15" />
            <Styles>
                <Header BackColor="#f8f9fa" ForeColor="#555" Font-Size="11px" Font-Bold="true" />
                <Row Font-Size="12px" />
                <AlternatingRow BackColor="#fafbfc" />
                <FocusedRow BackColor="#e3f2fd" />
            </Styles>
        </dx:ASPxGridView>
    </div>

    <!-- Sub Accounts Section -->
    <div class="coa-section">
        <div class="coa-section__header">
            <div class="coa-section__header-left">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg>
                Sub Accounts
                <span id="spanSelectedMain" runat="server" style="font-weight:400;color:#888;font-size:11px;margin-left:8px;"></span>
            </div>
        </div>
        <!-- Add Sub Account Form -->
        <div class="coa-form-row">
            <div class="coa-form-group">
                <label>Main Account</label>
                <asp:DropDownList ID="ddlMainAccountForSub" runat="server" />
            </div>
            <div class="coa-form-group">
                <label>Account Name</label>
                <asp:TextBox ID="txtSubAccName" runat="server" MaxLength="45" />
            </div>
            <div class="coa-form-group">
                <label>Details</label>
                <asp:TextBox ID="txtSubAccDetails" runat="server" MaxLength="150" />
            </div>
            <div class="coa-form-group">
                <label>Account Type</label>
                <asp:TextBox ID="txtSubAccType" runat="server" MaxLength="45" />
            </div>
            <div class="coa-form-group">
                <label>Ledger Type</label>
                <asp:DropDownList ID="ddlLedgerTypeForSub" runat="server" />
            </div>
            <asp:Button ID="btnAddSubAccount" runat="server" Text="Add Sub Account" CssClass="coa-btn coa-btn--primary" OnClick="btnAddSubAccount_Click" />
        </div>
        <dx:ASPxGridView ID="gvSubAccounts" runat="server" Width="100%" KeyFieldName="AccountCode"
            ClientInstanceName="gvSubAccounts"
            OnCustomCallback="gvSubAccounts_CustomCallback"
            OnRowDeleting="gvSubAccounts_RowDeleting">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="AccountCode" Caption="Code" Width="100" />
                <dx:GridViewDataTextColumn FieldName="AccountName" Caption="Account Name" />
                <dx:GridViewDataTextColumn FieldName="MainAccountCode" Caption="Main Acc" Width="90" />
                <dx:GridViewDataTextColumn FieldName="Details" Caption="Details" />
                <dx:GridViewDataTextColumn FieldName="accounttype" Caption="Type" Width="80" />
                <dx:GridViewDataTextColumn FieldName="collectionLedgerType" Caption="Ledger Type" Width="100" />
                <dx:GridViewCommandColumn Width="60" Caption=" " ShowDeleteButton="true" />
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
