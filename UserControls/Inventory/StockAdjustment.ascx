<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StockAdjustment.ascx.cs"
    Inherits="UserControls_Inventory_StockAdjustment" %>
<style type="text/css">
    
    .style2
    {
        width: 158px;
    }
    
    .style3
    {
        width: 122px;
    }
    .style4
    {
        width: 161px;
    }
    .style5
    {
        width: 255px;
    }
    .style6
    {
        width: 175px;
    }
    
</style>
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Stock Adjustment Panel"
            Width="100%">
            <HeaderImage Url="~/COOPERP/images/clipboard--plus.png">
            </HeaderImage>
            <PanelCollection>
                <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/StockAdjustment.png">
                    </dx:ASPxImage>
                    <br />
                    <img alt="" height="1" src="../../COOPERP/images/hor_line.png" width="100%" />
                    <br />
                    <table style="width: 100%;">
                        <tr>
                            <td class="style3">
                                Verified Sheet Nos.&nbsp;</td>
                            <td class="style6">
                                <dx:ASPxComboBox ID="txtsheetNo" runat="server" AutoPostBack="True" 
                                    DataSourceID="ds_sheetNo" TextField="SheetNo" ValueField="SheetNo" 
                                    ValueType="System.UInt32">
                                </dx:ASPxComboBox>
                            </td>
                            <td class="style2">
                                <dx:ASPxButton ID="cmdGenerate" runat="server" OnClick="cmdGenerate_Click" 
                                    Text="Generate Stock" ToolTip="Generate all Verified Stock Items" Width="170px">
                                    <Image Url="~/COOPERP/images/reports-stack.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                            <td class="style4">
                                <dx:ASPxButton ID="cmdAdjust" runat="server" Text="Adjust Stock" Width="170px" 
                                    OnClick="cmdAdjust_Click" ToolTip="Item Quanties will be Added to Stock">
                                    <Image Url="~/COOPERP/images/blue-folder--plus.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td class="style3">
                                &nbsp;</td>
                            <td class="style6">
                                &nbsp;</td>
                            <td class="style2">
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                    </table>
                    <dx:ASPxGridView ID="gv_stock" runat="server" Width="100%" 
                        AutoGenerateColumns="False" DataSourceID="ds_items" KeyFieldName="SNO">
                        <TotalSummary>
                            <dx:ASPxSummaryItem DisplayFormat="Total: {0:0,000.}" FieldName="Total" 
                                ShowInColumn="Total" ShowInGroupFooterColumn="Total" SummaryType="Sum" 
                                ValueDisplayFormat="{0:0,000}" />
                        </TotalSummary>
                        <Columns>
                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                ShowSelectCheckbox="True" VisibleIndex="0" Width="10px">
                            </dx:GridViewCommandColumn>
                            <dx:GridViewDataTextColumn FieldName="SNO" ReadOnly="True" 
                                ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemCode" ShowInCustomizationForm="True" 
                                VisibleIndex="3" Width="40px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="UnitCode" ShowInCustomizationForm="True" 
                                Visible="False" VisibleIndex="5">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="SysQty" ShowInCustomizationForm="True" 
                                VisibleIndex="8" Width="60px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn Caption="New Qty" FieldName="Qty" 
                                ShowInCustomizationForm="True" VisibleIndex="7" Width="40px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="CostPrice" ShowInCustomizationForm="True" 
                                VisibleIndex="9" Width="80px">
                                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                                </PropertiesTextEdit>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="Total" ShowInCustomizationForm="True" 
                                VisibleIndex="10" Width="80px">
                                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                                </PropertiesTextEdit>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="LocationCode" 
                                ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="SheetNo" ShowInCustomizationForm="True" 
                                VisibleIndex="2" Width="40px" Visible="False">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="Unit" ShowInCustomizationForm="True" 
                                VisibleIndex="6" Width="40px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" 
                                VisibleIndex="4" Width="270px">
                            </dx:GridViewDataTextColumn>
                        </Columns>
                        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" />
                        <SettingsPager Mode="ShowAllRecords">
                        </SettingsPager>
                        <Settings ShowFooter="True" />
                        <SettingsText EmptyDataRow="Identify Verified Stock Sheet Number!" />
                    </dx:ASPxGridView>
                    <asp:ObjectDataSource ID="ds_sheetNo" runat="server" 
                        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                        TypeName="InventoryDataTableAdapters.inv_GetVerifiedSheetNumbersTableAdapter">
                    </asp:ObjectDataSource>
                    <asp:ObjectDataSource ID="ds_items" runat="server" 
                        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                        TypeName="InventoryDataTableAdapters.inv_GetStockItemsToAdjustTableAdapter">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="txtsheetNo" Name="sht" PropertyName="Value" 
                                Type="Int32" />
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
