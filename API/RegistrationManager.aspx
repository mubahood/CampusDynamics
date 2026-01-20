<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RegistrationManager.aspx.cs" Inherits="API_RegistrationManager" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .auto-style1 {
            height: 18px;
        }
        .auto-style2 {
            width: 142px;
        }
        .auto-style3 {
            height: 18px;
            width: 142px;
        }
        .auto-style4 {
            height: 18px;
            width: 177px;
        }
        .auto-style5 {
            width: 177px;
        }
        .auto-style6 {
            width: 100%;
        }
        .auto-style7 {
            width: 169px;
            height: 42px;
        }
        .auto-style8 {
            width: 170px;
            height: 42px;
        }
        .auto-style9 {
            height: 42px;
        }
        


    *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
        
    }


    .style1
{
    width:100%;
}
    


        .auto-style10 {
            width: 142px;
            height: 43px;
        }
        .auto-style11 {
            height: 43px;
        }
        .auto-style12 {
            width: 177px;
            height: 43px;
        }
    


        </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="Registration Centre" Width="100%">
            <HeaderImage IconID="edit_edit_16x16">
            </HeaderImage>
            <HeaderStyle>
            <Paddings Padding="15px" />
            </HeaderStyle>
            <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <table class="dx-justification">
                    <tr>
                        <td class="auto-style3">Study Details:</td>
                        <td class="auto-style1">
                            <dx:ASPxLabel ID="lbl_study_details" runat="server" style="font-weight: 700; color: #0000FF" Text="YEAR 1, SEMESTER 1, 2019/2020">
                            </dx:ASPxLabel>
                        </td>
                        <td class="auto-style4">Fees Balance:</td>
                        <td class="auto-style1">
                            <dx:ASPxLabel ID="lbl_bal_comment" runat="server" style="font-weight: 700; color: #0000FF" Text="30,000 CREDIT">
                            </dx:ASPxLabel>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style3">Retistration Status</td>
                        <td class="auto-style1">
                            <dx:ASPxLabel ID="lbl_regStat" runat="server" style="font-weight: 700; color: #0000FF" Text="UNREGISTERED">
                            </dx:ASPxLabel>
                        </td>
                        <td class="auto-style4">Registration Comment:</td>
                        <td class="auto-style1">
                            <dx:ASPxLabel ID="lbl_reg_comment" runat="server" style="font-weight: 700; color: #FF0000" Text="INSUFFICIENT BALANCE">
                            </dx:ASPxLabel>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style10"></td>
                        <td class="auto-style11">
                            </td>
                        <td class="auto-style12">
                            <dx:ASPxButton ID="cmdPrintExamPermit" runat="server" Height="35px" OnClick="cmdPrintExamPermit_Click" Text="Print Exam Permit" Width="170px">
                                <Image IconID="print_print_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style11">
                            <dx:ASPxButton ID="cmdRegister" runat="server" Height="35px" Text="Register Now" Width="170px" OnClick="cmdRegister_Click">
                                <Image IconID="tasks_edittask_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style2">&nbsp;</td>
                        <td>&nbsp;</td>
                        <td class="auto-style5">&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <hr style="background-color:blue" />
            </td>
        </tr>
        <tr>
            <td style="text-align: center">
                <dx:ASPxLabel ID="lbl_study_details0" runat="server" style="font-weight: 700; color: #0000FF" Text="COURSE REGISTRATION">
                </dx:ASPxLabel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxButton ID="cmdCourseUnits" runat="server" Height="35px" Text="Select Course Units" Width="170px" HorizontalAlign="Center" OnClick="cmdCourseUnits_Click">
                    <Image IconID="chart_chartsshowlegend_16x16">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvCourseRegistration" runat="server" AutoGenerateColumns="False" DataSourceID="dsCourseRegistration" KeyFieldName="ID" OnHtmlDataCellPrepared="gvCourseRegistration_HtmlDataCellPrepared" Width="100%" OnRowDeleting="gvCourseRegistration_RowDeleting" OnCustomErrorText="gvCourseRegistration_CustomErrorText">
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
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
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="9" Width="25px">
                        </dx:GridViewCommandColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
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
                        <asp:QueryStringParameter DefaultValue="-" Name="reg" QueryStringField="reg" Type="String" />
                        <asp:QueryStringParameter DefaultValue="-" Name="acad" QueryStringField="acadyear" Type="String" />
                        <asp:QueryStringParameter DefaultValue="0" Name="sem" QueryStringField="sem" Type="Int32" />
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
                <dx:ASPxPopupControl ID="pop_msgbox" runat="server" HeaderText="Campus Dynamics ERP" Height="150px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td>
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="style3"></td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_pending" runat="server" CloseAction="CloseButton" HeaderText="Pending Course Units" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="700px">
                    <HeaderImage IconID="chart_chartsshowlegend_16x16">
                    </HeaderImage>
                    <HeaderStyle>
                    <Paddings Padding="15px" />
                    </HeaderStyle>
                    <ModalBackgroundStyle BackColor="#0099FF">
                    </ModalBackgroundStyle>
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="auto-style6">
                                <tr>
                                    <td class="auto-style1">
                                        <table cellspacing="1" class="auto-style6">
                                            <tr>
                                                <td class="auto-style7">
                                                    <dx:ASPxComboBox ID="txtCategory" runat="server" Height="35px" SelectedIndex="0" Width="170px" AutoPostBack="True">
                                                        <Items>
                                                            <dx:ListEditItem Selected="True" Text="Normal Papers" Value="Normal" />
                                                            <dx:ListEditItem Text="Retake Papers" Value="Retake" />
                                                        </Items>
                                                        <Paddings PaddingLeft="5px" />
                                                    </dx:ASPxComboBox>
                                                </td>
                                                <td class="auto-style8">
                                                    <dx:ASPxButton ID="cmdRegisterCourse" runat="server" Height="35px" HorizontalAlign="Center" OnClick="cmdRegisterCourse_Click" Text="Register Selected" Width="170px">
                                                        <Image IconID="content_checkbox_16x16">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td class="auto-style9">
                                                    <dx:ASPxLabel ID="lbl_cs_reg_comment" runat="server" Font-Bold="True" ForeColor="Red">
                                                    </dx:ASPxLabel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="gvPendingCourses" runat="server" AutoGenerateColumns="False" DataSourceID="dsPending" KeyFieldName="ID" OnHtmlDataCellPrepared="gvCourseRegistration_HtmlDataCellPrepared" Width="100%">
                                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                            <SettingsSearchPanel Visible="True" />
                                            <SettingsText CommandDelete="Remove" ConfirmDelete="Delete Course Unit?" />
                                            <Columns>
                                                <dx:GridViewDataTextColumn Caption="Course Name" FieldName="courseName" ShowInCustomizationForm="True" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="staffCode" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Code" FieldName="courseID" ShowInCustomizationForm="True" VisibleIndex="1" Width="100px">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="acad_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="semester" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="progcode" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="cyear" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="stud_session" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="intake" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Stream" FieldName="stream" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="campusId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="StartTime" ShowInCustomizationForm="True" VisibleIndex="14">
                                                    <PropertiesComboBox DisplayFormatInEditMode="True">
                                <Items>
                                                         <dx:ListEditItem Text="07:00 AM" Value="07:00:00" />
                                                                                <dx:ListEditItem Text="07:30 AM" Value="07:30:00" />
                                                                                <dx:ListEditItem Text="8:00 AM" Value="08:00:00" />
                                                                                <dx:ListEditItem Text="8:30 AM" Value="08:30:00" />
                                                                                <dx:ListEditItem Text="9:00 AM" Value="09:00:00" />
                                                                                <dx:ListEditItem Text="9:30 AM" Value="09:30:00" />
                                                                                <dx:ListEditItem Text="10:00 AM" Value="10:00:00" />
                                                                                <dx:ListEditItem Text="10:30 AM" Value="10:30:00" />
                                                                                <dx:ListEditItem Text="11:00 AM" Value="11:00:00" />
                                                                                <dx:ListEditItem Text="11:30 AM" Value="11:30:00" />
                                                                                <dx:ListEditItem Text="12:00 PM" Value="12:00:00" />
                                                                                <dx:ListEditItem Text="12:30 PM" Value="12:30:00" />
                                                                                <dx:ListEditItem Text="1:00 PM" Value="13:00:00" />
                                                                                <dx:ListEditItem Text="2:00 PM" Value="14:00:00" />
                                                                                <dx:ListEditItem Text="2:30 PM" Value="14:30:00" />
                                                                                <dx:ListEditItem Text="3:00 PM" Value="15:00:00" />
                                                                                <dx:ListEditItem Text="3:30 PM" Value="15:30:00" />
                                                                                <dx:ListEditItem Text="4:00 PM" Value="16:00:00" />
                                                                                <dx:ListEditItem Text="4:30 PM" Value="16:30:00" />
                                                                                <dx:ListEditItem Text="5:00 PM" Value="17:00:00" />
                                                                                <dx:ListEditItem Text="5:30 PM" Value="17:30:00" />
                                                                                <dx:ListEditItem Text="6:00 PM" Value="18:00:00" />
                                                                                <dx:ListEditItem Text="6:30 PM" Value="18:30:00" />
                                                                                <dx:ListEditItem Text="7:00 PM" Value="19:00:00" />
                                                                                <dx:ListEditItem Text="7:30 PM" Value="19:30:00" />
                                                                                <dx:ListEditItem Text="8:00 PM" Value="20:00:00" />
                                                                                <dx:ListEditItem Text="8:30 PM" Value="20:30:00" />
                                                                                <dx:ListEditItem Text="9:00 PM" Value="21:00:00" />
                                                                                <dx:ListEditItem Text="9:30 PM" Value="21:30:00" />
                                                                                <dx:ListEditItem Text="10:00 PM" Value="22:00:00" />
                                                         <dx:ListEditItem Text="10:30 PM" Value="22:30:00" />
                                                         <dx:ListEditItem Text="11:00 PM" Value="23:00:00" />
                                                    </Items>
                            </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="EndTime" ShowInCustomizationForm="True" VisibleIndex="15">
                                                    <PropertiesComboBox DisplayFormatInEditMode="True">
                                <Items>
                                                         <dx:ListEditItem Text="07:00 AM" Value="07:00:00" />
                                                                                <dx:ListEditItem Text="07:30 AM" Value="07:30:00" />
                                                                                <dx:ListEditItem Text="8:00 AM" Value="08:00:00" />
                                                                                <dx:ListEditItem Text="8:30 AM" Value="08:30:00" />
                                                                                <dx:ListEditItem Text="9:00 AM" Value="09:00:00" />
                                                                                <dx:ListEditItem Text="9:30 AM" Value="09:30:00" />
                                                                                <dx:ListEditItem Text="10:00 AM" Value="10:00:00" />
                                                                                <dx:ListEditItem Text="10:30 AM" Value="10:30:00" />
                                                                                <dx:ListEditItem Text="11:00 AM" Value="11:00:00" />
                                                                                <dx:ListEditItem Text="11:30 AM" Value="11:30:00" />
                                                                                <dx:ListEditItem Text="12:00 PM" Value="12:00:00" />
                                                                                <dx:ListEditItem Text="12:30 PM" Value="12:30:00" />
                                                                                <dx:ListEditItem Text="1:00 PM" Value="13:00:00" />
                                                                                <dx:ListEditItem Text="2:00 PM" Value="14:00:00" />
                                                                                <dx:ListEditItem Text="2:30 PM" Value="14:30:00" />
                                                                                <dx:ListEditItem Text="3:00 PM" Value="15:00:00" />
                                                                                <dx:ListEditItem Text="3:30 PM" Value="15:30:00" />
                                                                                <dx:ListEditItem Text="4:00 PM" Value="16:00:00" />
                                                                                <dx:ListEditItem Text="4:30 PM" Value="16:30:00" />
                                                                                <dx:ListEditItem Text="5:00 PM" Value="17:00:00" />
                                                                                <dx:ListEditItem Text="5:30 PM" Value="17:30:00" />
                                                                                <dx:ListEditItem Text="6:00 PM" Value="18:00:00" />
                                                                                <dx:ListEditItem Text="6:30 PM" Value="18:30:00" />
                                                                                <dx:ListEditItem Text="7:00 PM" Value="19:00:00" />
                                                                                <dx:ListEditItem Text="7:30 PM" Value="19:30:00" />
                                                                                <dx:ListEditItem Text="8:00 PM" Value="20:00:00" />
                                                                                <dx:ListEditItem Text="8:30 PM" Value="20:30:00" />
                                                                                <dx:ListEditItem Text="9:00 PM" Value="21:00:00" />
                                                                                <dx:ListEditItem Text="9:30 PM" Value="21:30:00" />
                                                                                <dx:ListEditItem Text="10:00 PM" Value="22:00:00" />
                                                         <dx:ListEditItem Text="10:30 PM" Value="22:30:00" />
                                                         <dx:ListEditItem Text="11:00 PM" Value="23:00:00" />
                                                    </Items>
                            </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                 <dx:GridViewDataComboBoxColumn Caption="Room" FieldName="roomNo" ShowInCustomizationForm="True" VisibleIndex="16">
                            <PropertiesComboBox DataSourceID="dsRooms" TextField="RoomName" TextFormatString="{1}" ValueField="RoomID" ValueType="System.Int32">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="RoomID" />
                                    <dx:ListBoxColumn FieldName="RoomName" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataTextColumn Caption="Lecture Day" FieldName="lectureday" ShowInCustomizationForm="True" VisibleIndex="13">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                </dx:GridViewCommandColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:ObjectDataSource ID="dsPending" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="PortalContentTableAdapters.acad_GetPendingCoursesTableAdapter" OnSelecting="dsPending_Selecting">
                                            <SelectParameters>
                                                <asp:QueryStringParameter DefaultValue="-" Name="reg" QueryStringField="reg" Type="String" />
                                                <asp:QueryStringParameter DefaultValue="-" Name="acad" QueryStringField="acadyear" Type="String" />
                                                <asp:QueryStringParameter DefaultValue="0" Name="sems" QueryStringField="sem" Type="Int32" />
                                                <asp:ControlParameter ControlID="txtCategory" Name="stat" PropertyName="Value" Type="String" />
                                            </SelectParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="dsRooms" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_CampusLectureRooms" TypeName="TimetableDataTableAdapters.acad_lectureroomsTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_RoomID" Type="Int32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="RoomID" Type="Int32" />
                                                <asp:Parameter Name="RoomName" Type="String" />
                                                <asp:Parameter Name="Capacity" Type="Int32" />
                                                <asp:Parameter Name="campusId" Type="Int32" />
                                            </InsertParameters>
                                            <SelectParameters>
                                                <asp:Parameter DefaultValue="3" Name="campusno" Type="Int32" />
                                            </SelectParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="RoomName" Type="String" />
                                                <asp:Parameter Name="Capacity" Type="Int32" />
                                                <asp:Parameter Name="campusId" Type="Int32" />
                                                <asp:Parameter Name="Original_RoomID" Type="Int32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                    </td>
                                </tr>
                            </table>
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_messagebox" runat="server" HeaderText="Campus Dynamics ERP Version 1.0" Height="150px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td height="30"></td>
                                </tr>
                                <tr>
                                    <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
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
    
    </div>
    </form>
</body>
</html>
