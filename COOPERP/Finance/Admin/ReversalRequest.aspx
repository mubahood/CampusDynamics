<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="ReversalRequest.aspx.cs" Inherits="COOPERP_Finance_Admin_ReversalRequest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Initiate Reversal Request</h2>
        <p style="margin:0 0 14px 0;color:#444;">
            Search for a voucher, review its ledger lines, then submit a reversal or correction request for Finance Admin approval.
            All requests are logged and cannot be executed without approval.
        </p>

        <asp:Label ID="lblStatus" runat="server" style="display:block;margin-bottom:10px;font-weight:bold;"></asp:Label>

        <%-- ─── Voucher Search ─────────────────────────────────────────────── --%>
        <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-bottom:16px;">
            <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Step 1 — Find Voucher</legend>
            <table>
                <tr>
                    <td style="padding:4px 8px 4px 0;"><b>Voucher Number:</b></td>
                    <td>
                        <asp:TextBox ID="txtVoucherNo" runat="server" Width="220px" MaxLength="30"
                            placeholder="e.g. RCP-2024-00042"
                            style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                        &nbsp;
                        <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click"
                            style="background:#05275C;color:#fff;border:none;padding:6px 18px;border-radius:3px;cursor:pointer;font-size:13px;" />
                    </td>
                </tr>
            </table>
        </fieldset>

        <%-- ─── Voucher Lines Preview ──────────────────────────────────────── --%>
        <asp:Panel ID="pnlVoucherLines" runat="server" Visible="false">
            <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-bottom:16px;">
                <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Step 2 — Review Voucher Lines</legend>
                <asp:Label ID="lblVoucherSummary" runat="server" style="display:block;margin-bottom:8px;color:#333;font-size:13px;"></asp:Label>
                <asp:GridView ID="gvVoucherLines" runat="server" Width="100%" AutoGenerateColumns="false"
                    GridLines="Horizontal" style="font-size:12px;">
                    <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
                    <AlternatingRowStyle BackColor="#f5f8ff" />
                    <Columns>
                        <asp:BoundField DataField="LedgerId"     HeaderText="Ledger ID"    />
                        <asp:BoundField DataField="AccountCode"  HeaderText="Account Code" />
                        <asp:BoundField DataField="AccountName"  HeaderText="Account Name" />
                        <asp:BoundField DataField="EntryType"    HeaderText="Dr/Cr"        />
                        <asp:BoundField DataField="Amount"       HeaderText="Amount"       DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="Narration"    HeaderText="Narration"    />
                        <asp:BoundField DataField="EntryDate"    HeaderText="Date"         />
                    </Columns>
                </asp:GridView>
            </fieldset>
        </asp:Panel>

        <%-- ─── Reversal Request Form ──────────────────────────────────────── --%>
        <asp:Panel ID="pnlRequestForm" runat="server" Visible="false">
            <fieldset style="padding:14px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-bottom:16px;">
                <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Step 3 — Submit Reversal Request</legend>
                <asp:HiddenField ID="hdnVoucherNo"     runat="server" />
                <asp:HiddenField ID="hdnVoucherAmount" runat="server" />
                <table style="width:100%;border-collapse:collapse;">
                    <tr>
                        <td style="width:200px;padding:6px 8px 6px 0;vertical-align:top;"><b>Reversal Type:</b></td>
                        <td style="padding:4px 0;">
                            <asp:DropDownList ID="ddlReversalType" runat="server"
                                style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;min-width:220px;">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem Value="FullReversal">Full Reversal</asp:ListItem>
                                <asp:ListItem Value="PartialReversal">Partial Reversal</asp:ListItem>
                                <asp:ListItem Value="Correction">Correction (Adjustment)</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Reversal Amount:</b></td>
                        <td style="padding:4px 0;">
                            <asp:TextBox ID="txtReversalAmount" runat="server" Width="150px" MaxLength="20"
                                placeholder="Leave blank to use full voucher amount"
                                style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                            <span style="color:#666;font-size:12px;margin-left:8px;">Leave blank to default to original amount</span>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Reason Code:</b></td>
                        <td style="padding:4px 0;">
                            <asp:DropDownList ID="ddlReasonCode" runat="server"
                                style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;min-width:220px;">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem Value="StudentWithdrawal">Student Withdrawal</asp:ListItem>
                                <asp:ListItem Value="DuplicateEntry">Duplicate Entry</asp:ListItem>
                                <asp:ListItem Value="WrongAmount">Wrong Amount Posted</asp:ListItem>
                                <asp:ListItem Value="WrongAccount">Wrong Account Posted</asp:ListItem>
                                <asp:ListItem Value="PeriodAdjustment">Period Adjustment</asp:ListItem>
                                <asp:ListItem Value="SponsorCancellation">Sponsor Cancellation</asp:ListItem>
                                <asp:ListItem Value="BankReconciliation">Bank Reconciliation Difference</asp:ListItem>
                                <asp:ListItem Value="Other">Other (explain in notes)</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Supporting Notes:</b></td>
                        <td style="padding:4px 0;">
                            <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" Rows="4" Width="98%"
                                MaxLength="1000"
                                placeholder="Provide a full explanation to assist the approver. Required for non-standard reason codes."
                                style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <div style="margin-top:12px;">
                    <asp:Button ID="btnSubmitRequest" runat="server" Text="Submit Reversal Request"
                        OnClick="btnSubmitRequest_Click"
                        style="background:#05275C;color:#fff;border:none;padding:8px 24px;border-radius:3px;cursor:pointer;font-size:13px;font-weight:bold;"
                        OnClientClick="return confirm('Submit this reversal request for Finance Admin approval?');" />
                    &nbsp;
                    <asp:Button ID="btnClearForm" runat="server" Text="Clear / Start Over"
                        OnClick="btnClearForm_Click" CausesValidation="false"
                        style="background:#aaa;color:#fff;border:none;padding:8px 18px;border-radius:3px;cursor:pointer;font-size:13px;" />
                </div>
            </fieldset>
        </asp:Panel>

        <%-- ─── Recent Requests ────────────────────────────────────────────── --%>
        <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-top:6px;">
            <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Recent Requests (My Submissions)</legend>
            <asp:GridView ID="gvRecentRequests" runat="server" Width="100%" AutoGenerateColumns="false"
                GridLines="Horizontal" style="font-size:12px;margin-top:6px;"
                EmptyDataText="No reversal requests found for your account.">
                <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
                <AlternatingRowStyle BackColor="#f5f8ff" />
                <Columns>
                    <asp:BoundField DataField="RequestRef"     HeaderText="Request Ref"     />
                    <asp:BoundField DataField="OriginalVoucher" HeaderText="Voucher"        />
                    <asp:BoundField DataField="ReversalType"   HeaderText="Type"            />
                    <asp:BoundField DataField="ReversalReason" HeaderText="Reason"          />
                    <asp:BoundField DataField="OriginalAmount" HeaderText="Amount"          DataFormatString="{0:N2}" />
                    <asp:BoundField DataField="RequestedAt"    HeaderText="Submitted At"    />
                    <asp:BoundField DataField="Status"         HeaderText="Status"          />
                    <asp:BoundField DataField="ApprovalNotes"  HeaderText="Approval Notes"  />
                </Columns>
            </asp:GridView>
        </fieldset>
    </div>
</asp:Content>
