    <%@ Control Language="C#" AutoEventWireup="true" CodeFile="AccountingPeriods.ascx.cs" Inherits="UserControls_Accounts_ChartAccounts" %>
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


        .auto-style1 {
            height: 18px;
        }
        .auto-style2 {
            height: 45px;
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
                                                <dx:ASPxButton ID="cmdAdd" runat="server" OnClick="cmdAdd_Click1" 
                                                    Text="Add Finacial Period" Width="170px" Height="35px">
                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td align="right">
                                                &nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxGridView ID="gvFinacialPeriods" runat="server" AutoGenerateColumns="False" 
                                        DataSourceID="dsFinacialPeriods" KeyFieldName="id" Width="100%" OnHtmlDataCellPrepared="gvMainAccounts_HtmlDataCellPrepared"
                                        OnCellEditorInitialize="gvFinacialPeriods_CellEditorInitialize">
                                        <Columns>
                                            <dx:GridViewCommandColumn Caption="Action" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="5" Width="200px">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataTextColumn FieldName="id" 
                                                ShowInCustomizationForm="True" VisibleIndex="0" ReadOnly="True" Visible="False">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                       
                                           <dx:GridViewDataComboBoxColumn FieldName="finacial_Year"
                                   Caption="Finacial Year"
                                   VisibleIndex="1">
        <PropertiesComboBox ValueType="System.String"
                            DropDownStyle="DropDownList">
        </PropertiesComboBox>
    </dx:GridViewDataComboBoxColumn>


                                            <dx:GridViewDataDateColumn Caption="Opening Date" FieldName="start_date" ShowInCustomizationForm="True" VisibleIndex="2">
                                            </dx:GridViewDataDateColumn>
                                            <dx:GridViewDataDateColumn Caption="Closing Date" FieldName="end_date" ShowInCustomizationForm="True" VisibleIndex="3">
                                            </dx:GridViewDataDateColumn>
                                            <dx:GridViewDataComboBoxColumn 
        FieldName="status"
        Caption="Status"
        VisibleIndex="4">

        <PropertiesComboBox 
            ValueType="System.String"
            DropDownStyle="DropDownList">
            <Items>
                <dx:ListEditItem Text="Open" Value="Open" />
                <dx:ListEditItem Text="Closed" Value="Closed" />
            </Items>
        </PropertiesComboBox>

    </dx:GridViewDataComboBoxColumn>


                                        </Columns>
                                        <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                        <SettingsEditing EditFormColumnCount="1" />
                                        <Settings ShowFilterRowMenu="True" />
                                        <SettingsSearchPanel Visible="True" />
                                        <SettingsText CommandCancel=" | Cancel |" CommandEdit="| " 
                                            CommandUpdate="| Save Changes |" ConfirmDelete="Delete Current Account?" />
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
                                                        <td>
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
                                <td class="auto-style1">
                                    <asp:ObjectDataSource ID="dsFinacialPeriods" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_financial_yearsTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_id" Type="Int32" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="finacial_Year" Type="String" />
                                            <asp:Parameter Name="start_date" Type="DateTime" />
                                            <asp:Parameter Name="end_date" Type="DateTime" />
                                            <asp:Parameter Name="status" Type="String" />
                                        </InsertParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="finacial_Year" Type="String" />
                                            <asp:Parameter Name="start_date" Type="DateTime" />
                                            <asp:Parameter Name="end_date" Type="DateTime" />
                                            <asp:Parameter Name="status" Type="String" />
                                            <asp:Parameter Name="Original_id" Type="Int32" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                            <tr>
                             <td class="auto-style2">
    <dx:ASPxPopupControl ID="pop_error" runat="server" 
        Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        ShowCloseButton="True" CloseAction="CloseButton" Width="400px" Height="150px">
        <ContentCollection>
            <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server" SupportsDisabledAttribute="True">
                <asp:Label ID="lblError" runat="server" Text="" CssClass="error-label" />
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
</td>



</td>


                            </tr>
                        </table>
                        </dx:PanelContent>
    </PanelCollection>

                </dx:ASPxRoundPanel>
        
