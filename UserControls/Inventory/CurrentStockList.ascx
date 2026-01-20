<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CurrentStockList.ascx.cs" Inherits="UserControls_Inventory_CurrentStockList" %>
<style type="text/css">
    .style2
    {
        width: 87px;
    }
    .style3
    {
        width: 271px;
    }
</style>
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Current Stock List" Width="100%" ShowHeader="False">
            <HeaderImage Url="~/COOPERP/images/reports-stack.png">
            </HeaderImage>
            <PanelCollection>
                <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <dx:ASPxImage ID="ASPxImage1" runat="server" 
                        ImageUrl="~/COOPERP/images/currentStock.png">
                    </dx:ASPxImage>
    <br />
    <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
                    <table style="width:100%;">
                        <tr>
                            <td class="style2">
                                &nbsp;</td>
                            <td class="style3">
                                &nbsp;</td>
                            <td width="170">
                                &nbsp;</td>
                            <td width="170">
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td class="style2">
                                Select Option:</td>
                            <td class="style3">
                                <dx:ASPxComboBox ID="txtoption" runat="server" AutoPostBack="True" 
                                    OnSelectedIndexChanged="txtoption_SelectedIndexChanged" Width="270px" 
                                    SelectedIndex="0" Height="35px">
                                    <Items>
                                        <dx:ListEditItem Text="---Select Option ---" Value="-" Selected="True" />
                                        <dx:ListEditItem Text="List All Items" Value="ALL" />
                                        <dx:ListEditItem Text="Search For Item" Value="SEARCH" />
                                    </Items>
                                </dx:ASPxComboBox>
                            </td>
                            <td width="170">
                                <dx:ASPxButton ID="cmdRefresh" runat="server" OnClick="cmdRefresh_Click" 
                                    Text="Refresh" Width="170px" Height="35px">
                                    <Image Url="~/COOPERP/images/arrow-circle-135-left.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                            <td width="170">
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                            <td align="right">
                                <dx:ASPxButton ID="cmdDeduct" runat="server" OnClick="cmdDeduct_Click" 
                                    Text="Deduct Stock" Width="170px" Height="35px">
                                    <Image Url="~/COOPERP/images/clipboard--minus.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                        <tr>
                            <td class="style2">
                                <dx:ASPxLabel ID="lbl_label" runat="server" Text="Item Name" Visible="False">
                                </dx:ASPxLabel>
                            </td>
                            <td class="style3">
                                <dx:ASPxTextBox ID="txtItem" runat="server" Visible="False" Width="270px" Height="35px">
                                </dx:ASPxTextBox>
                            </td>
                            <td>
                                <dx:ASPxButton ID="cmdSearch" runat="server" OnClick="cmdSearch_Click" 
                                    Text="Search" Visible="False" Width="170px" Height="35px">
                                    <Image Url="~/COOPERP/images/magnifier.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                            <td>
                                &nbsp;</td>
                            <td>
                                &nbsp;</td>
                            <td align="right">
                                <dx:ASPxButton ID="cmdCheckunit" runat="server" OnClick="cmdCheckunit_Click" 
                                    Text="View By Item Unit" Width="170px" Height="35px">
                                    <Image Url="~/COOPERP/images/clipboard-task.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                    </table>
                    <dx:ASPxGridView ID="gv_currentStock" runat="server" 
                        AutoGenerateColumns="False" DataSourceID="ds_stockList" KeyFieldName="ItemCode" 
                        Width="100%" OnHtmlRowPrepared="gv_currentStock_HtmlRowPrepared" >
                        <TotalSummary>
                            <dx:ASPxSummaryItem DisplayFormat="{0:0,000}" FieldName="StockValue" 
                                ShowInColumn="Stock Value" ShowInGroupFooterColumn="Stock Value" 
                                SummaryType="Sum" ValueDisplayFormat="{0:0,000}" />
                        </TotalSummary>
                        <SettingsSearchPanel Visible="True" />
                        <Columns>
                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                ShowSelectCheckbox="True" VisibleIndex="0" Width="10px">
                            </dx:GridViewCommandColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemCode" ReadOnly="True" 
                                ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                                <CellStyle HorizontalAlign="Left">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="ItemName" ShowInCustomizationForm="True" 
                                VisibleIndex="2" Width="270px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="Qty" ShowInCustomizationForm="True" 
                                VisibleIndex="6" Width="80px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="CostPrice" ShowInCustomizationForm="True" 
                                VisibleIndex="7" Width="100px">
                                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                                </PropertiesTextEdit>
                                <CellStyle HorizontalAlign="Left">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataDateColumn Caption="Date Modified" FieldName="DateCreated" 
                                ShowInCustomizationForm="True" VisibleIndex="3" Width="170px">
                                <PropertiesDateEdit DisplayFormatString="dddd, dd MMMM, yyyy">
                                </PropertiesDateEdit>
                            </dx:GridViewDataDateColumn>
                            <dx:GridViewDataTextColumn FieldName="Store" ShowInCustomizationForm="True" 
                                VisibleIndex="4" Width="80px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="CreatedBy" ShowInCustomizationForm="True" 
                                VisibleIndex="5" Width="80px">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="StockValue" 
                                ShowInCustomizationForm="True" VisibleIndex="8" Width="100px">
                                <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                                </PropertiesTextEdit>
                                <CellStyle HorizontalAlign="Right">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                        </Columns>
                        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" 
                            AllowSelectSingleRowOnly="True" />
                        <SettingsPager PageSize="20">
                        </SettingsPager>
                        <Settings ShowFooter="True" />
                    </dx:ASPxGridView>
                    <asp:ObjectDataSource ID="ds_stockList" runat="server" 
                        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                        TypeName="InventoryDataTableAdapters.inv_GetCurrentStockListTableAdapter">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="txtItem" Name="search" PropertyName="Text" 
                                Type="String" />
                        </SelectParameters>
                    </asp:ObjectDataSource>
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


