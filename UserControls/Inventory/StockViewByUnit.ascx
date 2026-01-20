<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StockViewByUnit.ascx.cs" Inherits="UserControls_Inventory_StockViewByUnit" %>
<style type="text/css">
    .style3
    {
        width: 82px;
    }
    .style4
    {
        height: 9px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Inventory Management: Stock List by Unit" Width="100%">
    <HeaderImage Url="~/COOPERP/images/clipboard-list.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table style="width:100%;">
        <tr>
            <td class="style3">
                Select Unit:</td>
            <td>
                <dx:ASPxComboBox ID="txtUnit" runat="server" AutoPostBack="True" 
                    DataSourceID="ds_ItemUnits" SelectedIndex="0" TextField="Unit" 
                    ValueField="UnitCode" ValueType="System.UInt32">
                </dx:ASPxComboBox>
            </td>
            <td>
                &nbsp;</td>
        </tr>
    </table>
    <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
    <table style="width:100%;">
        <tr>
            <td class="style4">
            </td>
            <td class="style4">
            </td>
            <td class="style4">
            </td>
        </tr>
    </table>
    <dx:ASPxGridView ID="gv_currentStock" runat="server" 
        AutoGenerateColumns="False" DataSourceID="ds_ItemsList" KeyFieldName="ItemCode" 
        Width="100%">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="ItemCode" ReadOnly="True" 
                ShowInCustomizationForm="True" VisibleIndex="0" Width="20px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" 
                VisibleIndex="1" Width="270px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="Qty" ShowInCustomizationForm="True" 
                VisibleIndex="5" Width="100px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="CostPrice" ShowInCustomizationForm="True" 
                VisibleIndex="6" Width="50px">
                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                </PropertiesTextEdit>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="StockValue" 
                ShowInCustomizationForm="True" VisibleIndex="7" Width="50px">
                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                </PropertiesTextEdit>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataDateColumn Caption="Date Modified" FieldName="DateCreated" 
                ShowInCustomizationForm="True" VisibleIndex="2" Width="180px">
                <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                </PropertiesDateEdit>
            </dx:GridViewDataDateColumn>
            <dx:GridViewDataTextColumn FieldName="Store" ShowInCustomizationForm="True" 
                VisibleIndex="3" Width="100px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="CreatedBy" ShowInCustomizationForm="True" 
                VisibleIndex="4" Width="100px">
            </dx:GridViewDataTextColumn>
        </Columns>
        <SettingsBehavior AllowFocusedRow="True" />
    </dx:ASPxGridView>
    <asp:ObjectDataSource ID="ds_ItemsList" runat="server" 
        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
        TypeName="InventoryDataTableAdapters.inv_GetStockList_ByUnitTableAdapter">
        <SelectParameters>
            <asp:SessionParameter Name="ICD" SessionField="ItemC" Type="Int32" />
            <asp:ControlParameter ControlID="txtUnit" Name="UCD" PropertyName="Value" 
                Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="ds_ItemUnits" runat="server" 
        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
        TypeName="InventoryDataTableAdapters.inv_GetOtherStockLitsUnitsTableAdapter">
        <SelectParameters>
            <asp:SessionParameter Name="ICD" SessionField="ItemC" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <table style="width:100%;">
        <tr>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
    </table>
    <table style="width:100%;">
        <tr>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
            <td>
                &nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

