<%@ Control Language="C#" AutoEventWireup="true" CodeFile="LedgersCentre.ascx.cs" Inherits="UserControls_Accounts_LedgersCentre" %>
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

    .style4
    {
        height: 23px;
    }
    .auto-style1 {
        height: 23px;
        width: 121px;
    }
    .auto-style2 {
        width: 121px;
    }
    .auto-style3 {
        height: 23px;
        width: 283px;
    }
    .auto-style4 {
        width: 283px;
    }
    .auto-style5 {
        height: 23px;
        width: 113px;
    }
    .auto-style6 {
        width: 113px;
    }
    .auto-style7 {
        width: 109px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_ledgercentre.png">
                            </dx:ASPxImage>
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
                <table class="style1">
                    <tr>
                        <td class="auto-style1">
                            &nbsp;</td>
                        <td class="auto-style3">
                            &nbsp;</td>
                        <td class="auto-style5">
                            &nbsp;</td>
                        <td class="style4">
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style1">Account Category:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtPayeeCategory" runat="server" AutoPostBack="True" DataSourceID="dsLedgerCategories" Height="35px" TextField="LedgerTypeCategory" ValueField="LedgerTypeCategory" Width="250px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Category" FieldName="LedgerTypeCategory" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style5">Account Name:</td>
                        <td class="style4">
                            <dx:ASPxComboBox ID="txtPayee" runat="server" AutoPostBack="True" DataSourceID="dsPayeeAccounts" Height="35px" TextField="accountName" TextFormatString="{1}" ValueField="accountCode" Width="250px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="accountCode" Width="60px" />
                                    <dx:ListBoxColumn Caption="Payee" FieldName="accountName" Width="250px" />
                                </Columns>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2" valign="top">
                            Ledger Type:</td>
                        <td class="auto-style4" valign="top">
                            <dx:ASPxComboBox ID="txtLedgerType" runat="server" DataSourceID="dsLedgerTypes" 
                                TextField="LedgerTypeName" ValueField="LedgerTypeName" 
                                ValueType="System.String" Width="250px" AutoPostBack="True" Height="35px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Ledger" FieldName="LedgerTypeName" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style6" valign="top">
                            Start Date:</td>
                        <td>
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True" 
                                Width="250px" DisplayFormatString="dd/MM/yyyy" Height="35px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxDateEdit>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2">
                            &nbsp;</td>
                        <td class="auto-style4">
                            <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" 
                                Text="Print Ledger" Width="250px" Height="35px">
                                <Image Url="~/COOPERP/images/printer.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style6">
                            End Date:</td>
                        <td>
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True" 
                                Width="250px" DisplayFormatString="dd/MM/yyyy" Height="35px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxDateEdit>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2">&nbsp;</td>
                        <td class="auto-style4">
                            <dx:ASPxButton ID="cmdAdjustments" runat="server" AutoPostBack="False" Height="35px" Text="Adjustments" Width="250px">
                                <Image IconID="tasks_edittask_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style6">Display Currency:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtDisplayCurrency" runat="server" AutoPostBack="True" DataSourceID="dsCurrency" Height="35px" SelectedIndex="0" TextField="code" TextFormatString="{0}" ValueField="code" Width="250px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="code" Width="60px" />
                                </Columns>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvLedger" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsJournalTransactions" KeyFieldName="voucherno" 
                    Width="100%" OnHtmlRowCreated="gvLedger_HtmlRowCreated"
                    EnableViewState="False">
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="Summary" FieldName="title" 
                            ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Date" FieldName="transactiondate" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entered By" FieldName="teller" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="CR" FieldName="cramount" 
                            ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="DR" FieldName="dramount" 
                            ShowInCustomizationForm="True" VisibleIndex="8" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Balance" FieldName="curr_balance" ShowInCustomizationForm="True" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="voucherno" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Details" ShowInCustomizationForm="True" VisibleIndex="10" Width="25px">
                            <DataItemTemplate>
                                <asp:ImageButton ID="cmdDetails" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="cmdDetails_Click" />
                            </DataItemTemplate>
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn Caption="Currency" FieldName="curr" ShowInCustomizationForm="True" VisibleIndex="6" Width="50px">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" />
                    <SettingsPager PageSize="50" AlwaysShowPager="True" Position="Bottom">
                    </SettingsPager>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsPayeeAccounts" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="CoopERPDataTableAdapters.fin_GetPayeeAccountsTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtPayeeCategory" Name="typ" 
                            PropertyName="Value" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsCurrency" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_currencyTableAdapter"></asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsJournalTransactions" runat="server" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="CoopERPDataTableAdapters.fin_GetAccountLedgerTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtPayee" Name="accno" PropertyName="Value" 
                            Type="String" />
                        <asp:ControlParameter ControlID="txtStartDate" Name="sDate" 
                            PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" 
                            Type="DateTime" />
                        <asp:ControlParameter ControlID="txtLedgerType" Name="typ" PropertyName="Value" 
                            Type="String" />
                        <asp:ControlParameter ControlID="txtDisplayCurrency" Name="displayCurr" PropertyName="Value" Type="String" />
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
                <dx:ASPxLoadingPanel ID="panel_billling" runat="server" ClientInstanceName="panel_billling" Modal="True" Text="Processing...Please wait&amp;hellip;">
                </dx:ASPxLoadingPanel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_msgbox" runat="server" 
                    HeaderText="Campus Dynamics ERP" Modal="True" 
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
                <dx:ASPxPopupControl ID="pop_adjustments" runat="server" HeaderText="Campus Dynamics ERP :: Adjustment Settings" Modal="True" PopupElementID="cmdAdjustments" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="450px">
                    <HeaderImage IconID="tasks_edittask_16x16">
                    </HeaderImage>
                    <ContentStyle>
                        <Paddings Padding="10px" />
                    </ContentStyle>
                    <HeaderStyle HorizontalAlign="Center">
                    <Paddings Padding="15px" />
                    </HeaderStyle>
                    <ModalBackgroundStyle BackColor="#0066FF">
                    </ModalBackgroundStyle>
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td class="style2"></td>
                                </tr>
                                <tr>
                                    <td class="style3">
                                        <table class="style1">
                                            <tr>
                                                <td class="auto-style7">Adjustment:</td>
                                                <td>
                                                    <dx:ASPxComboBox ID="txtType" runat="server" ClientInstanceName="cboAdjType" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="100%">
                                                        <Items>
                                                            <dx:ListEditItem Selected="True" Text="Request Reversal" Value="Request Reversal" />
                                                            <dx:ListEditItem Text="Request Correction" Value="Request Correction" />
                                                        </Items>
                                                        <Paddings PaddingLeft="10px" />
                                                    </dx:ASPxComboBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="auto-style7">New Amount:</td>
                                                <td>
                                                    <dx:ASPxTextBox ID="txtNewAmount" runat="server" Height="35px" Text="0" Width="100%">
                                                        <Paddings PaddingLeft="10px" />
                                                    </dx:ASPxTextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="auto-style7">Request Notes:</td>
                                                <td>
                                                    <dx:ASPxMemo ID="txt_reason" runat="server" Height="71px" Width="100%">
                                                    </dx:ASPxMemo>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="auto-style7">&nbsp;</td>
                                                <td>
                                                    <dx:ASPxButton ID="cmdProcess" runat="server" Height="35px" OnClick="cmdProcess_Click" Text="Process Adjustment" Width="100%">
                                                        <ClientSideEvents Click="function(s, e) {
    var op = cboAdjType.GetValue() || 'adjustment';
    var msg = 'Continue with ' + op + ' for the selected transaction?\n\nYou will be redirected into the Finance System Realignment approval workflow.';
    e.processOnServer = confirm(msg);
    if (e.processOnServer) { panel_billling.Show(); }
}" />
                                                        <Image IconID="tasks_edittask_16x16">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style3">&nbsp;</td>
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


