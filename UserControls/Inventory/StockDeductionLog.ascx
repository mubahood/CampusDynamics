<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StockDeductionLog.ascx.cs" Inherits="UserControls_Inventory_StockDeductionLog" %>
<style type="text/css">
    .style2
    {
        width: 92px;
    }
</style>

<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Stock Item Deduction Log" Width="100%">
            <HeaderImage Url="~/COOPERP/images/clipboard-task.png">
            </HeaderImage>
            <PanelCollection>
                <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <dx:ASPxImage ID="ASPxImage1" runat="server" 
                        ImageUrl="~/COOPERP/images/StockDeductions.png">
                    </dx:ASPxImage>
                    <br />
                    <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
                    <table style="width: 100%;">
                        <tr>
                            <td width="100">
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td width="100">
                                Specify Date:</td>
                            <td>
                                <dx:ASPxDateEdit ID="txtDate" runat="server" AutoPostBack="True">
                                </dx:ASPxDateEdit>
                            </td>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td class="style2">
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                        </tr>
                    </table>
                    <dx:ASPxGridView ID="gv_deductions" runat="server" AutoGenerateColumns="False" 
                        DataSourceID="ds_stocklist" KeyFieldName="sno" Width="100%">
                        <TotalSummary>
                            <dx:ASPxSummaryItem DisplayFormat="Total: {0:0,000}" FieldName="StockLoss" 
                                ShowInColumn="Stock Loss" ShowInGroupFooterColumn="Stock Loss" 
                                SummaryType="Sum" ValueDisplayFormat="{0:0,000}" />
                        </TotalSummary>
                        <Columns>
                            <dx:GridViewDataTextColumn Caption="SNO" FieldName="sno" ReadOnly="True" 
                                ShowInCustomizationForm="True" VisibleIndex="0" Width="15px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemCode" ShowInCustomizationForm="True" 
                                VisibleIndex="1" Width="50px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" 
                                VisibleIndex="2" Width="270px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="DeductionUnit" 
                                ShowInCustomizationForm="True" VisibleIndex="3" Width="100px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="DeductionQty" 
                                ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="CostPrice" ShowInCustomizationForm="True" 
                                VisibleIndex="5" Width="100px">
                                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                                </PropertiesTextEdit>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="StockLoss" ShowInCustomizationForm="True" 
                                VisibleIndex="6" Width="100px">
                                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                                </PropertiesTextEdit>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="Reason" ShowInCustomizationForm="True" 
                                VisibleIndex="7" Width="200px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataDateColumn FieldName="DeductionDate" 
                                ShowInCustomizationForm="True" VisibleIndex="8" Width="170px">
                                <PropertiesDateEdit DisplayFormatString="dddd, dd MMMM, yyyy" 
                                    EditFormat="Custom">
                                </PropertiesDateEdit>
                            </dx:GridViewDataDateColumn>
                            <dx:GridViewDataTextColumn FieldName="CreatedBy" ShowInCustomizationForm="True" 
                                VisibleIndex="9" Width="80px">
                            </dx:GridViewDataTextColumn>
                        </Columns>
                        <SettingsBehavior AllowFocusedRow="True" />
                        <SettingsPager Mode="ShowAllRecords">
                        </SettingsPager>
                        <Settings ShowFooter="True" />
                    </dx:ASPxGridView>
                    <asp:ObjectDataSource ID="ds_stocklist" runat="server" 
                        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                        TypeName="InventoryDataTableAdapters.inv_GetStockDeductionsTableAdapter">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="txtDate" Name="dat" PropertyName="Value" 
                                Type="DateTime" />
                        </SelectParameters>
                    </asp:ObjectDataSource>
    <br />
                </dx:PanelContent>
            </PanelCollection>
        </dx:ASPxRoundPanel>
    </ContentTemplate>
</asp:UpdatePanel>

