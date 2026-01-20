<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Groups.ascx.cs" Inherits="UserControls_Inventory_Groups" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }
    .style2
    {
        width: 100%;
    }
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Item Group Settings"
    Width="100%">
    <HeaderImage Url="~/COOPERP/images/reports-stack.png">
    </HeaderImage>
    <PanelCollection>
        <dx:PanelContent runat="server" SupportsDisabledAttribute="True">
            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/inv_groupsBanner.png">
            </dx:ASPxImage>
            <br />
            <img alt="" src="../../COOPERP/images/hor_line.png" height="1" width="100%" />
            <br />
            <table style="width: 100%;">
                <tr>
                    <td class="style2">
                        <dx:ASPxButton ID="cmdAdd" runat="server" Text="Add Group" Width="170px" 
                            OnClick="cmdAdd_Click">
                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                            </Image>
                        </dx:ASPxButton>
                    </td>
                    <td>
                        &nbsp;
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
            </table>
            <dx:ASPxGridView ID="gv_groups" runat="server" AutoGenerateColumns="False" DataSourceID="ds_groups"
                KeyFieldName="ItemGroupCode" Width="100%">
                <Columns>
                    <dx:GridViewCommandColumn ButtonType="Image" Caption="Action" ShowInCustomizationForm="True" VisibleIndex="3" Width="100px" ShowEditButton="True" ShowDeleteButton="True"/>
                    <dx:GridViewDataTextColumn FieldName="ItemGroupCode" ReadOnly="True" ShowInCustomizationForm="True"
                        VisibleIndex="0" Width="100px">
                        <EditFormSettings Visible="False" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="ItemGroupName" ShowInCustomizationForm="True"
                        VisibleIndex="1" Width="250px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="GroupDescription" ShowInCustomizationForm="True"
                        VisibleIndex="2">
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
            <asp:ObjectDataSource ID="ds_groups" runat="server" DeleteMethod="Delete" InsertMethod="Insert"
                OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="InventoryDataTableAdapters.inv_itemgroupTableAdapter"
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
            <br />
        </dx:PanelContent>
    </PanelCollection>
</dx:ASPxRoundPanel>
