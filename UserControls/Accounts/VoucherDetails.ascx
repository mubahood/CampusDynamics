<%@ Control Language="C#" AutoEventWireup="true" CodeFile="VoucherDetails.ascx.cs" Inherits="UserControls_Accounts_PaymentVoucher" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }


    *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
        
    }


    .style5
    {
        width: 99px;
    }
    .style7
    {
        width: 250px;
        height: 25px;
    }
    .style9
    {
        width: 349px;
    }
    .style10
    {
        width: 116px;
    }
    .style12
    {
        width: 115px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td align="center">
                            <dx:ASPxLabel ID="lbl_header" runat="server" Font-Bold="True" 
                                ForeColor="#FF3300">
                            </dx:ASPxLabel>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" 
                                ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="style10">
                            Voucher No:</td>
                        <td class="style9">
                            <table cellpadding="0" cellspacing="0" class="style7">
                                <tr>
                                    <td bgcolor="Black">
                                        &nbsp;&nbsp;
                                        <dx:ASPxLabel ID="lbl_VoucherNo" runat="server" Font-Bold="True" 
                                            Font-Italic="False" ForeColor="White" Text="5656">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td class="style5">
                            Status:</td>
                        <td>
                            <dx:ASPxTextBox ID="txtStatus" runat="server" ForeColor="Red" ReadOnly="True" 
                                Text="New" Width="250px">
                            </dx:ASPxTextBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="style10">
                            Paid From:</td>
                        <td class="style9">
                            <dx:ASPxComboBox ID="txtBankAccount" runat="server" DataSourceID="dsBanks" 
                                TextField="AccountName" TextFormatString="{1}" ValueField="AccountCode" 
                                ValueType="System.String" Width="250px">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="AccountCode" Width="60px" />
                                    <dx:ListBoxColumn FieldName="AccountName" Width="250px" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5">
                            Date:</td>
                        <td>
                            <dx:ASPxDateEdit ID="txtDate" runat="server" Width="250px">
                            </dx:ASPxDateEdit>
                        </td>
                    </tr>
                    <tr>
                        <td class="style10">
                            &nbsp;</td>
                        <td class="style9">
                            &nbsp;</td>
                        <td class="style5">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                </table>
                <p>
                    <dx:ASPxImage ID="ASPxImage3" runat="server" Height="1px" 
                        ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                    </dx:ASPxImage>
                </p>
                <table class="style1">
                    <tr>
                        <td class="style12">
                            &nbsp;</td>
                        <td class="style9">
                            &nbsp;</td>
                        <td class="style5">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style12">
                            Payee Category:</td>
                        <td class="style9">
                            <dx:ASPxComboBox ID="txtPayeeCategory" runat="server" AutoPostBack="True" 
                                SelectedIndex="0" ValueType="System.String" Width="250px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Supplier" Value="Supplier" />
                                    <dx:ListEditItem Text="Employee" Value="Employee" />
                                    <dx:ListEditItem Text="Expense Account" Value="Expense" />
                                    <dx:ListEditItem Text="Member" Value="Member" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5">
                            Pay To:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtPayee" runat="server" DataSourceID="dsPayeeAccounts" 
                                TextField="accountName" TextFormatString="{1}" ValueField="accountCode" 
                                ValueType="System.String" Width="250px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="accountCode" Width="60px" />
                                    <dx:ListBoxColumn Caption="Payee" FieldName="accountName" Width="250px" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="style12">
                            Ledger Type:</td>
                        <td class="style9">
                            <dx:ASPxComboBox ID="txtLedgerType" runat="server" DataSourceID="dsLedgerTypes" 
                                TextField="LedgerTypeName" ValueField="LedgerTypeName" 
                                ValueType="System.String" Width="250px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Ledger" FieldName="LedgerTypeName" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5" valign="top" rowspan="2">
                            Particulars:</td>
                        <td rowspan="2">
                            <dx:ASPxMemo ID="txtParticulars" runat="server" Height="50px" Width="250px">
                            </dx:ASPxMemo>
                        </td>
                    </tr>
                    <tr>
                        <td class="style12" valign="top">
                            Amount:</td>
                        <td class="style9" valign="top">
                            <dx:ASPxTextBox ID="txtAmount" runat="server" Text="0" Width="250px">
                            </dx:ASPxTextBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="style12">
                            &nbsp;</td>
                        <td class="style9">
                            &nbsp;</td>
                        <td class="style5">
                            &nbsp;</td>
                        <td>
                            <dx:ASPxButton ID="cmdPreview" runat="server" OnClick="cmdPreview_Click1" 
                                Text="View Voucher" Width="250px">
                                <Image Url="~/COOPERP/images/printer.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvJournalEntries" runat="server" 
                    AutoGenerateColumns="False" DataSourceID="dsVoucherTransactions" 
                    KeyFieldName="TID" Width="100%">
                    <Columns>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="20px" ShowClearFilterButton="True"/>
                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="TID" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Account Code" FieldName="accountcode" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Width="70px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="CR/DR" FieldName="transactionType" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="transaction_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Created By" FieldName="teller" 
                            ShowInCustomizationForm="True" VisibleIndex="8" Width="100px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Account" FieldName="accountname" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="True" VisibleIndex="10" Width="20px" ShowDeleteButton="True" ShowClearFilterButton="True"/>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
                        <DeleteButton>
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </DeleteButton>
                    </SettingsCommandButton>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsBanks" runat="server" 
                    OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetSelectedAccounts" 
                    TypeName="CoopERPDataTableAdapters.fin_subaccountsTableAdapter">
                    <SelectParameters>
                        <asp:Parameter DefaultValue="Bank" Name="acctype" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsVoucherTransactions" runat="server" 
                    DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetDataByVoucherNo" 
                    TypeName="CoopERPDataTableAdapters.fin_voucherTableAdapter">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_TID" Type="UInt32" />
                    </DeleteParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="0" Name="VNo" SessionField="VNo" 
                            Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsPayeeAccounts" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="CoopERPDataTableAdapters.fin_GetPayeeAccountsTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtPayeeCategory" Name="typ" 
                            PropertyName="Value" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsLedgerTypes" runat="server" 
                    OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetPaymentLedgerTypes" 
                    TypeName="CoopERPDataTableAdapters.fin_ledgertypesTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtPayeeCategory" Name="typ" 
                            PropertyName="Value" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_preview" runat="server" CloseAction="CloseButton" 
                    HeaderText="" PopupHorizontalAlign="WindowCenter" 
                    PopupVerticalAlign="WindowCenter" 
                    ContentUrl="~/COOPERP/accounts/VoucherPreview.aspx">
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_messagebox" runat="server" 
                    HeaderText="Cooperative ERP Version 1.0" Height="150px" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                            <table class="style1">
                                <tr>
                                    <td height="30">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <dx:ASPxImage ID="img_msg" runat="server" ImageAlign="AbsBottom">
                                        </dx:ASPxImage>
                                        &nbsp;<dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

