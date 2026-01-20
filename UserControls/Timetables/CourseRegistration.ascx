<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CourseRegistration.ascx.cs" Inherits="UserControls_Timetables_CourseRegistration" %>
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


    .auto-style1 {
        width: 97px;
    }
    .auto-style3 {
        width: 325px;
    }
    .auto-style5 {
        width: 118px;
    }


    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_course_reg.png" >
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>
                <table class="style1">
                    <tr>
                        <td class="auto-style1">Programme:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtProgramme" runat="server" Width="300px" DataSourceID="dsProgrammes" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" AutoPostBack="True" OnSelectedIndexChanged="txtProgramme_SelectedIndexChanged" Height="35px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="80px" />
                                    <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style5">Study Year:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtStudyYear" runat="server" SelectedIndex="0" Width="200px" AutoPostBack="True" Height="35px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                    <dx:ListEditItem Text="4" Value="4" />
                                    <dx:ListEditItem Text="5" Value="5" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">Academic Year:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtAcad" runat="server" Width="300px" AutoPostBack="True" Height="35px">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style5">Semester:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtSemester" runat="server" SelectedIndex="0" Width="200px" AutoPostBack="True" Height="35px">
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                    <dx:ListEditItem Text="2" Value="2" />
                                    <dx:ListEditItem Text="3" Value="3" />
                                    <dx:ListEditItem Text="4" Value="4" />
                                    <dx:ListEditItem Text="5" Value="5" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">Entry Year:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txt_entry_year" runat="server" AutoPostBack="True" Height="35px" Width="300px">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style5">Retake RegNo:</td>
                        <td>
                            <dx:ASPxTextBox ID="txtRegNo" runat="server" Width="200px" Height="35px">
                            </dx:ASPxTextBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">In-take</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtintake" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="300px">
                               
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="-" Value="-" />
                                    <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                    <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                    <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                    <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                    <dx:ListEditItem Text="MAY" Value="MAY" />
                                    <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                    <dx:ListEditItem Text="JULY" Value="JULY" />
                                    <dx:ListEditItem Text="AUGUST" Value="AUGUST" />
                                    <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                    <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                    <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                    <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style5">&nbsp;</td>
                        <td>
                            <dx:ASPxButton ID="cmdAddNew" runat="server" Height="35px" OnClick="cmdAddNew_Click" Text="Add Retake Case" Width="200px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">Course Name:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtCourse" runat="server" AutoPostBack="True" DataSourceID="dsCourses" Height="35px" SelectedIndex="1" TextField="course_name" TextFormatString="{0} :: {1}" ValueField="course_code" Width="300px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="course_code" Width="50px" />
                                    <dx:ListBoxColumn Caption="Course Name" FieldName="course_name" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style5">&nbsp;</td>
                        <td>
                            <dx:ASPxButton ID="cmdRegister" runat="server" OnClick="cmdRegister_Click" Text="Register Selected" Width="200px" Height="35px">
                                <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Do you want to continue?');
               if(e.processOnServer ==true)
{
lp_processing.Show();
}
}" />
                                <Image Url="~/COOPERP/images/tick-button.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">Status:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtRegStatus" runat="server" AutoPostBack="True" Height="35px" OnSelectedIndexChanged="txtRegStatus_SelectedIndexChanged" SelectedIndex="1" Width="300px">
                                <Items>
                                    <dx:ListEditItem Text="Registered" Value="Registered" />
                                    <dx:ListEditItem Selected="True" Text="Pending" Value="Pending" />
                                </Items>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style5">&nbsp;</td>
                        <td>
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvAllocations" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="dsAllocations" KeyFieldName="regno">
                    <SettingsPager PageSize="50" AlwaysShowPager="True" Position="TopAndBottom">
                    </SettingsPager>
                    <SettingsEditing Mode="Batch">
                    </SettingsEditing>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="Reg No" FieldName="regno" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Student Name" FieldName="stud_name" ShowInCustomizationForm="True" VisibleIndex="2" ReadOnly="True">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Specialisation | Combination" FieldName="spec" ShowInCustomizationForm="False" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Course Status" FieldName="course_status" ShowInCustomizationForm="True" VisibleIndex="4">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Selected="True" Text="REGULAR" Value="REGULAR" />
                                    <dx:ListEditItem Text="RETAKE" Value="RETAKE" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsAllocations" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="TimetableDataTableAdapters.acad_GetCourseRegistrationListsTableAdapter">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtProgramme" Name="prog" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtAcad" Name="acad" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtStudyYear" Name="yr" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtRegStatus" Name="stat" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtCourse" Name="csid" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txt_entry_year" Name="entyear" PropertyName="Value" Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.myaspnet_GetMyProgrammesTableAdapter">
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="-" Name="usr" SessionField="username" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsCourses" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="Get_CoursesByProgramAndPeriod" TypeName="TimetableDataTableAdapters.acad_programmecoursesTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="progcode" Type="String" />
                        <asp:Parameter Name="course_code" Type="String" />
                        <asp:Parameter Name="study_year" Type="UInt32" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtProgramme" DefaultValue="" Name="prog" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtStudyYear" Name="yr" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txt_entry_year" Name="entyr" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtintake" Name="intak" PropertyName="Value" Type="String" />
                        <asp:SessionParameter Name="usernm" SessionField="username" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="progcode" Type="String" />
                        <asp:Parameter Name="course_code" Type="String" />
                        <asp:Parameter Name="study_year" Type="UInt32" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <dx:ASPxLoadingPanel ID="lp_processing" runat="server" ClientInstanceName="lp_processing" Modal="True" Text="Processing...Please wait...">
                    <LoadingDivStyle BackColor="#99CCFF">
                    </LoadingDivStyle>
                </dx:ASPxLoadingPanel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
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
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
