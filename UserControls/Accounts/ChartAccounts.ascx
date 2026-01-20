<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ChartAccounts.ascx.cs" Inherits="UserControls_Accounts_ChartAccounts" %>
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
            <dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" 
                HeaderText="Chart of Accounts  Management Centre" Width="100%" 
    ShowHeader="False">
                <HeaderImage Url="~/COOPERP/images/clipboard-list.png">
                </HeaderImage>
                <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <table class="style1">
                        <tr>
                            <td>
                                <table cellpadding="0" cellspacing="0" class="style1">
                                    <tr>
                                        <td style="text-align: center">
                                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                                ImageUrl="~/COOPERP/images/header_chartofaccounts.png">
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
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <table cellspacing="0" class="style1">
                                    <tr>
                                        <td>
                                            <dx:ASPxButton ID="cmdAdd" runat="server" OnClick="cmdAdd_Click" 
                                                Text="New Category" Width="170px" Height="35px">
                                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                </Image>
                                            </dx:ASPxButton>
                                            <dx:ASPxButton ID="cmdExport" runat="server" Height="35px" OnClick="cmdExport_Click" Text="Export To Excel" Width="170px" HorizontalAlign="left">
                                                <Image IconID="export_exporttoxls_16x16">
                                                </Image>
                                                            
                                            </dx:ASPxButton>
                                            
                                        </td>
                                        <td align="right">
                                            <dx:ASPxButton ID="cmdCategories" runat="server" OnClick="cmdCategories_Click" 
                                                Text="Ledger Types &amp; Currencies" Width="250px" Height="35px">
                                                <Image Url="~/COOPERP/images/clipboard-invoice.png">
                                                </Image>
                                            </dx:ASPxButton>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxGridView ID="gvMainAccounts" runat="server" AutoGenerateColumns="False" 
                                    DataSourceID="dsMainAccounts" KeyFieldName="AccountCode" Width="100%" OnHtmlDataCellPrepared="gvMainAccounts_HtmlDataCellPrepared">
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="AccountCode" 
                                            ShowInCustomizationForm="True" VisibleIndex="0" Caption="Category Code" 
                                            Width="80px">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="AccountName" 
                                            ShowInCustomizationForm="True" VisibleIndex="1" Caption="Category">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="GeneralCategory" 
                                            ShowInCustomizationForm="True" VisibleIndex="3" Caption="Classification" 
                                            Width="100px">
                                            <EditFormSettings Visible="True" />
                                            <EditItemTemplate>
                                                <dx:ASPxComboBox ID="txtData" runat="server" AutoPostBack="True" 
                                                    onselectedindexchanged="txtData_SelectedIndexChanged" SelectedIndex="0" 
                                                    Value='<%# Bind("GeneralCategory") %>' ValueType="System.String" 
                                                    IncrementalFilteringMode="StartsWith" EnableIncrementalFiltering="True">
                                                    <Items>
                                                        <dx:ListEditItem Text="Assets" Value="Assets" />
                                                        <dx:ListEditItem Text="Expense" Value="Expense" />
                                                        <dx:ListEditItem Text="Income" Value="Income" />
                                                        <dx:ListEditItem Text="Liabilities" Value="Liabilities" />
                                                        <dx:ListEditItem Text="Equity" Value="Equity" />
                                                        <dx:ListEditItem Text="-" Value="-" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </EditItemTemplate>
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="SubCategory" 
                                            ShowInCustomizationForm="True" VisibleIndex="4" Caption="Sub Class" 
                                            Visible="False">
                                            <EditFormSettings Visible="True" />
                                            <EditItemTemplate>
                                                <dx:ASPxComboBox ID="txtData" runat="server" 
                                                    Value='<%# Bind("SubCategory") %>' ValueType="System.String" 
                                                    IncrementalFilteringMode="StartsWith">
                                                </dx:ASPxComboBox>
                                            </EditItemTemplate>
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="True" VisibleIndex="6" Width="50px" ShowEditButton="True" ShowDeleteButton="True"/>
                                    </Columns>
                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                    <SettingsEditing EditFormColumnCount="1" />
                                    <Settings ShowFilterRowMenu="True" />
                                    <SettingsSearchPanel Visible="True" />
                                    <SettingsText CommandCancel=" | Cancel |" CommandEdit="| " 
                                        CommandUpdate="| Save Changes |" ConfirmDelete="Delete Current Account?" />
                                    <SettingsDetail AllowOnlyOneMasterRowExpanded="True" ShowDetailRow="True" />
                                    <Templates>
                                        <DetailRow>
                                            <table id="table1" class="style1">
                                                <tr>
                                                    <td>
                                                        <dx:ASPxButton ID="cmdAddAccount" runat="server" OnClick="cmdAddAccount_Click" Text="New Account" Visible="False" Width="170px" Height="35px">
                                                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                            </Image>
                                                        </dx:ASPxButton>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td >
                                                        
                                                    
                                                        <dx:ASPxGridView ID="gvAccounts" runat="server" AutoGenerateColumns="False" DataSourceID="dsAccounts" KeyFieldName="AccountCode" onbeforeperformdataselect="gvAccounts_BeforePerformDataSelect" oncustomerrortext="gvHouseHold_CustomErrorText" oninitnewrow="gvAccounts_InitNewRow" Width="100%" OnHtmlDataCellPrepared="gvMainAccounts_HtmlDataCellPrepared">
                                                            <SettingsSearchPanel Visible="True" />
                                                          
                                                            <Columns>
                                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" VisibleIndex="8" Width="50px" />
                                                                <dx:GridViewCommandColumn ShowClearFilterButton="True" ShowNewButton="True" VisibleIndex="0" Width="30px" />
                                                                <dx:GridViewDataTextColumn FieldName="AccountCode" ReadOnly="True" VisibleIndex="1" Width="50px">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="MainAccountCode" Visible="False" VisibleIndex="2">
                                                                    <EditFormSettings Visible="True" />
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="AccountName" VisibleIndex="3">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Account Type" FieldName="accounttype" VisibleIndex="5">
                                                                    <PropertiesComboBox IncrementalFilteringMode="StartsWith" ValueType="System.String">
                                                                        <Items>
                                                                            <dx:ListEditItem Text="Basic Account" Value="Basic Account" />
                                                                            <dx:ListEditItem Text="Collection Account" Value="Collection Account" />
                                                                        </Items>
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Ledger Category" FieldName="collectionLedgerType" VisibleIndex="4">
                                                                    <PropertiesComboBox DataSourceID="dsCategories" IncrementalFilteringMode="Contains" TextField="LedgerTypeName" TextFormatString="{0} : {1}" ValueField="LedgerTypeName" ValueType="System.String">
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                                <dx:GridViewDataTextColumn FieldName="Details" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataComboBoxColumn Caption="Base Currency" FieldName="base_currency" VisibleIndex="6" Width="25px">
                                                                    <PropertiesComboBox DataSourceID="dsCurrencies" TextField="code" TextFormatString="{0}" ValueField="code">
                                                                        <Columns>
                                                                            <dx:ListBoxColumn Caption="Code" FieldName="code" Width="25px" />
                                                                            <dx:ListBoxColumn Caption="Currency" FieldName="currency_name" />
                                                                        </Columns>
                                                                    </PropertiesComboBox>
                                                                </dx:GridViewDataComboBoxColumn>
                                                            </Columns>
                                                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                            <Settings ShowFilterRowMenu="True" />
                                                        </dx:ASPxGridView>
                                                        

                                                    </td>
                                                </tr>
                                            </table>
                                            
                                        </DetailRow>
                                    </Templates>
                                    <SettingsCommandButton RenderMode="Button"><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Button"></CancelButton>
                                        <EditButton>
                                            <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                            </Image>
                                        </EditButton>
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
                                <dx:ASPxGridView ID="gvExportTemp" runat="server" Visible="false">
</dx:ASPxGridView>
<dx:ASPxGridViewExporter ID="gveExportTemp" runat="server" GridViewID="gvExportTemp" />

                                <asp:ObjectDataSource ID="dsMainAccounts" runat="server" InsertMethod="AddCategory" 
                                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetMainAccounts" 
                                    TypeName="AccountsBLL" UpdateMethod="UpdateCategory" 
                                    DeleteMethod="DeleteCategory">
                                    <DeleteParameters>
                                        <asp:Parameter Name="AccountCode" Type="String" />
                                        <asp:Parameter Name="original_AccountCode" Type="String" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="AccountCode" Type="String" />
                                        <asp:Parameter Name="AccountName" Type="String" />
                                        <asp:Parameter Name="GeneralCategory" Type="String" />
                                        <asp:Parameter Name="SubCategory" Type="String" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="AccountName" Type="String" />
                                        <asp:Parameter Name="GeneralCategory" Type="String" />
                                        <asp:Parameter Name="SubCategory" Type="String" />
                                        <asp:Parameter Name="AccountCode" Type="String" />
<asp:Parameter Name="original_AccountCode" Type="String"></asp:Parameter>
                                    </UpdateParameters>
                                </asp:ObjectDataSource>
                                <asp:ObjectDataSource ID="dsCurrencies" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_currencyTableAdapter"></asp:ObjectDataSource>
                                <asp:ObjectDataSource ID="dsAccounts" runat="server" 
                                    DeleteMethod="Delete" InsertMethod="Insert" 
                                    OldValuesParameterFormatString="original_{0}" 
                                    SelectMethod="GetAccountsbyCategory" TypeName="CoopERPDataTableAdapters.fin_subaccountsTableAdapter" 
                                    UpdateMethod="Update">
                                    <DeleteParameters>
                                        <asp:Parameter Name="original_AccountCode" Type="String" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="AccountCode" Type="String" />
                                        <asp:Parameter Name="MainAccountCode" Type="String" />
                                        <asp:Parameter Name="AccountName" Type="String" />
                                        <asp:Parameter Name="Details" Type="String" />
                                        <asp:Parameter Name="collectionLedgerType" Type="String" />
                                        <asp:Parameter Name="accounttype" Type="String" />
                                        <asp:Parameter Name="base_currency" Type="String" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="MainACC" SessionField="CategoryCode" 
                                            Type="String" DefaultValue="-" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="AccountCode" Type="String" />
                                        <asp:Parameter Name="MainAccountCode" Type="String" />
                                        <asp:Parameter Name="AccountName" Type="String" />
                                        <asp:Parameter Name="Details" Type="String" />
                                        <asp:Parameter Name="collectionLedgerType" Type="String" />
                                        <asp:Parameter Name="accounttype" Type="String" />
                                        <asp:Parameter Name="base_currency" Type="String" />
                                        <asp:Parameter Name="original_AccountCode" Type="String" />
                                    </UpdateParameters>
                                </asp:ObjectDataSource>
                                <asp:ObjectDataSource ID="dsCategories" runat="server" 
                                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllLedgerTypes" 
                                    TypeName="AccountsBLL"></asp:ObjectDataSource>
                                <dx:ASPxGridViewExporter ID="gve_charts" runat="server" ExportedRowType="All">
                                </dx:ASPxGridViewExporter>
                                <br />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxPopupControl ID="pop_categories" runat="server" 
                                    ContentUrl="~/COOPERP/accounts/ledgerTypes.aspx" HeaderText="" Modal="True" 
                                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                                    <ContentCollection>
                                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                                        </dx:PopupControlContentControl>
                                    </ContentCollection>
                                </dx:ASPxPopupControl>
                            </td>
                        </tr>
                    </table>
                    </dx:PanelContent>
</PanelCollection>
            </dx:ASPxRoundPanel>



        
