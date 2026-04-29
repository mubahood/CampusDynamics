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
            &nbsp;
            <asp:Button ID="btnExportAuditPdf" runat="server" Text="Export PDF" OnClick="btnExportAuditPdf_Click"
                CausesValidation="false" style="background:#336600;color:#fff;border:none;padding:6px 18px;border-radius:3px;cursor:pointer;" />
        </div>
        <asp:GridView ID="gvAudit" runat="server" Width="100%" AutoGenerateColumns="false" GridLines="Horizontal" style="margin-top:10px;"
            OnRowCommand="gvAudit_RowCommand">
            <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
            <AlternatingRowStyle BackColor="#f5f8ff" />
            <Columns>
                <asp:BoundField DataField="ActionTime" HeaderText="Timestamp" />
                <asp:BoundField DataField="ActionName" HeaderText="Action" />
                <asp:BoundField DataField="ChangedBy" HeaderText="Changed By" />
                <asp:BoundField DataField="ReasonCode" HeaderText="Reason" />
                <asp:BoundField DataField="TargetRecord" HeaderText="Target" />
                <asp:TemplateField HeaderText="Inspect">
                    <ItemTemplate>
                        <asp:LinkButton ID="lbViewDetail" runat="server" CommandName="ViewAuditDetail"
                            CommandArgument='<%# Eval("LogId") %>' style="color:#05275C;font-weight:bold;">View</asp:LinkButton>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

        <asp:Panel ID="pnlAuditDetail" runat="server" Visible="false"
            style="margin-top:14px;padding:14px;border:1px solid #c0c0c0;background:#fbfbfb;border-radius:4px;">
            <h3 style="margin:0 0 10px 0;color:#05275C;font-size:16px;">Audit Record Detail</h3>
            <asp:Label ID="lblAuditDetailHeader" runat="server" style="display:block;margin-bottom:10px;color:#333;"></asp:Label>
            <table style="width:100%;border-collapse:collapse;">
                <tr>
                    <td style="width:50%;vertical-align:top;padding-right:8px;">
                        <div style="font-weight:bold;margin-bottom:6px;color:#05275C;">Old Value</div>
                        <asp:TextBox ID="txtOldValue" runat="server" TextMode="MultiLine" Rows="12" Width="98%" ReadOnly="true"
                            style="font-family:Consolas, monospace;font-size:12px;background:#fff;border:1px solid #ccc;"></asp:TextBox>
                    </td>
                    <td style="width:50%;vertical-align:top;padding-left:8px;">
                        <div style="font-weight:bold;margin-bottom:6px;color:#05275C;">New Value</div>
                        <asp:TextBox ID="txtNewValue" runat="server" TextMode="MultiLine" Rows="12" Width="98%" ReadOnly="true"
                            style="font-family:Consolas, monospace;font-size:12px;background:#fff;border:1px solid #ccc;"></asp:TextBox>
                    </td>
                </tr>
            </table>
            <div style="margin-top:10px;">
                <b>Reason Text:</b>
                <asp:Label ID="lblAuditReasonText" runat="server"></asp:Label>
            </div>
        </asp:Panel>
    </div>
</asp:Content>
