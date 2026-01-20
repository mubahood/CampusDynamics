<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CashBook.ascx.cs" Inherits="UserControls_Accounts_CashBook" %>
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
    .auto-style5 {
        height: 23px;
        width: 113px;
    }
    .auto-style6 {
        width: 113px;
    }
    .auto-style9 {
        height: 23px;
        width: 87px;
    }
    .auto-style10 {
        width: 87px;
    }
    .auto-style11 {
        height: 23px;
        width: 268px;
    }
    .auto-style12 {
        width: 268px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table id="table1" class="style1">
                <tr>
                    <td>
                        <table id="table2" cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_cashbook.png" >
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png"  Width="100%">
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table id="table3" class="style1">
                            <tr>
                                <td class="auto-style5"></td>
                                <td class="auto-style11"></td>
                                <td class="auto-style9"></td>
                                <td class="style4"></td>
                            </tr>
                            <tr>
                                <td class="auto-style5">Bank Account:</td>
                                <td class="auto-style11">
                                    <dx:ASPxComboBox ID="txtPayee" runat="server" AutoPostBack="True" DataSourceID="dsPayeeAccounts" Height="27px" SelectedIndex="0" TextField="accountName" TextFormatString="{1}" ValueField="accountCode" Width="250px">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="accountCode" Width="60px" />
                                            <dx:ListBoxColumn Caption="Payee" FieldName="accountName" Width="250px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style9">Start Date:</td>
                                <td class="style4">
                                    <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True" DisplayFormatString="dd/MM/yyyy" Height="27px" Width="170px">
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxDateEdit>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style6" valign="top">&nbsp;</td>
                                <td class="auto-style12">
                                    <dx:ASPxButton ID="cmdPrint" runat="server" Height="27px" OnClick="cmdPrint_Click" Text="Print Ledger" Width="250px">
                                        <Image Url="~/COOPERP/images/printer.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="auto-style10">End Date:</td>
                                <td>
                                    <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True" DisplayFormatString="dd/MM/yyyy" Height="27px" Width="170px">
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxDateEdit>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style6">&nbsp;</td>
                                <td class="auto-style12">&nbsp;</td>
                                <td class="auto-style10">&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvLedger" runat="server" AutoGenerateColumns="False" DataSourceID="dsJournalTransactions" KeyFieldName="transactiondate" Width="100%">
                            <SettingsPager PageSize="500">
                            </SettingsPager>
                            <SettingsBehavior AllowFocusedRow="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="#" FieldName="title" VisibleIndex="0">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Date" FieldName="transactiondate" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Entered By" FieldName="teller" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="CR" FieldName="cramount" VisibleIndex="5" Width="80px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="DR" FieldName="dramount" VisibleIndex="6" Width="80px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Balance" FieldName="curr_balance" VisibleIndex="7">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Details" VisibleIndex="8" Width="25px">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="imgDetails" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="imgDetails_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="voucherno" Visible="False" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsPayeeAccounts" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_GetPayeeAccountsTableAdapter">
                            <SelectParameters>
                                <asp:Parameter DefaultValue="Bank" Name="typ" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsJournalTransactions" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_GetAccountLedgerTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtPayee" Name="accno" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtStartDate" Name="sDate" PropertyName="Value" Type="DateTime" />
                                <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" Type="DateTime" />
                                <asp:Parameter DefaultValue="Chart Account" Name="typ" Type="String" />
                                <asp:Parameter DefaultValue="UGX" Name="displayCurr" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_msgbox" runat="server" HeaderText="Campus Dynamics ERP" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td class="style2"></td>
                                        </tr>
                                        <tr>
                                            <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" ForeColor="Red" style="font-weight: 700;">
                                                </dx:ASPxLabel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="style3"></td>
                                        </tr>
                                    </table>
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>