<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StoresLocation.ascx.cs"
    Inherits="UserControls_Inventory_StoresLocation" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Store Location"
    Width="100%" ShowHeader="False">
    <HeaderImage Url="~/COOPERP/images/truck--arrow - Copy.png">
    </HeaderImage>
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/inv_storesBanner.png">
            </dx:ASPxImage>
            <br />
            <img alt="" src="../../COOPERP/images/hor_line.png" height="1" style="margin-bottom: 0px"
                width="100%" />
            <br />
            <table style="width: 100%;">
                <tr>
                    <td class="style1">
                        &nbsp;</td>
                    <td>
                        &nbsp;</td>
                    <td>
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style1">
                        <dx:ASPxButton ID="cmdAdd" runat="server" Height="27px" OnClick="cmdAdd_Click" Text="Add Store" Width="170px">
                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                    <td>&nbsp; </td>
                    <td>&nbsp; </td>
                </tr>
            </table>
            <dx:ASPxGridView ID="gv_store" runat="server" AutoGenerateColumns="False" DataSourceID="ds_store"
                KeyFieldName="LocationCode" Width="100%" OnHtmlDataCellPrepared="gv_store_HtmlDataCellPrepared">
                <Columns>
                    <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="True" VisibleIndex="4" Width="100px" ShowEditButton="True" ShowDeleteButton="True"/>
                    <dx:GridViewDataTextColumn FieldName="LocationCode" ReadOnly="True" ShowInCustomizationForm="True"
                        VisibleIndex="0" Width="100px">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Left">
                        </CellStyle>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn Caption="Store Name" FieldName="LocationName" ShowInCustomizationForm="True"
                        VisibleIndex="1" Width="300px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn Caption="Store Short Name" FieldName="ShortName" ShowInCustomizationForm="True"
                        VisibleIndex="2" Width="170px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Description" ShowInCustomizationForm="True"
                        VisibleIndex="3">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
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
            <asp:ObjectDataSource ID="ds_store" runat="server" DeleteMethod="Delete" InsertMethod="Insert"
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_storelocationTableAdapter"
                UpdateMethod="Update">
                <DeleteParameters>
                    <asp:Parameter Name="Original_LocationCode" Type="UInt32" />
                </DeleteParameters>
                <InsertParameters>
                    <asp:Parameter Name="LocationName" Type="String" />
                    <asp:Parameter Name="ShortName" Type="String" />
                    <asp:Parameter Name="Description" Type="String" />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="LocationName" Type="String" />
                    <asp:Parameter Name="ShortName" Type="String" />
                    <asp:Parameter Name="Description" Type="String" />
                    <asp:Parameter Name="Original_LocationCode" Type="UInt32" />
                </UpdateParameters>
            </asp:ObjectDataSource>
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
