<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="PeriodManagement.aspx.cs" Inherits="COOPERP_Finance_Admin_PeriodManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Accounting Period Management</h2>
        <p style="margin:0 0 6px 0;color:#444;">Controls the accounting period lifecycle: Open → Frozen → Closed → Archived. Each transition is validated and permanently recorded.</p>

        <div style="margin-bottom:12px;padding:8px 12px;background:#eef3fc;border-left:4px solid #05275C;font-size:12px;color:#333;">
            <b>State Rules:</b>
            Open periods accept new postings. &nbsp;|&nbsp;
            Frozen periods are in month-end (no new posts). &nbsp;|&nbsp;
            Closed periods are finalised. &nbsp;|&nbsp;
            Archived periods are read-only forever.
            Transitions can only move <em>forward</em> — you cannot reopen a closed period.
        </div>

        <asp:Label ID="lblPeriodInfo" runat="server" ForeColor="#0b5394"></asp:Label>

        <%-- Transition confirmation panel --%>
        <asp:Panel ID="pnlTransitionPanel" runat="server" Visible="false"
            style="margin-top:14px;padding:14px;border:1px solid #c0c0c0;background:#fff8e1;border-radius:4px;">
            <asp:Label ID="lblTransitionTitle" runat="server"
                style="font-weight:bold;font-size:14px;display:block;margin-bottom:8px;color:#333;"></asp:Label>
            <asp:HiddenField ID="hdnPeriodId" runat="server" />
            <asp:HiddenField ID="hdnTargetState" runat="server" />
            <table style="width:100%;"><tr>
                <td style="width:160px;padding:4px 8px 4px 0;"><b>Lock Reason (optional):</b></td>
                <td><asp:TextBox ID="txtLockReason" runat="server" Width="98%"
                    placeholder="e.g. Month-end commenced, auditors present..."></asp:TextBox></td>
            </tr></table>
            <div style="margin-top:10px;">
                <asp:Button ID="btnConfirmTransition" runat="server" Text="Confirm Transition"
                    OnClick="btnConfirmTransition_Click"
                    style="background:#05275C;color:#fff;border:none;padding:7px 22px;border-radius:3px;cursor:pointer;font-size:13px;" />
                &nbsp;
                <asp:Button ID="btnCancelTransition" runat="server" Text="Cancel"
                    OnClick="btnCancelTransition_Click" CausesValidation="false"
                    style="background:#aaa;color:#fff;border:none;padding:7px 18px;border-radius:3px;cursor:pointer;font-size:13px;" />
            </div>
        </asp:Panel>

        <asp:GridView ID="gvPeriods" runat="server" Width="100%" AutoGenerateColumns="false"
            GridLines="Horizontal" style="margin-top:14px;font-size:13px;"
            OnRowCommand="gvPeriods_RowCommand">
            <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
            <AlternatingRowStyle BackColor="#f5f8ff" />
            <Columns>
                <asp:BoundField DataField="PeriodId"       HeaderText="ID" />
                <asp:BoundField DataField="FiscalYear"     HeaderText="Fiscal Year" />
                <asp:BoundField DataField="Period"         HeaderText="Period" />
                <asp:BoundField DataField="PeriodName"     HeaderText="Name" />
                <asp:BoundField DataField="PostingStatus"  HeaderText="Posting" />
                <asp:BoundField DataField="FreezeStatus"   HeaderText="Month-End" />
                <asp:BoundField DataField="CloseStatus"    HeaderText="Close" />
                <asp:BoundField DataField="TBBalanced"     HeaderText="TB Balanced?" />
                <asp:BoundField DataField="CurrentState"   HeaderText="Current State" />
                <asp:TemplateField HeaderText="Transition To">
                    <ItemTemplate>
                        <%-- Freeze button: only when open and not yet frozen --%>
                        <asp:LinkButton runat="server" CommandName="FreezePeriod"
                            CommandArgument='<%# Eval("PeriodId") %>'
                            Visible='<%# (string)Eval("CurrentState") == "Open" %>'
                            style="color:#e65100;font-weight:bold;margin-right:8px;"
                            OnClientClick="return confirm('Freeze this period for month-end? No new transactions can be posted until closed.');">
                            Freeze
                        </asp:LinkButton>
                        <%-- Close button: only when frozen --%>
                        <asp:LinkButton runat="server" CommandName="ClosePeriod"
                            CommandArgument='<%# Eval("PeriodId") %>'
                            Visible='<%# (string)Eval("CurrentState") == "Frozen" %>'
                            style="color:#b71c1c;font-weight:bold;margin-right:8px;"
                            OnClientClick="return confirm('Close this period? This is final — it cannot be reopened for regular posting.');">
                            Close
                        </asp:LinkButton>
                        <%-- Archive button: only when closed --%>
                        <asp:LinkButton runat="server" CommandName="ArchivePeriod"
                            CommandArgument='<%# Eval("PeriodId") %>'
                            Visible='<%# (string)Eval("CurrentState") == "Closed" %>'
                            style="color:#37474f;font-weight:bold;" 
                            OnClientClick="return confirm('Archive this period? It will become permanently read-only.');">
                            Archive
                        </asp:LinkButton>
                        <%-- Show current state label for non-actionable states --%>
                        <asp:Literal runat="server"
                            Text='<%# ((string)Eval("CurrentState") == "Archived" || (string)Eval("CurrentState") == "Not Started") ? "<span style=\"color:gray;font-style:italic;\">" + System.Web.HttpUtility.HtmlEncode((string)Eval("CurrentState")) + "</span>" : "" %>'>
                        </asp:Literal>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
