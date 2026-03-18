<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="LedgerCategories.aspx.cs" Inherits="COOPERP_NewScreens_LedgerCategories" Title="Ledger Categories - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .lc-page-intro {
            background: #e3f2fd; border: 1px solid #90caf9; padding: 10px 16px; margin-bottom: 16px;
            font-size: 13px; color: #333;
        }
        .lc-add-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .lc-field { display: flex; flex-direction: column; gap: 4px; }
        .lc-field label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .lc-field input, .lc-field select {
            padding: 5px 8px; border: 1px solid #ccc; font-size: 12px;
        }
        .lc-btn {
            padding: 6px 16px; background: #1976d2; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .lc-btn:hover { background: #1565c0; }
        .lc-btn-danger {
            padding: 4px 10px; background: #c62828; color: #fff; border: none; cursor: pointer;
            font-size: 11px; font-weight: 600;
        }
        .lc-btn-danger:hover { background: #b71c1c; }
        .lc-msg {
            padding: 8px 12px; margin-bottom: 12px; font-size: 12px; font-weight: 600;
        }
        .lc-msg-ok { background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; }
        .lc-msg-err { background: #fce4ec; border: 1px solid #ef9a9a; color: #c62828; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <div class="lc-page-intro">
        <strong>Ledger Categories</strong> group sub-accounts into classification types (e.g. Current Assets, Fixed Assets, Operating Expenses).
        Each category belongs to a general category (Asset, Liability, Income, Expense, Equity).
    </div>

    <!-- Message Panel -->
    <asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="lc-msg lc-msg-ok">
        <asp:Literal ID="litMsg" runat="server" />
    </asp:Panel>

    <!-- Add / Edit Bar -->
    <div class="lc-add-bar">
        <asp:HiddenField ID="hdnEditId" runat="server" Value="" />
        <div class="lc-field">
            <label>Category Name</label>
            <asp:TextBox ID="txtCategoryName" runat="server" placeholder="e.g. Current Assets" Width="200" />
        </div>
        <div class="lc-field">
            <label>General Category</label>
            <asp:DropDownList ID="ddlGeneralCategory" runat="server">
                <asp:ListItem Value="Asset">Asset</asp:ListItem>
                <asp:ListItem Value="Liability">Liability</asp:ListItem>
                <asp:ListItem Value="Income">Income</asp:ListItem>
                <asp:ListItem Value="Expense">Expense</asp:ListItem>
                <asp:ListItem Value="Equity">Equity</asp:ListItem>
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnSave" runat="server" Text="+ Add Category" CssClass="lc-btn" OnClick="btnSave_Click" />
    </div>

    <!-- Categories Grid -->
    <dx:ASPxGridView ID="gridCategories" runat="server" Width="100%" KeyFieldName="LedgerTypeID"
        ClientInstanceName="gridCategories"
        Settings-ShowGroupPanel="false" Settings-ShowFilterRow="true"
        SettingsBehavior-AllowFocusedRow="true">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="LedgerTypeID" Caption="ID" Width="60" />
            <dx:GridViewDataTextColumn FieldName="LedgerTypeName" Caption="Category Name" Width="250" />
            <dx:GridViewDataTextColumn FieldName="LedgerTypeCategory" Caption="General Category" Width="150" />
            <dx:GridViewDataTextColumn Caption="Actions" Width="160" UnboundType="String">
                <DataItemTemplate>
                    <dx:ASPxButton ID="btnEdit" runat="server" Text="Edit"
                        CssClass="lc-btn" AutoPostBack="true" OnClick="btnEdit_Click"
                        CommandArgument='<%# Eval("LedgerTypeID") + "|" + Eval("LedgerTypeName") + "|" + Eval("LedgerTypeCategory") %>' />
                    &nbsp;
                    <dx:ASPxButton ID="btnDelete" runat="server" Text="Delete"
                        CssClass="lc-btn-danger" AutoPostBack="true" OnClick="btnDelete_Click"
                        CommandArgument='<%# Eval("LedgerTypeID") %>' />
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
        </Columns>
        <SettingsText EmptyDataRow="No ledger categories defined." />
    </dx:ASPxGridView>
</asp:Content>
