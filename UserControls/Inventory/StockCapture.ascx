<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StockCapture.ascx.cs"
    Inherits="UserControls_Inventory_StockCapture" %>

<style type="text/css">
    .style15
    {
        width: 208px;
    }
    .style17
    {
        width: 138px;
    }
    .style18
    {
        width: 83px;
    }
    .style19
    {
        width: 63px;
    }
</style>

<%--<style type="text/css">
    
   
    
</style>--%>
<%--<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>--%>
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Stock Capture Sheet"
            Width="100%" ShowHeader="False">
            <HeaderImage Url="~/COOPERP/images/truck--arrow - Copy.png">
            </HeaderImage>
            <PanelCollection>
                <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/StockCapture.png">
                    </dx:ASPxImage>
                    <br />
                    <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
                    <br />
                    <table style="width: 100%;">
                        <tr>
                            <td class="style19">
                                &nbsp;</td>
                            <td class="style15">
                                &nbsp;</td>
                            <td class="style17">
                                &nbsp;</td>
                            <td class="style18">
                                &nbsp;</td>
                            <td align="right">
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td class="style19">
                                Date:</td>
                            <td class="style15">
                                <dx:ASPxDateEdit ID="txtSheetDate" runat="server" AutoPostBack="True" 
                                    Width="200px" Height="35px">
                                </dx:ASPxDateEdit>
                            </td>
                            <td class="style17">
                                &nbsp;</td>
                            <td class="style18">
                                &nbsp;</td>
                            <td align="right">
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td class="style19">
                                &nbsp;</td>
                            <td class="style15">
                                <dx:ASPxButton ID="cmdNew" runat="server" OnClick="cmdNew_Click" 
                                    Text="Create New Sheet" Width="200px" Height="35px">
                                    <Image Url="~/COOPERP/images/clipboard-invoice.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                            <td class="style17">
                                &nbsp;</td>
                            <td class="style18">
                                &nbsp;</td>
                            <td align="right">
                                <dx:ASPxButton ID="cmdSubmit" runat="server" OnClick="cmdSubmit_Click" 
                                    TabIndex="9" Text="Approve GRN (Sheet)" Width="200px" Height="35px">
                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Approve Sheet?');
}" />
                                    <Image Url="~/COOPERP/images/tick-button.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                    </table>
                    <dx:ASPxGridView ID="gv_capturesheets" runat="server" 
                        AutoGenerateColumns="False" DataSourceID="ds_sheets" KeyFieldName="SheetNo" 
                        Width="100%" OnHtmlRowPrepared="gv_capturesheets_HtmlRowPrepared">
                        <Columns>
                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                ShowSelectCheckbox="True" VisibleIndex="0" Width="20px">
                            </dx:GridViewCommandColumn>
                            <dx:GridViewDataTextColumn Caption="GRN No." FieldName="SheetNo" 
                                ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" 
                                Width="100px" SortIndex="0" SortOrder="Descending">
                                <CellStyle HorizontalAlign="Left">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="SheetStatus" 
                                ShowInCustomizationForm="True" VisibleIndex="2">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn FieldName="CreatedBy" ShowInCustomizationForm="True" 
                                VisibleIndex="3">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataDateColumn FieldName="DateCreated" 
                                ShowInCustomizationForm="True" VisibleIndex="4" Width="200px">
                                <PropertiesDateEdit DisplayFormatString="dddd, dd MMMM, yyyy">
                                </PropertiesDateEdit>
                            </dx:GridViewDataDateColumn>
                            <dx:GridViewDataTextColumn FieldName="Comments" ShowInCustomizationForm="True" 
                                VisibleIndex="5">
                            </dx:GridViewDataTextColumn>
                            <dx:GridViewDataTextColumn Caption="Sheet Items" ShowInCustomizationForm="True" 
                                VisibleIndex="6" Width="30px">
                                <DataItemTemplate>
                                    <asp:ImageButton ID="imgDetails" runat="server" 
                                        ImageUrl="~/COOPERP/images/clipboard-invoice.png" onclick="imgDetails_Click" />
                                </DataItemTemplate>
                                <CellStyle HorizontalAlign="Center">
                                </CellStyle>
                            </dx:GridViewDataTextColumn>
                        </Columns>
                        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" 
                            AllowSelectSingleRowOnly="True" />
                        <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                        <SettingsText EmptyDataRow="No Capture sheets Found for Specified Date!" />
                    </dx:ASPxGridView>
                    <asp:ObjectDataSource ID="ds_sheets" runat="server" 
                        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                        TypeName="InventoryDataTableAdapters.inv_GetstockCaptureSheet_ByRunDateTableAdapter">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="txtSheetDate" Name="dat" PropertyName="Value" 
                                Type="DateTime" />
                        </SelectParameters>
                    </asp:ObjectDataSource>
                    <dx:ASPxPopupControl ID="pop_mgs" runat="server" CloseAction="CloseButton" HeaderText=".::"
                        Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                        <HeaderImage Url="~/COOPERP/images/clipboard-invoice.png">
                        </HeaderImage>
                        <ContentCollection>
                            <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                                <table style="width: 100%;">
                                    <tr>
                                        <td>
                                            &nbsp;
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
                                        <td style="text-align: left">
                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <br />
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
<%--    </ContentTemplate>
</asp:UpdatePanel>--%>
