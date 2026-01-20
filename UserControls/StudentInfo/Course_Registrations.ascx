<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Course_Registrations.ascx.cs" Inherits="UserControls_StudentInfo_Course_Registrations" %>
<style type="text/css">

        


    *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
        
    }


    .auto-style4 {
        width: 60%;
    }
    .auto-style5 {
        width: 2%;
    }
    .auto-style8 {
        width: 6%;
    }
    .auto-style9 {
        width: 232px;
    }
    .auto-style10 {
        width: 120px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table>
        <tr>
            <td class="auto-style10">Academic Year:</td>
            <td class="auto-style9">
                <dx:ASPxComboBox ID="txtAcad" runat="server" AutoPostBack="True" Height="30px" Width="200px">
                </dx:ASPxComboBox>
            </td>
            <td class="auto-style8">Semester/Quarter:</td>
            <td class="auto-style4">
                <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="200px">
                    <Items>
                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                        <dx:ListEditItem Text="2" Value="2" />
                        <dx:ListEditItem Text="3" Value="3" />
                        <dx:ListEditItem Text="4" Value="4" />
                        <dx:ListEditItem Text="5" Value="5" />
                    </Items>
                </dx:ASPxComboBox>
            </td>
            <td class="auto-style5">&nbsp;</td>
            <td class="auto-style5">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="6">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="6">
                <dx:ASPxGridView ID="gvCourseRegistration" runat="server" AutoGenerateColumns="False" DataSourceID="dsCourseRegistration" KeyFieldName="ID" OnHtmlDataCellPrepared="gvCourseRegistration_HtmlDataCellPrepared" Width="100%">
                    <SettingsPager PageSize="5">
                        <Summary Text="Page {0} of {1} ({2} Course(s))" />
                    </SettingsPager>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsDataSecurity AllowDelete="False" />
                    <SettingsSearchPanel Visible="True" />
                    <SettingsText CommandDelete="Remove" ConfirmDelete="Delete Course Unit?" />
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="regno" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Code" FieldName="courseID" ShowInCustomizationForm="True" VisibleIndex="2" Width="100px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="acad_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="semester" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Course Status" FieldName="course_status" ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="prog_id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="stud_session" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Course Name" FieldName="courseName" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="9" Width="25px" Visible="False">
                        </dx:GridViewCommandColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:ObjectDataSource ID="dsCourseRegistration" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetMyCourseRegistration" TypeName="PortalContentTableAdapters.acad_course_registrationTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="courseID" Type="String" />
                        <asp:Parameter Name="acad_year" Type="String" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                        <asp:Parameter Name="course_status" Type="String" />
                        <asp:Parameter Name="prog_id" Type="String" />
                        <asp:Parameter Name="stud_session" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="-" Name="reg" SessionField="regno" Type="String" />
                        <asp:ControlParameter ControlID="txtAcad" DefaultValue="-" Name="acad" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtSemester" DefaultValue="0" Name="sem" PropertyName="Value" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="courseID" Type="String" />
                        <asp:Parameter Name="acad_year" Type="String" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                        <asp:Parameter Name="course_status" Type="String" />
                        <asp:Parameter Name="prog_id" Type="String" />
                        <asp:Parameter Name="stud_session" Type="String" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

