<%@ Page Language="C#" AutoEventWireup="true" CodeFile="JournalDisplay.aspx.cs" Inherits="COOPERP_accounts_JournalDisplay" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        .auto-style1 {
            width: 94px;
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
    


        .auto-style5 {
            height: 138px;
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
                            <dx:ASPxComboBox ID="txtType" runat="server" DataSourceID="dsJournalTypes" TextField="journaltypename" ValueField="journaltypename" AutoPostBack="True" Height="35px" ReadOnly="True" Enabled="False" Width="250px">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="journaltypename" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style4">
                            <dx:ASPxButton ID="cmdPrintJournal" runat="server" OnClick="cmdPrintJournal_Click" Text="Print Journals" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/printer.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style3">
                            &nbsp;</td>
                        <td style="text-align: right">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style1">&nbsp;</td>
                        <td class="auto-style2">
                            <dx:ASPxRadioButtonList ID="rb_openingBalance" runat="server" Height="35px" RepeatDirection="Horizontal" SelectedIndex="0" Visible="False" Width="250px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Normal Journal" Value="Normal Journal" />
                                    <dx:ListEditItem Text="Opening Balance" Value="Opening Balance" />
                                </Items>
                            </dx:ASPxRadioButtonList>
                        </td>
                        <td class="auto-style4">&nbsp;</td>
                        <td class="auto-style3">&nbsp;</td>
                        <td style="text-align: right">&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="auto-style5">
                <dx:ASPxGridView ID="gvParticulars" runat="server" AutoGenerateColumns="False" DataSourceID="dsLatestJournal" KeyFieldName="JournalNo" OnDataBound="gvParticulars_DataBound" Width="100%" OnCustomErrorText="gvParticulars_CustomErrorText" OnHtmlDataCellPrepared="gvParticulars_HtmlDataCellPrepared">
                    <SettingsPager Mode="ShowAllRecords">
                    </SettingsPager>
                    <SettingsEditing Mode="Inline">
                        <BatchEditSettings StartEditAction="Click" />
                    </SettingsEditing>
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="JournalNo" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="Teller" ShowInCustomizationForm="True" VisibleIndex="3" Caption="Created By">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="PostStatus" ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Type" FieldName="journalType" ShowInCustomizationForm="True" VisibleIndex="5" Width="150px">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Entry Date" FieldName="journalDate" ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Journal No" FieldName="journal_serialno" ShowInCustomizationForm="True" VisibleIndex="0">
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Memo" FieldName="journalParticulars" ShowInCustomizationForm="True" VisibleIndex="9" Width="300px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="voucherType" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="GL_VoucherNo" ShowInCustomizationForm="True" VisibleIndex="8" Caption="GL Voucher No" Width="80px">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Transcation Date" FieldName="transactionDate" ShowInCustomizationForm="True" VisibleIndex="7">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Ref No" FieldName="RefNo" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvDetails" runat="server" AutoGenerateColumns="False" DataSourceID="dsJournalDetails" KeyFieldName="TID" Width="100%" OnRowUpdated="gvDetails_RowUpdated" OnCustomErrorText="gvDetails_CustomErrorText" OnHtmlDataCellPrepared="gvParticulars_HtmlDataCellPrepared">
                    <SettingsContextMenu EnableColumnMenu="True" Enabled="True" EnableRowMenu="True">
                    </SettingsContextMenu>
                    <SettingsEditing Mode="Batch">
                    </SettingsEditing>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="TID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Code" FieldName="accountcode" ShowInCustomizationForm="True" VisibleIndex="1" Width="120px">
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
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsLatestJournal" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSingleJournal" TypeName="CoopERPDataTableAdapters.fin_journalnumbersTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_JournalNo" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="Teller" Type="String" />
                        <asp:Parameter Name="PostStatus" Type="String" />
                        <asp:Parameter Name="Journaltype" Type="String" />
                        <asp:Parameter Name="journalDate" Type="DateTime" />
                        <asp:Parameter Name="journalParticulars" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter Name="JNO" SessionField="jno" Type="Int32" DefaultValue="0" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Teller" Type="String" />
                        <asp:Parameter Name="PostStatus" Type="String" />
                        <asp:Parameter Name="Journaltype" Type="String" />
                        <asp:Parameter Name="journalDate" Type="DateTime" />
                        <asp:Parameter Name="journalParticulars" Type="String" />
                        <asp:Parameter Name="Original_JournalNo" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsJournalDetails" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetJournalDetails" TypeName="CoopERPDataTableAdapters.fin_ledgerTableAdapter" UpdateMethod="UpdateJournalDetails">
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
                <asp:ObjectDataSource ID="dsJournalTypes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_journaltypesTableAdapter"></asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsCurrencies" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_currencyTableAdapter"></asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_messagebox" runat="server" HeaderText="Campus Dynamics ERP Version 1.0" Height="150px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
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