<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="ReversalApprovals.aspx.cs" Inherits="COOPERP_Finance_Admin_ReversalApprovals" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Reversal and Correction Approvals</h2>
        <p style="margin:0 0 12px 0;color:#444;">Review and approve or reject reversal/correction requests with full audit traceability. All actions are logged.</p>
        <asp:Label ID="lblApprovalInfo" runat="server" ForeColor="#0b5394"></asp:Label>

        <%-- Approval/Rejection comments panel (hidden until action is clicked) --%>
        <asp:Panel ID="pnlActionPanel" runat="server" Visible="false"
            style="margin-top:14px;padding:14px;border:1px solid #c0c0c0;background:#f8f8f8;border-radius:4px;">
            <asp:Label ID="lblActionTitle" runat="server" style="font-weight:bold;font-size:14px;display:block;margin-bottom:8px;"></asp:Label>
            <asp:HiddenField ID="hdnReversalId" runat="server" />
            <asp:HiddenField ID="hdnAction" runat="server" />
            <table style="width:100%;">
                <tr>
                    <td style="width:150px;padding:4px 8px 4px 0;"><b>Approval Comments:</b></td>
                    <td><asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine" Rows="3" Width="98%"
                        placeholder="Enter your comments (required for rejection)..."></asp:TextBox></td>
                </tr>
            </table>
            <div style="margin-top:10px;">
                <asp:Button ID="btnConfirmAction" runat="server" Text="Confirm" OnClick="btnConfirmAction_Click"
                    style="background:#05275C;color:#fff;border:none;padding:7px 22px;border-radius:3px;cursor:pointer;font-size:13px;" />
                &nbsp;
                <asp:Button ID="btnCancelAction" runat="server" Text="Cancel" OnClick="btnCancelAction_Click"
                    style="background:#aaa;color:#fff;border:none;padding:7px 18px;border-radius:3px;cursor:pointer;font-size:13px;" CausesValidation="false" />
            </div>
        </asp:Panel>

        <asp:GridView ID="gvApprovals" runat="server" Width="100%" AutoGenerateColumns="false"
            GridLines="Horizontal" style="margin-top:14px;font-size:13px;"
            OnRowCommand="gvApprovals_RowCommand">
            <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
            <AlternatingRowStyle BackColor="#f5f8ff" />
            <Columns>
                <asp:BoundField DataField="ReversalId" HeaderText="ID" />
                <asp:BoundField DataField="RequestId" HeaderText="Request Ref" />
                <asp:BoundField DataField="RequestType" HeaderText="Type" />
                <asp:BoundField DataField="OriginalVoucher" HeaderText="Original Voucher" />
                <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="{0:N2}" />
                <asp:BoundField DataField="RequestedBy" HeaderText="Requested By" />
                <asp:BoundField DataField="RequestedAt" HeaderText="Requested At" />
                <asp:BoundField DataField="ReversalReason" HeaderText="Reason" />
                <asp:BoundField DataField="Status" HeaderText="Status" />
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <asp:LinkButton ID="lbApprove" runat="server" CommandName="ApproveReversal"
                            CommandArgument='<%# Eval("ReversalId") %>'
                            Visible='<%# (string)Eval("Status") == "Pending" %>'
                            style="color:green;font-weight:bold;margin-right:10px;"
                            OnClientClick="return confirm('Approve this reversal request?');">Approve</asp:LinkButton>
                        <asp:LinkButton ID="lbReject" runat="server" CommandName="RejectReversal"
                            CommandArgument='<%# Eval("ReversalId") %>'
                            Visible='<%# (string)Eval("Status") == "Pending" %>'
                            style="color:#cc0000;font-weight:bold;">Reject</asp:LinkButton>
                        <asp:Literal ID="litStatus" runat="server"
                            Text='<%# (string)Eval("Status") != "Pending" ? "<span style=color:gray>" + Server.HtmlEncode((string)Eval("Status")) + "</span>" : "" %>'></asp:Literal>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
