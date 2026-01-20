<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentSpecialisationCentre.ascx.cs" Inherits="UserControls_StudentInfo_StudentSpecialisationCentre" %>
<style type="text/css">
    .style1
    {
        width: 100%;
    }

*
{ 
    /*padding: 0;*/
    margin-left: 0;
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
    .auto-style3 {
        width: 103px;
    }
    .auto-style6 {
        width: 363px;
    }
    .auto-style8 {
        width: 363px;
        height: 25px;
    }
    .auto-style9 {
        width: 103px;
        height: 25px;
    }
    .auto-style10 {
        height: 25px;
    }
    .auto-style13 {
        width: 130px;
        height: 25px;
    }
    .auto-style14 {
        width: 130px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/student_specialsations.png">
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
                <table class="style1">
                    <tr>
                        <td>
                            <table class="style1">
                                <tr>
                                    <td class="auto-style13">Campus:</td>
                                    <td class="auto-style8">
                                        <dx:ASPxComboBox ID="txtCampus" runat="server" AutoPostBack="True" DataSourceID="dsCampus" Height="30px" TextField="campus_name" TextFormatString="{0} :: {1}" ValueField="ID" ValueType="System.Int32" Width="350px">
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="50px" />
                                                <dx:ListBoxColumn Caption="Campus Name" FieldName="campus_name" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style9">Academic Year:</td>
                                    <td class="auto-style10">
                                        <dx:ASPxComboBox ID="txtAcadYear" runat="server" Height="30px" AutoPostBack="True">
                                        </dx:ASPxComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style13">Programme:</td>
                                    <td class="auto-style8">
                                        <dx:ASPxComboBox ID="txtProgramme" runat="server" DataSourceID="dsProgrammes" Height="30px" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="350px" AutoPostBack="True" OnSelectedIndexChanged="txtProgramme_SelectedIndexChanged">
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Code" FieldName="progcode" />
                                                <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                                <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style9">Study Year:</td>
                                    <td class="auto-style10">
                                        <dx:ASPxComboBox ID="txtYear" runat="server" Height="30px" SelectedIndex="0" AutoPostBack="True" >
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
                                    <td class="auto-style13">Study Session:</td>
                                    <td class="auto-style8">
                                        <dx:ASPxComboBox ID="txtSession" runat="server" AutoPostBack="True" DataSourceID="dsstudysessions" Height="30px" SelectedIndex="0" TextField="Session" TextFormatString="{0}" ValueField="Session" Width="350px">
                                            <Columns>
                                                <dx:ListBoxColumn FieldName="Session" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style9">Semester:</td>
                                    <td class="auto-style10">
                                        <dx:ASPxComboBox ID="txtSemester" runat="server" SelectedIndex="0" Height="30px" AutoPostBack="True" >
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
                                    <td class="auto-style13">Current Specialisation:</td>
                                    <td class="auto-style8">
                                        <dx:ASPxComboBox ID="txt_currentspecialisation" runat="server" Height="30px" SelectedIndex="0" Width="350px" DataSourceID="dsSpecialisations" DropDownWidth="600px" TextField="spec" TextFormatString="{1}" ValueField="spec_id" ValueType="System.Int32" AutoPostBack="True" ClientInstanceName="txt_currentspec">
                                           
                                            <Columns>
                                                <dx:ListBoxColumn Caption="SNo." FieldName="spec_id" Width="100px" />
                                                <dx:ListBoxColumn Caption="Specialisation" FieldName="spec" Width="500px" />
                                            </Columns>
                                           
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style9">Entry Year:</td>
                                    <td class="auto-style10">
                                        <dx:ASPxComboBox ID="txt_entry_year" runat="server" AutoPostBack="True" Height="30px">
                                        </dx:ASPxComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style14">New Specialisation:</td>
                                    <td class="auto-style6">
                                        <dx:ASPxComboBox ID="txt_newspecialisation" runat="server" SelectedIndex="0" Width="350px" Height="30px" DataSourceID="dsSpecialisations" DropDownWidth="600px" TextField="spec" TextFormatString="{1}" ValueField="spec_id" ValueType="System.Int32">
                                            
                                            <Columns>
                                                <dx:ListBoxColumn Caption="SNo." FieldName="spec_id" Width="100px" />
                                                <dx:ListBoxColumn Caption="Specialisation" FieldName="spec" Width="500px" />
                                            </Columns>
                                            
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style3">Intake:</td>
                                    <td>
                                        <dx:ASPxComboBox ID="txtIntake" runat="server" SelectedIndex="0" Height="30px" AutoPostBack="True">
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
                                    <td class="auto-style14">&nbsp;</td>
                                    <td class="auto-style6">
                                        <dx:ASPxButton ID="cmdSet_Specialisation" runat="server" Height="30px" OnClick="cmdSet_Specialisation_Click" Text="Set Specialisation" ToolTip="Set the Specialisation for the Selected Students to the Selected New Specialisation" Width="350px">
                                            <ClientSideEvents Click="function(s, e) {
                                                e.processOnServer = confirm('You are about to Change Student Specialisations/Subjects, Proceed?');
	lp_grads.Show();
}" />
                                            <Image IconID="actions_right_16x16">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                    <td class="auto-style3">&nbsp;</td>
                                    <td>
                                        <dx:ASPxButton ID="btn_managespecialisations" runat="server" ClientInstanceName="btn_managespecialisations" Height="30px" OnClick="btn_managespecialisations_Click" Text="Specialisations" ToolTip="Manage Specialisations for the Selected Programme" Width="170px">
                                            <Image IconID="actions_addfile_16x16">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style14">&nbsp;</td>
                                    <td class="auto-style6">
                                        &nbsp;</td>
                                    <td class="auto-style3">&nbsp;</td>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                            </table>
                        </td>
                        <td style="text-align: right" width="170px" valign="bottom">
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvStudentInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvStudentInfo" DataSourceID="dsStudentInfo" KeyFieldName="regno" OnHtmlDataCellPrepared="gvStudentInfo_HtmlDataCellPrepared" Width="100%">
                    <SettingsContextMenu Enabled="True">
                    </SettingsContextMenu>
                    <SettingsPager AlwaysShowPager="True" Position="TopAndBottom">
                        <Summary AllPagesText="Pages: {0} - {1} ({2} Student(s))" Text="Page {0} of {1} ({2} Student(s))" />
                    </SettingsPager>
                    <SettingsEditing Mode="PopupEditForm">
                        <BatchEditSettings StartEditAction="Click" />
                    </SettingsEditing>
                    <Settings ShowFilterRow="True" />
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
                    <SettingsDataSecurity AllowInsert="False" />
                    <SettingsSearchPanel Visible="True" />
                    <Columns>
                        <dx:GridViewDataTextColumn Caption="Student No" FieldName="regno" ShowInCustomizationForm="True" VisibleIndex="2">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="StudentName" ShowInCustomizationForm="True" VisibleIndex="4">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="AllPages" ShowClearFilterButton="True" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Reg Status" FieldName="regstatus" ShowInCustomizationForm="True" VisibleIndex="8">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="REGISTERED" Value="REGISTERED" />
                                    <dx:ListEditItem Text="UNREGISTERED" Value="UNREGISTERED" />
                                    <dx:ListEditItem Text="HALTED" Value="HALTED" />
                                    <dx:ListEditItem Text="DEAD YEAR" Value="DEAD YEAR" />
                                    <dx:ListEditItem Text="DISCONTINUED" Value="DISCONTINUED" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Programme" FieldName="progid" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Reg No" FieldName="entryno" ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter"></asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsstudysessions" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_StudySessionsWithALL" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_Session" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="Session" Type="String" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Original_Session" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
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
                <asp:ObjectDataSource ID="dsStudentInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_SpecialisationList" TypeName="StudentDataTableAdapters.acad_studentTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_regno" Type="String" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="entryno" Type="String" />
                        <asp:Parameter Name="regno" Type="String" />
                        <asp:Parameter Name="firstname" Type="String" />
                        <asp:Parameter Name="dob" Type="DateTime" />
                        <asp:Parameter Name="gender" Type="String" />
                        <asp:Parameter Name="nationality" Type="String" />
                        <asp:Parameter Name="religion" Type="String" />
                        <asp:Parameter Name="entrymethod" Type="String" />
                        <asp:Parameter Name="progid" Type="String" />
                        <asp:Parameter Name="studPhone" Type="String" />
                        <asp:Parameter Name="email" Type="String" />
                        <asp:Parameter Name="entryyear" Type="Int32" />
                        <asp:Parameter Name="studsesion" Type="String" />
                        <asp:Parameter Name="home_dist" Type="String" />
                        <asp:Parameter Name="intake" Type="String" />
                        <asp:Parameter Name="gradSystemID" Type="Int32" />
                        <asp:Parameter Name="othername" Type="String" />
                        <asp:Parameter Name="duration" Type="UInt32" />
                        <asp:Parameter Name="photofile" Type="String" />
                        <asp:Parameter Name="specialisation" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtProgramme" DefaultValue="-" Name="prog" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtYear" DefaultValue="" Name="yr" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtSemester" DefaultValue="0" Name="sem" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txtAcadYear" Name="acadyr" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtIntake" Name="intak" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtSession" Name="sess" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txt_entry_year" Name="entyr" PropertyName="Value" Type="Int32" />
                        <asp:ControlParameter ControlID="txt_currentspecialisation" DefaultValue="0" Name="spec" PropertyName="Value" Type="String" />
                        <asp:ControlParameter ControlID="txtCampus" DefaultValue="" Name="campusno" PropertyName="Value" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="entryno" Type="String" />
                        <asp:Parameter Name="firstname" Type="String" />
                        <asp:Parameter Name="dob" Type="DateTime" />
                        <asp:Parameter Name="gender" Type="String" />
                        <asp:Parameter Name="nationality" Type="String" />
                        <asp:Parameter Name="religion" Type="String" />
                        <asp:Parameter Name="entrymethod" Type="String" />
                        <asp:Parameter Name="progid" Type="String" />
                        <asp:Parameter Name="studPhone" Type="String" />
                        <asp:Parameter Name="email" Type="String" />
                        <asp:Parameter Name="entryyear" Type="Int32" />
                        <asp:Parameter Name="studsesion" Type="String" />
                        <asp:Parameter Name="home_dist" Type="String" />
                        <asp:Parameter Name="intake" Type="String" />
                        <asp:Parameter Name="gradSystemID" Type="Int32" />
                        <asp:Parameter Name="othername" Type="String" />
                        <asp:Parameter Name="duration" Type="Int32" />
                        <asp:Parameter Name="specialisation" Type="String" />
                        <asp:Parameter Name="studCampus" Type="Int32" />
                        <asp:Parameter Name="StudentHall" Type="String" />
                        <asp:Parameter Name="Original_regno" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsSpecialisations" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_ProgramSpecialisations" TypeName="StudentDataTableAdapters.acad_specialisationTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_spec_id" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="prog_id" Type="String" />
                        <asp:Parameter Name="spec" Type="String" />
                        <asp:Parameter Name="abbrev" Type="String" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="" Name="prog_id" SessionField="prog" Type="String" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="prog_id" Type="String" />
                        <asp:Parameter Name="spec" Type="String" />
                        <asp:Parameter Name="abbrev" Type="String" />
                        <asp:Parameter Name="Original_spec_id" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <dx:ASPxLoadingPanel ID="lp_grads" runat="server" ClientInstanceName="lp_grads" Modal="True">
                </dx:ASPxLoadingPanel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton" Height="100px" Width="300px">
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
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
                <dx:ASPxPopupControl ID="pop_specialisations" runat="server" CloseAction="CloseButton" HeaderText="PROGRAMME SPECIALISATIONS" Height="400px" Modal="True" PopupElementID="btn_managespecialisations" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="800px">
                    
                    <HeaderStyle Font-Bold="True" ForeColor="#3366FF" HorizontalAlign="Center" />
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td>
                                        <dx:ASPxButton ID="btn_addspecialisation" runat="server" Height="30px" OnClick="btn_addspecialisation_Click" Text="Add Specialisation" Width="200px">
                                            <Image IconID="actions_add_16x16">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="gv_Specialisations" runat="server" AutoGenerateColumns="False" DataSourceID="dsSpecialisations" KeyFieldName="spec_id" OnCustomErrorText="gv_Specialisations_CustomErrorText" OnInitNewRow="gv_Specialisations_InitNewRow" OnRowInserting="gv_Specialisations_RowInserting" Width="100%" EnableCallBacks="False" OnRowInserted="gv_Specialisations_RowInserted">
                                            <SettingsPager AlwaysShowPager="True">
                                                <Summary AllPagesText="Pages: {0} - {1} ({2} Specialisation(s))" Text="Page {0} of {1} ({2}  Specialisation(s))" />
                                            </SettingsPager>
                                            <Columns>
                                                <dx:GridViewDataTextColumn Caption="SNo." FieldName="spec_id" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Width="50px">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Programme" FieldName="prog_id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Specialisation" FieldName="spec" ShowInCustomizationForm="True" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Abbreviation" FieldName="abbrev" ShowInCustomizationForm="True" VisibleIndex="3" Width="150px">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="4" Width="50px">
                                                </dx:GridViewCommandColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
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
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>