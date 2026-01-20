<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentJournalsDetails.ascx.cs" Inherits="UserControls_Accounts_StudentJournalsDetails" %>
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


    
    .style2
    {
        height: 38px;
    }
    .style3
    {
        height: 42px;
    }

    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td align="center">
                <dx:ASPxLabel ID="lbl_header" runat="server" Font-Bold="True" 
                    ForeColor="#FF3300">
                </dx:ASPxLabel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxImage ID="ASPxImage3" runat="server" Height="1px" 
                    ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                </dx:ASPxImage>
            </td>
        </tr>
        <tr>
            <td>
                <strong>Journal Memo:</strong></td>
        </tr>
        <tr>
            <td>
                <dx:ASPxLabel ID="lbl_memo" runat="server" style="font-style: italic">
                </dx:ASPxLabel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxImage ID="ASPxImage4" runat="server" Height="1px" 
                    ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                </dx:ASPxImage>
            </td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="style12">
                            Account Category:</td>
                        <td class="style9">
                            <dx:ASPxComboBox ID="txtPayeeCategory" runat="server" AutoPostBack="True" 
                                DataSourceID="dsLedgerCategories" SelectedIndex="3" 
                                TextField="LedgerTypeCategory" ValueField="LedgerTypeCategory" 
                                ValueType="System.String" Width="250px" 
                                OnSelectedIndexChanged="txtPayeeCategory_SelectedIndexChanged">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Category" FieldName="LedgerTypeCategory" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5">
                            Search:</td>
                        <td>
                            <dx:ASPxTextBox ID="txtSearch" runat="server" AutoPostBack="True" 
                                NullText="Enter Name eg Kato" OnTextChanged="txtYear_NumberChanged" 
                                Width="250px">
                            </dx:ASPxTextBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="style12" valign="top">
                            Ledger Type:</td>
                        <td class="style9" valign="top">
                            <dx:ASPxComboBox ID="txtLedgerType" runat="server" DataSourceID="dsLedgerTypes" 
                                TextField="LedgerTypeName" ValueField="LedgerTypeName" 
                                ValueType="System.String" Width="250px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Ledger" FieldName="LedgerTypeName" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5" valign="top">
                            Account:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtPayee" runat="server" DataSourceID="dsPayeeAccounts" 
                                IncrementalFilteringMode="Contains" TextField="accountName" 
                                TextFormatString="{1}" ValueField="accountCode" ValueType="System.String" 
                                Width="250px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="accountCode" Width="120px" />
                                    <dx:ListBoxColumn Caption="Payee" FieldName="accountName" Width="250px" />
                                    <dx:ListBoxColumn Caption="Details" FieldName="details" Width="250px" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="style12">
                            CR/DR</td>
                        <td class="style9">
                            <dx:ASPxComboBox ID="txtDR_CR" runat="server" SelectedIndex="0" 
                                ValueType="System.String" Width="250px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="CR" Value="CR" />
                                    <dx:ListEditItem Text="DR" Value="DR" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5">
                            Amount:</td>
                        <td>
                            <dx:ASPxTextBox ID="txtAmount" runat="server" Text="0" Width="250px">
                            </dx:ASPxTextBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="style12">
                            Term:</td>
                        <td class="style9">
                            <dx:ASPxComboBox ID="txtTerm" runat="server" AutoPostBack="True" 
                                SelectedIndex="0" ValueType="System.String" Width="250px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                    <dx:ListEditItem Text="4" Value="4" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style5">
                            &nbsp;</td>
                        <td>
                            <dx:ASPxButton ID="cmdNew" runat="server" OnClick="cmdNew_Click" 
                                Text="Add New Entry" Width="250px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                    <tr>
                        <td class="style12">
                            Year:</td>
                        <td class="style9">
                            <dx:ASPxSpinEdit ID="txtYear" runat="server" AutoPostBack="True" Height="21px" 
                                MaxValue="3000" MinValue="2008" Number="2008" 
                                OnNumberChanged="txtYear_NumberChanged" Width="250px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxSpinEdit>
                        </td>
                        <td class="style5">
                            &nbsp;</td>
                        <td>
                            <dx:ASPxButton ID="cmdPost" runat="server" OnClick="cmdPost_Click" 
                                Text="Post to Ledger" Width="250px">
                                <Image Url="~/COOPERP/images/tick-button.png">
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
                    AutoGenerateColumns="False" DataSourceID="dsJournalTransactions" 
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
                <asp:ObjectDataSource ID="dsPayeeAccounts" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetStudentPayee" 
                    TypeName="CoopERPDataTableAdapters.fin_GetPayeeAccountsTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtSearch" Name="txt" 
                            PropertyName="Text" Type="String" />
                        <asp:ControlParameter ControlID="txtTerm" Name="trm" PropertyName="Value" 
                            Type="Int32" />
                        <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Number" 
                            Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsJournalTransactions" runat="server" 
                    DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetDataByJournalNo" 
                    TypeName="CoopERPDataTableAdapters.fin_journalTableAdapter">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_TID" Type="UInt32" />
                    </DeleteParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="0" Name="JNo" SessionField="JNo" 
                            Type="Int32" />
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
                <asp:ObjectDataSource ID="dsLedgerCategories" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="CoopERPDataTableAdapters.fin_GetLedgerCategoriesTableAdapter">
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_msgbox" runat="server" 
                    HeaderText="Academica ERP Version 3.0" Modal="True" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                            <table class="style1">
                                <tr>
                                    <td class="style2">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <dx:ASPxImage ID="img_msg" runat="server" ImageAlign="AbsBottom">
                                        </dx:ASPxImage>
                                        &nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" 
                                            style="font-weight: 700;">
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
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>


