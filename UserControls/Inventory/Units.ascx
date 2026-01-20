<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Units.ascx.cs" Inherits="UserControls_Inventory_Units" %>
<style type="text/css">
    .style2
    {
        width: 196px;
        height: 27px;
    }
    .style3
    {
        height: 27px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Product Unit Settings" Width="100%">
    <HeaderImage Url="~/COOPERP/images/target - Copy.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <dx:ASPxImage ID="ASPxImage1" runat="server" 
        ImageUrl="~/COOPERP/images/inv_unitsBanner.png">
    </dx:ASPxImage>
    <br />
    <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
    <br />
    <table style="width:100%;">
        <tr>
            <td class="style2">
                <dx:ASPxButton ID="cmdAdd" runat="server" OnClick="cmdAdd_Click" 
                    Text="Add Unit" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
            <td class="style3">
            </td>
            <td class="style3">
            </td>
        </tr>
    </table>
    <dx:ASPxGridView ID="gv_units" runat="server" AutoGenerateColumns="False" 
        DataSourceID="ds_units" KeyFieldName="UnitCode" Width="100%">
        <Columns>
            <dx:GridViewCommandColumn ButtonType="Image" Caption="Action" ShowInCustomizationForm="True" VisibleIndex="4" Width="100px" ShowEditButton="True" ShowDeleteButton="True"/>
            <dx:GridViewDataTextColumn FieldName="UnitCode" ReadOnly="True" 
                ShowInCustomizationForm="True" VisibleIndex="0" Width="100px">
                <EditFormSettings Visible="False" />
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="UnitName" ShowInCustomizationForm="True" 
                VisibleIndex="1" Width="200px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="UnitShortName" 
                ShowInCustomizationForm="True" VisibleIndex="2" Width="170px">
            </dx:GridViewDataTextColumn>
            <dx:GridViewDataTextColumn FieldName="Descriptions" 
                ShowInCustomizationForm="True" VisibleIndex="3">
            </dx:GridViewDataTextColumn>
        </Columns>
        <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
        <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
        <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
            <EditButton>
                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                </Image>
            </EditButton>
            <DeleteButton>
                <Image Url="~/COOPERP/images/minus-button.png">
                </Image>
            </DeleteButton>
        </SettingsCommandButton>
    </dx:ASPxGridView>
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
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

