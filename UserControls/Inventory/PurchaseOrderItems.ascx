<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PurchaseOrderItems.ascx.cs"
    Inherits="UserControls_Inventory_PurchaseOrderItems" %>
<style type="text/css">
   <%-- .style14
    {
        width: 74px;
    }
    .style15
    {
        width: 255px;
    }
    
    .dxeButtonEdit
    {
        background-color: white;
        border: solid 1px #9F9F9F;
        width: 170px;
    }
    .dxeButtonEdit .dxeEditArea
    {
        background-color: white;
    }
    
    .dxeEditArea
    {
        font-family: Tahoma;
        font-size: 9pt;
        border: 1px solid #A0A0A0;
    }
    .dxeEditAreaSys
    {
        width: 100%;
    }
    
    .dxeEditAreaSys, .dxeEditAreaNotStrechSys
    {
        border: 0px !important;
        padding: 0px;
    }
    .dxeButtonEditButton, .dxeSpinIncButton, .dxeSpinDecButton, .dxeSpinLargeIncButton, .dxeSpinLargeDecButton
    {
        padding: 0px 2px 0px 3px;
        background-image: url('<%=WebResource("DevExpress.Web.ASPxEditors.Images.edtDropDownBack.gif")%>');
        background-repeat: repeat-x;
        background-position: top;
        background-color: #e6e6e6;
    }
    .dxeButtonEditButton, .dxeCalendarButton, .dxeSpinIncButton, .dxeSpinDecButton, .dxeSpinLargeIncButton, .dxeSpinLargeDecButton
    {
        vertical-align: middle;
        border: solid 1px #7f7f7f;
        cursor: pointer;
    }
    .style19
    {
        width: 224px;
    }
    .dxbButton
    {
        color: #000000;
        font-weight: normal;
        font-size: 9pt;
        font-family: Tahoma;
        vertical-align: middle;
        border: solid 1px #7F7F7F;
        background: #E0DFDF url('<%=WebResource("DevExpress.Web.ASPxEditors.Images.edtButtonBack.gif")%>') top;
        background-repeat: repeat-x;
        padding: 1px 1px 1px 1px;
        cursor: pointer;
    }
    .dxeTextBox, .dxeMemo
    {
        background-color: white;
        border: solid 1px #9f9f9f;
    }
    .dxeTextBoxSys, .dxeMemoSys
    {
        border-collapse: separate !important;
    }
    
    .dxeTextBox .dxeEditArea
    {
        background-color: white;
    }
    --%>
    .style23
    {
        width: 321px;
    }
    .style24
    {
        width: 89px;
    }
    .style25
    {
        width: 101px;
    }
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Purchase Order Items"
    Width="100%">
    <HeaderImage Url="~/COOPERP/images/clipboard-list.png">
    </HeaderImage>
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <table style="width: 100%;">
                <tr>
                    <td class="style25">
                        Item Name
                    </td>
                    <td class="style23">
                        <dx:ASPxComboBox ID="txtItemName" runat="server" AutoPostBack="True" DataSourceID="ds_items"
                            IncrementalFilteringMode="Contains" OnSelectedIndexChanged="txtItemName_SelectedIndexChanged"
                            TabIndex="1" TextField="ItemName" TextFormatString="{0}; {1}" ValueField="ItemCode"
                            ValueType="System.UInt32" Width="270px">
                            <Columns>
                                <dx:ListBoxColumn FieldName="ItemName" Width="200px" />
                                <dx:ListBoxColumn FieldName="CostPrice" Width="70px" />
                            </Columns>
                        </dx:ASPxComboBox>
                    </td>
                    <td class="style24">
                        Unit
                    </td>
                    <td class="style19">
                        <dx:ASPxComboBox ID="txtUnit" runat="server" AutoPostBack="True" DataSourceID="ds_Units"
                            TabIndex="2" TextField="Unit" ValueField="UnitCode" ValueType="System.UInt32"
                            Width="200px">
                        </dx:ASPxComboBox>
                    </td>
                    <td>
                        <dx:ASPxButton ID="cmdAdd" runat="server" OnClick="cmdAdd_Click" TabIndex="5" Text="Add Item"
                            Width="170px">
                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                </tr>
                <tr>
                    <td class="style25">
                        &nbsp;</td>
                    <td class="style23">
                        <dx:ASPxCheckBox ID="txtTaxStatus" runat="server" CheckState="Unchecked" 
                            OnCheckedChanged="txtTaxStatus_CheckedChanged" Text="VAT Inclusive">
                        </dx:ASPxCheckBox>
                    </td>
                    <td class="style24">
                        Order Qty
                    </td>
                    <td class="style19">
                        <dx:ASPxTextBox ID="txtQty" runat="server" TabIndex="3" Width="200px">
                        </dx:ASPxTextBox>
                    </td>
                    <td>
                        <dx:ASPxButton ID="cmdClear" runat="server" OnClick="cmdClear_Click" TabIndex="6"
                            Text="Clear" Width="170px">
                            <Image Url="~/COOPERP/images/clipboard--minus.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                </tr>
                <tr>
                    <td class="style25">
                        &nbsp;
                    </td>
                    <td class="style23">
                        &nbsp;</td>
                    <td class="style24">
                        &nbsp;</td>
                    <td class="style19">
                        &nbsp;
                    </td>
                    <td>
                        <dx:ASPxButton ID="cmdDelete" runat="server" OnClick="cmdDelete_Click" TabIndex="7"
                            Text="Delete" Width="170px">
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                </tr>
            </table>
            <dx:ASPxGridView ID="gv_poItems" runat="server" AutoGenerateColumns="False" 
                DataSourceID="ds_poItems" Width="100%" KeyFieldName="S_no">
                <TotalSummary>
                    <dx:ASPxSummaryItem DisplayFormat="{0}" FieldName="VAT_Amount" 
                        ShowInColumn="VAT " ShowInGroupFooterColumn="VAT " SummaryType="Sum" />
                    <dx:ASPxSummaryItem DisplayFormat="Total: {0:0,000}" FieldName="Amount" 
                        ShowInColumn="Amount" ShowInGroupFooterColumn="Amount" SummaryType="Sum" 
                        ValueDisplayFormat="{0:0,000}" />
                </TotalSummary>
                <Columns>
                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="10px" ShowClearFilterButton="True"/>
                    <dx:GridViewDataTextColumn Caption="S/NO" FieldName="S_no" 
                        ShowInCustomizationForm="True" VisibleIndex="1" Width="10px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Po_No" ShowInCustomizationForm="True" 
                        Visible="False" VisibleIndex="2">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="ItemCode" ShowInCustomizationForm="True" 
                        Visible="False" VisibleIndex="3" Width="50px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" 
                        VisibleIndex="4" Width="270px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="QtyOrder" ShowInCustomizationForm="True" 
                        VisibleIndex="6" Width="20px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Unit" ShowInCustomizationForm="True" 
                        VisibleIndex="5" Width="20px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="UnitPrice" ShowInCustomizationForm="True" 
                        VisibleIndex="7" Width="100px">
                        <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Amount" ShowInCustomizationForm="True" 
                        VisibleIndex="8" Width="100px">
                        <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn Caption="VAT " FieldName="VAT_Amount" 
                        ShowInCustomizationForm="True" VisibleIndex="9" Width="100px">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" 
                    AllowSelectSingleRowOnly="True" />
                <SettingsPager Mode="ShowAllRecords">
                </SettingsPager>
                <Settings ShowFooter="True" />
            </dx:ASPxGridView>
            <asp:ObjectDataSource ID="ds_poItems" runat="server" 
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                TypeName="InventoryDataTableAdapters.inv_GetPurchaseOrderItemsTableAdapter">
                <SelectParameters>
                    <asp:SessionParameter Name="PO" SessionField="PON" Type="Int32" />
                </SelectParameters>
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
            <br />
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
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
