<%@ Control Language="C#" AutoEventWireup="true" CodeFile="billitems.ascx.cs" Inherits="UserControls_financials_billitems" %>
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


    </style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Accounts: Fees Structure Settings" Width="100%">
            <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
        <TabPages>
            <dx:TabPage Text=" Billing Items">
                <TabImage IconID="functionlibrary_financial_16x16">
                </TabImage>
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <table id="table1" class="style1">
                            <tr>
                                <td>
                                    <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" Text="Add New" Width="170px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxGridView ID="gvBillingItems" runat="server" AutoGenerateColumns="False" DataSourceID="dsBillItems" KeyFieldName="ItemCode" Width="100%">
                                        <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" ProcessSelectionChangedOnServer="True" />
                                        <SettingsSearchPanel Visible="True" />
                                        <Columns>
                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="4" Width="50px">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataTextColumn Caption="Code" FieldName="ItemCode" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0">
                                                <EditFormSettings Visible="False" />
                                                <BatchEditModifiedCellStyle HorizontalAlign="Left">
                                                </BatchEditModifiedCellStyle>
                                                <CellStyle HorizontalAlign="Left">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" VisibleIndex="1">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="PriorityCode" ShowInCustomizationForm="True" VisibleIndex="3" Caption="Mandatory" Width="100px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataComboBoxColumn FieldName="AccountCode" ShowInCustomizationForm="True" VisibleIndex="2">
                                                <PropertiesComboBox DataSourceID="dsAccounts" TextField="AccountName" TextFormatString="{0} : {1}" ValueField="AccountCode">
                                                </PropertiesComboBox>
                                            </dx:GridViewDataComboBoxColumn>
                                        </Columns>
                                    </dx:ASPxGridView>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:ObjectDataSource ID="dsBillItems" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentAccountingDataTableAdapters.academicbillingitemsTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_ItemCode" Type="UInt32" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="ItemName" Type="String" />
                                            <asp:Parameter Name="AccountCode" Type="String" />
                                            <asp:Parameter Name="PriorityCode" Type="Byte" />
                                        </InsertParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="ItemName" Type="String" />
                                            <asp:Parameter Name="AccountCode" Type="String" />
                                            <asp:Parameter Name="PriorityCode" Type="Byte" />
                                            <asp:Parameter Name="Original_ItemCode" Type="UInt32" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                    <asp:ObjectDataSource ID="dsAccounts" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSelectedAccounts" TypeName="CoopERPDataTableAdapters.fin_subaccountsTableAdapter" UpdateMethod="Update">
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
                                        <SelectParameters>
                                            <asp:Parameter DefaultValue="Income" Name="acctype" Type="String" />
                                        </SelectParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="AccountCode" Type="String" />
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
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            <dx:TabPage Text=" Registration Percentage">
                <TabImage IconID="businessobjects_boreport_16x16">
                </TabImage>
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <table class="style1">
                            <tr>
                                <td>
                                    <dx:ASPxCardView ID="cvRegPercantage" runat="server" AutoGenerateColumns="False" DataSourceID="dsRegPercantage" KeyFieldName="ID" Width="100%">
                                        <SettingsEditing Mode="Batch">
                                            <BatchEditSettings StartEditAction="Click" />
                                        </SettingsEditing>
                                        <SettingsDataSecurity AllowDelete="False" AllowInsert="False" />
                                        <Columns>
                                            <dx:CardViewTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                            </dx:CardViewTextColumn>
                                            <dx:CardViewTextColumn Caption="Payment Percentage" FieldName="pay_percent" ShowInCustomizationForm="True" VisibleIndex="1">
                                            </dx:CardViewTextColumn>
                                        </Columns>
                                        <CardLayoutProperties>
                                            <Items>
                                                <dx:CardViewCommandLayoutItem HorizontalAlign="Right">
                                                </dx:CardViewCommandLayoutItem>
                                                <dx:CardViewLayoutGroup Caption="Registration Requirements">
                                                    <Items>
                                                        <dx:EmptyLayoutItem>
                                                        </dx:EmptyLayoutItem>
                                                        <dx:CardViewColumnLayoutItem ColumnName="pay_percent">
                                                        </dx:CardViewColumnLayoutItem>
                                                        <dx:EmptyLayoutItem>
                                                        </dx:EmptyLayoutItem>
                                                    </Items>
                                                </dx:CardViewLayoutGroup>
                                                <dx:EditModeCommandLayoutItem HorizontalAlign="Right">
                                                </dx:EditModeCommandLayoutItem>
                                            </Items>
                                        </CardLayoutProperties>
                                    </dx:ASPxCardView>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:ObjectDataSource ID="dsRegPercantage" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="AdjustmentsCentreTableAdapters.fin_registration_percentTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="pay_percent" Type="Double" />
                                        </InsertParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="pay_percent" Type="Double" />
                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                        </table>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
        </TabPages>
        <TabStyle>
            <Paddings Padding="10px" />
        </TabStyle>
    </dx:ASPxPageControl>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
