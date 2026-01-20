<%@ Control Language="C#" AutoEventWireup="true" CodeFile="TaxInfo.ascx.cs" Inherits="UserControls_Inventory_TaxInfo" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
    .style2
    {
        width: 100%;
    }
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="TAX Info Setting"
    Width="100%">
    <HeaderImage Url="~/COOPERP/images/calculate.png">
    </HeaderImage>
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/inv_taxBanner.png">
            </dx:ASPxImage>
            <br />
            <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
            <br />
            <table style="width: 100%;">
                <tr>
                    <td class="style2">
                        <dx:ASPxButton ID="cmdAdd" runat="server" Text="Add TAX Type" Width="170px" 
                            OnClick="cmdAdd_Click">
                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                    <td>
                        &nbsp;
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
            </table>
            <dx:ASPxGridView ID="gv_tax" runat="server" AutoGenerateColumns="False" DataSourceID="ds_tax"
                KeyFieldName="TaxCode" Width="100%">
                <Columns>
                    <dx:GridViewCommandColumn ButtonType="Image" Caption="Action" ShowInCustomizationForm="True" VisibleIndex="4" Width="100px" ShowEditButton="True" ShowDeleteButton="True"/>
                    <dx:GridViewDataTextColumn FieldName="TaxCode" ReadOnly="True" ShowInCustomizationForm="True"
                        VisibleIndex="0" Width="100px">
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="TaxName" ShowInCustomizationForm="True" VisibleIndex="1"
                        Width="300px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Percentage" ShowInCustomizationForm="True"
                        VisibleIndex="2" Width="80px" Caption="Percentage (%)">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="TaxType" ShowInCustomizationForm="True" VisibleIndex="3"
                        Width="170px">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
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
            <asp:ObjectDataSource ID="ds_tax" runat="server" DeleteMethod="Delete" InsertMethod="Insert"
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_taxdetailTableAdapter"
                UpdateMethod="Update">
                <DeleteParameters>
                    <asp:Parameter Name="Original_TaxCode" Type="UInt32" />
                </DeleteParameters>
                <InsertParameters>
                    <asp:Parameter Name="TaxName" Type="String" />
                    <asp:Parameter Name="Percentage" Type="UInt32" />
                    <asp:Parameter Name="TaxType" Type="String" />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="TaxName" Type="String" />
                    <asp:Parameter Name="Percentage" Type="UInt32" />
                    <asp:Parameter Name="TaxType" Type="String" />
                    <asp:Parameter Name="Original_TaxCode" Type="UInt32" />
                </UpdateParameters>
            </asp:ObjectDataSource>
            <br />
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
