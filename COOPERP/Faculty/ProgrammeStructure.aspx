<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ProgrammeStructure.aspx.cs" Inherits="COOPERP_Faculty_ProgrammeStructure" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .style1 {
            width:100%;
        }
        .auto-style1 {
            width: 165px;
        }
        .auto-style2 {
            width: 168px;
        }
    
*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


        .auto-style5 {
            width: 239px;
        }
        .auto-style6 {
            width: 164px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
            <TabPages>
                <dx:TabPage Text="Courses">
                    <TabImage IconID="businessobjects_botask_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <dx:ASPxRoundPanel ID="panel_progCourses" runat="server" Font-Bold="True" ShowHeader="False" Width="100%">
                                <HeaderStyle ForeColor="Red" HorizontalAlign="Center" />
                                <PanelCollection>
                                    <dx:PanelContent runat="server">
                                        <table class="style1">
                                            <tr>
                                                <td colspan="3">
                                                    <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Curriculum:">
                                                    </dx:ASPxLabel>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="auto-style5">
                                                    <dx:ASPxComboBox ID="txt_curriculums" runat="server" AutoPostBack="True" DataSourceID="dsCurriculumInfo" DropDownWidth="500px" Height="25px" SelectedIndex="0" TextField="Tittle" TextFormatString="{0}" ValueField="ID" ValueType="System.Int32" Width="250px">
                                                        <Columns>
                                                            <dx:ListBoxColumn FieldName="ID" Visible="False" />
                                                            <dx:ListBoxColumn FieldName="Tittle" />
                                                        </Columns>
                                                    </dx:ASPxComboBox>
                                                </td>
                                                <td class="auto-style6">
                                                    <dx:ASPxButton ID="cmdUpdateCurriculum" runat="server" Height="25px" Text="Change | Refresh Curriculums" ToolTip="Click to Switch/Copy Selected Courses to another Curriculum" Width="220px" OnClick="cmdUpdateCurriculum_Click">
                                                        <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td>
                                                    <dx:ASPxButton ID="btn_print" runat="server" Height="25px" OnClick="btn_print_Click" Text="Print Structure" ToolTip="Click to Print Program Structure for the Selected Curriculum" Width="220px">
                                                        <Image IconID="print_printer_16x16">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="3">
                                                    <table class="style1">
                                                        <tr>
                                                            <td class="auto-style1">
                                                                <dx:ASPxTextBox ID="txtPrefix" runat="server" Height="25px" NullText="Prefix eg BABA or Code eg BABA 1101" style="margin-bottom: 0px" Width="250px">
                                                                    <Paddings PaddingLeft="5px" />
                                                                </dx:ASPxTextBox>
                                                            </td>
                                                            <td class="auto-style2">
                                                                <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" Text="Add New" Width="220px" Height="25px" ToolTip="Click to ADD the entered Course onto the Program Course Structure">
                                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </td>
                                                            <td>
                                                                <dx:ASPxButton ID="cmdBatch" runat="server" OnClick="cmdBatch_Click" Text="Add Batch" Width="220px" Height="25px" ToolTip="Click to ADD all courses with the entered PREFIX onto the Program Course Structure">
                                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </td>
                                                            <td>&nbsp;</td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="3">
                                                    <dx:ASPxGridView ID="gvProgCourses" runat="server" AutoGenerateColumns="False" DataSourceID="dsProgCourses" KeyFieldName="ID" OnInitNewRow="gvProgCourses_InitNewRow" Width="100%" OnRowInserted="gvProgCourses_RowInserted">
                                                        <SettingsEditing Mode="Batch">
                                                        </SettingsEditing>
                                                        <Settings ShowFilterRowMenu="True" ShowFilterRow="True" />
                                                        <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                        <SettingsSearchPanel Visible="True" />
                                                        <Columns>
                                                            <dx:GridViewDataTextColumn Caption="Prog Code" FieldName="progcode" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                <EditFormSettings Visible="True" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Code" FieldName="course_code" ShowInCustomizationForm="True" VisibleIndex="3" Width="160px">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Year" FieldName="study_year" ShowInCustomizationForm="True" VisibleIndex="5" Width="60px">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Semester" FieldName="semester" ShowInCustomizationForm="True" VisibleIndex="6" Width="60px">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Course Name" FieldName="course_name" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewCommandColumn ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="7" Width="25px" ShowClearFilterButton="True">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                            </dx:GridViewDataTextColumn>
                                                        </Columns>
                                                    </dx:ASPxGridView>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="3">
                                                    <asp:ObjectDataSource ID="dsProgCourses" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetCoursesByProgCode" TypeName="FacultyDataTableAdapters.acad_programmecoursesTableAdapter" UpdateMethod="Update">
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
                                                            <asp:SessionParameter DefaultValue="-" Name="prog" SessionField="prog" Type="String" />
                                                            <asp:ControlParameter ControlID="txt_curriculums" Name="currID" PropertyName="Value" Type="Int32" />
                                                        </SelectParameters>
                                                        <UpdateParameters>
                                                            <asp:Parameter Name="progcode" Type="String" />
                                                            <asp:Parameter Name="course_code" Type="String" />
                                                            <asp:Parameter Name="study_year" Type="UInt32" />
                                                            <asp:Parameter Name="semester" Type="UInt32" />
                                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                        </UpdateParameters>
                                                    </asp:ObjectDataSource>
                                                    <asp:ObjectDataSource ID="dsCurriculumInfo" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_ProgrammeCurriculums" TypeName="FacultyDataTableAdapters.acad_curriculumTableAdapter">
                                                        <DeleteParameters>
                                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                        </DeleteParameters>
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="prog" SessionField="prog" Type="String" />
                                                        </SelectParameters>
                                                    </asp:ObjectDataSource>
                                                    <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Text="Processing. Please wait&amp;hellip;">
                                                    </dx:ASPxLoadingPanel>
                                                    <dx:ASPxPopupControl ID="pop_changeCurriculum" runat="server" CloseAction="CloseButton" HeaderText="Campus Dynamics Version 1.0" Height="200px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="500px">
                                                        <ContentCollection>
                                                            <dx:PopupControlContentControl runat="server">
                                                                <table class="style1">
                                                                    <tr>
                                                                        <td>
                                                                            <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text="New Curriculum:">
                                                                            </dx:ASPxLabel>
                                                                        </td>
                                                                        <td>
                                                                            <dx:ASPxComboBox ID="txt_curriculums_new" runat="server" AutoPostBack="True" DataSourceID="dsOtherCurriculums" DropDownWidth="500px" Height="30px" SelectedIndex="0" TextField="Tittle" TextFormatString="{0}" ValueField="ID" ValueType="System.Int32" Width="300px">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn FieldName="ID" Visible="False" />
                                                                                    <dx:ListBoxColumn FieldName="Tittle" />
                                                                                </Columns>
                                                                            </dx:ASPxComboBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Change Type:</td>
                                                                        <td>
                                                                            <dx:ASPxRadioButtonList ID="rb_type" runat="server" AutoPostBack="True" Height="30px" RepeatDirection="Horizontal" SelectedIndex="1" Width="300px">
                                                                                <Items>
                                                                                    <dx:ListEditItem Selected="True" Text="Switch Course(s)" Value="Switch" />
                                                                                    <dx:ListEditItem Text="Copy Course(s)" Value="Copy" />
                                                                                </Items>
                                                                            </dx:ASPxRadioButtonList>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>&nbsp;</td>
                                                                        <td>
                                                                            <dx:ASPxButton ID="cmdChangeCurriculum" runat="server" Height="30px" Text="Update" ToolTip="Click to Switch/Copy Selected Courses to the Selected New Curriculum" Width="300px" OnClick="cmdChangeCurriculum_Click">
                                                                                <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Change/Copy the Selected Course(s) to the Selected Curriculum?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }	
}" />
                                                                                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                                                </Image>
                                                                            </dx:ASPxButton>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>&nbsp;</td>
                                                                        <td>
                                                                            <asp:ObjectDataSource ID="dsOtherCurriculums" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_OtherCurriculums" TypeName="FacultyDataTableAdapters.acad_curriculumTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                                                                                <DeleteParameters>
                                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                                </DeleteParameters>
                                                                                <InsertParameters>
                                                                                    <asp:Parameter Name="Tittle" Type="String" />
                                                                                    <asp:Parameter Name="Description" Type="String" />
                                                                                    <asp:Parameter Name="Progcode" Type="String" />
                                                                                    <asp:Parameter Name="StartYear" Type="UInt32" />
                                                                                    <asp:Parameter Name="intake" Type="String" />
                                                                                </InsertParameters>
                                                                                <SelectParameters>
                                                                                    <asp:ControlParameter ControlID="txt_curriculums" Name="CurriculumID" PropertyName="Value" Type="Int32" />
                                                                                    <asp:SessionParameter Name="prog" SessionField="prog" Type="String" />
                                                                                </SelectParameters>
                                                                                <UpdateParameters>
                                                                                    <asp:Parameter Name="Tittle" Type="String" />
                                                                                    <asp:Parameter Name="Description" Type="String" />
                                                                                    <asp:Parameter Name="Progcode" Type="String" />
                                                                                    <asp:Parameter Name="StartYear" Type="UInt32" />
                                                                                    <asp:Parameter Name="intake" Type="String" />
                                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                                </UpdateParameters>
                                                                            </asp:ObjectDataSource>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </dx:PopupControlContentControl>
                                                        </ContentCollection>
                                                    </dx:ASPxPopupControl>
                                                    <dx:ASPxPopupControl ID="pop_response" runat="server" Height="100px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px" HeaderText="Campus Dynamics Version 1.0">
                                                        <ContentCollection>
                                                            <dx:PopupControlContentControl runat="server">
                                                                <table class="style1">
                                                                    <tr>
                                                                        <td align="center">
                                                                            <dx:ASPxLabel ID="lbl_response" runat="server" ForeColor="Red">
                                                                            </dx:ASPxLabel>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </dx:PopupControlContentControl>
                                                        </ContentCollection>
                                                    </dx:ASPxPopupControl>
                                                    <dx:ASPxPopupControl ID="pop_details" runat="server" CloseAction="CloseButton" HeaderText="" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                                                        <HeaderStyle ForeColor="Red" HorizontalAlign="Center" />
                                                        <ContentCollection>
                                                            <dx:PopupControlContentControl runat="server">
                                                            </dx:PopupControlContentControl>
                                                        </ContentCollection>
                                                    </dx:ASPxPopupControl>
                                                </td>
                                            </tr>
                                        </table>
                                    </dx:PanelContent>
                                </PanelCollection>
                            </dx:ASPxRoundPanel>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text="Curriculums">
                    <TabImage IconID="businessobjects_boreport2_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
                            <table class="style1">
                <tr>
                    <td>
                        <table class="style1">
                            <tr>
                                <td>
                                    <dx:ASPxButton ID="cmdAddNewCurriculum" runat="server" Text="Add New" Width="170px" OnClick="cmdAddNewCurriculum_Click">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td style="text-align: right" width="170px">
                                    &nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvCurriculumInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvCurriculum_Info" DataSourceID="ds_curriculum" KeyFieldName="ID" Width="100%" OnCustomErrorText="gvCurriculumInfo_CustomErrorText" OnRowInserting="gvCurriculumInfo_RowInserting">
                            <SettingsDataSecurity AllowDelete="False" />
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="SNo" FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="25px">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Curriculum Tittle" FieldName="Tittle" ShowInCustomizationForm="True" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Comments" FieldName="Description" ShowInCustomizationForm="True" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ButtonType="Image" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="7" Width="40px"/>
                                <dx:GridViewCommandColumn ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn FieldName="Progcode" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataComboBoxColumn FieldName="StartYear" ShowInCustomizationForm="True" VisibleIndex="5">
                                    <PropertiesComboBox DataSourceID="ds_entryears" TextField="entryyear" TextFormatString="{0}" ValueField="entryyear" ValueType="System.Int32">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Year" FieldName="entryyear" />
                                        </Columns>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataComboBoxColumn Caption="First Intake" FieldName="intake" ShowInCustomizationForm="True" VisibleIndex="6">
                                    <PropertiesComboBox DataSourceID="ds_months" TextField="MonthName" TextFormatString="{0}" ValueField="MonthName">
                                        <Columns>
                                            <dx:ListBoxColumn FieldName="MonthName" />
                                        </Columns>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
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
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="ds_curriculum" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_ProgrammeCurriculums" TypeName="FacultyDataTableAdapters.acad_curriculumTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="Tittle" Type="String" />
                                <asp:Parameter Name="Description" Type="String" />
                                <asp:Parameter Name="Progcode" Type="String" />
                                <asp:Parameter Name="StartYear" Type="UInt32" />
                                <asp:Parameter Name="intake" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:SessionParameter Name="prog" SessionField="prog" Type="String" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="Tittle" Type="String" />
                                <asp:Parameter Name="Description" Type="String" />
                                <asp:Parameter Name="Progcode" Type="String" />
                                <asp:Parameter Name="StartYear" Type="UInt32" />
                                <asp:Parameter Name="intake" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="ds_entryears" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.Entry_YearsTableAdapter"></asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="ds_months" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_calendermonthsTableAdapter">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                        </asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red" style="font-weight: 700">
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
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <%--<dx:TabPage Text="Assessment Score Ratios">
                    <TabImage IconID="alignment_alignhorizontalbottom2_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" Width="100%">
                                <PanelCollection>
                                    <dx:PanelContent runat="server">
                                        <table class="style1">
                                            <tr>
                                                <td>
                                                    <dx:ASPxButton ID="btn_addnew" runat="server" Height="30px" OnClick="btn_addnew_Click" Text="Create Scores" Width="200px">
                                                        <Image IconID="actions_addfile_16x16">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxGridView ID="gv_scores" runat="server" AutoGenerateColumns="False" DataSourceID="ds_scores" KeyFieldName="progcode" OnCustomErrorText="gv_scores_CustomErrorText" OnRowUpdating="gv_scores_RowUpdating" Width="100%">
                                                        <SettingsEditing Mode="Batch">
                                                        </SettingsEditing>
                                                        <SettingsCommandButton>
                                                            <UpdateButton Text="| Save Changes |">
                                                            </UpdateButton>
                                                            <CancelButton Text="| Cancel Changes |">
                                                            </CancelButton>
                                                        </SettingsCommandButton>
                                                        <SettingsDataSecurity AllowDelete="False" />
                                                        <Columns>
                                                            <dx:GridViewDataTextColumn FieldName="progcode" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Course Work" FieldName="Coursework" ShowInCustomizationForm="True" VisibleIndex="1">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Practicals" ShowInCustomizationForm="True" VisibleIndex="2">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Exams" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                        </Columns>
                                                    </dx:ASPxGridView>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:ObjectDataSource ID="ds_scores" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_ProgrammeResultRatios" TypeName="FacultyDataTableAdapters.acad_programme_resultsratiosTableAdapter" UpdateMethod="Update">
                                                        <DeleteParameters>
                                                            <asp:Parameter Name="Original_progcode" Type="String" />
                                                        </DeleteParameters>
                                                        <InsertParameters>
                                                            <asp:Parameter Name="progcode" Type="String" />
                                                            <asp:Parameter Name="Coursework" Type="UInt32" />
                                                            <asp:Parameter Name="Practicals" Type="UInt32" />
                                                            <asp:Parameter Name="Exams" Type="UInt32" />
                                                        </InsertParameters>
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="progcode" SessionField="prog" Type="String" />
                                                        </SelectParameters>
                                                        <UpdateParameters>
                                                            <asp:Parameter Name="Coursework" Type="UInt32" />
                                                            <asp:Parameter Name="Practicals" Type="UInt32" />
                                                            <asp:Parameter Name="Exams" Type="UInt32" />
                                                            <asp:Parameter Name="Original_progcode" Type="String" />
                                                        </UpdateParameters>
                                                    </asp:ObjectDataSource>
                                                </td>
                                            </tr>
                                        </table>
                                    </dx:PanelContent>
                                </PanelCollection>
                            </dx:ASPxRoundPanel>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text=" Study Sessions">
                    <TabImage IconID="conditionalformatting_adateoccurring_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="gvProgSession" runat="server" AutoGenerateColumns="False" DataSourceID="dsProgSessions" KeyFieldName="ID" OnHtmlRowPrepared="gvProgSession_HtmlRowPrepared" OnInitNewRow="gvProgSession_InitNewRow" Width="100%">
                                            <SettingsContextMenu Enabled="True">
                                            </SettingsContextMenu>
                                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                            <SettingsText CommandUpdate="Save Changes" ConfirmDelete="Delete Session" />
                                            <Columns>
                                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Prog Code" FieldName="progid" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Study Session" FieldName="prog_session" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <PropertiesComboBox>
                                                        <Items>
                                                            <dx:ListEditItem Text="Day-release" Value="Day-release" />
                                                            <dx:ListEditItem Text="Full time" Value="Full time" />
                                                            <dx:ListEditItem Text="Modular" Value="Modular" />
                                                            <dx:ListEditItem Text="Part time" Value="Part time" />
                                                            <dx:ListEditItem Text="Remote Learning" Value="Remote Learning" />
                                                            <dx:ListEditItem Text="Top-up" Value="Top-up" />
                                                            <dx:ListEditItem Text="Weekend" Value="Weekend" />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="4" Width="80px">
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                </dx:GridViewCommandColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:ObjectDataSource ID="dsProgSessions" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSingleProgSessions" TypeName="admission_dataTableAdapters.prog_sessionsTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_ID" Type="Int32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="progid" Type="String" />
                                                <asp:Parameter Name="prog_session" Type="String" />
                                            </InsertParameters>
                                            <SelectParameters>
                                                <asp:SessionParameter DefaultValue="-" Name="prog" SessionField="prog" Type="String" />
                                            </SelectParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="progid" Type="String" />
                                                <asp:Parameter Name="prog_session" Type="String" />
                                                <asp:Parameter Name="Original_ID" Type="Int32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                    </td>
                                </tr>
                            </table>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>--%>
                <dx:TabPage Text="Graduation Loads">
                    <TabImage IconID="spreadsheet_allowuserstoeditranges_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <dx:ASPxRoundPanel ID="ASPxRoundPanel3" runat="server" DefaultButton="txtSearch" HeaderText="System Applications" ShowHeader="False" Width="100%">
                                <PanelCollection>
                                    <dx:PanelContent runat="server">
                                        <table class="style1">
                                            <tr>
                                                <td>
                                                    <table class="style1">
                                                        <tr>
                                                            <td>
                                                                <dx:ASPxButton ID="cmdAddNewEntryType" runat="server" OnClick="cmdAddNewEntryType_Click" Text="Add New" Width="170px">
                                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </td>
                                                            <td style="text-align: right" width="170px">&nbsp;</td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxGridView ID="gv_graduationloads" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvCurriculum_Info" DataSourceID="ds_graduationload" KeyFieldName="ID" OnCustomErrorText="gv_graduationloads_CustomErrorText" OnRowInserting="gv_graduationloads_RowInserting" Width="100%">
                                                        <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                        <SettingsCommandButton>
                                                            <UpdateButton RenderMode="Link">
                                                            </UpdateButton>
                                                            <CancelButton RenderMode="Link">
                                                            </CancelButton>
                                                            <EditButton>
                                                                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                                </Image>
                                                            </EditButton>
                                                            <DeleteButton>
                                                                <Image Url="~/COOPERP/images/minus-button.png">
                                                                </Image>
                                                            </DeleteButton>
                                                        </SettingsCommandButton>
                                                        <SettingsDataSecurity AllowDelete="False" />
                                                        <Columns>
                                                            <dx:GridViewDataTextColumn Caption="SNo" FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1" Width="25px">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Minimum Graduation Load" FieldName="MinimumCreditUnits" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewCommandColumn ButtonRenderMode="Image" ButtonType="Image" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="7" Width="40px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn FieldName="progcode" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataComboBoxColumn Caption="Entry Method" FieldName="EntryType" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                <PropertiesComboBox DataSourceID="ds_entrytypes" DropDownWidth="400px" TextField="EntryMethod" ValueField="EntryMethod">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn FieldName="EntryMethod" />
                                                                    </Columns>
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
                                                <td>
                                                    <asp:ObjectDataSource ID="ds_graduationload" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_ProgrammeLoads" TypeName="FacultyDataTableAdapters.acad_programme_creditunitsTableAdapter" UpdateMethod="Update">
                                                        <DeleteParameters>
                                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                        </DeleteParameters>
                                                        <InsertParameters>
                                                            <asp:Parameter Name="progcode" Type="String" />
                                                            <asp:Parameter Name="EntryType" Type="String" />
                                                            <asp:Parameter Name="MinimumCreditUnits" Type="UInt32" />
                                                        </InsertParameters>
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="progcode" SessionField="prog" Type="String" />
                                                        </SelectParameters>
                                                        <UpdateParameters>
                                                            <asp:Parameter Name="progcode" Type="String" />
                                                            <asp:Parameter Name="EntryType" Type="String" />
                                                            <asp:Parameter Name="MinimumCreditUnits" Type="UInt32" />
                                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                        </UpdateParameters>
                                                    </asp:ObjectDataSource>
                                                    <asp:ObjectDataSource ID="ds_entrytypes" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_programme_entry_typesTableAdapter" UpdateMethod="Update">
                                                        <DeleteParameters>
                                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                        </DeleteParameters>
                                                        <InsertParameters>
                                                            <asp:Parameter Name="EntryMethod" Type="String" />
                                                        </InsertParameters>
                                                        <UpdateParameters>
                                                            <asp:Parameter Name="EntryMethod" Type="String" />
                                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                        </UpdateParameters>
                                                    </asp:ObjectDataSource>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxPopupControl ID="pop_messagebox0" runat="server" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                                        <HeaderStyle HorizontalAlign="Center" />
                                                        <ContentCollection>
                                                            <dx:PopupControlContentControl runat="server">
                                                                <table align="center" class="style1">
                                                                    <tr>
                                                                        <td align="center">
                                                                            <br />
                                                                            <br />
                                                                            <dx:ASPxLabel ID="lbl_comment0" runat="server" ForeColor="Red" style="font-weight: 700">
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
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text="Specialisations">
                    <TabImage IconID="businessobjects_boparameter_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <dx:ASPxRoundPanel ID="ASPxRoundPanel4" runat="server" DefaultButton="txtSearch" HeaderText="Programme Specialisations" ShowHeader="False" Width="100%">
                                <PanelCollection>
                                    <dx:PanelContent runat="server">
                                        <table class="style1">
                                            <tr>
                                                <td>
                                                    <table class="style1">
                                                        <tr>
                                                            <td>
                                                                <dx:ASPxButton ID="cmdAddNewSpec" runat="server" OnClick="cmdAddNewSpec_Click" Text="Add New Specialisation" Width="200px">
                                                                    <Image IconID="actions_add_16x16">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </td>
                                                            <td style="text-align: right" width="170px">&nbsp;</td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxGridView ID="gv_specialisations" runat="server" AutoGenerateColumns="False" ClientInstanceName="gv_specialisations" DataSourceID="ds_specialisations" KeyFieldName="spec_id" OnCustomErrorText="gv_specialisations_CustomErrorText" OnRowInserting="gv_specialisations_RowInserting" Width="100%">
                                                        <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                        <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                                        <SettingsPager AlwaysShowPager="True">
                                                            <Summary AllPagesText="Pages: {0} - {1} ({2} Specialisation(s))" Text="Page {0} of {1} ({2} Specialisation(s))" />
                                                        </SettingsPager>
                                                        <SettingsCommandButton>
                                                            <UpdateButton RenderMode="Link">
                                                            </UpdateButton>
                                                            <CancelButton RenderMode="Link">
                                                            </CancelButton>
                                                            <EditButton>
                                                                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                                </Image>
                                                            </EditButton>
                                                            <DeleteButton>
                                                                <Image Url="~/COOPERP/images/minus-button.png">
                                                                </Image>
                                                            </DeleteButton>
                                                        </SettingsCommandButton>
                                                        <Columns>
                                                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn Caption="ID" FieldName="spec_id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="50px">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="prog_id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Specialisation Name" FieldName="spec" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                <PropertiesTextEdit>
                                                                    <ValidationSettings>
                                                                        <RequiredField IsRequired="True" ErrorText="Specialisation name is required" />
                                                                    </ValidationSettings>
                                                                </PropertiesTextEdit>
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Abbreviation" FieldName="abbrev" ShowInCustomizationForm="True" VisibleIndex="4" Width="150px">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewCommandColumn ButtonRenderMode="Image" ButtonType="Image" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="5" Width="50px">
                                                            </dx:GridViewCommandColumn>
                                                        </Columns>
                                                    </dx:ASPxGridView>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:SqlDataSource ID="ds_specialisations" runat="server" 
                                                        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
                                                        ProviderName="MySql.Data.MySqlClient"
                                                        SelectCommand="SELECT spec_id, prog_id, spec, abbrev FROM acad_specialisation WHERE prog_id = @prog_id ORDER BY spec"
                                                        InsertCommand="INSERT INTO acad_specialisation (prog_id, spec, abbrev) VALUES (@prog_id, @spec, @abbrev)"
                                                        UpdateCommand="UPDATE acad_specialisation SET spec=@spec, abbrev=@abbrev WHERE spec_id=@Original_spec_id"
                                                        DeleteCommand="DELETE FROM acad_specialisation WHERE spec_id=@Original_spec_id">
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="prog_id" SessionField="prog" Type="String" DefaultValue="" />
                                                        </SelectParameters>
                                                        <InsertParameters>
                                                            <asp:SessionParameter Name="prog_id" SessionField="prog" Type="String" />
                                                            <asp:Parameter Name="spec" Type="String" />
                                                            <asp:Parameter Name="abbrev" Type="String" />
                                                        </InsertParameters>
                                                        <UpdateParameters>
                                                            <asp:Parameter Name="spec" Type="String" />
                                                            <asp:Parameter Name="abbrev" Type="String" />
                                                            <asp:Parameter Name="Original_spec_id" Type="Int32" />
                                                        </UpdateParameters>
                                                        <DeleteParameters>
                                                            <asp:Parameter Name="Original_spec_id" Type="Int32" />
                                                        </DeleteParameters>
                                                    </asp:SqlDataSource>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxPopupControl ID="pop_spec_messagebox" runat="server" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                                        <HeaderStyle HorizontalAlign="Center" />
                                                        <ContentCollection>
                                                            <dx:PopupControlContentControl runat="server">
                                                                <table align="center" class="style1">
                                                                    <tr>
                                                                        <td align="center">
                                                                            <br />
                                                                            <br />
                                                                            <dx:ASPxLabel ID="lbl_spec_comment" runat="server" ForeColor="Red" style="font-weight: 700">
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
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
            </TabPages>
            <TabStyle>
                <Paddings Padding="10px" />
            </TabStyle>
        </dx:ASPxPageControl>
    
    </div>
    </form>
</body>
</html>
