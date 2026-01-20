<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ItemSuppliers.ascx.cs"
    Inherits="UserControls_Inventory_ItemSuppliers" %>
<style type="text/css">
    
    .style1
    {
        width: 817px;
    }
    .style3
    {
        width: 306px;
    }
    .style4
    {
        width: 69px;
    }
    .style5
    {
        width: 66px;
    }
    .style7
    {
        width: 1086px;
    }
    
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" Width="100%">
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <span class="style1">Item Suppliers:<br />
                <img alt="" height="1" src="../../COOPERP/images/hor_line.png" width="100%" />
                <br />
                <table style="width: 100%;">
                    <tr>
                        <td class="style5">
                            Supplier
                        </td>
                        <td class="style3">
                            <dx:ASPxComboBox ID="txtsupplier" runat="server" ValueType="System.String" 
                                Width="270px" DataSourceID="ds_Supplier" 
                                IncrementalFilteringMode="Contains" TextField="SupplierName" 
                                ValueField="SupplierCode">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style4">
                            Cost Price</td>
                        <td>
                            <span class="style1">
                            <dx:ASPxTextBox ID="txtCostPrice" runat="server" Width="170px">
                            </dx:ASPxTextBox>
                            </span>
                        </td>
                    </tr>
                    <tr>
                        <td class="style5">
                            Unit
                        </td>
                        <td class="style3">
                            <dx:ASPxComboBox ID="txtUnits" runat="server" ValueType="System.UInt32" 
                                Width="270px" DataSourceID="ds_units" IncrementalFilteringMode="Contains" 
                                TextField="UnitShortName" ValueField="UnitCode">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="style4">
                            &nbsp;
                        </td>
                        <td>
                            <dx:ASPxButton ID="cmdAdd" runat="server" Text="Add Supplier" Width="170px" 
                                OnClick="cmdAdd_Click">
                                <Image Url="~/COOPERP/images/user--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                    <tr>
                        <td class="style5">
                            &nbsp;
                        </td>
                        <td class="style3">
                            &nbsp;
                        </td>
                        <td class="style4">
                            &nbsp;
                        </td>
                        <td>
                            &nbsp;</td>
                    </tr>
                </table>
            <dx:ASPxGridView ID="gv_supplier" runat="server" Width="100%" 
                AutoGenerateColumns="False" DataSourceID="ds_SupplierList" 
                KeyFieldName="Supplier">
                <Columns>
                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                        ShowSelectCheckbox="True" VisibleIndex="4" Width="20px">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="Supplier" ShowInCustomizationForm="True" 
                        VisibleIndex="0" Width="270px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" 
                        VisibleIndex="1" Width="200px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Unit" ShowInCustomizationForm="True" 
                        VisibleIndex="2" Width="50px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="CostPrice" ShowInCustomizationForm="True" 
                        VisibleIndex="3" Width="100px">
                        <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                </Columns>
                <SettingsBehavior AllowFocusedRow="True" />
                <SettingsPager Mode="ShowAllRecords">
                </SettingsPager>
                <Settings ShowVerticalScrollBar="True" VerticalScrollableHeight="150" />
            </dx:ASPxGridView>
            <table style="width:100%;">
                <tr>
                    <td class="style7">
                        &nbsp;</td>
                    <td>
                        <dx:ASPxButton ID="cmdDelete" runat="server" Text="Deleted" Width="170px">
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                </tr>
            </table>
            <asp:ObjectDataSource ID="ds_SupplierList" runat="server" 
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                TypeName="InventoryDataTableAdapters.inv_GetItemSupplierTableAdapter">
                <SelectParameters>
                    <asp:SessionParameter Name="ICODE" SessionField="ItemCode" Type="Int32" />
                </SelectParameters>
            </asp:ObjectDataSource>
            <asp:ObjectDataSource ID="ds_Supplier" runat="server" DeleteMethod="Delete" 
                InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                SelectMethod="GetData" 
                TypeName="InventoryDataTableAdapters.inv_supplierdetailsTableAdapter" 
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
            <asp:ObjectDataSource ID="ds_units" runat="server" DeleteMethod="Delete" 
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                TypeName="InventoryDataTableAdapters.inv_itemunitsTableAdapter" 
                UpdateMethod="Update">
                <DeleteParameters>
                    <asp:Parameter Name="Original_UnitCode" Type="UInt32" />
                </DeleteParameters>
                <UpdateParameters>
                    <asp:Parameter Name="UnitName" Type="String" />
                    <asp:Parameter Name="UnitShortName" Type="String" />
                    <asp:Parameter Name="Descriptions" Type="String" />
                    <asp:Parameter Name="Original_UnitCode" Type="UInt32" />
                </UpdateParameters>
            </asp:ObjectDataSource>
            </span>
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
