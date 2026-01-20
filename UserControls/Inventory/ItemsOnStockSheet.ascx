<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ItemsOnStockSheet.ascx.cs" Inherits="UserControls_Inventory_ItemsOnStockSheet" %>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Items On Capture Sheet" Width="100%">
    <HeaderImage Url="~/COOPERP/images/truck--arrow - Copy.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <dx:ASPxGridView ID="gv_sheetitems" runat="server" AutoGenerateColumns="False" 
        DataSourceID="ds_sheetitems" KeyFieldName="SNO" Width="100%">
        <Columns>
            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                ShowSelectCheckbox="True" VisibleIndex="0" Width="30px">
            </dx:GridViewCommandColumn>
            <dx:GridViewDataTextColumn FieldName="SNO" ShowInCustomizationForm="True" 
                SortIndex="0" SortOrder="Ascending" VisibleIndex="1" Width="20px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="SheetNo" ShowInCustomizationForm="True" 
                VisibleIndex="2" Width="20px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" 
                VisibleIndex="3" Width="190px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="Unit" ShowInCustomizationForm="True" 
                VisibleIndex="4" Width="40px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="Qty" ShowInCustomizationForm="True" 
                VisibleIndex="5" Width="40px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="CostPrice" ShowInCustomizationForm="True" 
                VisibleIndex="6" Width="50px">
                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                </PropertiesTextEdit>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="Total" ShowInCustomizationForm="True" 
                VisibleIndex="7" Width="50px">
                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                </PropertiesTextEdit>
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="Store" ShowInCustomizationForm="True" 
                VisibleIndex="8" Width="80px">
            </dx:GridViewDataTextColumn>
        </Columns>
        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" 
            AllowSelectSingleRowOnly="True" />
        <SettingsPager Mode="ShowAllRecords">
        </SettingsPager>
    </dx:ASPxGridView>
    <asp:ObjectDataSource ID="ds_sheetitems" runat="server" 
        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
        TypeName="InventoryDataTableAdapters.inv_GetStockCaptureSheetitemsTableAdapter">
        <SelectParameters>
            <asp:Parameter DefaultValue="0" Name="Act" Type="Int32" />
            <asp:SessionParameter Name="SHNO" SessionField="Sht_No" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

