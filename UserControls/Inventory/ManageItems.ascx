<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ManageItems.ascx.cs" Inherits="UserControls_Inventory_ManageItems" %>

<style type="text/css">
    .auto-style1 {
        height: 18px;
    }
</style>

<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Items Info Management Center" Width="100%" ShowHeader="False">
            <HeaderImage Url="~/COOPERP/images/clipboard-list.png">
            </HeaderImage>
            <PanelCollection>
                <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <dx:ASPxImage ID="ASPxImage1" runat="server" 
                        ImageUrl="~/COOPERP/images/ItemsManager.png" style="text-align: center">
                    </dx:ASPxImage>
                    <br />
                    <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
                    <br />
                    <table style="width:100%;">
                        <tr>
                            <td width="170">
                                &nbsp;</td>
                            <td width="170">
                                &nbsp;</td>
                            <td align="right">
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td width="170">
                                <dx:ASPxButton ID="cmdNewItem" runat="server" Text="New Item" Width="170px" OnClick="cmdNewItem_Click" Height="35px">
                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                            <td width="170">&nbsp;</td>
                            <td align="right">
                                <dx:ASPxButton ID="cmdDelete" runat="server" OnClick="cmdDelete_Click" Text="Delete Item" Width="170px" Height="35px">
                                    <Image Url="~/COOPERP/images/minus-button.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                    </table>
                    <dx:ASPxGridView ID="gv_Items" runat="server" AutoGenerateColumns="False" 
                        DataSourceID="ds_items" KeyFieldName="ItemCode" Width="100%" OnHtmlDataCellPrepared="gv_Items_HtmlDataCellPrepared">
                        <SettingsSearchPanel Visible="True" />
                        <Columns>
                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                ShowSelectCheckbox="True" VisibleIndex="0" Width="10px">
                            </dx:GridViewCommandColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemCode" ReadOnly="True" 
                                ShowInCustomizationForm="True" VisibleIndex="1" Width="30px">
                                <EditFormSettings Visible="False" />
                                <CellStyle HorizontalAlign="Left">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" 
                                VisibleIndex="2" Width="300px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemShortName" 
                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                <EditFormSettings Visible="True" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="Qty" ShowInCustomizationForm="True" 
                                Visible="False" VisibleIndex="6">
                                <EditFormSettings Visible="False" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="TaxCode" ShowInCustomizationForm="True" 
                                Visible="False" VisibleIndex="7">
                                <EditFormSettings Visible="False" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="CostPrice" ShowInCustomizationForm="True" 
                                VisibleIndex="8" Width="50px">
                                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                                </PropertiesTextEdit>
                                <HeaderStyle HorizontalAlign="Center" />
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="SellingPrice" 
                                ShowInCustomizationForm="True" VisibleIndex="9" Visible="False">
                                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                                </PropertiesTextEdit>
                                <HeaderStyle HorizontalAlign="Center" />
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ReorderLevel" 
                                ShowInCustomizationForm="True" VisibleIndex="10" Width="10px">
                                <HeaderStyle HorizontalAlign="Center" />
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ReorderQty" 
                                ShowInCustomizationForm="True" VisibleIndex="11" Width="50px">
                                <HeaderStyle HorizontalAlign="Center" />
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="Description" 
                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                <EditFormSettings Visible="True" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn Caption="Barcode 1" FieldName="int_Barcode1" 
                                ShowInCustomizationForm="True" VisibleIndex="13" Width="100px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn Caption="Barcode 2" FieldName="int_Barcode2" 
                                ShowInCustomizationForm="True" VisibleIndex="14" Width="100px" 
                                Visible="False">
                                <EditFormSettings Visible="True" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewCommandColumn ButtonType="Image" ShowInCustomizationForm="False" VisibleIndex="18" Width="10px" ShowEditButton="True" ShowClearFilterButton="True"/>
                            <dx:GridViewDataTextColumn Caption="Barcode 3" FieldName="int_Barcode3" 
                                ShowInCustomizationForm="True" VisibleIndex="15" Width="100px" 
                                Visible="False">
                                <EditFormSettings Visible="True" />
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn Caption="Suppliers" ShowInCustomizationForm="True" 
                                VisibleIndex="16" Width="25px">
                                <EditFormSettings Visible="False" />
                                <DataItemTemplate>
                                    <asp:ImageButton ID="cmdSuppliers" runat="server" 
                                        ImageUrl="~/COOPERP/images/truck.png" onclick="cmdSuppliers_Click" />
                                </DataItemTemplate>
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn Caption="Units" ShowInCustomizationForm="True" 
                                VisibleIndex="17" Width="25px">
                                <EditFormSettings Visible="False" />
                                <DataItemTemplate>
                                    <asp:ImageButton ID="cmdUnits" runat="server" 
                                        ImageUrl="~/COOPERP/images/block.png" onclick="cmdUnits_Click1" />
                                </DataItemTemplate>
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataComboBoxColumn FieldName="ItemGroupCode" ShowInCustomizationForm="True" VisibleIndex="5">
                                <PropertiesComboBox DataSourceID="dsCategories" TextField="ItemGroupName" TextFormatString="{1}" ValueField="ItemGroupCode">
                                    <Columns>
                                        <dx:ListBoxColumn Caption="Code" FieldName="ItemGroupCode" />
                                        <dx:ListBoxColumn Caption="Category" FieldName="ItemGroupName" />
                                    </Columns>
                                </PropertiesComboBox>
                            </dx:GridViewDataComboBoxColumn>
                            <dx:GridViewDataComboBoxColumn Caption="Item Units" FieldName="UnitCode" ShowInCustomizationForm="True" VisibleIndex="4">
                                <PropertiesComboBox DataSourceID="dsUnits" TextField="UnitName" TextFormatString="{1}" ValueField="UnitCode">
                                    <Columns>
                                        <dx:ListBoxColumn Caption="Code" FieldName="UnitCode" />
                                        <dx:ListBoxColumn FieldName="UnitName" />
                                    </Columns>
                                </PropertiesComboBox>
                            </dx:GridViewDataComboBoxColumn>
                        </Columns>
                        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" 
                            AllowSelectSingleRowOnly="True" />
                        <SettingsContextMenu Enabled="True">
                        </SettingsContextMenu>
                        <SettingsPager PageSize="20">
                        </SettingsPager>
                        <Settings ShowFilterRowMenu="True" ShowFooter="True" />
                        <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
                            <EditButton>
                                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                </Image>
                            </EditButton>
                        </SettingsCommandButton>
                    </dx:ASPxGridView>
                    <dx:ASPxPopupControl ID="pop_mgs" runat="server" CloseAction="CloseButton" 
                        HeaderText=".::" Modal="True" PopupHorizontalAlign="WindowCenter" 
                        PopupVerticalAlign="WindowCenter" Width="400px">
                        <HeaderImage Url="~/COOPERP/images/clipboard-invoice.png">
                        </HeaderImage>
                        <ContentCollection>
                            <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                                <table style="width: 100%;">
                                    <tr>
                                        <td>
                                            <br />
                                            <br />
                                            <br />
                                        </td>
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
                                        <td>
                                            <br />
                                            <br />
                                            <br />
                                            <dx:ASPxButton ID="cmdContinue" runat="server" OnClick="cmdContinue_Click" 
                                                Text="Continue &gt;&gt;" Width="100%" Height="35px">
                                                <Image Url="~/COOPERP/images/minus-button.png">
                                                </Image>
                                            </dx:ASPxButton>
                                        </td>
                                    </tr>
                                </table>
                            </dx:PopupControlContentControl>
                        </ContentCollection>
                    </dx:ASPxPopupControl>
                    <asp:ObjectDataSource ID="ds_items" runat="server" DeleteMethod="Delete" 
                        InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                        SelectMethod="GetData" 
                        TypeName="InventoryDataTableAdapters.inv_itemdetailsTableAdapter" 
                        UpdateMethod="Update">
                        <DeleteParameters>
                            <asp:Parameter Name="Original_ItemCode" Type="UInt32" />
                        </DeleteParameters>
                        <InsertParameters>
                            <asp:Parameter Name="ItemCode" Type="UInt32" />
                            <asp:Parameter Name="ItemName" Type="String" />
                            <asp:Parameter Name="ItemShortName" Type="String" />
                            <asp:Parameter Name="UnitCode" Type="UInt32" />
                            <asp:Parameter Name="ItemGroupCode" Type="UInt32" />
                            <asp:Parameter Name="Qty" Type="UInt64" />
                            <asp:Parameter Name="TaxCode" Type="UInt32" />
                            <asp:Parameter Name="CostPrice" Type="Double" />
                            <asp:Parameter Name="SellingPrice" Type="Double" />
                            <asp:Parameter Name="ReorderLevel" Type="UInt32" />
                            <asp:Parameter Name="ReorderQty" Type="UInt32" />
                            <asp:Parameter Name="Description" Type="String" />
                            <asp:Parameter Name="int_Barcode1" Type="String" />
                            <asp:Parameter Name="int_Barcode2" Type="String" />
                            <asp:Parameter Name="int_Barcode3" Type="String" />
                        </InsertParameters>
                        <UpdateParameters>
                            <asp:Parameter Name="ItemCode" Type="UInt32" />
                            <asp:Parameter Name="ItemName" Type="String" />
                            <asp:Parameter Name="ItemShortName" Type="String" />
                            <asp:Parameter Name="UnitCode" Type="UInt32" />
                            <asp:Parameter Name="ItemGroupCode" Type="UInt32" />
                            <asp:Parameter Name="Qty" Type="UInt64" />
                            <asp:Parameter Name="TaxCode" Type="UInt32" />
                            <asp:Parameter Name="CostPrice" Type="Double" />
                            <asp:Parameter Name="SellingPrice" Type="Double" />
                            <asp:Parameter Name="ReorderLevel" Type="UInt32" />
                            <asp:Parameter Name="ReorderQty" Type="UInt32" />
                            <asp:Parameter Name="Description" Type="String" />
                            <asp:Parameter Name="int_Barcode1" Type="String" />
                            <asp:Parameter Name="int_Barcode2" Type="String" />
                            <asp:Parameter Name="int_Barcode3" Type="String" />
                            <asp:Parameter Name="Original_ItemCode" Type="UInt32" />
                        </UpdateParameters>
                    </asp:ObjectDataSource>
                    <asp:ObjectDataSource ID="dsCategories" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_itemgroupTableAdapter"></asp:ObjectDataSource>
                    <asp:ObjectDataSource ID="dsUnits" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_itemunitsTableAdapter"></asp:ObjectDataSource>
                </dx:PanelContent>
            </PanelCollection>
        </dx:ASPxRoundPanel>
    </ContentTemplate>
</asp:UpdatePanel>

