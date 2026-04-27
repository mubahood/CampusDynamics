<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="CorrectionRequest.aspx.cs" Inherits="COOPERP_Finance_Admin_CorrectionRequest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Initiate Correction Request</h2>
        <p style="margin:0 0 14px 0;color:#444;">
            Search for a posted voucher, review its ledger lines, then submit a correction request for Finance Admin approval.
            A correction creates a paired reversal + repost under the corrected values. No changes are made without approval.
        </p>

        <asp:Label ID="lblStatus" runat="server" style="display:block;margin-bottom:10px;font-weight:bold;"></asp:Label>

        <%-- ─── Step 1: Voucher Search ─────────────────────────────────────── --%>
        <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-bottom:16px;">
            <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Step 1 — Find Posted Voucher</legend>
            <table>
                <tr>
                    <td style="padding:4px 8px 4px 0;"><b>Voucher Number:</b></td>
                    <td>
                        <asp:TextBox ID="txtVoucherNo" runat="server" Width="220px" MaxLength="30"
                            placeholder="e.g. PAY-2024-00012"
                            style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                        &nbsp;
                        <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click"
                            style="background:#05275C;color:#fff;border:none;padding:6px 18px;border-radius:3px;cursor:pointer;font-size:13px;" />
                    </td>
                </tr>
            </table>
        </fieldset>

        <%-- ─── Step 2: Voucher Lines Preview ───────────────────────────────── --%>
        <asp:Panel ID="pnlVoucherLines" runat="server" Visible="false">
            <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-bottom:16px;">
                <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Step 2 — Review Existing Voucher Lines</legend>
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

        <%-- ─── Step 3: Correction Details Form ─────────────────────────────── --%>
        <asp:Panel ID="pnlCorrectionForm" runat="server" Visible="false">
            <fieldset style="padding:14px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-bottom:16px;">
                <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Step 3 — Specify Correction Details</legend>
                <asp:HiddenField ID="hdnVoucherNo"     runat="server" />
                <asp:HiddenField ID="hdnOriginalAmount" runat="server" />

                <table style="width:100%;border-collapse:collapse;">
                    <tr>
                        <td style="width:210px;padding:6px 8px 6px 0;vertical-align:top;"><b>Correction Type:</b></td>
                        <td style="padding:4px 0;">
                            <asp:DropDownList ID="ddlCorrectionType" runat="server" AutoPostBack="true"
                                OnSelectedIndexChanged="ddlCorrectionType_Changed"
                                style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;min-width:240px;">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem Value="WrongAmount">Wrong Amount Posted</asp:ListItem>
                                <asp:ListItem Value="WrongAccount">Wrong Account Used</asp:ListItem>
                                <asp:ListItem Value="WrongAmountAndAccount">Wrong Amount and Account</asp:ListItem>
                                <asp:ListItem Value="WrongNarration">Wrong Narration / Description</asp:ListItem>
                                <asp:ListItem Value="WrongDate">Wrong Posting Date</asp:ListItem>
                                <asp:ListItem Value="DuplicateRemove">Remove Duplicate Entry</asp:ListItem>
                                <asp:ListItem Value="Other">Other (explain in notes)</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>

                    <%-- Amount correction fields (shown for WrongAmount / WrongAmountAndAccount) --%>
                    <asp:Panel ID="pnlAmountFields" runat="server" Visible="false">
                        <tr>
                            <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Original Amount:</b></td>
                            <td style="padding:4px 0;">
                                <asp:Label ID="lblOriginalAmount" runat="server" style="font-size:13px;color:#555;"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Corrected Amount:</b></td>
                            <td style="padding:4px 0;">
                                <asp:TextBox ID="txtCorrectedAmount" runat="server" Width="150px" MaxLength="20"
                                    placeholder="New correct amount"
                                    style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                            </td>
                        </tr>
                    </asp:Panel>

                    <%-- Account correction fields (shown for WrongAccount / WrongAmountAndAccount) --%>
                    <asp:Panel ID="pnlAccountFields" runat="server" Visible="false">
                        <tr>
                            <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Ledger Line ID to Correct:</b></td>
                            <td style="padding:4px 0;">
                                <asp:TextBox ID="txtLedgerLineId" runat="server" Width="100px" MaxLength="20"
                                    placeholder="Ledger ID from Step 2"
                                    style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                                <span style="color:#666;font-size:12px;margin-left:8px;">Enter the Ledger ID of the line to be re-posted to a new account</span>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Corrected Account Code:</b></td>
                            <td style="padding:4px 0;">
                                <asp:TextBox ID="txtCorrectedAccount" runat="server" Width="200px" MaxLength="50"
                                    placeholder="New correct account code"
                                    style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                            </td>
                        </tr>
                    </asp:Panel>

                    <%-- Narration correction field (shown for WrongNarration) --%>
                    <asp:Panel ID="pnlNarrationField" runat="server" Visible="false">
                        <tr>
                            <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Corrected Narration:</b></td>
                            <td style="padding:4px 0;">
                                <asp:TextBox ID="txtCorrectedNarration" runat="server" Width="98%" MaxLength="500"
                                    placeholder="Enter the correct narration / description"
                                    style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                            </td>
                        </tr>
                    </asp:Panel>

                    <%-- Date correction field (shown for WrongDate) --%>
                    <asp:Panel ID="pnlDateField" runat="server" Visible="false">
                        <tr>
                            <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Corrected Posting Date:</b></td>
                            <td style="padding:4px 0;">
                                <asp:TextBox ID="txtCorrectedDate" runat="server" Width="150px" MaxLength="10"
                                    placeholder="YYYY-MM-DD"
                                    style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                            </td>
                        </tr>
                    </asp:Panel>

                    <%-- Always-visible: reason and notes --%>
                    <tr>
                        <td style="padding:6px 8px 6px 0;vertical-align:top;"><b>Supporting Notes:</b></td>
                        <td style="padding:4px 0;">
                            <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" Rows="4" Width="98%"
                                MaxLength="1000"
                                placeholder="Provide full explanation to help the approver understand exactly what needs to change and why."
                                style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;"></asp:TextBox>
                        </td>
                    </tr>
                </table>

                <div style="margin-top:12px;padding:10px;background:#fff8e1;border:1px solid #ffe082;border-radius:4px;font-size:12px;color:#555;">
                    <b>Note:</b> Submitting this form does <b>not</b> post any entries. A Finance Admin will review and action this
                    request in <b>Reversal and Correction Approvals</b>. The corrected entries will only be posted after approval.
                </div>

                <div style="margin-top:12px;">
                    <asp:Button ID="btnSubmitRequest" runat="server" Text="Submit Correction Request"
                        OnClick="btnSubmitRequest_Click"
                        style="background:#05275C;color:#fff;border:none;padding:8px 24px;border-radius:3px;cursor:pointer;font-size:13px;font-weight:bold;"
                        OnClientClick="return confirm('Submit this correction request for Finance Admin approval?');" />
                    &nbsp;
                    <asp:Button ID="btnClearForm" runat="server" Text="Clear / Start Over"
                        OnClick="btnClearForm_Click" CausesValidation="false"
                        style="background:#aaa;color:#fff;border:none;padding:8px 18px;border-radius:3px;cursor:pointer;font-size:13px;" />
                </div>
            </fieldset>
        </asp:Panel>

        <%-- ─── Recent Requests ────────────────────────────────────────────── --%>
        <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-top:6px;">
            <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Recent Correction Requests (My Submissions)</legend>
            <asp:GridView ID="gvRecentRequests" runat="server" Width="100%" AutoGenerateColumns="false"
                GridLines="Horizontal" style="font-size:12px;margin-top:6px;"
                EmptyDataText="No correction requests found for your account.">
                <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
                <AlternatingRowStyle BackColor="#f5f8ff" />
                <Columns>
                    <asp:BoundField DataField="RequestRef"      HeaderText="Request Ref"     />
                    <asp:BoundField DataField="OriginalVoucher" HeaderText="Voucher"         />
                    <asp:BoundField DataField="CorrectionType"  HeaderText="Correction Type" />
                    <asp:BoundField DataField="ReversalReason"  HeaderText="Reason / Detail" />
                    <asp:BoundField DataField="OriginalAmount"  HeaderText="Orig. Amount"    DataFormatString="{0:N2}" />
                    <asp:BoundField DataField="RequestedAt"     HeaderText="Submitted At"    />
                    <asp:BoundField DataField="Status"          HeaderText="Status"          />
                    <asp:BoundField DataField="ApprovalNotes"   HeaderText="Approval Notes"  />
                </Columns>
            </asp:GridView>
        </fieldset>
    </div>
</asp:Content>
