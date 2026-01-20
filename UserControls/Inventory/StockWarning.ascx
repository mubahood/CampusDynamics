<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StockWarning.ascx.cs" Inherits="UserControls_Inventory_StockWaring" %>
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Stock Warning" Width="100%" ShowHeader="False">
            <HeaderImage Url="~/COOPERP/images/folder--exclamation.png">
            </HeaderImage>
            <PanelCollection>
                <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <dx:ASPxImage ID="ASPxImage1" runat="server" 
                        ImageUrl="~/COOPERP/images/StockWarning.png">
                    </dx:ASPxImage>
                    <br />
                    <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
                    <table style="width:100%;">
                        <tr>
                            <td>
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                        </tr>
                    </table>
                    <dx:ASPxGridView ID="gv_stockAlert" runat="server" AutoGenerateColumns="False" 
                        DataSourceID="ds_warings" KeyFieldName="ItemCode" Width="100%">
                        <Columns>
                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                ShowSelectCheckbox="True" VisibleIndex="0" Width="10px">
                                <CellStyle HorizontalAlign="Left">
                                </CellStyle>
                            </dx:GridViewCommandColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemCode" ReadOnly="True" 
                                ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" 
                                VisibleIndex="2" Width="300px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="Unit" ShowInCustomizationForm="True" 
                                VisibleIndex="3" Width="40px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ReorderLevel" 
                                ShowInCustomizationForm="True" VisibleIndex="5" Width="170px">
                                <HeaderStyle HorizontalAlign="Center" />
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ReorderQty" 
                                ShowInCustomizationForm="True" VisibleIndex="6" Width="170px">
                                <HeaderStyle HorizontalAlign="Center" />
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn Caption="Remaining Qty" FieldName="CurrentQty" 
                                ShowInCustomizationForm="True" VisibleIndex="4" Width="170px">
                                <HeaderStyle HorizontalAlign="Left" />
                                <CellStyle HorizontalAlign="Left">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                        </Columns>
                        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" 
                            AllowSelectSingleRowOnly="True" />
                    </dx:ASPxGridView>
                    <asp:ObjectDataSource ID="ds_warings" runat="server" 
                        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                        TypeName="InventoryDataTableAdapters.inv_GetStockWarningsTableAdapter">
                    </asp:ObjectDataSource>
                </dx:PanelContent>
            </PanelCollection>
        </dx:ASPxRoundPanel>
    </ContentTemplate>
</asp:UpdatePanel>

