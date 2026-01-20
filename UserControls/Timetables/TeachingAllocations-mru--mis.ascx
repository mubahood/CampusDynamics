<%@ Control Language="C#" AutoEventWireup="true" CodeFile="TeachingAllocations.ascx.cs" Inherits="UserControls_TeachingAllocations" %>
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
        width: 97px;
        height: 27px;
    }
    .auto-style6 {
        width: 325px;
        height: 27px;
    }
    .auto-style7 {
        width: 100px;
        height: 27px;
    }
    .auto-style8 {
        height: 27px;
    }


    .auto-style9 {
        width: 100px;
    }


    .auto-style10 {
        width: 98px;
    }


    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <table class="dx-justification">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_teaching_alloc.png" >
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
                        <td class="auto-style1">Campus:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtCampus" runat="server" AutoPostBack="True" DataSourceID="dsCampus" Height="30px" OnSelectedIndexChanged="txtCampus_SelectedIndexChanged" TextField="campus_name" TextFormatString="{0} :: {1}" ValueField="ID" ValueType="System.Int32" Width="300px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="50px" />
                                    <dx:ListBoxColumn Caption="Campus Name" FieldName="campus_name" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style9">Academic Year:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtAcad" runat="server" AutoPostBack="True" Height="30px" Width="200px">
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">Programme:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtProgramme" runat="server" AutoPostBack="True" DataSourceID="dsProgrammes" Height="30px" OnSelectedIndexChanged="txtProgramme_SelectedIndexChanged" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="300px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="80px" />
                                    <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style9">Study Year:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtStudyYear" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="200px">
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
                        <td class="auto-style1">Course Name:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtCourse" runat="server" AutoPostBack="True" DataSourceID="dsCourses" DropDownWidth="700px" Height="30px" SelectedIndex="1" TextField="course_name" TextFormatString="{0} :: {1}" ValueField="course_code" Width="300px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="course_code" Width="50px" />
                                    <dx:ListBoxColumn Caption="Course Name" FieldName="course_name" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style9">Semester/Quarter:</td>
                        <td>
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
                    </tr>
                    <tr>
                        <td class="auto-style1">Lecturer:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtLecturer" runat="server" AutoPostBack="True" DataSourceID="dsContractInfo" Height="30px" OnSelectedIndexChanged="txtLecturer_SelectedIndexChanged" SelectedIndex="0" TextField="emp_name" TextFormatString="{0} :: {1}" ValueField="empID" Width="300px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Emp No" FieldName="empID" Width="60px" />
                                    <dx:ListBoxColumn Caption="Lecturer Name" FieldName="emp_name" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style9">Entry Year:</td>
                        <td>
                            <dx:ASPxComboBox ID="txt_entry_year" runat="server" AutoPostBack="True" Height="30px" Width="200px">
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style5">&nbsp;</td>
                        <td class="auto-style6">
                            <dx:ASPxButton ID="cmdAddNew" runat="server" Height="30px" OnClick="cmdAddNew_Click" Text="Add Allocation" ToolTip="Click to add a new Time table allocation for the selected course" Width="300px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style7">In-take:</td>
                        <td class="auto-style8">
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
                    </tr>
                    <tr>
                        <td class="auto-style1">&nbsp;</td>
                        <td class="auto-style3">
                            <dx:ASPxButton ID="cmdAdopt" runat="server" Height="30px" Text="Adopt Allocation" ToolTip="Click to adopt the displayed Allocations for another entry year within the same Study Period" Width="300px" OnClick="cmdAdopt_Click">
                                <Image IconID="actions_convert_16x16">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td class="auto-style9">Study Session:</td>
                        <td>
                            <dx:ASPxComboBox ID="txtsession" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="200px" DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="Session" />
                                </Columns>
                            </dx:ASPxComboBox>
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style1">&nbsp;</td>
                        <td class="auto-style3">
                            &nbsp;</td>
                        <td class="auto-style9">&nbsp;</td>
                        <td align="right">
                            <dx:ASPxButton ID="cmdPrint" runat="server" Text="Print Allocation" ToolTip="Click to Print the selected allocation details" Width="200px" OnClick="cmdPrint_Click" Height="30px">
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
                <dx:ASPxGridView ID="gvAllocations" runat="server" Width="100%" AutoGenerateColumns="False" DataSourceID="dsAllocations" KeyFieldName="ID" OnCustomErrorText="gvAllocations_CustomErrorText">
                    <SettingsPager AlwaysShowPager="True" Position="TopAndBottom">
                    </SettingsPager>
                    <SettingsEditing Mode="Batch">
                    </SettingsEditing>
                    <Settings ShowFilterRowMenu="True" />
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsDataSecurity AllowDelete="True" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="30px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Course Code" FieldName="courseID" ShowInCustomizationForm="True" VisibleIndex="4" Width="60px">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="acad_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="semester" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="progcode" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="cyear" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Stream" FieldName="stream" ShowInCustomizationForm="True" VisibleIndex="13" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Course Name" FieldName="course_name" ShowInCustomizationForm="True" VisibleIndex="5">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Lecturer Name" FieldName="emp_name" ShowInCustomizationForm="True" VisibleIndex="3">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="19" Width="30px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Session" FieldName="stud_session" ShowInCustomizationForm="True" VisibleIndex="11">
                            <PropertiesComboBox>
                                <Items>
                                    
 				    <dx:ListEditItem Selected="True" Text="-" Value="-" />
                                    <dx:ListEditItem Text="Part time" Value="Part time" />
                                    <dx:ListEditItem Text="Full time" Value="Full time" />
                                    <dx:ListEditItem Text="Weekend" Value="Weekend" />
                                    <dx:ListEditItem Text="Remote Learning" Value="Remote Learning" />
                                    <dx:ListEditItem Text="Modular" Value="Modular" />
                               </Items>
                            
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Intake" FieldName="intake" ShowInCustomizationForm="True" VisibleIndex="12">
                            <PropertiesComboBox>
                                <Items>
                                    
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
                            
</PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Campus" FieldName="campusId" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn FieldName="StartTime" ShowInCustomizationForm="True" VisibleIndex="16">
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
										<dx:ListEditItem Text="1:30 PM" Value="13:30:00" />
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
                        <dx:GridViewDataComboBoxColumn FieldName="EndTime" ShowInCustomizationForm="True" VisibleIndex="17">
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
										<dx:ListEditItem Text="1:30 PM" Value="13:30:00" />
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
                        <dx:GridViewDataComboBoxColumn Caption="Room" FieldName="roomNo" ShowInCustomizationForm="True" VisibleIndex="18">
                            <PropertiesComboBox DataSourceID="dsRooms" TextField="RoomName" TextFormatString="{0}" ValueField="RoomID">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="RoomName" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Day" FieldName="lectureday" ShowInCustomizationForm="True" VisibleIndex="15">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="MONDAY" Value="MONDAY" />
                                    <dx:ListEditItem Text="TUESDAY" Value="TUESDAY" />
                                    <dx:ListEditItem Text="WEDNESDAY" Value="WEDNESDAY" />
                                    <dx:ListEditItem Text="THURSDAY" Value="THURSDAY" />
                                    <dx:ListEditItem Text="FRIDAY" Value="FRIDAY" />
                                    <dx:ListEditItem Text="SATURDAY" Value="SATURDAY" />
                                    <dx:ListEditItem Text="SUNDAY" Value="SUNDAY" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Lecturer" FieldName="staffCode" ShowInCustomizationForm="True" VisibleIndex="2" Width="30px">
                            <PropertiesComboBox DataSourceID="dsContractInfo" TextField="empID" TextFormatString="{0}" ValueField="empID" DropDownWidth="500px">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Staff Code" FieldName="empID" Width="50px" />
                                    <dx:ListBoxColumn Caption="Staff Name" FieldName="emp_name" Width="450px" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn FieldName="EntryYear" ShowInCustomizationForm="True" VisibleIndex="10">
                            <PropertiesComboBox DataSourceID="ds_EntryYears" TextField="EntryYear" TextFormatString="{0}" ValueField="EntryYear" ValueType="System.UInt32">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="EntryYear" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsAllocations" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllocationsByCourse" TypeName="TimetableDataTableAdapters.acad_teaching_allocationTableAdapter" UpdateMethod="acad_EditTeachingAllocations" InsertMethod="Insert">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="staffCode" Type="String" />
                        <asp:Parameter Name="courseID" Type="String" />
                        <asp:Parameter Name="acad_year" Type="String" />
                        <asp:Parameter Name="semester" Type="Int32" />
                        <asp:Parameter Name="progcode" Type="String" />
                        <asp:Parameter Name="cyear" Type="Int32" />
                        <asp:Parameter Name="stud_session" Type="String" />
                        <asp:Parameter Name="intake" Type="String" />
                        <asp:Parameter Name="stream" Type="String" />
                        <asp:Parameter Name="campusId" Type="Int32" />
                        <asp:Parameter Name="lectureday" Type="String" />
                        <asp:Parameter Name="EntryYear" Type="Int32" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtProgramme" Name="prog" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtAcad" Name="acad" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtSemester" Name="sems" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtStudyYear" Name="cyr" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txt_entry_year" Name="entyear" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtintake" Name="in_take" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtsession" Name="sess" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtCampus" Name="campusno" PropertyName="Value" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt64" />
                        <asp:Parameter Name="staffCode" Type="String" />
                        <asp:Parameter Name="EntryYear" Type="UInt32" />
                        <asp:Parameter Name="stud_session" Type="String" />
                        <asp:Parameter Name="intake" Type="String" />
                        <asp:Parameter Name="StartTime" Type="String" />
                        <asp:Parameter Name="EndTime" Type="String" />
                        <asp:Parameter Name="roomNo" Type="String" />
                        <asp:Parameter Name="lectureday" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.myaspnet_GetMyProgrammesTableAdapter">
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="-" Name="usr" SessionField="username" Type="String" />
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
                        <asp:ControlParameter ControlID="txtCampus" Name="campusno" PropertyName="Value" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="RoomName" Type="String" />
                        <asp:Parameter Name="Capacity" Type="Int32" />
                        <asp:Parameter Name="campusId" Type="Int32" />
                        <asp:Parameter Name="Original_RoomID" Type="Int32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsContractInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_ValidEmployees" TypeName="HRMDataTableAdapters.hrm_emp_contractsTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="empID" Type="UInt32" />
                        <asp:Parameter Name="contractStart" Type="DateTime" />
                        <asp:Parameter Name="contractEnd" Type="DateTime" />
                        <asp:Parameter Name="jobID" Type="UInt32" />
                        <asp:Parameter Name="departmentID" Type="UInt32" />
                        <asp:Parameter Name="comments" Type="String" />
                        <asp:Parameter Name="contractStatus" Type="String" />
                        <asp:Parameter Name="payscale" Type="UInt32" />
                        <asp:Parameter Name="fixedamount" Type="Double" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="empID" Type="UInt32" />
                        <asp:Parameter Name="contractStart" Type="DateTime" />
                        <asp:Parameter Name="contractEnd" Type="DateTime" />
                        <asp:Parameter Name="jobID" Type="UInt32" />
                        <asp:Parameter Name="departmentID" Type="UInt32" />
                        <asp:Parameter Name="comments" Type="String" />
                        <asp:Parameter Name="contractStatus" Type="String" />
                        <asp:Parameter Name="payscale" Type="UInt32" />
                        <asp:Parameter Name="fixedamount" Type="Double" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
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
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="progcode" Type="String" />
                        <asp:Parameter Name="course_code" Type="String" />
                        <asp:Parameter Name="study_year" Type="UInt32" />
                        <asp:Parameter Name="semester" Type="UInt32" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsstudysessions" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update">
                    <InsertParameters>
                        <asp:Parameter Name="Session" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Original_Session" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <br />
                <asp:ObjectDataSource ID="dsCampus" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="CampusDataTableAdapters.acad_campusesTableAdapter" UpdateMethod="Update">
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
                <asp:ObjectDataSource ID="ds_EntryYears" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetEntryYears" TypeName="TimetableDataTableAdapters.acad_studentTableAdapter"></asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
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
                <dx:ASPxPopupControl ID="pop_print" runat="server" HeaderText="Campus Dynamics Version 1.0" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <HeaderStyle HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
                <dx:ASPxPopupControl ID="pop_adopt" runat="server" CloseAction="CloseButton" Height="150px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px" HeaderText="Campus Dynamics :: Version 1.0" Modal="True" ShowPageScrollbarWhenModal="True">
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td class="auto-style10">New Entry Year:</td>
                                    <td>
                                        <dx:ASPxComboBox ID="txt_new_entry_year" runat="server" Height="30px" Width="200px">
                                        </dx:ASPxComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style10">&nbsp;</td>
                                    <td>
                                        <dx:ASPxButton ID="cmdAdoptAllocation" runat="server" Height="30px" Text="Create Allocations" ToolTip="Click to create allocations for the entry year selected" Width="200px" OnClick="cmdAdoptAllocation_Click">
                                            <Image IconID="actions_convert_16x16">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style10">&nbsp;</td>
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

