<%@ Control Language="C#" AutoEventWireup="true" CodeFile="bankcharges.ascx.cs" Inherits="UserControls_financials_bankcharges" %>
<style type="text/css">
        .style1
        {
            width: 100%;
        }
    </style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Bank Charge Rates" Width="100%">
            <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" 
                    Text="Add New" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvBankRates" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsBankRates" KeyFieldName="BankCode" Width="100%">
                    <Columns>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="35px" ShowClearFilterButton="True"/>
                        <dx:GridViewDataTextColumn FieldName="BankCode" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="60px">
                            <EditItemTemplate>
                                <dx:ASPxComboBox ID="txtData" runat="server" DataSourceID="dsBankAccounts" 
                                    IncrementalFilteringMode="Contains" TextField="AccountName" 
                                    TextFormatString="{1}" Value='<%# Bind("BankCode") %>' ValueField="AccountCode" 
                                    ValueType="System.String" Width="100%">
                                    <Columns>
                                        <dx:ListBoxColumn FieldName="AccountCode" Width="100px" />
                                        <dx:ListBoxColumn FieldName="AccountName" Width="300px" />
                                    </Columns>
                                </dx:ASPxComboBox>
                            </EditItemTemplate>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="BankCharge" 
                            ShowInCustomizationForm="True" VisibleIndex="3" Width="100px">
                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Account Name" FieldName="accountName" 
                            ShowInCustomizationForm="True" VisibleIndex="2">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="True" VisibleIndex="4" Width="45px" ShowEditButton="True" ShowDeleteButton="True" ShowClearFilterButton="True"/>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
                        <EditButton>
                            <Image Url="~/COOPERP/images/clipboard--pencil.png" ToolTip="Edit">
                            </Image>
                        </EditButton>
                        <DeleteButton>
                            <Image Url="~/COOPERP/images/minus-button.png" ToolTip="Delete">
                            </Image>
                        </DeleteButton>
                    </SettingsCommandButton>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsBankAccounts" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="AccountingDataTableAdapters.fin_AccountFinderTableAdapter">
                    <SelectParameters>
                        <asp:Parameter DefaultValue="Bank" Name="cat" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsBankRates" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetBankChargesData" 
                    TypeName="StudentAccountingDataTableAdapters.bankchargeratesTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_BankCode" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="BankCode" Type="String" />
                        <asp:Parameter Name="BankCharge" Type="UInt32" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="BankCharge" Type="UInt32" />
                        <asp:Parameter Name="Original_BankCode" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
                </dx:PanelContent>
</PanelCollection>
        </dx:ASPxRoundPanel>
