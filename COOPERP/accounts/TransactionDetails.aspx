<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TransactionDetails.aspx.cs" Inherits="COOPERP_accounts_TransactionDetails" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
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
            height: 37px;
        }

    </style>
</head>
<body>
    <form id="form1" runat="server">

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td align="center" height="30">
                <dx:ASPxLabel ID="lbl_header" runat="server" Font-Bold="True" ForeColor="Red">
                </dx:ASPxLabel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvLedger" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsJournalTransactions" KeyFieldName="TID" 
                    Width="100%">
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="#" FieldName="accName" 
                            ShowInCustomizationForm="True" VisibleIndex="0" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entered By" FieldName="teller" 
                            ShowInCustomizationForm="True" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" 
                            ShowInCustomizationForm="True" VisibleIndex="7" Width="350px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Running Balance" FieldName="curr_balance" ShowInCustomizationForm="True" VisibleIndex="11" Width="100px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Journal No" FieldName="journal_no" ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Entry Date" FieldName="transactionDate" ShowInCustomizationForm="True" VisibleIndex="2" Width="150px">
                            <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="transaction_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="10" Width="80px">
                            <PropertiesTextEdit DisplayFormatString="{0:,0,0}">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="CR | DR" FieldName="transactionType" 
                            ShowInCustomizationForm="True" VisibleIndex="9" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Account Name" FieldName="accountname" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
<dx:GridViewDataTextColumn FieldName="accountcode" ShowInCustomizationForm="True" Caption="Account Code" VisibleIndex="4" Width="100px"></dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Transcation Date" FieldName="InvoiceDate" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn FieldName="RefNo" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" />
                    <SettingsPager Mode="ShowAllRecords">
                    </SettingsPager>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td class="auto-style1">
                <asp:ObjectDataSource ID="dsJournalTransactions" runat="server" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetSingleTransactionDetails" 
                    TypeName="CoopERPDataTableAdapters.fin_ledgerTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
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
                        <asp:SessionParameter DefaultValue="0" Name="Vno" SessionField="VNo" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="accountcode" Type="String" />
                        <asp:Parameter Name="account_type" Type="String" />
                        <asp:Parameter Name="transactionType" Type="String" />
                        <asp:Parameter Name="transaction_amount" Type="UInt64" />
                        <asp:Parameter Name="particulars" Type="String" />
                        <asp:Parameter Name="voucherNo" Type="UInt32" />
                        <asp:Parameter Name="transactionDate" Type="DateTime" />
                        <asp:Parameter Name="teller" Type="String" />
                        <asp:Parameter Name="timeLog" Type="DateTime" />
                        <asp:Parameter Name="Original_TID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>



    <div>
    
    </div>
    </form>
</body>
</html>
