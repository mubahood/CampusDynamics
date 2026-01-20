<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SupplierLedger.ascx.cs" Inherits="UserControls_Inventory_SupplierLedger" %>
<style type="text/css">




    
*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    
    .style1
    {
        width: 100%;
    }


    
    .style4
    {
        height: 23px;
    }


    
    .style2
    {
        height: 38px;
    }
    .style3
    {
        height: 42px;
    }

    .auto-style1 {
        height: 23px;
        width: 107px;
    }
    .auto-style2 {
        width: 107px;
    }
    .auto-style3 {
        height: 23px;
        width: 172px;
    }
    .auto-style5 {
        height: 23px;
        width: 81px;
    }
    .auto-style6 {
        width: 81px;
    }

    .auto-style7 {
        width: 172px;
    }

    .auto-style8 {
        height: 37px;
    }
    .auto-style9 {
        height: 18px;
    }
    .auto-style10 {
        height: 149px;
    }

    .auto-style11 {
        height: 31px;
    }

    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td align="center" height="30">
                <dx:ASPxLabel ID="lbl_header" runat="server" Font-Bold="True" ForeColor="Red">
                </dx:ASPxLabel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxImage ID="ASPxImage1" runat="server" Height="1px" 
                    ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                </dx:ASPxImage>
            </td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style1">
                            Supplier Code:</td>
                        <td class="auto-style3">
                            <dx:ASPxTextBox ID="txtAdmNo" runat="server" ReadOnly="True" Width="170px" Height="27px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxTextBox>
                        </td>
                        <td class="auto-style5">
                            <dx:ASPxButton ID="cmdInvoice" runat="server" Height="27px" OnClick="cmdInvoice_Click" Text="Capture Invoice" Width="170px">
                                <Image Url="~/COOPERP/images/clipboard-invoice.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="style4">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style2" valign="top">
                            &nbsp;</td>
                        <td class="auto-style7" valign="top">
                            <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" Text="Print Ledger" Width="170px" Height="27px">
                                <Image Url="~/COOPERP/images/printer.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style6" valign="top">
                            <dx:ASPxButton ID="cmdPayments" runat="server" Height="27px" OnClick="cmdPayments_Click" Text="Capture Payments" Width="170px">
                                <Image Url="~/COOPERP/images/cheque.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style2">
                            &nbsp;</td>
                        <td class="auto-style7">
                            &nbsp;</td>
                        <td class="auto-style6">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvLedger" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsJournalTransactions" KeyFieldName="TID" 
                    Width="100%" OnHtmlDataCellPrepared="gvLedger_HtmlDataCellPrepared">
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="#" FieldName="accName" 
                            ShowInCustomizationForm="True" VisibleIndex="0" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entry Date" FieldName="formated_date" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Width="150px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entered By" FieldName="teller" 
                            ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="CR" FieldName="cr_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="DR" FieldName="dr_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="8" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Balance" FieldName="curr_balance" ShowInCustomizationForm="True" VisibleIndex="9" Width="100px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Journal No" FieldName="voucherNo" ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="InvoiceDate" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Ref No" FieldName="ref_no" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" />
                    <SettingsPager Mode="ShowAllRecords">
                    </SettingsPager>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td class="auto-style8">
                <asp:ObjectDataSource ID="dsJournalTransactions" runat="server" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="InventoryAccountingTableAdapters.fin_GetLimitedSupplierLedgerTableAdapter">
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="0" Name="sid" SessionField="SupplierCode" Type="String" />
                        <asp:SessionParameter DefaultValue="" Name="sDate" SessionField="sDate" Type="DateTime" />
                        <asp:SessionParameter Name="eDate" SessionField="eDate" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsjounalInvoiceDate" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_GetSingleTransactionDetailsDateTableAdapter">
                    <SelectParameters>
                        <asp:SessionParameter Name="Vno" SessionField="VNo" Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td class="auto-style10">
                <dx:ASPxPopupControl ID="pop_msgbox" runat="server" 
                    HeaderText="Campus Dynamics ERP" Modal="True" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server" SupportsDisabledAttribute="True">
                            <table class="style1">
                                <tr>
                                    <td class="style2">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        &nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" 
                                            style="font-weight: 700;" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3">
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
                <dx:ASPxPopupControl ID="pop_transactions" runat="server" HeaderText="Campus Dynamics ERP :: Supplier Transactions" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td align="center" style="text-align: left">
                                        <br />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="text-align: center">
                                        <dx:ASPxLabel runat="server" ID="lbl_accountLabel" Font-Bold="True" ForeColor="#0000CC"></dx:ASPxLabel>

                                        <br />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="text-align: center">
                                        <dx:ASPxTextBox ID="txtRefNo" runat="server" Height="27px" NullText="Ref No" Width="100%">
                                            <Paddings PaddingLeft="5px" />
                                        </dx:ASPxTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" class="auto-style9" style="text-align: center">
                                        <dx:ASPxComboBox ID="txtAccountName" runat="server" DataSourceID="dsPayeeAccounts" Height="27px" SelectedIndex="0" TextField="accountName" TextFormatString="{0} : {1}" ValueField="accountCode" Width="100%">
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Code" FieldName="accountCode" Width="80px" />
                                                <dx:ListBoxColumn Caption="Account Name" FieldName="accountName" Width="200px" />
                                            </Columns>
                                            <Paddings PaddingLeft="5px" />
                                        </dx:ASPxComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="text-align: left" class="auto-style11">
                                        <dx:ASPxTextBox ID="txtAmount" runat="server" Height="27px" NullText="Transaction Amount" Width="100%">
                                            <Paddings PaddingLeft="5px" />
                                        </dx:ASPxTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" class="auto-style11" style="text-align: left">
                                        <dx:ASPxDateEdit ID="txtInvoiceDate" runat="server" NullText="Invoice Date" Width="100%">
                                        </dx:ASPxDateEdit>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="text-align: left">
                                        <dx:ASPxMemo ID="txtParticulars" runat="server" Height="71px" NullText="Particulars of transaction" Width="100%">
                                        </dx:ASPxMemo>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="text-align: left">
                                        <dx:ASPxButton ID="cmdAddTransaction" runat="server" Height="27px" OnClick="cmdAddTransaction_Click" Text="Add Transaction" Width="100%">
                                            <Image Url="~/COOPERP/images/tick-button.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="text-align: left">
                                        <br />
                                        <asp:ObjectDataSource ID="dsPayeeAccounts" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_GetPayeeAccountsTableAdapter">
                                            <SelectParameters>
                                                <asp:SessionParameter DefaultValue="BANK" Name="typ" SessionField="typ" Type="String" />
                                            </SelectParameters>
                                        </asp:ObjectDataSource>
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
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>