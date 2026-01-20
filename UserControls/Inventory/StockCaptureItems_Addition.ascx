<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StockCaptureItems_Addition.ascx.cs"
    Inherits="UserControls_Inventory_StockCaptureItems_Addition" %>
<style type="text/css">
    .style14
    {
        width: 74px;
    }
    .style15
    {
        width: 255px;
    }
    .style17
    {
        width: 45px;
    }
    .style19
    {
        width: 224px;
    }
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Add Items on Capturing Sheet"
    Width="100%">
    <HeaderImage Url="~/COOPERP/images/clipboard--plus.png">
    </HeaderImage>
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <table style="width: 100%;">
                <tr>
                    <td class="style14">
                        &nbsp;</td>
                    <td class="style15">
                        &nbsp;</td>
                    <td class="style17">
                        &nbsp;</td>
                    <td class="style19">
                        &nbsp;</td>
                    <td>
                        &nbsp;</td>
                </tr>
                <tr>
                    <td class="style14">
                        Item Name
                    </td>
                    <td class="style15">
                        <dx:ASPxComboBox ID="txtItemName" runat="server" AutoPostBack="True" 
                            DataSourceID="ds_items" IncrementalFilteringMode="Contains" 
                            OnSelectedIndexChanged="txtItemName_SelectedIndexChanged" TabIndex="1" 
                            TextField="ItemName" TextFormatString="{0}; {1}" ValueField="ItemCode" 
                            ValueType="System.UInt32" Width="270px" Height="35px">
                            <Columns>
                                <dx:ListBoxColumn FieldName="ItemName" Width="200px" />
                                <dx:ListBoxColumn FieldName="CostPrice" Width="70px" />
                            </Columns>
                        </dx:ASPxComboBox>
                    </td>
                    <td class="style17">
                        Unit
                    </td>
                    <td class="style19">
                        <dx:ASPxComboBox ID="txtUnit" runat="server" AutoPostBack="True" 
                            DataSourceID="ds_Units" TabIndex="2" TextField="Unit" ValueField="UnitCode" 
                            ValueType="System.Int32" Width="200px" Height="35px">
                        </dx:ASPxComboBox>
                    </td>
                    <td>
                        <dx:ASPxButton ID="cmdAdd" runat="server" OnClick="cmdAdd_Click" TabIndex="5" 
                            Text="Add Item" Width="170px" Height="35px">
                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                </tr>
                <tr>
                    <td class="style14">
                        Store
                    </td>
                    <td class="style15">
                        <dx:ASPxComboBox ID="txtlocation" runat="server" DataSourceID="ds_location" TabIndex="4"
                            TextField="ShortName" ValueField="LocationCode" ValueType="System.UInt32" Width="270px" Height="35px">
                        </dx:ASPxComboBox>
                    </td>
                    <td class="style17">
                        Qty
                    </td>
                    <td class="style19">
                        <dx:ASPxTextBox ID="txtQty" runat="server" TabIndex="3" Width="200px" Height="35px">
                        </dx:ASPxTextBox>
                    </td>
                    <td>
                        <dx:ASPxButton ID="cmdClear" runat="server" OnClick="cmdClear_Click" TabIndex="6"
                            Text="Clear" Width="170px" Height="35px">
                            <Image Url="~/COOPERP/images/clipboard--minus.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                </tr>
                <tr>
                    <td class="style14">
                        &nbsp;
                    </td>
                    <td class="style15">
                        &nbsp;
                    </td>
                    <td class="style17">
                        &nbsp;
                    </td>
                    <td class="style19">
                        &nbsp;
                    </td>
                    <td>
                        <dx:ASPxButton ID="cmdDelete" runat="server" OnClick="cmdDelete_Click" TabIndex="7"
                            Text="Delete" Width="170px" Height="35px">
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                </tr>
            </table>
            <dx:ASPxGridView ID="gv_sheetitems" runat="server" AutoGenerateColumns="False" DataSourceID="ds_sheetitems"
                KeyFieldName="SNO" Width="100%" OnHtmlRowPrepared="gv_sheetitems_HtmlRowPrepared">
                <Columns>
                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True"
                        VisibleIndex="0" Width="20px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="SNO" ShowInCustomizationForm="True" SortIndex="0"
                        SortOrder="Ascending" VisibleIndex="1" Width="40px">
                        <CellStyle HorizontalAlign="Left">
                        </CellStyle>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn Caption="GRN No." FieldName="SheetNo" ShowInCustomizationForm="True"
                        VisibleIndex="2" Width="20px" Visible="False">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" VisibleIndex="3"
                        Width="180px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Unit" ShowInCustomizationForm="True" VisibleIndex="4"
                        Width="40px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Qty" ShowInCustomizationForm="True" VisibleIndex="5"
                        Width="40px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="CostPrice" ShowInCustomizationForm="True" VisibleIndex="6"
                        Width="50px">
                        <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Total" ShowInCustomizationForm="True" VisibleIndex="7"
                        Width="50px">
                        <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Store" ShowInCustomizationForm="True" VisibleIndex="8"
                        Width="80px">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <SettingsBehavior AllowFocusedRow="True" />
                <SettingsPager Mode="ShowAllRecords">
                </SettingsPager>
                <SettingsSearchPanel Visible="True" />
                <SettingsText EmptyDataRow="No Items on Stock Capture Sheet!" />
            </dx:ASPxGridView>
            <asp:ObjectDataSource ID="ds_sheetitems" runat="server" OldValuesParameterFormatString="original_{0}"
                SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_GetStockCaptureSheetitemsTableAdapter">
                <SelectParameters>
                    <asp:Parameter DefaultValue="1" Name="Act" Type="Int32" />
                    <asp:SessionParameter Name="SHNO" SessionField="CapSheetNo" Type="Int32" />
                </SelectParameters>
            </asp:ObjectDataSource>
            <asp:ObjectDataSource ID="ds_items" runat="server" DeleteMethod="Delete" InsertMethod="Insert"
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_itemdetailsTableAdapter"
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
            <asp:ObjectDataSource ID="ds_Units" runat="server" OldValuesParameterFormatString="original_{0}"
                SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_GetItemPrimaryUnitTableAdapter">
                <SelectParameters>
                    <asp:ControlParameter ControlID="txtItemName" Name="ICD" PropertyName="Value" Type="Int32" />
                </SelectParameters>
            </asp:ObjectDataSource>
            <asp:ObjectDataSource ID="ds_location" runat="server" DeleteMethod="Delete" InsertMethod="Insert"
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
            <dx:ASPxPopupControl ID="pop_mgs" runat="server" CloseAction="CloseButton" HeaderText=".::"
                Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                <HeaderImage Url="~/COOPERP/images/clipboard-invoice.png">
                </HeaderImage>
                <ContentCollection>
                    <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                        <table style="width: 100%;">
                            <tr>
                                <td>
                                    &nbsp;
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
