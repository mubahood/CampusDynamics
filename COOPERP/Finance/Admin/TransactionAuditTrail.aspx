<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="TransactionAuditTrail.aspx.cs" Inherits="COOPERP_Finance_Admin_TransactionAuditTrail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Transaction Audit Trail</h2>
        <p style="margin:0 0 12px 0;color:#444;">Tracks before/after changes and user actions for forensic-level transaction visibility. Search by user, reason, table, record, voucher text, or JSON snapshot content.</p>
        <asp:Label ID="lblAuditInfo" runat="server" ForeColor="#0b5394"></asp:Label>
        <div style="margin-top:10px;padding:10px 12px;background:#eef3fc;border-left:4px solid #05275C;">
            <asp:Label ID="lblSearchPrompt" runat="server" Text="Search Audit Trail:" style="font-weight:bold;margin-right:8px;"></asp:Label>
            <asp:TextBox ID="txtAuditSearch" runat="server" Width="320px" placeholder="e.g. REC-2025, john, Reverse, DUPLICATE_ENTRY"></asp:TextBox>
            &nbsp;
            <asp:Button ID="btnSearchAudit" runat="server" Text="Search" OnClick="btnSearchAudit_Click"
                style="background:#05275C;color:#fff;border:none;padding:6px 18px;border-radius:3px;cursor:pointer;" />
            &nbsp;
            <asp:Button ID="btnClearAuditSearch" runat="server" Text="Clear" OnClick="btnClearAuditSearch_Click"
                CausesValidation="false" style="background:#999;color:#fff;border:none;padding:6px 18px;border-radius:3px;cursor:pointer;" />
        </div>
        <asp:GridView ID="gvAudit" runat="server" Width="100%" AutoGenerateColumns="false" GridLines="Horizontal" style="margin-top:10px;">
            <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
            <AlternatingRowStyle BackColor="#f5f8ff" />
            <Columns>
                <asp:BoundField DataField="ActionTime" HeaderText="Timestamp" />
                <asp:BoundField DataField="ActionName" HeaderText="Action" />
                <asp:BoundField DataField="ChangedBy" HeaderText="Changed By" />
                <asp:BoundField DataField="ReasonCode" HeaderText="Reason" />
                <asp:BoundField DataField="TargetRecord" HeaderText="Target" />
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
