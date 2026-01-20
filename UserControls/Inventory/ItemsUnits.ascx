<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ItemsUnits.ascx.cs" Inherits="UserControls_Inventory_ItemsUnits" %>
<style type="text/css">
    .style4
    {
        width: 1231px;
    }
</style>
<dx:ASPxRoundPanel runat="server" ShowHeader="False" Width="100%" ID="ASPxRoundPanel2">
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <div class="style25">
                <span class="style26"><strong>Enter Alternate Unit Qty:<br />
                    <img alt="" src="../../COOPERP/images/hor_line.png" width="100%" height="1" />
                </strong></span>
                <br />
            </div>
            <table style="width: 100%;">
                <tr>
                    <td class="style22">
                        Unit Code
                    </td>
                    <td class="style27">
                        <dx:ASPxComboBox runat="server" ValueType="System.UInt32" DataSourceID="ds_unitcodes"
                            TextField="UnitShortName" ValueField="UnitCode" Width="270px" ID="txtUnit_ucode"
                            TabIndex="1">
                        </dx:ASPxComboBox>
                    </td>
                    <td class="style28">
                        Cost Price
                    </td>
                    <td>
                        <dx:ASPxTextBox runat="server" Width="270px" ID="txtUnit_Costprice" TabIndex="5">
                        </dx:ASPxTextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style22">
                        Main Unit Qty
                    </td>
                    <td class="style27">
                        <dx:ASPxTextBox runat="server" Width="270px" ID="txtUnit_mainQty" TabIndex="2" 
                            AutoPostBack="True" OnTextChanged="txtUnit_mainQty_TextChanged">
                        </dx:ASPxTextBox>
                    </td>
                    <td class="style28">
                        Selling Price
                    </td>
                    <td>
                        <dx:ASPxTextBox runat="server" Width="270px" ID="txtUnit_SellingPrice" TabIndex="6">
                        </dx:ASPxTextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style22">
                        Alternate Unit Qty
                    </td>
                    <td class="style27">
                        <dx:ASPxTextBox runat="server" Width="270px" ID="txtUnit_alternateQty" 
                            TabIndex="3" AutoPostBack="True" 
                            OnTextChanged="txtUnit_alternateQty_TextChanged">
                        </dx:ASPxTextBox>
                    </td>
                    <td class="style28">
                        International Barcode 1
                    </td>
                    <td>
                        <dx:ASPxTextBox runat="server" Width="270px" ID="txtUnit_barcode1" TabIndex="7">
                        </dx:ASPxTextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style22">
                        Conversion To main Unit Qty
                    </td>
                    <td class="style27">
                        <dx:ASPxTextBox runat="server" Width="270px" ID="txtUnit_conversionQty" 
                            TabIndex="4" AutoPostBack="True" Enabled="False" ReadOnly="True">
                        </dx:ASPxTextBox>
                    </td>
                    <td class="style28">
                        International Barcode 2
                    </td>
                    <td>
                        <dx:ASPxTextBox runat="server" Width="270px" ID="txtUnit_barcode2" TabIndex="8">
                        </dx:ASPxTextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style22">
                        &nbsp;
                    </td>
                    <td class="style27">
                        <dx:ASPxButton runat="server" Text="Add Unit" Width="270px" ID="cmdAddUnit" OnClick="cmdAddUnit_Click"
                            TabIndex="10">
                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                    <td class="style28">
                        International Barcode 3
                    </td>
                    <td>
                        <dx:ASPxTextBox runat="server" Width="270px" ID="txtUnit_Barcode3" TabIndex="9">
                        </dx:ASPxTextBox>
                    </td>
                </tr>
                <tr>
                    <td class="style22">
                        &nbsp;
                    </td>
                    <td class="style27">
                        <dx:ASPxButton runat="server" Text="Clear" Width="270px" ID="cmdClear" OnClick="cmdClear_Click"
                            TabIndex="11">
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                    <td class="style28">
                        &nbsp;
                    </td>
                    <td style="text-align: right">
                        &nbsp;
                    </td>
                </tr>
            </table>
            <dx:ASPxGridView runat="server" KeyFieldName="ItemCode" AutoGenerateColumns="False"
                DataSourceID="ds_unitsList" Width="100%" ID="gv_Itemunits">
                <Columns>
                    <dx:GridViewCommandColumn ShowSelectCheckbox="True" ShowInCustomizationForm="True"
                        Width="20px" Caption="&lt;" VisibleIndex="11">
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="ItemCode" ReadOnly="True" ShowInCustomizationForm="True"
                        Visible="False" VisibleIndex="0">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="UnitCode" ReadOnly="True" ShowInCustomizationForm="True"
                        Visible="False" VisibleIndex="1">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="CostPrice" ShowInCustomizationForm="True" Width="100px"
                        VisibleIndex="3">
                        <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                        </PropertiesTextEdit>
                        <CellStyle HorizontalAlign="Left">
                        </CellStyle>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="SellingPrice" ShowInCustomizationForm="True"
                        Width="100px" VisibleIndex="4">
                        <PropertiesTextEdit DisplayFormatString="{0:0,000}">
                        </PropertiesTextEdit>
                        <CellStyle HorizontalAlign="Left">
                        </CellStyle>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="MainUnitQty" ShowInCustomizationForm="True"
                        Width="100px" VisibleIndex="5">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center">
                        </CellStyle>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="AlternateUnitQty" ShowInCustomizationForm="True"
                        Width="100px" VisibleIndex="6">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center">
                        </CellStyle>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="ConversionToMainQty" ShowInCustomizationForm="True"
                        Width="170px" VisibleIndex="7">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center">
                        </CellStyle>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="int_Barcode1" ShowInCustomizationForm="True"
                        Width="100px" Caption="Barcode" VisibleIndex="8">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="int_Barcode2" ShowInCustomizationForm="True"
                        Visible="False" VisibleIndex="9">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="int_Barcode3" ShowInCustomizationForm="True"
                        Visible="False" VisibleIndex="10">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="ShortName" ShowInCustomizationForm="True" Width="50px"
                        Caption="Unit" VisibleIndex="2">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <SettingsBehavior AllowFocusedRow="True"></SettingsBehavior>
                <SettingsPager Mode="ShowAllRecords">
                </SettingsPager>
                <Settings ShowVerticalScrollBar="True" VerticalScrollableHeight="150"></Settings>
            </dx:ASPxGridView>
            <table style="width: 100%;">
                <tr>
                    <td class="style4">
                    </td>
                    <td style="vertical-align: middle; text-align: right;">
                        <dx:ASPxButton ID="cmdDelete" runat="server" OnClick="cmdDelete_Click" TabIndex="13"
                            Text="Delete Selected" Width="170px">
                            <Image Url="~/COOPERP/images/minus-button.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                </tr>
            </table>
            <asp:ObjectDataSource runat="server" DeleteMethod="DeleteItemUnits" OldValuesParameterFormatString="original_{0}"
                SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_GetitemUnitsTableAdapter"
                ID="ds_unitsList">
                <DeleteParameters>
                    <asp:Parameter Name="icd" Type="Int32"></asp:Parameter>
                    <asp:Parameter Name="ucd" Type="Int32"></asp:Parameter>
                </DeleteParameters>
                <SelectParameters>
                    <asp:SessionParameter Name="Icode" SessionField="ItemCode" Type="Int32" />
                </SelectParameters>
            </asp:ObjectDataSource>
            <asp:ObjectDataSource runat="server" OldValuesParameterFormatString="original_{0}"
                SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_GetsecondaryItemUnitsTableAdapter"
                ID="ds_unitcodes">
                <SelectParameters>
                    <asp:SessionParameter Name="Icode" SessionField="ItemCode" Type="Int32" />
                </SelectParameters>
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
                                <td>
                                    &nbsp;
                                </td>
                            </tr>
                        </table>
                    </dx:PopupControlContentControl>
                </ContentCollection>
            </dx:ASPxPopupControl>
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
