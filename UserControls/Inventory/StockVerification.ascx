<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StockVerification.ascx.cs" Inherits="UserControls_Inventory_StockVerification" %>
<style type="text/css">

    .style3
    {
        width: 164px;
    }
    .style4
    {
        width: 123px;
    }
</style>
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Stock Verification" Width="100%" ShowHeader="False">
            <HeaderImage Url="~/COOPERP/images/blue-document-attribute-v - Copy.png">
            </HeaderImage>
            <PanelCollection>
                <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <dx:ASPxImage ID="ASPxImage1" runat="server" 
                        ImageUrl="~/COOPERP/images/StockVerification.png">
                    </dx:ASPxImage>
    <br />
    <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
    <br />
                    <table style="width: 100%;">
                        <tr>
                            <td class="style3">
                                <dx:ASPxButton ID="cmdVerify" runat="server" OnClick="cmdVerify_Click" 
                                    Text="Verify GRN (Sheet)" Width="170px">
                                    <Image Url="~/COOPERP/images/tick-button.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                            <td class="style4">
                                <dx:ASPxButton ID="cmdRollback" runat="server" OnClick="cmdRollback_Click" 
                                    Text="Roll Back" Width="170px">
                                    <Image Url="~/COOPERP/images/arrow-circle-135-left.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                            <td align="right">
                                <dx:ASPxButton ID="cmdPreview" runat="server" OnClick="cmdPreview_Click" 
                                    Text="Items on Sheet" Width="170px">
                                    <Image Url="~/COOPERP/images/clipboard-list.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                    </table>
    <br />
                    <dx:ASPxGridView ID="gv_sheets" runat="server" AutoGenerateColumns="False" 
                        DataSourceID="ds_sheets" KeyFieldName="SheetNo" Width="100%">
                        <Columns>
                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                ShowSelectCheckbox="True" VisibleIndex="0" Caption="&gt;" Width="20px">
                            </dx:GridViewCommandColumn>
                            <dx:GridViewDataTextColumn FieldName="SheetNo" ReadOnly="True" 
                                ShowInCustomizationForm="True" VisibleIndex="1" Caption="GRN No." 
                                SortIndex="1" SortOrder="Ascending">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="SheetStatus" 
                                ShowInCustomizationForm="True" VisibleIndex="2">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="CreatedBy" ShowInCustomizationForm="True" 
                                VisibleIndex="3">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataDateColumn FieldName="DateCreated" 
                                ShowInCustomizationForm="True" VisibleIndex="4" Caption="Submission Date" 
                                SortIndex="0" SortOrder="Ascending">
                                <PropertiesDateEdit DisplayFormatString="dddd, dd MMMM, yyyy">
                                </PropertiesDateEdit>
                            </dx:GridViewDataDateColumn>
                            <dx:GridViewDataTextColumn FieldName="Comments" ShowInCustomizationForm="True" 
                                VisibleIndex="5">
                            </dx:GridViewDataTextColumn>
                        </Columns>
                        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" 
                            AllowSelectSingleRowOnly="True" />
                        <SettingsText EmptyDataRow="No Submitted Stock Sheet Availalbe!" />
                    </dx:ASPxGridView>
                    <asp:ObjectDataSource ID="ds_sheets" runat="server" 
                        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                        TypeName="InventoryDataTableAdapters.inv_GetStockVerificationSheetTableAdapter">
                    </asp:ObjectDataSource>
                    <dx:ASPxPopupControl ID="pop_mgs" runat="server" CloseAction="CloseButton" 
                        HeaderText=".::" Modal="True" PopupHorizontalAlign="WindowCenter" 
                        PopupVerticalAlign="WindowCenter">
                        <HeaderImage Url="~/COOPERP/images/clipboard-invoice.png">
                        </HeaderImage>
                        <ContentCollection>
                            <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                                <table style="width: 100%;">
                                    <tr>
                                        <td>
                                            &nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: center">
                                            <dx:ASPxImage ID="img_pop" runat="server">
                                            </dx:ASPxImage>
                                            <dx:ASPxLabel ID="lbl_pop" runat="server">
                                            </dx:ASPxLabel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: left">
                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </td>
                                    </tr>
                                </table>
                            </dx:PopupControlContentControl>
                        </ContentCollection>
                    </dx:ASPxPopupControl>
                </dx:PanelContent>
            </PanelCollection>
        </dx:ASPxRoundPanel>
    </ContentTemplate>
</asp:UpdatePanel>


