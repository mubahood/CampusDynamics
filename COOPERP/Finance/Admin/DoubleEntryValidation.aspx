<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="DoubleEntryValidation.aspx.cs" Inherits="COOPERP_Finance_Admin_DoubleEntryValidation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Double-Entry Validation</h2>
        <p style="margin:0 0 12px 0;color:#444;">Validates accounting rules, highlights debit-credit exceptions, and lets administrators activate or deactivate posting rules safely.</p>
        <asp:Label ID="lblValidationInfo" runat="server" ForeColor="#0b5394"></asp:Label>
        <div style="margin-top:10px;padding:10px 12px;background:#eef3fc;border-left:4px solid #05275C;font-size:12px;color:#333;">
            <asp:Label ID="lblRuleSummary" runat="server"></asp:Label>
        </div>
        <asp:GridView ID="gvRules" runat="server" Width="100%" AutoGenerateColumns="false" GridLines="Horizontal" style="margin-top:10px;"
            OnRowCommand="gvRules_RowCommand">
            <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
            <AlternatingRowStyle BackColor="#f5f8ff" />
            <Columns>
                <asp:BoundField DataField="RuleId" HeaderText="Rule ID" />
                <asp:BoundField DataField="RuleName" HeaderText="Rule" />
                <asp:BoundField DataField="TransactionType" HeaderText="Transaction Type" />
                <asp:BoundField DataField="Enforcement" HeaderText="Enforcement" />
                <asp:BoundField DataField="Status" HeaderText="Status" />
                <asp:BoundField DataField="RecentViolations" HeaderText="Recent Violations" />
                <asp:TemplateField HeaderText="Rule Action">
                    <ItemTemplate>
                        <asp:LinkButton ID="lbToggleRule" runat="server"
                            CommandName="ToggleRuleStatus"
                            CommandArgument='<%# Eval("RuleId") + "|" + Eval("Status") %>'
                            style="color:#05275C;font-weight:bold;">
                            <%# (string)Eval("Status") == "Active" ? "Deactivate" : "Activate" %>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
