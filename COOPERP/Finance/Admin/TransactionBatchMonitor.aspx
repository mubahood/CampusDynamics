<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="TransactionBatchMonitor.aspx.cs" Inherits="COOPERP_Finance_Admin_TransactionBatchMonitor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Transaction Batch Monitor</h2>
        <p style="margin:0 0 12px 0;color:#444;">Monitors financial transaction batches, highlights failed or unbalanced operations, and lets administrators inspect the ledger lines inside each batch.</p>
        <asp:Label ID="lblStatus" runat="server" ForeColor="#0b5394"></asp:Label>
        <asp:GridView ID="gvBatchSummary" runat="server" Width="100%" AutoGenerateColumns="false" GridLines="Horizontal" style="margin-top:10px;"
            OnRowCommand="gvBatchSummary_RowCommand">
            <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
            <AlternatingRowStyle BackColor="#f5f8ff" />
            <Columns>
                <asp:BoundField DataField="BatchId" HeaderText="Batch ID" />
                <asp:BoundField DataField="BatchType" HeaderText="Batch Type" />
                <asp:BoundField DataField="Status" HeaderText="Status" />
                <asp:BoundField DataField="CreatedBy" HeaderText="Created By" />
                <asp:BoundField DataField="TotalDebit" HeaderText="Total Debit" DataFormatString="{0:N2}" />
                <asp:BoundField DataField="TotalCredit" HeaderText="Total Credit" DataFormatString="{0:N2}" />
                <asp:TemplateField HeaderText="Batch Review">
                    <ItemTemplate>
                        <asp:LinkButton ID="lbInspectBatch" runat="server"
                            CommandName="InspectBatch"
                            CommandArgument='<%# Eval("BatchId") %>'
                            style="color:#05275C;font-weight:bold;">
                            View Lines
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

        <asp:Panel ID="pnlBatchDetails" runat="server" Visible="false"
            style="margin-top:16px;padding:14px;border:1px solid #c9d7ee;background:#fafcff;border-radius:4px;">
            <asp:Label ID="lblBatchDetailsTitle" runat="server" style="font-weight:bold;font-size:15px;color:#05275C;display:block;margin-bottom:10px;"></asp:Label>
            <asp:Label ID="lblBatchDetailsInfo" runat="server" ForeColor="#555"></asp:Label>
            <asp:GridView ID="gvBatchLines" runat="server" Width="100%" AutoGenerateColumns="false" GridLines="Horizontal" style="margin-top:10px;">
                <HeaderStyle BackColor="#305496" ForeColor="White" Font-Bold="True" />
                <AlternatingRowStyle BackColor="#f7f9fd" />
                <Columns>
                    <asp:BoundField DataField="LineId" HeaderText="Line ID" />
                    <asp:BoundField DataField="AccountCode" HeaderText="Account Code" />
                    <asp:BoundField DataField="Narration" HeaderText="Narration / Detail" />
                    <asp:BoundField DataField="DebitAmount" HeaderText="Debit" DataFormatString="{0:N2}" />
                    <asp:BoundField DataField="CreditAmount" HeaderText="Credit" DataFormatString="{0:N2}" />
                </Columns>
            </asp:GridView>
        </asp:Panel>
    </div>
</asp:Content>
