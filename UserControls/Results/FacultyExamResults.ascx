<%@ Control Language="C#" AutoEventWireup="true" CodeFile="FacultyExamResults.ascx.cs" Inherits="UserControls_Results_FacultyExamResults" %>
<%@ Register src="MarksheetDetails.ascx" tagname="MarksheetDetails" tagprefix="uc1" %>
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
    .auto-style8 {
        width: 110px;
    }
    .auto-style10 {
        width: 317px;
    }
    .auto-style11 {
        width: 84px;
    }
    .auto-style12 {
        width: 110px;
        height: 27px;
    }
    .auto-style13 {
        width: 317px;
        height: 27px;
    }
    .auto-style14 {
        width: 84px;
        height: 27px;
    }
    .auto-style15 {
        height: 27px;
    }
    .auto-style16 {
        height: 70px;
    }
    .auto-style17 {
        width: 110px;
        height: 32px;
    }
    .auto-style18 {
        width: 317px;
        height: 32px;
    }
    .auto-style19 {
        width: 84px;
        height: 32px;
    }
    .auto-style20 {
        height: 32px;
    }
    .auto-style21 {
        height: 24px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
   <%-- <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>--%>
            <table class="style1">
                <tr>
                    <td>
                        <table cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_faculty_exams.png" >
                                    </dx:ASPxImage>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png"  Width="100%">
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
                                <td rowspan="7">
                                    <table class="style1">
                                        <tr>
                                            <td class="auto-style12">Campus:</td>
                                            <td class="auto-style13">
                                                <dx:ASPxComboBox ID="txtCampus" runat="server" AutoPostBack="True" DataSourceID="dsCampus" Height="30px" TextField="campus_name" TextFormatString="{0} :: {1}" ValueField="ID" ValueType="System.Int32" Width="300px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="50px" />
                                                        <dx:ListBoxColumn Caption="Campus Name" FieldName="campus_name" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style14">Entry Year:</td>
                                            <td class="auto-style15">
                                                <dx:ASPxComboBox ID="txt_entry_year" runat="server" AutoPostBack="True" Height="30px" Width="200px">
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style15">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style12">Academic Year:</td>
                                            <td class="auto-style13">
                                                <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Height="30px" Width="300px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style14">In-take</td>
                                            <td class="auto-style15">
                                                <dx:ASPxComboBox ID="txtintake" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="200px">
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
                                            <td class="auto-style15">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style12">Programme:</td>
                                            <td class="auto-style13">
                                                <dx:ASPxComboBox ID="txtProg" runat="server" AutoPostBack="True" DataSourceID="dsProgrammes" Height="30px" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="300px" OnSelectedIndexChanged="txtProg_SelectedIndexChanged1">
                                                   
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
txt_course.SetText(&quot; &quot;);	
}" />
                                                   
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="50px" />
                                                        <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="300px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style14">Session:</td>
                                            <td class="auto-style15" colspan="2">
                                               <dx:ASPxComboBox ID="txtSession" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="200px" DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                                    <Columns>
                                                        <dx:ListBoxColumn FieldName="Session" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style12">Course Unit:</td>
                                            <td class="auto-style13">
                                                <dx:ASPxComboBox ID="txtCourse" runat="server"  DataSourceID="dsCourses" Height="30px" SelectedIndex="1" TextField="courseName" TextFormatString="{0} :: {1}" ValueField="course_code" Width="300px" DropDownWidth="400px" ClientInstanceName="txt_course" AutoPostBack="True">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="course_code" Width="50px" />
                                                        <dx:ListBoxColumn Caption="Course Name" FieldName="courseName" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style14">Study year:</td>
                                            <td class="auto-style15" colspan="2">
                                                <dx:ASPxComboBox ID="txtStudyYear" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="200px" OnSelectedIndexChanged="txtProg_SelectedIndexChanged1">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
txt_course.SetText(&quot; &quot;);	
}" />
                                                     <Items>
                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style12">Exam Status:</td>
                                            <td class="auto-style13">
                                                <dx:ASPxComboBox ID="txtExamStatus" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="300px">
                                                    <Items>
                                                        <dx:ListEditItem Text="SUPPLIMENTARY" Value="SUPPLIMENTARY" Selected="True" />
                                                        <dx:ListEditItem Text="SPECIAL" Value="SPECIAL" />
                                                        <dx:ListEditItem Text="RETAKE" Value="RETAKE" />
                                                        <dx:ListEditItem Text="REGULAR" Value="REGULAR" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style14">Semester:</td>
                                            <td class="auto-style15" colspan="2">
                                                <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="200px" OnSelectedIndexChanged="txtProg_SelectedIndexChanged1">
                                                     <ClientSideEvents SelectedIndexChanged="function(s, e) {
txt_course.SetText(&quot; &quot;);	
}" />
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8">&nbsp;</td>
                                            <td class="auto-style10">
                                                <dx:ASPxButton ID="cmddisplayratios" runat="server" Height="30px" Text="Refresh Marksheet" Width="300px" ClientInstanceName="cmdShowRatios" OnClick="cmddisplayratios_Click">
                                                    <Image IconID="scheduling_recurrence_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td class="auto-style11">&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdApprove" runat="server" Enabled="False" Height="30px" OnClick="cmdApprove_Click" Text="Approve Results" Width="200px">
                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Approve Selected Results?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }

}" />
                                                    <Image IconID="content_checkbox_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style17"></td>
                                            <td class="auto-style18">
                                                <dx:ASPxButton ID="cmdPrintSheet" runat="server" Height="30px" OnClick="cmdPrintSheet_Click" Text="Print Result Sheet" Width="300px">
                                                    <Image IconID="print_printer_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td class="auto-style19"></td>
                                            <td class="auto-style20">
                                                <dx:ASPxButton ID="cmdCancelApprove" runat="server" Enabled="False" Height="30px" OnClick="cmdCancelApprove_Click" Text="Cancel Approval" Width="200px">
                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Cancel Approval of Selected Results?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }

}" />
                                                    <Image IconID="actions_close_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td class="auto-style20">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8">&nbsp;</td>
                                            <td class="auto-style10">
                                                &nbsp;</td>
                                            <td class="auto-style11">&nbsp;</td>
                                            <td>
                                                <%--<dx:ASPxButton ID="cmdAddSingle" runat="server" Height="30px" OnClick="cmdApprove_Click" Text="Add Single Student" Width="200px">
                                                    <Image IconID="actions_add_16x16">
                                                    </Image>
                                                </dx:ASPxButton>--%>
                                            </td>
                                            <td align="right" valign="bottom">
                                                &nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="text-align: right" valign="bottom" width="170px">&nbsp;</td>
                            </tr>
                            <tr>
                                <td style="text-align: right" valign="bottom" width="170px">&nbsp;</td>
                            </tr>
                            <tr>
                                <td style="text-align: right" valign="bottom" width="170px">&nbsp;</td>
                            </tr>
                            <tr>
                                <td style="text-align: right" valign="bottom" width="170px">&nbsp;</td>
                            </tr>
                            <tr>
                                <td style="text-align: right" valign="bottom" width="170px">&nbsp;</td>
                            </tr>
                            <tr>
                                <td style="text-align: right" valign="bottom" width="170px" class="auto-style21"></td>
                            </tr>
                            <tr>
                                <td valign="bottom" align="right">
                                    <dx:ASPxButton ID="cmdPrintBlankExamSheet" runat="server" Height="30px" OnClick="cmdPrintBlankExamSheet_Click" Text="Print Blank Exam Result Sheets" ToolTip="Select a Campus, Study Year, Semester Academic Year, Intake and Entry Year, then Click to Print a Blank Exam Sheet for Only Registered Students" Width="250px" Visible="False">
                                        <Image IconID="print_printer_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                    <dx:ASPxButton ID="cmdPrintInternshipSheet" runat="server" Height="30px" Text="Print Blank Internship Sheets" ToolTip="Select a Campus, Study Year, Semester, Academic Year, Intake and Entry Year,  then Click to Print a Blank Internship Sheet for Only Registered Students" Width="250px" OnClick="cmdPrintInternshipSheet_Click" Visible="False">
                                        <Image IconID="print_printer_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                    <dx:ASPxButton ID="cmdPrintBlankCourseWorkSheet" runat="server" Height="30px" OnClick="cmdPrintBlankCourseWorkSheet_Click" Text="Print Blank CourseWork Sheets" ToolTip="Select a Campus, Study Year, Semester, Academic Year, Intake and Entry Year,  then Click to Print a Blank CourseWork Sheet for Only Registered Students" Width="250px" Visible="False">
                                        <Image IconID="print_printer_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                    <dx:ASPxButton ID="cmdPrintBlankResearchSheet" runat="server" Height="30px" Text="Print Blank Research Sheets" ToolTip="Select a Campus, Study Year, Semester, Academic Year, Intake and Entry Year,  then Click to Print a Blank Research Sheet for Only Registered Students" Width="250px" OnClick="cmdPrintBlankResearchSheet_Click" Visible="False">
                                        <Image IconID="print_printer_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheet" runat="server" AutoGenerateColumns="False" DataSourceID="dsMarksheetInfo" KeyFieldName="ID" OnRowUpdating="gvMarksheet_RowUpdating" Width="100%" OnCustomErrorText="gvMarksheet_CustomErrorText" OnRowDeleting="gvMarksheet_RowDeleting" OnRowUpdated="gvMarksheet_RowUpdated">
                            <SettingsPager PageSize="100" AlwaysShowPager="True" Position="TopAndBottom">
                            </SettingsPager>
                            <SettingsEditing Mode="Batch">
                                <BatchEditSettings StartEditAction="Click" />
                            </SettingsEditing>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsCommandButton>
                                <UpdateButton RenderMode="Button">
                                </UpdateButton>
                                <CancelButton RenderMode="Button">
                                </CancelButton>
                            </SettingsCommandButton>
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" Visible="False" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Student No" FieldName="regno" VisibleIndex="2" Width="200px">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="course_id" Visible="False" VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="acadyear" Visible="False" VisibleIndex="6">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="semester" Visible="False" VisibleIndex="7">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Course Work" FieldName="cw_mark_entered" VisibleIndex="8" Width="60px">
                                    <HeaderStyle HorizontalAlign="Center" />
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Exam Score" FieldName="exam_mark_entered" VisibleIndex="10" Width="60px">
                                    <HeaderStyle HorizontalAlign="Center" />
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Total" FieldName="total_mark" VisibleIndex="11" Width="60px">
                                    <EditFormSettings Visible="False" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="progid" Visible="False" VisibleIndex="12">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="stud_session" Visible="False" VisibleIndex="13">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Grade" FieldName="grade" VisibleIndex="14" Width="25px">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Grade PT" FieldName="gradept" VisibleIndex="15" Width="60px">
                                    <PropertiesTextEdit DisplayFormatString="{0:0.0}">
                                    </PropertiesTextEdit>
                                    <EditFormSettings Visible="False" />
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="exam_status" Visible="False" VisibleIndex="17">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="cyear" Visible="False" VisibleIndex="18">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Student Name" FieldName="stud_name" VisibleIndex="4" Width="400px">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewCommandColumn ButtonRenderMode="Button" ButtonType="Button" ShowDeleteButton="True" VisibleIndex="22" Width="25px" Name="#">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="Approved By" FieldName="approved_by" VisibleIndex="16" Width="80px" Name="approved_by">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Registration No" FieldName="EntryNo" VisibleIndex="3" Width="200px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="cw_mark" Visible="False" VisibleIndex="19">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="ex_mark" Visible="False" VisibleIndex="20">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Practicals Score" FieldName="test_mark_entered" VisibleIndex="9" Width="60px">
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="test_mark" Visible="False" VisibleIndex="21">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridViewExporter ID="GVE_Marksheets" runat="server" ExportedRowType="All" GridViewID="gvMarksheetInfo">
                        </dx:ASPxGridViewExporter>
                                 <asp:ObjectDataSource ID="dsstudysessions" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update">
                            <InsertParameters>
                                <asp:Parameter Name="Session" Type="String" />
                            </InsertParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="Original_Session" Type="String" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Text="Processing. Please wait&amp;hellip;">
                        </dx:ASPxLoadingPanel>
                    </td>
                </tr>
                <tr>
                    <td class="auto-style16">
                        <asp:ObjectDataSource ID="dsMarksheetInfo" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetFacultyMarksheet" TypeName="ResultsDataTableAdapters.acad_examresults_facultyTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="Int32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="course_id" Type="String" />
                                <asp:Parameter Name="acadyear" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="cw_mark_entered" Type="Int32" />
                                <asp:Parameter Name="cw_mark" Type="UInt32" />
                                <asp:Parameter Name="test_mark_entered" Type="Int32" />
                                <asp:Parameter Name="test_mark" Type="Int32" />
                                <asp:Parameter Name="exam_mark_entered" Type="Int32" />
                                <asp:Parameter Name="ex_mark" Type="UInt32" />
                                <asp:Parameter Name="total_mark" Type="UInt32" />
                                <asp:Parameter Name="progid" Type="String" />
                                <asp:Parameter Name="stud_session" Type="String" />
                                <asp:Parameter Name="grade" Type="String" />
                                <asp:Parameter Name="gradept" Type="Double" />
                                <asp:Parameter Name="exam_status" Type="String" />
                                <asp:Parameter Name="cyear" Type="UInt32" />
                                <asp:Parameter Name="approved_by" Type="String" />
                                <asp:Parameter Name="creditUnits" Type="Double" />
                                <asp:Parameter Name="gpa" Type="Double" />
                                <asp:Parameter Name="settingsID" Type="UInt32" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtProg" Name="prog" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtSemester" Name="sems" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtSession" Name="sess" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtStudyYear" Name="yr" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtCourse" Name="csid" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtExamStatus" Name="stat" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtintake" Name="intak" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txt_entry_year" Name="entyr" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtCampus" Name="camp" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="course_id" Type="String" />
                                <asp:Parameter Name="acadyear" Type="String" />
                                <asp:Parameter Name="semester" Type="Int32" />
                                <asp:Parameter Name="cw_mark_entered" Type="Int32" />
                                <asp:Parameter Name="cw_mark" Type="Int32" />
                                <asp:Parameter Name="test_mark_entered" Type="Int32" />
                                <asp:Parameter Name="test_mark" Type="Int32" />
                                <asp:Parameter Name="exam_mark_entered" Type="Int32" />
                                <asp:Parameter Name="ex_mark" Type="Int32" />
                                <asp:Parameter Name="total_mark" Type="Int32" />
                                <asp:Parameter Name="progid" Type="String" />
                                <asp:Parameter Name="stud_session" Type="String" />
                                <asp:Parameter Name="grade" Type="String" />
                                <asp:Parameter Name="gradept" Type="Decimal" />
                                <asp:Parameter Name="exam_status" Type="String" />
                                <asp:Parameter Name="cyear" Type="Int32" />
                                <asp:Parameter Name="approved_by" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="Int32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.myaspnet_GetMyProgrammesTableAdapter">
                            <SelectParameters>
                                <asp:SessionParameter Name="usr" SessionField="username" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsCourses" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetProgrammeCourses_ByStudyPeriod" TypeName="ResultsDataTableAdapters.acad_programmecoursesTableAdapter" UpdateMethod="Update">
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
                                <asp:ControlParameter ControlID="txtProg" Name="progcode" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtStudyYear" Name="study_year" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtSemester" Name="semester" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="progcode" Type="String" />
                                <asp:Parameter Name="course_code" Type="String" />
                                <asp:Parameter Name="study_year" Type="UInt32" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsCampus" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_Campus" TypeName="CampusDataTableAdapters.acad_campusesTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="campus_name" Type="String" />
                                <asp:Parameter Name="campus_phone" Type="String" />
                                <asp:Parameter Name="campus_email" Type="String" />
                                <asp:Parameter Name="campus_short_name" Type="String" />
                                <asp:Parameter Name="campus_head" Type="String" />
                                <asp:Parameter Name="campus_code" Type="String" />
                            </InsertParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="campus_name" Type="String" />
                                <asp:Parameter Name="campus_phone" Type="String" />
                                <asp:Parameter Name="campus_email" Type="String" />
                                <asp:Parameter Name="campus_short_name" Type="String" />
                                <asp:Parameter Name="campus_head" Type="String" />
                                <asp:Parameter Name="campus_code" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" CloseAction="CloseButton" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="350px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px" PopupElementID="cmddisplayratios" ShowPageScrollbarWhenModal="True">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" ShowCollapseButton="True" ShowHeader="False" Width="100%" Height="100%">
                                        <PanelCollection>
                                            <dx:PanelContent runat="server">
                                                <table align="center" class="style1">
                                                    <tr>
                                                        <td align="center">
                                                            <table class="style1">
                                                                <tr>
                                                                    <td>
                                                                        <br />
                                                                        <table class="style1">
                                                                            <tr>
                                                                                <td align="center">
                                                                                    <dx:ASPxLabel ID="lbl_courseInfo" runat="server" ForeColor="Blue" Text="MARK RATIOS">
                                                                                    </dx:ASPxLabel>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="center">&nbsp;</td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="center">Course Work:</td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <dx:ASPxSpinEdit ID="txt_courseworkratio" runat="server" Font-Size="Small" Height="30px" HorizontalAlign="Center" Number="0" Width="100%">
                                                                        </dx:ASPxSpinEdit>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center">Practicals:</td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <dx:ASPxSpinEdit ID="txt_testratio" runat="server" Font-Size="Small" Height="30px" HorizontalAlign="Center" Number="0" Width="100%">
                                                                        </dx:ASPxSpinEdit>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center">Exam </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <dx:ASPxSpinEdit ID="txt_examratio" runat="server" Font-Size="Small" Height="30px" HorizontalAlign="Center" Number="0" Width="100%">
                                                                        </dx:ASPxSpinEdit>
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
                                                                        <dx:ASPxButton ID="cmdCreateSheet" runat="server" Height="30px" Text="Create | Refresh MarkSheet" Width="100%" OnClick="cmdCreateSheet_Click">
                                                                            <Image Url="~/COOPERP/images/tick-button.png">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <br />
                                                            <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red">
                                                            </dx:ASPxLabel>
                                                            <br />
                                                            <br />
                                                            <br />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </dx:PanelContent>
                                        </PanelCollection>
                                    </dx:ASPxRoundPanel>
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton">
                            <HeaderStyle Font-Bold="True" ForeColor="Red" HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px" ShowPageScrollbarWhenModal="True">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <br />
                                                <dx:ASPxLabel ID="lbl_msg" runat="server" ForeColor="Red" style="font-weight: 700">
                                                </dx:ASPxLabel>
                                                <br />
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
       <%-- </ContentTemplate>
    </asp:UpdatePanel>--%>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>