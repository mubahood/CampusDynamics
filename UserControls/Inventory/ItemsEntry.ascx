<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ItemsEntry.ascx.cs" Inherits="UserControls_Inventory_ItemsEntry" %>
<style type="text/css">
 

    .style2
    {
        width: 32%;
    }
    .style19
    {
        width: 17%;
    }
 

    .style29
    {
        width: 258px;
    }
 

    .style31
    {
        width: 20%;
    }
    .style32
    {
        width: 29%;
    }
 

</style>
<asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
            HeaderText="Items Details" Width="100%" ShowHeader="False">
            <HeaderImage Url="~/COOPERP/images/clipboard-list.png">
            </HeaderImage>
            <PanelCollection>
                <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
                    <dx:ASPxImage ID="ASPxImage1" runat="server" 
                        ImageUrl="~/COOPERP/images/inv_ItemDetailsBanner.png">
                    </dx:ASPxImage>
            <br />
            <img alt="" src="../../COOPERP/images/hor_line.png" width="100%" height="1" style="margin-bottom: 0px" />
            <br />
                    <table style="width: 100%;">
                        <tr>
                            <td class="style2">
                                &nbsp;
                                <dx:ASPxLabel ID="lbl_item" runat="server" Visible="False">
                                </dx:ASPxLabel>
                            </td>
                            <td style="text-align: right">
                                &nbsp;<dx:ASPxLabel ID="lbl_itemcount" runat="server" Style="color: #0000FF">
                                </dx:ASPxLabel>
                            </td>
                        </tr>
                    </table>
                    <dx:ASPxPageControl ID="pgc_items" runat="server" ActiveTabIndex="0" 
                        Width="100%">
                        <TabPages>
                            <dx:TabPage Text="Item Detail">
                                <ActiveTabImage Url="~/COOPERP/images/fill.png">
                                </ActiveTabImage>
                                <ContentCollection>
                                    <dx:ContentControl runat="server" SupportsDisabledAttribute="True">
                                        <table style="width: 100%;">
                                            <tr>
                                                <td class="style19">
                                                    Item Group:</td>
                                                <td class="style32">
                                                    <dx:ASPxComboBox ID="txtgroup" runat="server" AutoPostBack="True" 
                                                        DataSourceID="ds_groups" IncrementalFilteringMode="Contains" 
                                                        OnSelectedIndexChanged="txtgroup_SelectedIndexChanged" 
                                                        TextField="ItemGroupName" ValueField="ItemGroupCode" ValueType="System.UInt32" 
                                                        Width="270px" TabIndex="1">
                                                    </dx:ASPxComboBox>
                                                </td>
                                                <td class="style31">
                                                    Primary Unit Re-Order Level</td>
                                                <td class="style29">
                                                    <dx:ASPxTextBox ID="txtreorderlevel" runat="server" TabIndex="7" Width="270px">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td>
                                                    <dx:ASPxButton ID="cmdSave" runat="server" OnClick="cmdSave_Click" 
                                                        TabIndex="15" Text="Save" Width="170px">
                                                        <Image Url="~/COOPERP/images/disk.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="style19">
                                                    Last Item Code:</td>
                                                <td class="style32">
                                                    <dx:ASPxTextBox ID="txtLasticode" runat="server" Width="270px" Enabled="False">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td class="style31">
                                                    &nbsp;Primary Unit Re-Order Quantity</td>
                                                <td class="style29">
                                                    <dx:ASPxTextBox ID="txtreorderQty" runat="server" TabIndex="8" Width="270px">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td>
                                                    <dx:ASPxButton ID="cmdUnits" runat="server" OnClick="cmdUnits_Click" 
                                                        TabIndex="17" Text="Add Units" Width="170px">
                                                        <Image Url="~/COOPERP/images/clipboard-list.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="style19">
                                                    Item Code:</td>
                                                <td class="style32">
                                                    <dx:ASPxTextBox ID="txticode" runat="server" Width="270px" Enabled="False" 
                                                        NullText="AUTO GENERATED">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td class="style31">
                                                    Tax code:</td>
                                                <td class="style29">
                                                    <dx:ASPxComboBox ID="txttax" runat="server" DataSourceID="ds_tax" TabIndex="9" 
                                                        TextField="TaxName" ValueField="TaxCode" ValueType="System.UInt32" 
                                                        Width="270px">
                                                    </dx:ASPxComboBox>
                                                </td>
                                                <td>
                                                    <dx:ASPxButton ID="cmdAddsupplier" runat="server" 
                                                        OnClick="cmdAddsupplier_Click" TabIndex="18" Text="Add Supplier" Width="170px">
                                                        <Image Url="~/COOPERP/images/truck.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="style19">
                                                    Item Name
                                                </td>
                                                <td class="style32">
                                                    <dx:ASPxTextBox ID="txtiname" runat="server" Width="270px" TabIndex="2">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td class="style31">
                                                    Cost Price:</td>
                                                <td class="style29">
                                                    <dx:ASPxTextBox ID="txtcostprice" runat="server" TabIndex="10" Width="270px">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td>
                                                    <dx:ASPxButton ID="cmdNew" runat="server" OnClick="cmdNew_Click" TabIndex="16" 
                                                        Text="New " Width="170px">
                                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="style19">
                                                    Item Short Name:</td>
                                                <td class="style32">
                                                    <dx:ASPxTextBox ID="txtshortname" runat="server" Width="270px" TabIndex="3">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td class="style31">
                                                    &nbsp;Selling Price</td>
                                                <td class="style29">
                                                    <dx:ASPxTextBox ID="txtsellingprice" runat="server" TabIndex="11" Width="270px" 
                                                        Text="0" Enabled="False">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td>
                                                    &nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td class="style19">
                                                    Unit
                                                </td>
                                                <td class="style32">
                                                    <dx:ASPxComboBox ID="txtunit" runat="server" ValueType="System.UInt32" 
                                                        Width="270px" DataSourceID="ds_units" IncrementalFilteringMode="Contains" 
                                                        TextField="UnitShortName" ValueField="UnitCode" TabIndex="4">
                                                    </dx:ASPxComboBox>
                                                </td>
                                                <td class="style31">
                                                    International Barcode 1:</td>
                                                <td class="style29">
                                                    <dx:ASPxTextBox ID="txtbarcode1" runat="server" TabIndex="12" Width="270px">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td>
                                                    &nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td class="style19">
                                                    Quantity Per Unit:</td>
                                                <td class="style32">
                                                    <dx:ASPxTextBox ID="txtqty" runat="server" TabIndex="5" Width="270px">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td class="style31">
                                                    International Barcode 2:</td>
                                                <td class="style29">
                                                    <dx:ASPxTextBox ID="txtbarcode2" runat="server" TabIndex="13" Width="270px">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td>
                                                    &nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td class="style19" style="vertical-align: top">
                                                    Description:</td>
                                                <td class="style32" style="vertical-align: top">
                                                    <dx:ASPxMemo ID="txtdesc" runat="server" Height="71px" TabIndex="6" 
                                                        Width="270px">
                                                    </dx:ASPxMemo>
                                                </td>
                                                <td class="style31" style="vertical-align: top">
                                                    International Barcode 3:</td>
                                                <td class="style29" style="vertical-align: top">
                                                    <dx:ASPxTextBox ID="txtbarcode3" runat="server" TabIndex="14" Width="270px">
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td>
                                                    &nbsp;</td>
                                            </tr>
                                        </table>
                                        <asp:ObjectDataSource ID="ds_groups" runat="server" DeleteMethod="Delete" 
                                            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                            SelectMethod="GetData" 
                                            TypeName="InventoryDataTableAdapters.inv_itemgroupTableAdapter" 
                                            UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_ItemGroupCode" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="ItemGroupName" Type="String" />
                                                <asp:Parameter Name="GroupDescription" Type="String" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="ItemGroupName" Type="String" />
                                                <asp:Parameter Name="GroupDescription" Type="String" />
                                                <asp:Parameter Name="Original_ItemGroupCode" Type="UInt32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="ds_units" runat="server" DeleteMethod="Delete" 
                                            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                            SelectMethod="GetData" 
                                            TypeName="InventoryDataTableAdapters.inv_itemunitsTableAdapter" 
                                            UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_UnitCode" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="UnitName" Type="String" />
                                                <asp:Parameter Name="UnitShortName" Type="String" />
                                                <asp:Parameter Name="Descriptions" Type="String" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="UnitName" Type="String" />
                                                <asp:Parameter Name="UnitShortName" Type="String" />
                                                <asp:Parameter Name="Descriptions" Type="String" />
                                                <asp:Parameter Name="Original_UnitCode" Type="UInt32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="ds_tax" runat="server" DeleteMethod="Delete" 
                                            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                            SelectMethod="GetData" 
                                            TypeName="InventoryDataTableAdapters.inv_taxdetailTableAdapter" 
                                            UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_TaxCode" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="TaxName" Type="String" />
                                                <asp:Parameter Name="Percentage" Type="UInt32" />
                                                <asp:Parameter Name="TaxType" Type="String" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="TaxName" Type="String" />
                                                <asp:Parameter Name="Percentage" Type="UInt32" />
                                                <asp:Parameter Name="TaxType" Type="String" />
                                                <asp:Parameter Name="Original_TaxCode" Type="UInt32" />
                                            </UpdateParameters>
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
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                        </TabPages>
                    </dx:ASPxPageControl>
            <br />
                </dx:PanelContent>
            </PanelCollection>
        </dx:ASPxRoundPanel>
    </ContentTemplate>
</asp:UpdatePanel>

