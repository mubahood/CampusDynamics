<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SupplierInfo.ascx.cs"
    Inherits="UserControls_Inventory_SupplierInfo" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Supplier's Information Center"
    Width="100%" ShowHeader="False">
    <HeaderImage Url="~/COOPERP/images/user-business-boss.png">
    </HeaderImage>
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/inv_suppliersBanner.png">
            </dx:ASPxImage>
            <br />
            <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
            <br />
            <table style="width: 100%;">
                <tr>
                    <td class="style1">
                        &nbsp;</td>
                    <td>
                        &nbsp;
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td class="style1">
                        <dx:ASPxButton ID="cmdAdd" runat="server" Height="27px" OnClick="cmdAdd_Click" Text="Add Supplier" Width="170px">
                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
            </table>
            <dx:ASPxGridView ID="gv_supplier" runat="server" AutoGenerateColumns="False" DataSourceID="ds_supplier"
                KeyFieldName="SupplierCode" Width="100%" OnHtmlDataCellPrepared="gv_supplier_HtmlDataCellPrepared">
                <SettingsSearchPanel Visible="True" />
                <Columns>
                    <dx:GridViewCommandColumn ButtonType="Image" Caption="Action" ShowInCustomizationForm="True" VisibleIndex="9" Width="100px" ShowEditButton="True" ShowDeleteButton="True"/>
                    <dx:GridViewDataTextColumn FieldName="SupplierCode" ReadOnly="True" ShowInCustomizationForm="True"
                        VisibleIndex="0" Width="100px">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Left">
                        </CellStyle>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="SupplierName" ShowInCustomizationForm="True"
                        VisibleIndex="1" Width="250px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="BoxNo" ShowInCustomizationForm="True" Visible="False"
                        VisibleIndex="2" Width="170px">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Address" ShowInCustomizationForm="True" VisibleIndex="3"
                        Width="170px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="PhoneContact" ShowInCustomizationForm="True"
                        VisibleIndex="4" Width="170px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Email" ShowInCustomizationForm="True" Visible="False"
                        VisibleIndex="5">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Website" ShowInCustomizationForm="True" Visible="False"
                        VisibleIndex="6">
                        <EditFormSettings Visible="True" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn Caption="TIN" FieldName="TIN_No" ShowInCustomizationForm="True"
                        VisibleIndex="7" Width="170px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn Caption="VAT No" FieldName="VAT_No" ShowInCustomizationForm="True"
                        VisibleIndex="8" Width="170px">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                <Settings ShowFilterRowMenu="True" />
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
            <asp:ObjectDataSource ID="ds_supplier" runat="server" DeleteMethod="Delete" InsertMethod="Insert"
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_supplierdetailsTableAdapter"
                UpdateMethod="Update">
                <DeleteParameters>
                    <asp:Parameter Name="Original_SupplierCode" Type="UInt32" />
                </DeleteParameters>
                <InsertParameters>
                    <asp:Parameter Name="SupplierName" Type="String" />
                    <asp:Parameter Name="BoxNo" Type="String" />
                    <asp:Parameter Name="Address" Type="String" />
                    <asp:Parameter Name="PhoneContact" Type="String" />
                    <asp:Parameter Name="Email" Type="String" />
                    <asp:Parameter Name="Website" Type="String" />
                    <asp:Parameter Name="TIN_No" Type="String" />
                    <asp:Parameter Name="VAT_No" Type="String" />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="SupplierName" Type="String" />
                    <asp:Parameter Name="BoxNo" Type="String" />
                    <asp:Parameter Name="Address" Type="String" />
                    <asp:Parameter Name="PhoneContact" Type="String" />
                    <asp:Parameter Name="Email" Type="String" />
                    <asp:Parameter Name="Website" Type="String" />
                    <asp:Parameter Name="TIN_No" Type="String" />
                    <asp:Parameter Name="VAT_No" Type="String" />
                    <asp:Parameter Name="Original_SupplierCode" Type="UInt32" />
                </UpdateParameters>
            </asp:ObjectDataSource>
            <br />
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
