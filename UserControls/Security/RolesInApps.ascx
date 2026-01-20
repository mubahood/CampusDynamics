<%@ Control Language="C#" AutoEventWireup="true" CodeFile="RolesInApps.ascx.cs" Inherits="UserControls_Security_RolesInApps" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    .style2
    {
        width: 89px;
    }
    .style3
    {
        width: 366px;
    }


</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Application Access Definition" Width="100%">
    <HeaderImage Url="~/COOPERP/images/tick-shield.png">
    </HeaderImage>
    <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="style3" valign="top">
                            <table class="style1">
                                <tr>
                                    <td class="style2">
                                        Application:</td>
                                    <td>
                                        <dx:ASPxComboBox ID="txtApplications" runat="server" AutoPostBack="True" 
                                            DataSourceID="dsApps" EnableIncrementalFiltering="True" 
                                            IncrementalFilteringMode="StartsWith" TextField="app_name" 
                                            TextFormatString="{1}" ValueField="app_ID" ValueType="System.UInt32" 
                                            Width="250px">
                                            <Columns>
                                                <dx:ListBoxColumn Caption="SNo" FieldName="app_ID" Width="40px" />
                                                <dx:ListBoxColumn Caption="Application" FieldName="app_name" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style2">
                                        Role:</td>
                                    <td>
                                        <dx:ASPxComboBox ID="txtRoles" runat="server" DataSourceID="ods_roles" 
                                            EnableIncrementalFiltering="True" IncrementalFilteringMode="StartsWith" 
                                            TextField="name" TextFormatString="{1}" ValueField="id" 
                                            ValueType="System.Int32" Width="250px">
                                            <Columns>
                                                <dx:ListBoxColumn Caption="SNo" FieldName="id" />
                                                <dx:ListBoxColumn Caption="Application" FieldName="name" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style2">
                                        &nbsp;</td>
                                    <td>
                                        <dx:ASPxButton ID="cmdAdd" runat="server" OnClick="cmdAdd_Click" 
                                            Text="Add Role to Application" Width="250px">
                                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style2">
                                        &nbsp;</td>
                                    <td>
                                        <dx:ASPxButton ID="cmdRemove" runat="server" OnClick="cmdRemove_Click" 
                                            Text="Remove from Application" Width="250px">
                                            <Image Url="~/COOPERP/images/minus-button.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td valign="top">
                            <dx:ASPxGridView ID="gvRoles" runat="server" AutoGenerateColumns="False" 
                                DataSourceID="dsRolesInApps" KeyFieldName="appID" Width="50%">
                                <Columns>
                                    <dx:GridViewDataTextColumn FieldName="appID" ReadOnly="True" 
                                        ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataComboBoxColumn Caption="Roles In Application" 
                                        FieldName="roleID" ReadOnly="True" ShowInCustomizationForm="True" 
                                        VisibleIndex="1">
                                        <PropertiesComboBox DataSourceID="ods_roles" TextField="name" 
                                            TextFormatString="{1}" ValueField="id" ValueType="System.String">
                                        </PropertiesComboBox>
                                    </dx:GridViewDataComboBoxColumn>
                                </Columns>
                            </dx:ASPxGridView>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsApps" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="SecurityTableAdapters.my_aspnet_appsTableAdapter">
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="ods_roles" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="SecurityTableAdapters.my_aspnet_rolesTableAdapter">
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsRolesInApps" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetRolesInApp" 
                    TypeName="SecurityTableAdapters.my_aspnet_roles_in_appsTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtApplications" Name="AppID" 
                            PropertyName="Value" Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

