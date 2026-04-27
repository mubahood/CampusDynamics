<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="BankRecoMatching.aspx.cs" Inherits="COOPERP_Finance_Admin_BankRecoMatching" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Bank Reconciliation Matching</h2>
        <p style="margin:0 0 14px 0;color:#444;">
            Select a validated bank statement import, review unreconciled ledger entries in the same date range,
            and mark matched entries as bank-reconciled. All actions are logged for audit.
        </p>

        <asp:Label ID="lblStatus" runat="server" style="display:block;margin-bottom:10px;font-weight:bold;"></asp:Label>

        <%-- ─── Step 1: Select Import ──────────────────────────────────────── --%>
        <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-bottom:16px;">
            <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Step 1 — Select Validated Import</legend>
            <table>
                <tr>
                    <td style="padding:4px 8px 4px 0;"><b>Bank Statement Import:</b></td>
                    <td>
                        <asp:DropDownList ID="ddlImport" runat="server" AutoPostBack="false"
                            style="border:1px solid #aaa;padding:5px 8px;border-radius:3px;font-size:13px;min-width:360px;">
                        </asp:DropDownList>
                        &nbsp;
                        <asp:Button ID="btnLoadImport" runat="server" Text="Load Import" OnClick="btnLoadImport_Click"
                            style="background:#05275C;color:#fff;border:none;padding:6px 18px;border-radius:3px;cursor:pointer;font-size:13px;" />
                    </td>
                </tr>
            </table>
        </fieldset>

        <%-- ─── Import Summary ────────────────────────────────────────────── --%>
        <asp:Panel ID="pnlImportSummary" runat="server" Visible="false">
            <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-bottom:16px;">
                <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Import Details</legend>
                <asp:Label ID="lblImportDetails" runat="server" style="font-size:13px;color:#333;"></asp:Label>
            </fieldset>
        </asp:Panel>

        <%-- ─── Step 2: Unreconciled Ledger Entries ──────────────────────── --%>
        <asp:Panel ID="pnlLedgerEntries" runat="server" Visible="false">
            <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;margin-bottom:16px;">
                <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Step 2 — Unreconciled Ledger Entries in Statement Period</legend>
                <p style="margin:0 0 8px 0;color:#555;font-size:12px;">
                    These are <b>un-reconciled</b> entries from <code>fin_ledger</code> within the statement date range.
                    Click <b>Mark Reconciled</b> on a matching row to link it to this import.
                </p>
                <asp:GridView ID="gvLedgerEntries" runat="server" Width="100%" AutoGenerateColumns="false"
                    GridLines="Horizontal" style="font-size:12px;"
                    OnRowCommand="gvLedgerEntries_RowCommand"
                    EmptyDataText="No unreconciled ledger entries found in the statement date range.">
                    <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
                    <AlternatingRowStyle BackColor="#f5f8ff" />
                    <Columns>
                        <asp:BoundField DataField="LedgerId"     HeaderText="Ledger ID"    />
                        <asp:BoundField DataField="VoucherNo"    HeaderText="Voucher"      />
                        <asp:BoundField DataField="AccountCode"  HeaderText="Account Code" />
                        <asp:BoundField DataField="EntryType"    HeaderText="Dr/Cr"        />
                        <asp:BoundField DataField="Amount"       HeaderText="Amount"       DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="Narration"    HeaderText="Narration"    />
                        <asp:BoundField DataField="EntryDate"    HeaderText="Date"         />
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:LinkButton ID="lbReconcile" runat="server"
                                    CommandName="MarkReconciled"
                                    CommandArgument='<%# Eval("LedgerId") %>'
                                    style="color:green;font-weight:bold;"
                                    OnClientClick="return confirm('Mark this ledger entry as bank-reconciled?');">
                                    Mark Reconciled
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </fieldset>
        </asp:Panel>

        <%-- ─── Step 3: Already Reconciled in This Import ─────────────────── --%>
        <asp:Panel ID="pnlReconciledEntries" runat="server" Visible="false">
            <fieldset style="padding:12px 16px;border:1px solid #c0c0c0;border-radius:4px;">
                <legend style="font-weight:bold;color:#05275C;padding:0 6px;">Already Reconciled Against This Import</legend>
                <asp:GridView ID="gvReconciledEntries" runat="server" Width="100%" AutoGenerateColumns="false"
                    GridLines="Horizontal" style="font-size:12px;"
                    EmptyDataText="No reconciled entries yet for this import.">
                    <HeaderStyle BackColor="#336600" ForeColor="White" Font-Bold="True" />
                    <AlternatingRowStyle BackColor="#f5fff5" />
                    <Columns>
                        <asp:BoundField DataField="LedgerId"      HeaderText="Ledger ID"    />
                        <asp:BoundField DataField="VoucherNo"     HeaderText="Voucher"      />
                        <asp:BoundField DataField="AccountCode"   HeaderText="Account Code" />
                        <asp:BoundField DataField="EntryType"     HeaderText="Dr/Cr"        />
                        <asp:BoundField DataField="Amount"        HeaderText="Amount"       DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="Narration"     HeaderText="Narration"    />
                        <asp:BoundField DataField="EntryDate"     HeaderText="Date"         />
                        <asp:BoundField DataField="ReconciledBy"  HeaderText="Reconciled By" />
                        <asp:BoundField DataField="ReconciledAt"  HeaderText="Reconciled At" />
                    </Columns>
                </asp:GridView>
            </fieldset>
        </asp:Panel>
    </div>
</asp:Content>
