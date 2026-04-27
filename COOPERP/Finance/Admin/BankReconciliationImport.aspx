<%@ Page Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="BankReconciliationImport.aspx.cs" Inherits="COOPERP_Finance_Admin_BankReconciliationImport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div style="padding:16px;">
        <h2 style="margin:0 0 8px 0;color:#05275C;">* Bank Reconciliation Import Validation</h2>
        <p style="margin:0 0 12px 0;color:#444;">Upload a bank statement file (CSV/TXT). The system generates a SHA-256 fingerprint to prevent duplicate imports, shows a preview of the content, then saves the record for validation and reconciliation.</p>

        <asp:Label ID="lblImportInfo" runat="server" ForeColor="#0b5394"></asp:Label>

        <%-- ── UPLOAD PANEL ────────────────────────────────────────────────────── --%>
        <fieldset style="margin-top:12px;padding:14px;border:1px solid #cddff5;background:#f9fcff;">
            <legend style="font-weight:bold;color:#05275C;padding:0 6px;">New Statement Import</legend>
            <table style="width:100%;border-collapse:collapse;">
                <tr>
                    <td style="width:160px;padding:4px 8px;"><label>Bank Account ID:</label></td>
                    <td style="padding:4px 8px;">
                        <asp:TextBox ID="txtBankAccountId" runat="server" Width="80px" />
                        <span style="color:#888;font-size:11px;"> (numeric ID from fin_bank_accounts)</span>
                    </td>
                </tr>
                <tr>
                    <td style="padding:4px 8px;"><label>Statement Date:</label></td>
                    <td style="padding:4px 8px;">
                        <asp:TextBox ID="txtStatementDate" runat="server" Width="120px" placeholder="YYYY-MM-DD" />
                    </td>
                </tr>
                <tr>
                    <td style="padding:4px 8px;"><label>File Format:</label></td>
                    <td style="padding:4px 8px;">
                        <asp:DropDownList ID="ddlImportFormat" runat="server">
                            <asp:ListItem Value="CSV" Text="CSV" />
                            <asp:ListItem Value="MT940" Text="MT940" />
                            <asp:ListItem Value="OFX" Text="OFX" />
                            <asp:ListItem Value="Excel" Text="Excel (not parsed)" />
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td style="padding:4px 8px;"><label>Opening Balance:</label></td>
                    <td style="padding:4px 8px;">
                        <asp:TextBox ID="txtOpeningBalance" runat="server" Width="140px" placeholder="0.00" />
                    </td>
                </tr>
                <tr>
                    <td style="padding:4px 8px;"><label>Closing Balance:</label></td>
                    <td style="padding:4px 8px;">
                        <asp:TextBox ID="txtClosingBalance" runat="server" Width="140px" placeholder="0.00" />
                    </td>
                </tr>
                <tr>
                    <td style="padding:4px 8px;"><label>Statement File:</label></td>
                    <td style="padding:4px 8px;">
                        <asp:FileUpload ID="fuStatement" runat="server" Width="340px" />
                    </td>
                </tr>
                <tr>
                    <td style="padding:4px 8px;"></td>
                    <td style="padding:8px 8px;">
                        <asp:Button ID="btnUploadStatement" runat="server" Text="Preview &amp; Hash File"
                            OnClick="btnUploadStatement_Click"
                            style="background:#05275C;color:white;border:none;padding:6px 16px;cursor:pointer;font-size:13px;" />
                    </td>
                </tr>
            </table>
        </fieldset>

        <%-- ── PREVIEW PANEL (shown after upload) ────────────────────────────── --%>
        <asp:Panel ID="pnlPreview" runat="server" Visible="false" style="margin-top:16px;border:1px solid #c3d9a8;background:#f6fff0;padding:14px;">
            <h4 style="margin:0 0 8px 0;color:#2a5c0a;">File Preview &amp; Hash</h4>
            <asp:Label ID="lblPreviewMeta" runat="server" style="display:block;margin-bottom:8px;"></asp:Label>
            <pre id="prePreviewContent" style="background:#f0f0f0;border:1px solid #ccc;padding:10px;font-size:11px;max-height:220px;overflow:auto;white-space:pre-wrap;">
                <asp:Literal ID="litPreviewContent" runat="server" /></pre>
            <div style="margin-top:10px;">
                <asp:Button ID="btnConfirmImport" runat="server" Text="Confirm and Save Import Record"
                    OnClick="btnConfirmImport_Click"
                    style="background:#2a7a1c;color:white;border:none;padding:6px 18px;cursor:pointer;font-size:13px;" />
                &nbsp;
                <asp:Button ID="btnCancelUpload" runat="server" Text="Cancel"
                    OnClick="btnCancelUpload_Click"
                    style="background:#888;color:white;border:none;padding:6px 14px;cursor:pointer;font-size:13px;" />
            </div>
        </asp:Panel>

        <%-- ── EXISTING IMPORTS GRID ─────────────────────────────────────────── --%>
        <div style="margin-top:18px;border:1px solid #dbe8f5;padding:10px;background:#fafbff;">
            <asp:Label ID="lblImportChecklist" runat="server" Text="Validation checks: duplicate file hash, required metadata, statement date, line integrity." />
        </div>
        <asp:GridView ID="gvImports" runat="server" Width="100%" AutoGenerateColumns="false" GridLines="Horizontal" style="margin-top:10px;"
            OnRowCommand="gvImports_RowCommand">
            <HeaderStyle BackColor="#05275C" ForeColor="White" Font-Bold="True" />
            <AlternatingRowStyle BackColor="#f5f8ff" />
            <Columns>
                <asp:BoundField DataField="ImportId" HeaderText="Import ID" />
                <asp:BoundField DataField="OriginalFilename" HeaderText="File" />
                <asp:BoundField DataField="StatementDate" HeaderText="Statement Date" />
                <asp:BoundField DataField="ImportedBy" HeaderText="Imported By" />
                <asp:BoundField DataField="ValidationStatus" HeaderText="Validation Status" />
                <asp:BoundField DataField="ReconciliationStatus" HeaderText="Reco Status" />
                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <asp:LinkButton ID="lbValidateImport" runat="server"
                            CommandName="ValidateImport"
                            CommandArgument='<%# Eval("ImportId") %>'
                            style="color:#05275C;font-weight:bold;">Run Validation</asp:LinkButton>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
