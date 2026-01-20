<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StockDeduction.ascx.cs" Inherits="UserControls_Inventory_StockDeduction" %>
<style type="text/css">
    .style1
    {
        width: 157px;
    }
    .style2
    {
        width: 93px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Stock Item Quantity Deduction Panel:" Width="100%">
    <HeaderImage Url="~/COOPERP/images/clipboard--minus.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <img alt="" height="1" 
    src="../../COOPERP/images/hor_line.png" width="100%" />
    <table style="width:100%;">
        <tr>
            <td class="style2">
                Item Name</td>
            <td>
                <dx:ASPxLabel ID="lblItemName" runat="server" style="color: #0000FF">
                </dx:ASPxLabel>
            </td>
        </tr>
        <tr>
            <td class="style2">
                Deduction Unit</td>
            <td>
                <dx:ASPxComboBox ID="txtDeductionUnit" runat="server" DataSourceID="ds_units" 
                    TextField="Unit" ValueField="UnitCode" ValueType="System.UInt32" Width="270px">
                </dx:ASPxComboBox>
            </td>
        </tr>
        <tr>
            <td class="style2">
                Deduction Qty</td>
            <td>
                <dx:ASPxTextBox ID="txtDeductionQty" runat="server" Width="270px">
                </dx:ASPxTextBox>
            </td>
        </tr>
        <tr>
            <td class="style2">
                Reason</td>
            <td>
                <dx:ASPxTextBox ID="txtreason" runat="server" Width="270px">
                    <ValidationSettings>
                        <RequiredField IsRequired="True" />
                    </ValidationSettings>
                </dx:ASPxTextBox>
            </td>
        </tr>
        <tr>
            <td class="style2">
                &nbsp;</td>
            <td>
                <dx:ASPxButton ID="cmdSubmit" runat="server" Text="Deduct Qty" Width="270px" 
                    OnClick="cmdSubmit_Click">
                    <Image Url="~/COOPERP/images/eraser--minus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td class="style2">
                &nbsp;</td>
            <td>
                <dx:ASPxButton ID="cmdRollback" runat="server" OnClick="cmdRollback_Click" 
                    Text="Roll Back" Width="270px">
                    <Image Url="~/COOPERP/images/arrow-circle-135-left.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
    </table>
    <asp:ObjectDataSource ID="ds_units" runat="server" 
        OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
        TypeName="InventoryDataTableAdapters.inv_GetItemPrimaryUnitTableAdapter">
        <SelectParameters>
            <asp:SessionParameter Name="ICD" SessionField="ICD" Type="Int32" />
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
                            <td>
                                &nbsp;</td>
                        </tr>
                    </table>
                </dx:PopupControlContentControl>
            </ContentCollection>
    </dx:ASPxPopupControl>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

