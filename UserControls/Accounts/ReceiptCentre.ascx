<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ReceiptCentre.ascx.cs" Inherits="UserControls_Accounts_ReceiptCentre" %>
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
    .style16
    {
        width: 186px;
    }
    .style18
    {
        width: 88px;
    }
    .style20
    {
        width: 116px;
    }
    .style21
    {
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
                        <td>
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_receipts.png">
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
                        <td class="style20">
                            Document Type:</td>
                        <td class="style16">
                            <dx:ASPxComboBox ID="txtJournalType" runat="server" AutoPostBack="True" 
                                SelectedIndex="0" ValueType="System.String" Height="35px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="Student Receipt" Value="Receipt" />
                                </Items>
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style21">
                            List Start Date:</td>
                        <td class="style18">
                            <dx:ASPxDateEdit ID="txtStartDate" runat="server" AutoPostBack="True" DisplayFormatString="dd-MM-yyyy" Height="35px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="style20">
                            &nbsp;</td>
                        <td class="style16">
                            <dx:ASPxButton ID="cmdNew" runat="server" OnClick="cmdNew_Click" 
                                Text="Create New" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="style21">
                            List End Date:</td>
                        <td class="style18">
                            <dx:ASPxDateEdit ID="txtEndDate" runat="server" AutoPostBack="True" Height="35px">
                                <Paddings PaddingLeft="5px" />
                            </dx:ASPxDateEdit>
                        </td>
                        <td>
                            &nbsp;</td>
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
                            <dx:ASPxButton ID="cmdDetails" runat="server" OnClick="cmdDetails_Click" 
                                Text="Details" Width="170px" Height="35px">
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
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="60px" 
                            Caption="Serial No">
                            <EditFormSettings Visible="False" />
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
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
                        <dx:GridViewDataTextColumn FieldName="summary" ShowInCustomizationForm="True" 
                            VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="#" ShowInCustomizationForm="True" 
                            VisibleIndex="8" Width="40px">
                            <DataItemTemplate>
                                <asp:ImageButton ID="cmdEdit" runat="server" 
                                    ImageUrl="~/COOPERP/images/clipboard--pencil.png" onclick="cmdEdit_Click" />
                                <asp:ImageButton ID="cmdDelete" runat="server" 
                                    ImageUrl="~/COOPERP/images/minus-button.png" onclick="cmdDelete_Click" 
                                    onclientclick="return confirm('Delete this receipt? This will permanently remove it and cannot be undone.')" />
                            </DataItemTemplate>
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" />
                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
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
                        <asp:ControlParameter ControlID="txtJournalType" DefaultValue="0" Name="typ" 
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
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_messagebox" runat="server" 
                    HeaderText="School Dymanics Version 1.0" Height="150px" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                    Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                            <table class="style1">
                                <tr>
                                    <td height="30">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <dx:ASPxImage ID="img_msg" runat="server" ImageAlign="AbsBottom">
                                        </dx:ASPxImage>
                                        &nbsp;<dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>






