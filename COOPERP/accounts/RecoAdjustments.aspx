<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RecoAdjustments.aspx.cs" Inherits="COOPERP_accounts_RecoAdjustments" %>

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


        .auto-style1 {
            width: 73px;
        }


    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Reconciliation Adjustments" ShowCollapseButton="true" Width="100%">
            <HeaderStyle HorizontalAlign="Center" />
            <PanelCollection>
<dx:PanelContent runat="server">
    <table id="table1" class="dx-justification">
        <tr>
            <td>
                <table id="table2" class="dxeBinImgCPnlSys">
                    <tr>
                        <td class="auto-style1">Category:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtAdjustmentCategory" runat="server" AutoPostBack="True" SelectedIndex="0" Width="220px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Unpresented Cheques" Value="Unpresented Cheques" />
                                    <dx:ListEditItem Text="Uncredited Deposits" Value="Uncredited Deposits" />
                                    <dx:ListEditItem Text="Direct Debits" Value="Direct Debits" />
                                    <dx:ListEditItem Text="Direct Credits" Value="Direct Credits" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvAdjustments" runat="server" AutoGenerateColumns="False" DataSourceID="dsAdjustments" KeyFieldName="ID" Width="100%">
                    <SettingsContextMenu Enabled="True">
                    </SettingsContextMenu>
                    <SettingsEditing Mode="Inline">
                    </SettingsEditing>
                    <Settings ShowFooter="True" />
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Adjustment Account" FieldName="adj_account" ShowInCustomizationForm="True" VisibleIndex="1" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Transaction Type" FieldName="trans_type" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="RID" FieldName="recoID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Bank Code" FieldName="bank_code" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="amount" ShowInCustomizationForm="True" VisibleIndex="6">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                            <FooterCellStyle Font-Bold="True" ForeColor="Red">
                            </FooterCellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="7" Width="30px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                    <TotalSummary>
                        <dx:ASPxSummaryItem DisplayFormat="TOTAL: {0:0,0}" FieldName="amount" ShowInColumn="Amount" ShowInGroupFooterColumn="Amount" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                    </TotalSummary>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsAdjustments" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAdjustmentByReconciliation" TypeName="CoopERPDataTableAdapters.fin_reco_adjustmentsTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="adj_account" Type="String" />
                        <asp:Parameter Name="trans_type" Type="String" />
                        <asp:Parameter Name="recoID" Type="UInt32" />
                        <asp:Parameter Name="bank_code" Type="String" />
                        <asp:Parameter Name="amount" Type="Double" />
                        <asp:Parameter Name="particulars" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter Name="RID" SessionField="RID" Type="Int32" />
                        <asp:ControlParameter ControlID="txtAdjustmentCategory" Name="cat" PropertyName="Value" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="adj_account" Type="String" />
                        <asp:Parameter Name="trans_type" Type="String" />
                        <asp:Parameter Name="recoID" Type="UInt32" />
                        <asp:Parameter Name="bank_code" Type="String" />
                        <asp:Parameter Name="amount" Type="Double" />
                        <asp:Parameter Name="particulars" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsAccounts" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_subaccountsTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_AccountCode" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="AccountCode" Type="String" />
                        <asp:Parameter Name="MainAccountCode" Type="String" />
                        <asp:Parameter Name="AccountName" Type="String" />
                        <asp:Parameter Name="Details" Type="String" />
                        <asp:Parameter Name="collectionLedgerType" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="MainAccountCode" Type="String" />
                        <asp:Parameter Name="AccountName" Type="String" />
                        <asp:Parameter Name="Details" Type="String" />
                        <asp:Parameter Name="collectionLedgerType" Type="String" />
                        <asp:Parameter Name="Original_AccountCode" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
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
