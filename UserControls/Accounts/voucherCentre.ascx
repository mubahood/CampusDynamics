<%@ Control Language="C#" AutoEventWireup="true" CodeFile="voucherCentre.ascx.cs" Inherits="COOPERP_accounts_voucherCentre" %>
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
    .style16
    {
        width: 186px;
    }
    .style15
    {
        width: 63px;
    }
    .style17
    {
        width: 189px;
    }
    .style18
    {
        width: 88px;
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
                        <td>
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_vouchers.png">
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
                        <td class="style13">
                            Start Date:</td>
                        <td class="style16">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server">
                            </dx:ASPxDateEdit>
                        </td>
                        <td class="style15">
                            End Date:</td>
                        <td class="style17">
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server">
                            </dx:ASPxDateEdit>
                        </td>
                        <td class="style18">
                            Voucher Type:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtJournalType" runat="server" AutoPostBack="True" 
                                SelectedIndex="0" ValueType="System.String">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Payment Voucher" Value="Payment" />
                                </Items>
                            </dx:ASPxComboBox>
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
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td>
                            <dx:ASPxButton ID="cmdNew" runat="server" OnClick="cmdNew_Click" 
                                Text="Create New" Width="170px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td align="right">
                            <dx:ASPxButton ID="cmdDetails" runat="server" OnClick="cmdDetails_Click" 
                                Text="Details" Width="170px">
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
                <dx:ASPxGridView ID="gvVouchers" runat="server" AutoGenerateColumns="False" 
                    ClientInstanceName="gvVouchers" DataSourceID="dsVouchers" 
                    KeyFieldName="VoucherNo" Width="100%">
                    <Columns>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="20px" ShowClearFilterButton="True"/>
                        <dx:GridViewDataTextColumn FieldName="VoucherNo" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="60px">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="Teller" ShowInCustomizationForm="True" 
                            VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="PostStatus" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="Vouchertype" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Date" FieldName="voucherDate" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                            <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="True" VisibleIndex="6" Width="40px" ShowEditButton="True" ShowDeleteButton="True" ShowClearFilterButton="True"/>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" />
                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
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
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    ContentUrl="~/COOPERP/accounts/voucherDetails.aspx">
                    <ClientSideEvents CloseUp="function(s, e) {
	gvVouchers.Refresh();
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
                <asp:ObjectDataSource ID="dsVouchers" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetDataByType" 
                    TypeName="CoopERPDataTableAdapters.fin_vouchernumbersTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_VoucherNo" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="Teller" Type="String" />
                        <asp:Parameter Name="PostStatus" Type="String" />
                        <asp:Parameter Name="Vouchertype" Type="String" />
                        <asp:Parameter Name="voucherDate" Type="DateTime" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtStartDate" Name="startDate" 
                            PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtEndDate" Name="endDate" 
                            PropertyName="Value" Type="DateTime" />
                        <asp:ControlParameter ControlID="txtJournalType" DefaultValue="-" Name="typ" 
                            PropertyName="Value" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Teller" Type="String" />
                        <asp:Parameter Name="PostStatus" Type="String" />
                        <asp:Parameter Name="Vouchertype" Type="String" />
                        <asp:Parameter Name="voucherDate" Type="DateTime" />
                        <asp:Parameter Name="Original_VoucherNo" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>





