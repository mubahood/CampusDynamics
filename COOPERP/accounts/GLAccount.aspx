<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GLAccount.aspx.cs" Inherits="COOPERP_accounts_GLAccount" %>

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


    
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="rp_gl_listing" runat="server" ShowCollapseButton="true" Width="100%">
            <ContentPaddings Padding="20px" />
            <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxButton ID="cmdPrint" runat="server" Height="27px" OnClick="cmdPrint_Click" Text="Export Excel" Width="170px">
                    <Image Url="~/COOPERP/images/document-excel-table.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gv_gl" runat="server" AutoGenerateColumns="False" DataSourceID="ds_gl_listing" KeyFieldName="TID" Width="100%">
                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                    <SettingsBehavior AllowFocusedRow="True" />
                    <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="TID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Code" FieldName="accountcode" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Type" FieldName="account_type" ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="CR|DR" FieldName="transactionType" ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="transaction_amount" ShowInCustomizationForm="True" VisibleIndex="10">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Particulars" FieldName="particulars" ShowInCustomizationForm="True" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Voucher No" FieldName="voucherNo" ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Date" FieldName="transactionDate" ShowInCustomizationForm="True" VisibleIndex="7">
                            <PropertiesDateEdit DisplayFormatString="dd-MMM-yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Created By" FieldName="teller" ShowInCustomizationForm="True" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn FieldName="timeLog" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn FieldName="curr_balance" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Account Name" FieldName="accountname" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="journal_no" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="trans_currency" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowClearFilterButton="True" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="ds_gl_listing" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetPeriodicGL" TypeName="CoopERPDataTableAdapters.fin_ledgerTableAdapter" UpdateMethod="Update">
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
                        <asp:SessionParameter Name="s_date" SessionField="s_date" Type="DateTime" />
                        <asp:SessionParameter Name="e_date" SessionField="e_date" Type="DateTime" />
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
                <dx:ASPxGridViewExporter ID="gve_gl_listing" runat="server" ExportedRowType="All" GridViewID="gv_gl">
                </dx:ASPxGridViewExporter>
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
