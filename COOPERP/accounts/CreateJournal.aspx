<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CreateJournal.aspx.cs" Inherits="COOPERP_accounts_CreateJournal" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        .auto-style1 {
            width: 121px;
        }
        .auto-style2 {
            width: 176px;
        }
        .auto-style3 {
            width: 122px;
        }
        .auto-style4 {
            width: 175px;
        }
        .auto-style5 {
            width: 100%;
        }
        .auto-style6 {
        }
        


    *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
        
    }


    .style1
{
    width:100%;
}
    


        .auto-style7 {
            width: 169px;
        }
    


        .auto-style9 {
            width: 144px;
        }
    


        .auto-style10 {
            height: 242px;
        }
    


        .auto-style11 {
            width: 79px;
        }
        .auto-style12 {
            width: 173px;
        }
    


    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" ShowCollapseButton="true" Width="100%">
            <HeaderStyle HorizontalAlign="Center" />
            <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <table class="dx-justification">
                    <tr>
                        <td class="auto-style1">Journal Type:</td>
                        <td class="auto-style2">
                            <dx:ASPxComboBox ID="txtType" runat="server" DataSourceID="dsJournalTypes" TextField="journaltypename" ValueField="journaltypename" AutoPostBack="True" Height="35px">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="journaltypename" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style11">Ref No:</td>
                        <td>
                            <dx:ASPxTextBox ID="txtRefNo" runat="server" AutoPostBack="true" OnTextChanged="txtRefNo_TextChanged" Height="35px" Width="170px" />

                        </td>
                        <td></td>
                        <td></td>
                        <td>
                            <dx:ASPxButton ID="cmdCreateNew" runat="server" Height="35px" OnClick="cmdCreateNew_Click" Text="Create New" Width="170px">
                                <Image Url="~/COOPERP/images/tick-button.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style12">&nbsp;</td>
                        <td class="auto-style4">
                            &nbsp;</td>
                        <td class="auto-style3">
                            &nbsp;</td>
                        <td></td>
                        <td></td>
                        <td style="text-align: right">
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="auto-style10">
                <dx:ASPxGridView ID="gvParticulars" runat="server" AutoGenerateColumns="False" DataSourceID="dsLatestJournal" KeyFieldName="JournalNo" OnDataBound="gvParticulars_DataBound" Width="100%" OnCustomErrorText="gvParticulars_CustomErrorText" OnHtmlDataCellPrepared="gvParticulars_HtmlDataCellPrepared">
                    <SettingsPager Mode="ShowAllRecords">
                    </SettingsPager>
                    <SettingsEditing Mode="Batch">
                        <BatchEditSettings StartEditAction="Click" />
                    </SettingsEditing>
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="JournalNo" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="Teller" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Created By" ReadOnly="True">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="PostStatus" ShowInCustomizationForm="True" VisibleIndex="3" ReadOnly="True">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Type" FieldName="journalType" ShowInCustomizationForm="True" VisibleIndex="4" Width="200px" ReadOnly="True">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Entry Date" FieldName="journalDate" ShowInCustomizationForm="True" VisibleIndex="5">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Journal No" FieldName="journal_serialno" ShowInCustomizationForm="True" VisibleIndex="0">
                            <EditFormSettings Visible="False" />
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Memo" FieldName="journalParticulars" ShowInCustomizationForm="True" VisibleIndex="10" Width="300px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="voucherType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="GL_VoucherNo" ShowInCustomizationForm="True" VisibleIndex="7" Caption="GL Voucher No" Width="80px" ReadOnly="True">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Currency" FieldName="journal_currency" ShowInCustomizationForm="True" VisibleIndex="8" ReadOnly="True">
                            <PropertiesComboBox DataSourceID="dsCurrencies" TextField="code" TextFormatString="{0}" ValueField="code">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="code" Width="60px" />
                                    <dx:ListBoxColumn Caption="Currency" FieldName="currency_name" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Forex Rate" FieldName="forex_rate" ShowInCustomizationForm="True" VisibleIndex="9" ReadOnly="True">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0.00}">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="transactionDate" ShowInCustomizationForm="True" VisibleIndex="6" Caption="Invoice Date"   >
 
                            <EditFormSettings Visible="True" />
 
                        </dx:GridViewDataDateColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style7">
                            <dx:ASPxButton ID="cmdAddItem" runat="server" Height="35px" OnClick="cmdAddItem_Click" Text="Add Detail" Width="170px">
                                <Image Url="~/COOPERP/images/tick-button.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvDetails" runat="server" AutoGenerateColumns="False" DataSourceID="dsJournalDetails" KeyFieldName="TID" Width="100%" OnRowUpdated="gvDetails_RowUpdated" OnCustomErrorText="gvDetails_CustomErrorText" OnHtmlDataCellPrepared="gvParticulars_HtmlDataCellPrepared">
                    <SettingsContextMenu EnableColumnMenu="True" Enabled="True" EnableRowMenu="True">
                    </SettingsContextMenu>
                    <SettingsEditing Mode="Batch">
                    </SettingsEditing>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsDataSecurity AllowDelete="False" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="TID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Code" FieldName="accountcode" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="account_type" ShowInCustomizationForm="True" VisibleIndex="3" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="transaction_amount" ShowInCustomizationForm="True" VisibleIndex="12" Width="100px">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="particulars" ShowInCustomizationForm="True" VisibleIndex="5" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="voucherNo" ShowInCustomizationForm="True" VisibleIndex="6" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="transactionDate" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn FieldName="teller" ShowInCustomizationForm="True" VisibleIndex="9" Caption="Teller">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="timeLog" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn FieldName="curr_balance" ShowInCustomizationForm="True" VisibleIndex="13" Caption="Balance" Width="100px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="accountname" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Account Name">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="CR | DR" FieldName="transactionType" ShowInCustomizationForm="True" VisibleIndex="4" Width="30px">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="CR" Value="CR" />
                                    <dx:ListEditItem Text="DR" Value="DR" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Currency" FieldName="trans_currency" ShowInCustomizationForm="True" VisibleIndex="11" Width="60px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Journal No" FieldName="journal_no" ShowInCustomizationForm="True" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Delete" ShowInCustomizationForm="True" VisibleIndex="14" Width="25px">
                            <DataItemTemplate>
                                <dx:ASPxButton ID="cmdDelete" runat="server" Height="35px" OnClick="cmdDelete_Click" Width="25px">
                                    <ClientSideEvents Click="function(s, e) {
 e.processOnServer = confirm('Delete Voucher Item?'); 	
}" />
                                    <Image IconID="actions_cancel_16x16">
                                    </Image>
                                </dx:ASPxButton>
                            </DataItemTemplate>
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsLatestJournal" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetLatestJournal" TypeName="CoopERPDataTableAdapters.fin_journalnumbersTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_JournalNo" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="Teller" Type="String" />
                        <asp:Parameter Name="PostStatus" Type="String" />
                        <asp:Parameter Name="journalType" Type="String" />
                        <asp:Parameter Name="journalDate" Type="DateTime" />
                        <asp:Parameter Name="journalParticulars" Type="String" />
                        <asp:Parameter Name="journal_serialno" Type="UInt32" />
                        <asp:Parameter Name="journal_currency" Type="String" />
                        <asp:Parameter Name="GL_VoucherNo" Type="String" />
                        <asp:Parameter Name="voucherType" Type="String" />
                        <asp:Parameter Name="forex_rate" Type="Double" />
                        <asp:Parameter Name="transactionDate" Type="DateTime" />
                        <asp:Parameter Name="RefNo" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtType" Name="typ" PropertyName="Value" Type="String" />
                        <asp:SessionParameter Name="usr" SessionField="username" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Teller" Type="String" />
                        <asp:Parameter Name="PostStatus" Type="String" />
                        <asp:Parameter Name="journalType" Type="String" />
                        <asp:Parameter Name="journalDate" Type="DateTime" />
                        <asp:Parameter Name="journalParticulars" Type="String" />
                        <asp:Parameter Name="journal_serialno" Type="UInt32" />
                        <asp:Parameter Name="journal_currency" Type="String" />
                        <asp:Parameter Name="GL_VoucherNo" Type="String" />
                        <asp:Parameter Name="voucherType" Type="String" />
                        <asp:Parameter Name="forex_rate" Type="Double" />
                        <asp:Parameter Name="transactionDate" Type="DateTime" />
                        <asp:Parameter Name="RefNo" Type="String" />
                        <asp:Parameter Name="Original_JournalNo" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsJournalDetails" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetJournalDetails" TypeName="CoopERPDataTableAdapters.fin_ledgerTableAdapter" UpdateMethod="UpdateJournalDetails" InsertMethod="Insert">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_TID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="accountcode" Type="String" />
                        <asp:Parameter Name="account_type" Type="String" />
                        <asp:Parameter Name="transactionType" Type="String" />
                        <asp:Parameter Name="transaction_amount" Type="UInt64" />
                        <asp:Parameter Name="particulars" Type="String" />
                        <asp:Parameter Name="voucherNo" Type="UInt32" />
                        <asp:Parameter Name="transactionDate" Type="DateTime" />
                        <asp:Parameter Name="teller" Type="String" />
                        <asp:Parameter Name="timeLog" Type="DateTime" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="0" Name="jno" SessionField="jno" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="accountcode" Type="String" />
                        <asp:Parameter Name="account_type" Type="String" />
                        <asp:Parameter Name="transactionType" Type="String" />
                        <asp:Parameter Name="transaction_amount" Type="Decimal" />
                        <asp:Parameter Name="particulars" Type="String" />
                        <asp:Parameter Name="voucherNo" Type="Int32" />
                        <asp:Parameter Name="transactionDate" Type="DateTime" />
                        <asp:Parameter Name="teller" Type="String" />
                        <asp:Parameter Name="timeLog" Type="DateTime" />
                        <asp:Parameter Name="folio" Type="String" />
                        <asp:Parameter Name="curr_balance" Type="String" />
                        <asp:Parameter Name="journal_no" Type="String" />
                        <asp:Parameter Name="trans_currency" Type="String" />
                        <asp:Parameter Name="actual_amount" Type="Decimal" />
                        <asp:Parameter Name="Original_TID" Type="Int32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsJournalTypes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_journaltypesTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_journalTypeID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="journaltypename" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="journaltypename" Type="String" />
                        <asp:Parameter Name="Original_journalTypeID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsCurrencies" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_currencyTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_code" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="code" Type="String" />
                        <asp:Parameter Name="currency_name" Type="String" />
                        <asp:Parameter Name="rates" Type="Double" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="currency_name" Type="String" />
                        <asp:Parameter Name="rates" Type="Double" />
                        <asp:Parameter Name="Original_code" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_NewDetail" runat="server" CloseAction="CloseButton" HeaderText="New Detail" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                            <table class="auto-style5">
                                <tr>
                                    <td class="auto-style9">
                                        <br />
                                        <br />
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style9">Search:</td>
                                    <td>
                                        <dx:ASPxTextBox ID="txtSearch" runat="server" AutoPostBack="True" NullText="Account | Client Name eg Income" Width="250px" OnTextChanged="txtSearch_TextChanged" Height="35px">
                                            <ClientSideEvents TextChanged="function(s, e) {
	lp_details.Show();
}" />
                                            <Paddings PaddingLeft="5px" />
                                        </dx:ASPxTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style9">Account Name:</td>
                                    <td>
                                        <dx:ASPxComboBox ID="txtAccount" runat="server" DataSourceID="dsAccounts" SelectedIndex="0" TextField="AccountName" TextFormatString="{1}" ValueField="AccountCode" Width="250px" Height="35px">
                                            <Columns>
                                                <dx:ListBoxColumn FieldName="AccountCode" />
                                                <dx:ListBoxColumn FieldName="AccountName" Width="250px" />
                                                <dx:ListBoxColumn Caption="Category" FieldName="category" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style9">CR|DR</td>
                                    <td>
                                        <dx:ASPxComboBox ID="txtTransactionType" runat="server" SelectedIndex="0" Width="250px" Height="35px">
                                            <Items>
                                                <dx:ListEditItem Selected="True" Text="CR" Value="CR" />
                                                <dx:ListEditItem Text="DR" Value="DR" />
                                            </Items>
                                        </dx:ASPxComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style9">Forex Operation:</td>
                                    <td>
                                        <dx:ASPxRadioButtonList ID="rb_forex_op" runat="server" AutoPostBack="True" RepeatDirection="Horizontal" SelectedIndex="0" Width="250px">
                                            <Items>
                                                <dx:ListEditItem Selected="True" Text="Buying" Value="Buying" />
                                                <dx:ListEditItem Text="Selling" Value="Selling" />
                                            </Items>
                                        </dx:ASPxRadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style9">Forex Rate:</td>
                                    <td>
                                        <dx:ASPxTextBox ID="txtForexRate" runat="server" AutoPostBack="True" Height="35px" OnTextChanged="txtSearch_TextChanged" Text="1" Width="250px">
                                            <ClientSideEvents TextChanged="function(s, e) {
	lp_details.Show();
}" />
                                            <Paddings PaddingLeft="5px" />
                                        </dx:ASPxTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style9">&nbsp;</td>
                                    <td>
                                        <dx:ASPxButton ID="AddNewItem" runat="server" Height="35px" OnClick="AddNewItem_Click" Text="Add Item" Width="250px">
                                            <ClientSideEvents Click="function(s, e) {
	}" />
                                            <Image Url="~/COOPERP/images/tick-button.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style6" colspan="2">
                                        <asp:ObjectDataSource ID="dsAccounts" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_GetJournalAccountsTableAdapter">
                                            <SelectParameters>
                                                <asp:ControlParameter ControlID="txtSearch" DefaultValue="**" Name="txt" PropertyName="Text" Type="String" />
                                                <asp:SessionParameter DefaultValue="-" Name="typ" SessionField="JournalType" Type="String" />
                                            </SelectParameters>
                                        </asp:ObjectDataSource>
                                        <dx:ASPxLoadingPanel ID="lp_details" runat="server" ClientInstanceName="lp_details" HorizontalAlign="Center" Modal="True" VerticalAlign="Middle">
                                        </dx:ASPxLoadingPanel>
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_messagebox" runat="server" HeaderText="Academica ERP Version 3.0" Height="150px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                            <table class="style1">
                                <tr>
                                    <td height="30"></td>
                                </tr>
                                <tr>
                                    <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
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
    
    </div>
    </form>
</body>
</html>