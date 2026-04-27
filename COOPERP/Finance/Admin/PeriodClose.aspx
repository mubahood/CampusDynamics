<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="PeriodClose.aspx.cs" Inherits="COOPERP_Finance_Admin_PeriodClose" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Period Close Management</h2>
        <p style="margin:0 0 12px 0;color:#444;">Coordinates month-end close checks, validates readiness, and can execute the close procedure when the roadmap stored procedure has been deployed.</p>
        <asp:Label ID="lblCloseInfo" runat="server" ForeColor="#0b5394"></asp:Label>
        <div style="margin-top:10px;padding:12px;background:#eef3fc;border-left:4px solid #05275C;">
            <table style="width:100%;">
                <tr>
                    <td style="width:140px;"><b>Fiscal Year:</b></td>
                    <td style="width:220px;"><asp:TextBox ID="txtCloseFiscalYear" runat="server" Width="180px" placeholder="e.g. 2025-2026"></asp:TextBox></td>
                    <td style="width:120px;"><b>Period No:</b></td>
                    <td style="width:160px;"><asp:TextBox ID="txtClosePeriodNumber" runat="server" Width="80px" placeholder="1-12"></asp:TextBox></td>
                    <td>
                        <asp:Button ID="btnExecutePeriodClose" runat="server" Text="Execute Month-End Close"
                            OnClick="btnExecutePeriodClose_Click"
                            style="background:#05275C;color:#fff;border:none;padding:7px 18px;border-radius:3px;cursor:pointer;" />
                    </td>
                </tr>
            </table>
        </div>
        <asp:CheckBoxList ID="chkCloseChecklist" runat="server" style="margin-top:10px;">
            <asp:ListItem>All batches are completed</asp:ListItem>
            <asp:ListItem>Trial balance is balanced</asp:ListItem>
            <asp:ListItem>Bank reconciliation is complete</asp:ListItem>
            <asp:ListItem>Depreciation posting is complete</asp:ListItem>
            <asp:ListItem>Revenue recognition is complete</asp:ListItem>
        </asp:CheckBoxList>
    </div>
</asp:Content>
