<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Superviors.ascx.cs" Inherits="UserControls_Graduate_Superviors" %>
<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <dx:ASPxImage ID="ASPxImage1" runat="server" ImageUrl="~/COOPERP/images/header_supervior.png"  ShowLoadingImage="True">
                </dx:ASPxImage>
                <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="True" Width="100%">
                </dx:ASPxImage>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <dx:ASPxButton ID="ASPxButton1" runat="server" Text="Add New" Width="170px" OnClick="ASPxButton1_Click">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="superviorGV" runat="server" AutoGenerateColumns="False" DataSourceID="SuperviorODS" KeyFieldName="Id" Width="100%">
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="5" Width="30px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="Id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Width="1px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Supervisor Name" FieldName="supervior_name" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Contact" FieldName="contact" ShowInCustomizationForm="True" VisibleIndex="2">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Status" FieldName="status" ShowInCustomizationForm="True" VisibleIndex="4">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="ACTIVE" Value="ACTIVE" />
                                    <dx:ListEditItem Text="NOT ACTIVE" Value="NOT ACTIVE" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Category" FieldName="category" ShowInCustomizationForm="True" VisibleIndex="3">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="Supervisor" Value="Supervisor" />
                                    <dx:ListEditItem Text="Other" Value="Other" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="SuperviorODS" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="GraduateDataTableAdapters.acad_superviorsTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="supervior_name" Type="String" />
                        <asp:Parameter Name="contact" Type="String" />
                        <asp:Parameter Name="status" Type="String" />
                        <asp:Parameter Name="category" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="supervior_name" Type="String" />
                        <asp:Parameter Name="contact" Type="String" />
                        <asp:Parameter Name="status" Type="String" />
                        <asp:Parameter Name="category" Type="String" />
                        <asp:Parameter Name="Original_Id" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

