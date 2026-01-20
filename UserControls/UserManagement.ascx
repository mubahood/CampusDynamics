<%@ Control Language="C#" AutoEventWireup="true" CodeFile="UserManagement.ascx.cs" Inherits="UserControls_UserManagement" %>
<%@ Register src="Security/RolesInApps.ascx" tagname="RolesInApps" tagprefix="uc1" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
<style type="text/css">



img 
{
	border-width: 0px;
}


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


.style7
    {
        width: 19px;
    }
    

    .auto-style1 {
        width: 85px;
    }
    

</style>
    <dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" 
        HeaderText="User Management Panel" Width="100%">
        <HeaderImage Url="~/COOPERP/images/user.png">
        </HeaderImage>
        <PanelCollection>
<dx:PanelContent runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_accessmagt.png">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" 
                                ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
    </table>
    
                <dx:ASPxPageControl ID="pc_usermanager" runat="server" ActiveTabIndex="0" Width="100%">
                    <TabPages>
                        <dx:TabPage Text=" Users List">
                            <TabImage IconID="people_usergroup_16x16">
                            </TabImage>
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <dx:ASPxCallbackPanel ID="CBP_Users" runat="server" OnCallback="CBP_Users_Callback" Width="100%">
                                        <PanelCollection>
                                            <dx:PanelContent runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td style="width: 702px">
                                                            <dx:ASPxButton ID="cmdNewUser" runat="server" PostBackUrl="~/Security/Register.aspx" Text="Add User" Width="150px" Height="35px">
                                                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td style="width: 11px">&nbsp;</td>
                                                        <td>
                                                            &nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td style="width: 702px" valign="top">
                                                            <dx:ASPxGridView ID="gvUsers" runat="server" AutoGenerateColumns="False" DataSourceID="ods_usersList" KeyFieldName="id" OnFocusedRowChanged="gvUsers_FocusedRowChanged" OnSelectionChanged="gvUsers_FocusedRowChanged" Width="100%" OnHtmlDataCellPrepared="gvUserPhones_HtmlDataCellPrepared" OnCustomErrorText="gvUsers_CustomErrorText">
                                                                <ClientSideEvents FocusedRowChanged="function(s, e) {
	gvUserRoles.Refresh();
gvUserFaculties.Refresh();

}" />
                                                                <SettingsDataSecurity AllowDelete="False" />
                                                                <SettingsSearchPanel Visible="True" />
                                                                <Columns>
                                                                    <dx:GridViewDataTextColumn FieldName="id" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                        <EditFormSettings Visible="False" />
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="applicationId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn Caption="User Name" FieldName="name" ShowInCustomizationForm="True" VisibleIndex="4" ReadOnly="True">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataDateColumn Caption="Last Active Date" FieldName="lastActivityDate" ShowInCustomizationForm="True" VisibleIndex="6" Width="150px" ReadOnly="True">
                                                                        <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy HH:mm">
                                                                        </PropertiesDateEdit>
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataCheckColumn Caption="Aproved" FieldName="IsApproved" ShowInCustomizationForm="True" VisibleIndex="7" ReadOnly="True">
                                                                    </dx:GridViewDataCheckColumn>
                                                                    <dx:GridViewDataDateColumn FieldName="LastLoginDate" ShowInCustomizationForm="True" VisibleIndex="8" ReadOnly="True">
                                                                        <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy HH:mm">
                                                                        </PropertiesDateEdit>
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataDateColumn FieldName="CreationDate" ShowInCustomizationForm="True" VisibleIndex="10" Visible="False">
                                                                        <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy">
                                                                        </PropertiesDateEdit>
                                                                    </dx:GridViewDataDateColumn>
                                                                    <dx:GridViewDataCheckColumn FieldName="IsLockedOut" ShowInCustomizationForm="True" VisibleIndex="11">
                                                                    </dx:GridViewDataCheckColumn>
                                                                    <dx:GridViewDataTextColumn Caption="Failed Attempts" FieldName="FailedPasswordAttemptCount" ShowInCustomizationForm="True" VisibleIndex="12" Visible="False">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="1" Width="25px">
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="13" Width="40px" ShowEditButton="True">
                                                                    </dx:GridViewCommandColumn>
                                                                </Columns>
                                                                <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" AllowSelectSingleRowOnly="True" ConfirmDelete="True" />
                                                                <SettingsPager PageSize="5">
                                                                </SettingsPager>
                                                                <Settings ShowFilterRowMenu="True" />
                                                            </dx:ASPxGridView>
                                                        </td>
                                                        <td style="width: 11px" valign="top">&nbsp;</td>
                                                        <td valign="top">
                                                            <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                                                                <TabPages>
                                                                    <dx:TabPage Text=" User Roles">
                                                                        <TabImage IconID="dashboards_locknavigation_16x16">
                                                                        </TabImage>
                                                                        <ContentCollection>
                                                                            <dx:ContentControl runat="server">
                                                                                <table class="style1">
                                                                                    <tr>
                                                                                        <td>
                                                                                            <table class="style1">
                                                                                                <tr>
                                                                                                    <td class="auto-style1">
                                                                                                        <dx:ASPxComboBox ID="txtNewRole" runat="server" DataSourceID="dsCurrRoles" Height="35px" TextField="name" TextFormatString="{0} :: {1}" ValueField="id">
                                                                                                            <Columns>
                                                                                                                <dx:ListBoxColumn Caption="No" FieldName="id" />
                                                                                                                <dx:ListBoxColumn Caption="Role" FieldName="name" />
                                                                                                            </Columns>
                                                                                                        </dx:ASPxComboBox>
                                                                                                    </td>
                                                                                                    <td align="right" style="text-align: left">
                                                                                                        <dx:ASPxButton ID="cmdNewUserRole" runat="server" Height="35px" OnClick="cmdNewUserRole_Click" Text="Add Role" Width="150px">
                                                                                                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                                                                            </Image>
                                                                                                        </dx:ASPxButton>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                            <dx:ASPxGridView ID="gvUserRoles" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvUserRoles" DataSourceID="ods_UserRoles" KeyFieldName="idrole" OnInitNewRow="gvUserRoles_InitNewRow" Width="100%">
                                                                                                <SettingsEditing Mode="Batch">
                                                                                                </SettingsEditing>
                                                                                                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                                                                <Columns>
                                                                                                    <dx:GridViewDataTextColumn FieldName="userId" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                                                        <EditFormSettings Visible="True" />
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="roleId" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                        <EditFormSettings Visible="True" />
                                                                                                        <EditItemTemplate>
                                                                                                            <dx:ASPxComboBox ID="txtData" runat="server" DataSourceID="dsCurrRoles" IncrementalFilteringMode="Contains" TextField="name" TextFormatString="{1}" Value='<%# Bind("roleId") %>' ValueField="id" ValueType="System.Int32" Width="100%">
                                                                                                                <Columns>
                                                                                                                    <dx:ListBoxColumn Caption="ID" FieldName="id" Width="25px" />
                                                                                                                    <dx:ListBoxColumn Caption="Role" FieldName="name" Width="80px" />
                                                                                                                </Columns>
                                                                                                            </dx:ASPxComboBox>
                                                                                                        </EditItemTemplate>
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="2" Width="25px">
                                                                                                    </dx:GridViewCommandColumn>
                                                                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="5" Width="25px">
                                                                                                    </dx:GridViewCommandColumn>
                                                                                                    <dx:GridViewDataComboBoxColumn Caption="User Role" FieldName="rolename" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                                        <PropertiesComboBox DataSourceID="dsCurrRoles" TextField="name" TextFormatString="{1}" ValueField="id" ValueType="System.Int32">
                                                                                                            <Columns>
                                                                                                                <dx:ListBoxColumn Caption="ID" FieldName="id" Width="30px" />
                                                                                                                <dx:ListBoxColumn Caption="Role" FieldName="name" Width="50px" />
                                                                                                            </Columns>
                                                                                                        </PropertiesComboBox>
                                                                                                        <EditFormSettings Visible="False" />
                                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="idrole" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                </Columns>
                                                                                            </dx:ASPxGridView>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>&nbsp;</td>
                                                                                    </tr>
                                                                                </table>
                                                                            </dx:ContentControl>
                                                                        </ContentCollection>
                                                                    </dx:TabPage>
                                                                    <dx:TabPage Text=" User Faculties">
                                                                        <TabImage IconID="people_usergroup_16x16">
                                                                        </TabImage>
                                                                        <ContentCollection>
                                                                            <dx:ContentControl runat="server">
                                                                                <table class="style1">
                                                                                    <tr>
                                                                                        <td>
                                                                                            <table class="style1">
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <dx:ASPxButton ID="cmdNewUserFaculty" runat="server" Height="35px" OnClick="cmdNewUserFaculty_Click" Text="Add Faculty" Width="150px">
                                                                                                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                                                                            </Image>
                                                                                                        </dx:ASPxButton>
                                                                                                    </td>
                                                                                                    <td align="right">&nbsp;</td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                            <dx:ASPxGridView ID="gvUserFaculties" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvUserFaculties" DataSourceID="dsUserFaculties" KeyFieldName="ID" OnBeforePerformDataSelect="gvUserFaculties_BeforePerformDataSelect" OnHtmlDataCellPrepared="gvUserPhones_HtmlDataCellPrepared" OnRowInserting="gvUserFaculties_RowInserting" Width="100%">
                                                                                                <SettingsEditing Mode="EditForm">
                                                                                                </SettingsEditing>
                                                                                                <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                                                                <Columns>
                                                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewDataTextColumn FieldName="user_name" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                        <EditFormSettings Visible="False" />
                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                    <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="4" Width="40px">
                                                                                                    </dx:GridViewCommandColumn>
                                                                                                    <dx:GridViewDataComboBoxColumn Caption="Faculty" FieldName="fax_code" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                        <PropertiesComboBox DataSourceID="dsFaculties" TextField="faculty_name" TextFormatString="{0} :: {1}" ValueField="faculty_code">
                                                                                                            <Columns>
                                                                                                                <dx:ListBoxColumn Caption="Code" FieldName="faculty_code" Width="60px" />
                                                                                                                <dx:ListBoxColumn Caption="Faculty Name" FieldName="faculty_name" Width="250px" />
                                                                                                            </Columns>
                                                                                                        </PropertiesComboBox>
                                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                                    <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="2" Width="25px">
                                                                                                    </dx:GridViewCommandColumn>
                                                                                                </Columns>
                                                                                            </dx:ASPxGridView>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>&nbsp;</td>
                                                                                    </tr>
                                                                                </table>
                                                                            </dx:ContentControl>
                                                                        </ContentCollection>
                                                                    </dx:TabPage>
                                                                </TabPages>
                                                                <TabStyle>
                                                                    <Paddings Padding="10px" />
                                                                </TabStyle>
                                                            </dx:ASPxPageControl>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="width: 602px">
                                                            <asp:ObjectDataSource ID="ods_usersList" runat="server" DeleteMethod="RemoveUser" OldValuesParameterFormatString="original_{0}" SelectMethod="GetUsersList" TypeName="SecurityTableAdapters.my_aspnet_usersTableAdapter" UpdateMethod="UpdateLockStatus">
                                                                <DeleteParameters>
                                                                    <asp:Parameter Name="Original_id" Type="Int32" />
                                                                </DeleteParameters>
                                                                <UpdateParameters>
                                                                    <asp:Parameter Name="IsLockedOut" Type="Object" />
                                                                    <asp:Parameter Name="original_id" Type="Int32" />
                                                                </UpdateParameters>
                                                            </asp:ObjectDataSource>
                                                        </td>
                                                        <td style="width: 11px">&nbsp;</td>
                                                        <td>
                                                            <asp:ObjectDataSource ID="ods_UserRoles" runat="server" DeleteMethod="DeleteUserRole" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetMyRoles" TypeName="SecurityTableAdapters.my_aspnet_usersinrolesTableAdapter">
                                                                <DeleteParameters>
                                                                    <asp:Parameter Name="Original_idrole" Type="Int32" />
                                                                </DeleteParameters>
                                                                <InsertParameters>
                                                                    <asp:Parameter Name="userId" Type="Int32" />
                                                                    <asp:Parameter Name="roleId" Type="Int32" />
                                                                </InsertParameters>
                                                                <SelectParameters>
                                                                    <asp:SessionParameter DefaultValue="0" Name="uid" SessionField="uid" Type="Int32" />
                                                                </SelectParameters>
                                                            </asp:ObjectDataSource>
                                                            <asp:ObjectDataSource ID="dsCurrRoles" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.my_aspnet_rolesTableAdapter"></asp:ObjectDataSource>
                                                            <asp:ObjectDataSource ID="dsFaculties" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_facultyTableAdapter"></asp:ObjectDataSource>
                                                            <asp:ObjectDataSource ID="dsUserFaculties" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetUserFaculties" TypeName="SecurityTableAdapters.my_aspnet_user_facultiesTableAdapter" UpdateMethod="Update">
                                                                <DeleteParameters>
                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                </DeleteParameters>
                                                                <InsertParameters>
                                                                    <asp:Parameter Name="user_name" Type="String" />
                                                                    <asp:Parameter Name="fax_code" Type="String" />
                                                                </InsertParameters>
                                                                <SelectParameters>
                                                                    <asp:SessionParameter DefaultValue="-" Name="unm" SessionField="curUserName" Type="String" />
                                                                </SelectParameters>
                                                                <UpdateParameters>
                                                                    <asp:Parameter Name="user_name" Type="String" />
                                                                    <asp:Parameter Name="fax_code" Type="String" />
                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                </UpdateParameters>
                                                            </asp:ObjectDataSource>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="width: 602px">
                                                            <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ContentCollection>
                                                                    <dx:PopupControlContentControl runat="server">
                                                                        <table align="center" class="style1">
                                                                            <tr>
                                                                                <td align="center">
                                                                                    <br />
                                                                                    <br />
                                                                                    <dx:ASPxLabel ID="lbl_msg" runat="server" ForeColor="Red" style="font-weight: 700">
                                                                                    </dx:ASPxLabel>
                                                                                    <br />
                                                                                    <br />
                                                                                    <br />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </dx:PopupControlContentControl>
                                                                </ContentCollection>
                                                            </dx:ASPxPopupControl>
                                                        </td>
                                                        <td style="width: 11px">&nbsp;</td>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                </table>
                                            </dx:PanelContent>
                                        </PanelCollection>
                                    </dx:ASPxCallbackPanel>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Text=" Password Reset">
                            <TabImage IconID="actions_reset_16x16">
                            </TabImage>
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td style="width: 80px">User Name:</td>
                                            <td style="width: 178px">
                                                <dx:ASPxComboBox ID="txtUserName" runat="server" DataSourceID="dsResetUsers" TextField="name" TextFormatString="{1}" ValueField="id" ValueType="System.Int32">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="ID" FieldName="id" />
                                                        <dx:ListBoxColumn Caption="User Name" FieldName="name" />
                                                        <dx:ListBoxColumn Caption="Last Active" FieldName="lastActivityDate" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td>
                                                <dx:ASPxLabel ID="lbl_resetComment" runat="server" ForeColor="Red">
                                                </dx:ASPxLabel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="width: 80px">&nbsp;</td>
                                            <td style="width: 178px">
                                                <dx:ASPxButton ID="cmdReset" runat="server" OnClick="cmdReset_Click" Text="Reset Password" Width="170px">
                                                    <Image Url="~/COOPERP/images/eraser--pencil.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td style="width: 80px">&nbsp;</td>
                                            <td style="width: 178px">
                                                <asp:ObjectDataSource ID="dsResetUsers" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.my_aspnet_usersTableAdapter"></asp:ObjectDataSource>
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Text="User Contact Info">
                            <TabImage IconID="miscellaneous_content_16x16">
                            </TabImage>
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" Text="Add User Phone" Width="170px">
                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxGridView ID="gvUserPhones" runat="server" AutoGenerateColumns="False" DataSourceID="dsUserPhones" KeyFieldName="username" Width="100%" OnHtmlDataCellPrepared="gvUserPhones_HtmlDataCellPrepared">
                                                    <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                                                    </SettingsEditing>
                                                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                    <SettingsPopup>
                                                        <EditForm HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter" />
                                                    </SettingsPopup>
                                                    <SettingsSearchPanel Visible="True" />
                                                    <SettingsText CommandCancel="Cancel Changes" CommandUpdate="Save Changes" />
                                                    <EditFormLayoutProperties>
                                                        <Items>
                                                            <dx:GridViewLayoutGroup Caption="User Contact Info">
                                                                <Items>
                                                                    <dx:GridViewColumnLayoutItem ColumnName="username">
                                                                    </dx:GridViewColumnLayoutItem>
                                                                    <dx:GridViewColumnLayoutItem ColumnName="phone_no">
                                                                    </dx:GridViewColumnLayoutItem>
                                                                    <dx:GridViewColumnLayoutItem ColumnName="emails">
                                                                    </dx:GridViewColumnLayoutItem>
                                                                    <dx:EditModeCommandLayoutItem Height="35px" HorizontalAlign="Right">
                                                                    </dx:EditModeCommandLayoutItem>
                                                                </Items>
                                                                <Paddings Padding="15px" />
                                                            </dx:GridViewLayoutGroup>
                                                        </Items>
                                                    </EditFormLayoutProperties>
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="User Name" FieldName="username" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesTextEdit Height="35px">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Phone Contact" FieldName="phone_no" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            <PropertiesTextEdit Height="35px">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="4" Width="40px" ButtonRenderMode="Button" ButtonType="Button">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn Caption="Email Address" FieldName="emails" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            <PropertiesTextEdit Height="35px">
                                                            </PropertiesTextEdit>
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="dsUserPhones" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.my_aspnet_userphoneTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_username" Type="String" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="username" Type="String" />
                                                        <asp:Parameter Name="phone_no" Type="String" />
                                                        <asp:Parameter Name="emails" Type="String" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="phone_no" Type="String" />
                                                        <asp:Parameter Name="emails" Type="String" />
                                                        <asp:Parameter Name="Original_username" Type="String" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Text=" Role Management">
                            <TabImage IconID="toolboxitems_shape_16x16">
                            </TabImage>
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="cmdNewRole" runat="server" OnClick="cmdNewRole_Click" Text="Add New Role" Width="150px">
                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxGridView ID="gvRoles" runat="server" AutoGenerateColumns="False" DataSourceID="ods_roles" KeyFieldName="id" OnInitNewRow="gvRoles_InitNewRow" Width="100%" OnHtmlDataCellPrepared="gvUserPhones_HtmlDataCellPrepared">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="Code" FieldName="id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Width="30px">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Application Code" FieldName="applicationId" ShowInCustomizationForm="True" VisibleIndex="1" Width="100px">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Role Name" FieldName="name" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        
                                                    </Columns>
                                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="ods_roles" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.my_aspnet_rolesTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_id" Type="Int32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="applicationId" Type="Int32" />
                                                        <asp:Parameter Name="name" Type="String" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="applicationId" Type="Int32" />
                                                        <asp:Parameter Name="name" Type="String" />
                                                        <asp:Parameter Name="Original_id" Type="Int32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Name="sysapps" Text=" System Applications">
                            <TabImage IconID="chart_chartsshowlegend_16x16">
                            </TabImage>
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="cmdNew" runat="server" OnClick="cmdNew_Click" Text="Create New" Width="170px">
                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxGridView ID="gvApps" runat="server" AutoGenerateColumns="False" DataSourceID="dsApps" KeyFieldName="app_ID" Width="100%">
                                                    <SettingsDataSecurity AllowDelete="False" />
                                                    <SettingsSearchPanel Visible="True" />
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn Caption="App ID" FieldName="app_ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Width="40px">
                                                            <EditFormSettings Visible="False" />
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Application Name" FieldName="app_name" ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Description" FieldName="app_description" ShowInCustomizationForm="True" VisibleIndex="3">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Icon" FieldName="app_icon" ShowInCustomizationForm="True" VisibleIndex="4" Visible="False">
                                                            <EditFormSettings Visible="True" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Home Page" FieldName="app_home" ShowInCustomizationForm="True" VisibleIndex="5">
                                                        </dx:GridViewDataTextColumn>
                                                       
                                                        
                                                        <dx:GridViewDataImageColumn Caption="#" FieldName="app_icon" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            <PropertiesImage ImageUrlFormatString="~/COOPERP/images/{0}">
                                                            </PropertiesImage>
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataImageColumn>
                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="6" Width="40px">
                                                        </dx:GridViewCommandColumn>
                                                    </Columns>
                                                    <SettingsBehavior AllowFocusedRow="True" />
                                                    <Settings ShowFilterRowMenu="True" />
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="dsApps" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.my_aspnet_appsTableAdapter" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_app_ID" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="app_name" Type="String" />
                                                        <asp:Parameter Name="app_description" Type="String" />
                                                        <asp:Parameter Name="app_icon" Type="String" />
                                                        <asp:Parameter Name="app_home" Type="String" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="app_name" Type="String" />
                                                        <asp:Parameter Name="app_description" Type="String" />
                                                        <asp:Parameter Name="app_icon" Type="String" />
                                                        <asp:Parameter Name="app_home" Type="String" />
                                                        <asp:Parameter Name="Original_app_ID" Type="UInt32" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                            </td>
                                        </tr>
                                    </table>
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                        <dx:TabPage Name="appsettings" Text=" Application Access Settings">
                            <TabImage IconID="dashboards_locknavigation_16x16">
                            </TabImage>
                            <ContentCollection>
                                <dx:ContentControl runat="server">
                                    <uc1:RolesInApps ID="RolesInApps1" runat="server" />
                                </dx:ContentControl>
                            </ContentCollection>
                        </dx:TabPage>
                    </TabPages>
                    <TabStyle>
                        <Paddings Padding="10px" />
                    </TabStyle>
                </dx:ASPxPageControl>
            </dx:PanelContent>
        
</PanelCollection>
    </dx:ASPxRoundPanel>

