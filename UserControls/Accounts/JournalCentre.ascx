<%@ Control Language="C#" AutoEventWireup="true" CodeFile="JournalCentre.ascx.cs" Inherits="UserControls_Accounts_JournalCentre" %>
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


    .style12
    {
        height: 18px;
    }
    .style13
    {
        width: 65px;
    }
    .style15
    {
        width: 63px;
    }
    .style16
    {
        width: 186px;
    }
    .style17
    {
        width: 189px;
    }
    .style18
    {
        width: 88px;
    }
    .style21
    {
        width: 214px;
    }
    .style22
    {
        width: 112px;
    }
    .style23
    {
        width: 40px;
    }
    .style24
    {
    }
    .style29
    {
        width: 177px;
    }
    .style30
    {
        width: 172px;
    }
    .auto-style1 {
        width: 161px;
    }
    .auto-style2 {
        width: 164px;
    }
    .auto-style3 {
        width: 93px;
    }
    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="img_headerimg" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_journals.png">
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
            <td class="style12">
                </td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style3">
                            Voucher Type:</td>
                        <td class="style13">
                            <dx:ASPxComboBox ID="txtJournalType" runat="server" AutoPostBack="True" Height="35px" TextField="journaltypename" ValueField="journaltypename" Width="170px" SelectedIndex="1">
                                <Items>
                                    <dx:ListEditItem Text="Contra" Value="Contra" />
                                    <dx:ListEditItem Selected="True" Text="Journal" Value="Journal" />
                                    <dx:ListEditItem Text="Receipt" Value="Receipt" />
                                    <dx:ListEditItem Text="Payment" Value="Payment" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style13">
                            &nbsp;</td>
                        <td class="style13">Start Date:</td>
                        <td class="auto-style1">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True" DisplayFormatString="dd MMMM yyyy" Height="35px" Width="170px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxDateEdit>
                        </td>
                        <td class="style15">
                            &nbsp;</td>
                        <td class="auto-style2">
                            &nbsp;</td>
                        <td class="style18">
                            &nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style3">Document Type:</td>
                        <td class="style13">
                            <dx:ASPxComboBox ID="txtReceiptType" runat="server" AutoPostBack="True" Height="35px" Width="170px" SelectedIndex="0">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Student Receipt" Value="Student Receipt" />
                                    <dx:ListEditItem Text="Sponsor Receipt" Value="Sponsor Receipt" />
                                    <dx:ListEditItem Text="Sponsorship Distribution" Value="Sponsorship Distribution" />
                                    <dx:ListEditItem Text="Donation" Value="Donation" />
                                    <dx:ListEditItem Text="Payment Voucher" Value="Payment Voucher" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style13">&nbsp;</td>
                        <td class="style13">End Date:</td>
                        <td class="auto-style1">
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True" DisplayFormatString="dd MMMM yyyy" Height="35px" Width="170px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxDateEdit>
                        </td>
                        <td class="style15">&nbsp;</td>
                        <td class="auto-style2">&nbsp;</td>
                        <td class="style18">&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style3">&nbsp;</td>
                        <td class="style13">
                            <dx:ASPxButton ID="cmdWizard" runat="server" Height="35px" OnClick="cmdNew_Click" Text="Journal Wizard" Width="170px">
                                <Image Url="~/COOPERP/images/wand.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="style13">&nbsp;</td>
                        <td class="style13">&nbsp;</td>
                        <td class="auto-style1">&nbsp;</td>
                        <td class="style15">&nbsp;</td>
                        <td class="auto-style2">&nbsp;</td>
                        <td class="style18">&nbsp;</td>
                        <td align="right">
                            <dx:ASPxButton ID="cmdDetails" runat="server" Height="35px" OnClick="cmdDetails_Click" Text="Details" Width="170px">
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
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td>
                            &nbsp;</td>
                        <td align="right">
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvJournals" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsJournals" KeyFieldName="JournalNo" 
                    OnInitNewRow="gvJournals_InitNewRow" Width="100%" 
                    ClientInstanceName="gvJournals" OnRowDeleting="gvJournals_RowDeleting" OnHtmlDataCellPrepared="gvJournals_HtmlDataCellPrepared">
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="20px"/>
                        <dx:GridViewDataTextColumn FieldName="JournalNo" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="60px">
                            <EditFormSettings Visible="False" />
                            <BatchEditModifiedCellStyle HorizontalAlign="Left">
                            </BatchEditModifiedCellStyle>
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Created By" FieldName="Teller" 
                            ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Particulars" FieldName="journalParticulars" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Status" FieldName="PostStatus" 
                            ShowInCustomizationForm="True" VisibleIndex="7">
                            <PropertiesComboBox IncrementalFilteringMode="StartsWith" 
                                ValueType="System.String">
                                <Items>
                                    <dx:ListEditItem Text="Posted" Value="Posted" />
                                    <dx:ListEditItem Text="Not Posted" Value="Not Posted" />
                                    <dx:ListEditItem Text="Rejected" Value="Rejected" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Type" FieldName="journalType" 
                            ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Date" FieldName="journalDate" 
                            ShowInCustomizationForm="True" VisibleIndex="4" Width="120px">
                            <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="True" VisibleIndex="8" Width="25px" ShowDeleteButton="True" ShowClearFilterButton="True"/>
                        <dx:GridViewDataComboBoxColumn Caption="Currency" FieldName="journal_currency" ShowInCustomizationForm="True" VisibleIndex="6" Width="25px">
                            <PropertiesComboBox DataSourceID="dsCurrencies">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="code" Width="25px" />
                                    <dx:ListBoxColumn Caption="Currency" FieldName="currency_name" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <Settings ShowFilterRowMenu="True" />
                    <Templates>
                        <EditForm>
                            <table class="style1">
                                <tr>
                                    <td>
                                        <table class="style1">
                                            <tr>
                                                <td class="style23">
                                                    &nbsp;</td>
                                                <td class="style22">
                                                    Journal No:</td>
                                                <td class="style21">
                                                    <dx:ASPxTextBox ID="ASPxTextBox2" runat="server" ReadOnly="True" 
                                                        Text='<%# Bind("JournalNo") %>' Width="170px">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td class="style15">
                                                    Date:</td>
                                                <td class="style29">
                                                    <dx:ASPxDateEdit ID="ASPxDateEdit1" runat="server" 
                                                        Value='<%# Bind("journalDate") %>'>
                                                    </dx:ASPxDateEdit>
                                                </td>
                                                <td>
                                                    <dx:ASPxButton ID="cmdSave" runat="server" onclick="cmdSave_Click" 
                                                        Text="Save Changes" Width="170px">
                                                        <Image Url="~/COOPERP/images/disk.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="style23">
                                                    &nbsp;</td>
                                                <td class="style22">
                                                    Type:</td>
                                                <td class="style21">
                                                    <dx:ASPxComboBox ID="ASPxComboBox1" runat="server" 
                                                        IncrementalFilteringMode="Contains" Value='<%# Bind("journalType") %>' 
                                                        ValueType="System.String">
                                                        <Items>
                                                            <dx:ListEditItem Text="General Journal" Value="General" />
                                                            <dx:ListEditItem Text="Payment Journal" Value="Payment" />
                                                            <dx:ListEditItem Text="Member Journal" Value="Member" />
                                                        </Items>
                                                    </dx:ASPxComboBox>
                                                </td>
                                                <td class="style15">
                                                    Status:</td>
                                                <td class="style29">
                                                    <dx:ASPxComboBox ID="ASPxComboBox2" runat="server" 
                                                        Value='<%# Bind("PostStatus") %>' ValueType="System.String">
                                                        <Items>
                                                            <dx:ListEditItem Text="Not Posted" Value="Not Posted" />
                                                            <dx:ListEditItem Text="Posted" Value="Posted" />
                                                            <dx:ListEditItem Text="Rejected" Value="Rejected" />
                                                        </Items>
                                                    </dx:ASPxComboBox>
                                                </td>
                                                <td>
                                                    &nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td class="style23">
                                                    &nbsp;</td>
                                                <td class="style22" valign="top">
                                                    Created By:</td>
                                                <td class="style21" valign="top">
                                                    <dx:ASPxTextBox ID="ASPxTextBox1" runat="server" ReadOnly="True" 
                                                        Text='<%# Bind("Teller") %>' Width="170px">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td class="style15" valign="top">
                                                    Memo:</td>
                                                <td class="style24" colspan="2">
                                                    <dx:ASPxMemo ID="txtMemo" runat="server" Height="50px" Width="170px" 
                                                        Text='<%# Bind("journalParticulars") %>'>
                                                    </dx:ASPxMemo>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxImage ID="ASPxImage3" runat="server" Height="1px" 
                                            ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                                        </dx:ASPxImage>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                            </table>
                        </EditForm>
                    </Templates>
                    <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
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
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <ClientSideEvents CloseUp="function(s, e) {
	gvJournals.Refresh();
}" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsJournals" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetDataByPeriod_Type" 
                    TypeName="CoopERPDataTableAdapters.fin_journalnumbersTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_JournalNo" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="Teller" Type="String" />
                        <asp:Parameter Name="PostStatus" Type="String" />
                        <asp:Parameter Name="journalType" Type="String" />
                        <asp:Parameter Name="journalDate" Type="DateTime" />
                        <asp:Parameter Name="journalParticulars" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtStartDate" Name="startDate" 
                            PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtEndDate" Name="endDate" 
                            PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtJournalType" Name="typ" 
                            PropertyName="Value" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Teller" Type="String" />
                        <asp:Parameter Name="PostStatus" Type="String" />
                        <asp:Parameter Name="journalType" Type="String" />
                        <asp:Parameter Name="journalDate" Type="DateTime" />
                        <asp:Parameter Name="journalParticulars" Type="String" />
                        <asp:Parameter Name="journal_currency" Type="String" />
                        <asp:Parameter Name="Original_JournalNo" Type="Int32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsCurrencies" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CoopERPDataTableAdapters.fin_currencyTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_code" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="code" Type="String" />
                        <asp:Parameter Name="currency_name" Type="String" />
                        <asp:Parameter Name="rates" Type="Double" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="currency_name" Type="String" />
                        <asp:Parameter Name="rates" Type="Double" />
                        <asp:Parameter Name="Original_code" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsJournalTypes" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" 
                    TypeName="CoopERPDataTableAdapters.fin_journaltypesTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_journalTypeID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="journaltypename" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="journaltypename" Type="String" />
                        <asp:Parameter Name="Original_journalTypeID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>




