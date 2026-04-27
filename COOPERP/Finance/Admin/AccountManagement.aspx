<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="AccountManagement.aspx.cs" Inherits="COOPERP_Finance_Admin_AccountManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Chart of Accounts Lifecycle Management</h2>
        <p style="margin:0 0 12px 0;color:#444;">Manages account activation, deactivation, and controlled lifecycle operations with audit safety. Accounts with posted ledger lines are protected from unsafe deactivation changes.</p>
        <asp:Label ID="lblAccountInfo" runat="server" ForeColor="#0b5394"></asp:Label>
        <asp:GridView ID="gvAccounts" runat="server" Width="100%" AutoGenerateColumns="false" GridLines="Horizontal" style="margin-top:10px;"
            OnRowCommand="gvAccounts_RowCommand">
            <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
            <AlternatingRowStyle BackColor="#f5f8ff" />
            <Columns>
                <asp:BoundField DataField="AccountCode" HeaderText="Account Code" />
                <asp:BoundField DataField="AccountName" HeaderText="Account Name" />
                <asp:BoundField DataField="AccountType" HeaderText="Type" />
                <asp:BoundField DataField="Status" HeaderText="Status" />
                <asp:BoundField DataField="LedgerLines" HeaderText="Ledger Lines" />
                <asp:TemplateField HeaderText="Lifecycle Action">
                    <ItemTemplate>
                        <asp:LinkButton ID="lbDeactivate" runat="server"
                            CommandName="DeactivateAccount"
                            CommandArgument='<%# Eval("AccountCode") + "|" + Eval("LedgerLines") + "|" + Eval("Status") %>'
                            Visible='<%# (string)Eval("Status") == "Active" %>'
                            style="color:#b71c1c;font-weight:bold;margin-right:10px;">
                            Deactivate
                        </asp:LinkButton>
                        <asp:LinkButton ID="lbRestore" runat="server"
                            CommandName="RestoreAccount"
                            CommandArgument='<%# Eval("AccountCode") + "|" + Eval("LedgerLines") + "|" + Eval("Status") %>'
                            Visible='<%# (string)Eval("Status") != "Active" %>'
                            style="color:#1b5e20;font-weight:bold;">
                            Restore
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
