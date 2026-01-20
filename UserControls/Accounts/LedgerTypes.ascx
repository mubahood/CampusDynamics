<%@ Control Language="C#" AutoEventWireup="true" CodeFile="LedgerTypes.ascx.cs" Inherits="UserControls_Accounts_LedgerTypes" %>
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
    HeaderText="Ledger Types" Width="100%">
    <HeaderImage Url="~/COOPERP/images/clipboard-invoice.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
        <TabPages>
            <dx:TabPage Text=" Ledger Types">
                <TabImage IconID="filterelements_listbox_16x16">
                </TabImage>
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <table class="style1">
                            <tr>
                                <td>
                                    <dx:ASPxButton ID="cmdAdd" runat="server" Height="35px" OnClick="cmdAdd_Click" Text="New Category" Width="170px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxGridView ID="gvLedgerTypes" runat="server" AutoGenerateColumns="False" DataSourceID="dsLedgerTypes" KeyFieldName="LedgerTypeID" Width="100%">
                                        <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                        <SettingsCommandButton>
                                            <UpdateButton RenderMode="Link">
                                            </UpdateButton>
                                            <CancelButton RenderMode="Link">
                                            </CancelButton>
                                            <EditButton>
                                                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                </Image>
                                            </EditButton>
                                            <DeleteButton>
                                                <Image Url="~/COOPERP/images/minus-button.png">
                                                </Image>
                                            </DeleteButton>
                                        </SettingsCommandButton>
                                        <SettingsSearchPanel Visible="True" />
                                        <Columns>
                                            <dx:GridViewDataTextColumn Caption="SNo" FieldName="LedgerTypeID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Width="25px">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Ledger Type" FieldName="LedgerTypeName" ShowInCustomizationForm="True" VisibleIndex="2">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Category" FieldName="LedgerTypeCategory" ShowInCustomizationForm="True" VisibleIndex="1">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn ButtonRenderMode="Image" ButtonType="Image" ShowClearFilterButton="True" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="3" Width="40px">
                                            </dx:GridViewCommandColumn>
                                        </Columns>
                                    </dx:ASPxGridView>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:ObjectDataSource ID="dsLedgerTypes" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_ledgertypesTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_LedgerTypeID" Type="UInt32" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="LedgerTypeName" Type="String" />
                                            <asp:Parameter Name="LedgerTypeCategory" Type="String" />
                                        </InsertParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="LedgerTypeName" Type="String" />
                                            <asp:Parameter Name="LedgerTypeCategory" Type="String" />
                                            <asp:Parameter Name="Original_LedgerTypeID" Type="UInt32" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                        </table>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            <dx:TabPage Text=" Currency Info">
                <TabImage IconID="miscellaneous_currency_16x16">
                </TabImage>
                <ContentCollection>
                    <dx:ContentControl runat="server">
                        <table class="style1">
                            <tr>
                                <td>
                                    <dx:ASPxButton ID="cmdAddCurrency" runat="server" Height="35px" OnClick="cmdAddCurrency_Click" Text="New Currency" Width="170px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxGridView ID="gvCurrencyList" runat="server" AutoGenerateColumns="False" DataSourceID="dsCurrencyInfo" KeyFieldName="code" Width="100%">
                                        <SettingsContextMenu Enabled="True">
                                        </SettingsContextMenu>
                                        <SettingsEditing Mode="EditForm">
                                        </SettingsEditing>
                                        <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                        <SettingsCommandButton>
                                            <UpdateButton RenderMode="Link">
                                            </UpdateButton>
                                            <CancelButton RenderMode="Link">
                                            </CancelButton>
                                            <EditButton>
                                                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                </Image>
                                            </EditButton>
                                            <DeleteButton>
                                                <Image Url="~/COOPERP/images/minus-button.png">
                                                </Image>
                                            </DeleteButton>
                                        </SettingsCommandButton>
                                        <SettingsSearchPanel Visible="True" />
                                        <Columns>
                                            <dx:GridViewDataTextColumn Caption="Code" FieldName="code" ShowInCustomizationForm="True" VisibleIndex="1">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Currency Name" FieldName="currency_name" ShowInCustomizationForm="True" VisibleIndex="2">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Sale Rate" FieldName="rates" ShowInCustomizationForm="True" VisibleIndex="3" Width="100px">
                                                <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                </PropertiesTextEdit>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataTextColumn Caption="Buy Rate" FieldName="buy_rates" ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                                                <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                </PropertiesTextEdit>
                                            </dx:GridViewDataTextColumn>
                                        </Columns>
                                    </dx:ASPxGridView>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:ObjectDataSource ID="dsCurrencyInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_currencyTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_code" Type="String" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="code" Type="String" />
                                            <asp:Parameter Name="currency_name" Type="String" />
                                            <asp:Parameter Name="rates" Type="Double" />
                                            <asp:Parameter Name="buy_rates" Type="Double" />
                                        </InsertParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="code" Type="String" />
                                            <asp:Parameter Name="currency_name" Type="String" />
                                            <asp:Parameter Name="rates" Type="Double" />
                                            <asp:Parameter Name="buy_rates" Type="Double" />
                                            <asp:Parameter Name="Original_code" Type="String" />
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

