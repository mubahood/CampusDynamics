<%@ Control Language="C#" AutoEventWireup="true" CodeFile="FacultyInfo.ascx.cs" Inherits="UserControls_Faculty_Faculty_Info" %>
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


    .style2_apps
    {
        width: 80px;
    }
    .style3
    {
        width: 218px;
    }
    .style4
    {
        width:40px;
    }
    .style5
    {
        width: 1052px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_faculty_info.png">
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
        <tr>
            <td>
                <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" Text="Add New" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvFacultyInfo" runat="server" AutoGenerateColumns="False" DataSourceID="dsFacultyInfo" KeyFieldName="faculty_code" Width="100%">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="faculty_name" ShowInCustomizationForm="True" VisibleIndex="2" Caption="Faculty Name">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Faculty Code" FieldName="faculty_code" ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Dean Name" FieldName="faculty_dean" ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Faculty Contacts" FieldName="faculty_contacts" ShowInCustomizationForm="True" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewCommandColumn ButtonType="Image" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="6" Width="40px"/>
                        <dx:GridViewDataTextColumn Caption="Abbreviation" FieldName="abbrev" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                   <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
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
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsFacultyInfo" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="FacultyDataTableAdapters.acad_facultyTableAdapter" 
                    DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_faculty_code" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="faculty_name" Type="String" />
                        <asp:Parameter Name="faculty_code" Type="String" />
                        <asp:Parameter Name="faculty_dean" Type="String" />
                        <asp:Parameter Name="faculty_contacts" Type="String" />
                        <asp:Parameter Name="abbrev" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="faculty_name" Type="String" />
                        <asp:Parameter Name="faculty_code" Type="String" />
                        <asp:Parameter Name="faculty_dean" Type="String" />
                        <asp:Parameter Name="faculty_contacts" Type="String" />
                        <asp:Parameter Name="abbrev" Type="String" />
                        <asp:Parameter Name="Original_faculty_code" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
