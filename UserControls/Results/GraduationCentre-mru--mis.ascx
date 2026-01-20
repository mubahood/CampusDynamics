<%@ Control Language="C#" AutoEventWireup="true" CodeFile="GraduationCentre.ascx.cs" Inherits="UserControls_Results_GraduationCentre" %>
<%@ Register src="ResultsProblems.ascx" tagname="ResultsProblems" tagprefix="uc1" %>
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
    .auto-style3 {
        width: 103px;
    }
    .auto-style5 {
        width: 78px;
    }
    .auto-style6 {
        width: 360px;
    }
    .auto-style7 {
        width: 165px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table class="style1">
                <tr>
                    <td>
                        <table cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_graduation.png">
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
                                <td>
                                    <table class="style1">
                                        <tr>
                                            <td class="auto-style5">Faculty:</td>
                                            <td class="auto-style6">
                                                <dx:ASPxComboBox ID="txtFaculty" runat="server" DataSourceID="dsFaculties" SelectedIndex="0" TextField="faculty_name" TextFormatString="{2} - {1}" ValueField="faculty_code" Width="350px" AutoPostBack="True" Height="35px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
txtprog.SetText(&quot; &quot;);		
}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="faculty_code" />
                                                        <dx:ListBoxColumn Caption="Faculty" FieldName="faculty_name" Width="250px" />
                                                        <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style3">Entry Year:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txt_entry_year" runat="server" AutoPostBack="True" Height="35px">
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5">Programme:</td>
                                            <td class="auto-style6">
                                                <dx:ASPxComboBox ID="txtProgramme" runat="server" AutoPostBack="True" ClientInstanceName="txtprog" DataSourceID="dsProgrammes" Height="35px" OnSelectedIndexChanged="txtProgramme_SelectedIndexChanged" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="350px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
lp_grads.Show();
	}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="progcode" />
                                                        <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                                        <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style3">Academic Year:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Height="35px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
lp_grads.Show();

	}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5">Intake:</td>
                                            <td class="auto-style6">
                                                <dx:ASPxComboBox ID="txtIntake" runat="server" AutoPostBack="True" Height="35px" Width="350px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	lp_grads.Show();

}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style3">Study Year:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtYear" runat="server" SelectedIndex="2" AutoPostBack="True" Height="35px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	lp_grads.Show();

}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Selected="True" Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5">&nbsp;</td>
                                            <td class="auto-style6">
                                                <dx:ASPxButton ID="cmdApprove" runat="server" Height="35px" OnClick="cmdApprove_Click" Text="Add Graduand[s]" Width="350px">
                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Are you Sure?');
}" />
                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td class="auto-style3">Semester:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="1">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	lp_grads.Show();

}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="1" Value="1" />
                                                        <dx:ListEditItem Selected="True" Text="2" Value="2" />
                                                        <dx:ListEditItem Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5">&nbsp;</td>
                                            <td class="auto-style6">
                                                <table cellspacing="0" class="style1">
                                                    <tr>
                                                        <td class="auto-style7">
                                                            <dx:ASPxButton ID="cmdExportExcel" runat="server" OnClick="cmdExportExcel_Click" Text="Export Excel" Width="175px" Height="35px">
                                                                <Image Url="~/COOPERP/images/export_excel.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" Text="Print List" Width="173px" Height="35px">
                                                                <Image Url="~/COOPERP/images/printer.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td class="auto-style3">List Status:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtStatus" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="1">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	lp_grads.Show();

}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="ALL" Value="ALL" />
                                                        <dx:ListEditItem Text="GRADUANDS" Value="GRAD" Selected="True" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5">&nbsp;</td>
                                            <td class="auto-style6">
                                                <dx:ASPxButton ID="cmdAddDates" runat="server" AutoPostBack="False" Height="35px" Text="Add Graduation Dates" Width="350px">
                                                    <ClientSideEvents Click="function(s, e) {
}" />
                                                    <Image IconID="conditionalformatting_adateoccurring_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td class="auto-style3">Print Grad Date:</td>
                                            <td>
                                                <dx:ASPxDateEdit ID="txtPrintGradDate" runat="server" DisplayFormatString="dd MMMM, yyyy" Height="35px" Width="170px">
                                                </dx:ASPxDateEdit>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="text-align: right" valign="bottom" width="170px">
                                    <dx:ASPxTextBox ID="txtSearch" runat="server" AutoCompleteType="Search" Height="27px" NullText="Enter Search Text" Width="170px" ClientVisible="False">
                                        <ClientSideEvents TextChanged="function(s, e) {
	gvMarksheetInfo.Refresh();
}" />
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxTextBox>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheetInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheetInfo" DataSourceID="dsMarksheetInfo" KeyFieldName="regno" Width="100%">
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="Student Number" FieldName="regno" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Student" FieldName="stud_name" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Completion Status" FieldName="comp" VisibleIndex="6">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Total Credits" FieldName="credits" VisibleIndex="8" Width="50px">
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="CGPA" FieldName="cgpa" VisibleIndex="9" Width="50px">
                                    <PropertiesTextEdit DisplayFormatString="{0:0.00}">
                                    </PropertiesTextEdit>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="AwardClass" VisibleIndex="10">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="Pending" VisibleIndex="13" Width="25px" Name="pending">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdProbs" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="cmdProbs_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Profile" VisibleIndex="14" Width="25px">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdProbs" runat="server" ImageUrl="~/COOPERP/images/card-address.png" OnClick="cmdProfile_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Alignment" VisibleIndex="12" Width="25px">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdAlign" runat="server" ImageUrl="~/COOPERP/images/clipboard-task.png" OnClick="cmdAlign_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Reg Number" FieldName="entryno" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Graduation Date" FieldName="grad_date" VisibleIndex="11">
                                    <PropertiesDateEdit DisplayFormatString="{0:dd-MMM-yyyy}">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataDateColumn Caption="Completion Date" FieldName="comp_date" VisibleIndex="7">
                                    <PropertiesDateEdit DisplayFormatString="{0:dd-MMM-yyyy}">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Phone No." FieldName="studPhone" VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Gender" FieldName="gen" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsPager PageSize="50" AlwaysShowPager="True" Position="TopAndBottom">
                            </SettingsPager>
                            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridViewExporter ID="GVE_Marksheets" runat="server" GridViewID="gvMarksheetInfo">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsMarksheetInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_GraduationData" TypeName="ResultsDataTableAdapters.acad_Get_GraduationCompletionDataTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtProgramme" Name="prog" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtStatus" Name="cat" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtPrintGradDate" Name="gdt" PropertyName="Value" Type="DateTime" />
                                <asp:ControlParameter ControlID="txtSemester" Name="sems" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtIntake" Name="intk" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txt_entry_year" Name="entyr" PropertyName="Value" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetProgrammesByFaculty" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_progcode" Type="String" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="progcode" Type="String" />
                                <asp:Parameter Name="progname" Type="String" />
                                <asp:Parameter Name="mincredit" Type="Double" />
                                <asp:Parameter Name="abbrev" Type="String" />
                                <asp:Parameter Name="couselength" Type="Double" />
                                <asp:Parameter Name="maxduration" Type="Double" />
                                <asp:Parameter Name="faculty_code" Type="String" />
                                <asp:Parameter Name="levelCode" Type="UInt32" />
                                <asp:Parameter Name="study_system" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtFaculty" Name="faculty_code" PropertyName="Value" Type="String" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="progname" Type="String" />
                                <asp:Parameter Name="mincredit" Type="Double" />
                                <asp:Parameter Name="abbrev" Type="String" />
                                <asp:Parameter Name="couselength" Type="Double" />
                                <asp:Parameter Name="maxduration" Type="Double" />
                                <asp:Parameter Name="faculty_code" Type="String" />
                                <asp:Parameter Name="levelCode" Type="UInt32" />
                                <asp:Parameter Name="study_system" Type="String" />
                                <asp:Parameter Name="Original_progcode" Type="String" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsFaculties" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_facultyTableAdapter" UpdateMethod="Update">
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
                                <asp:Parameter Name="faculty_dean" Type="String" />
                                <asp:Parameter Name="faculty_contacts" Type="String" />
                                <asp:Parameter Name="abbrev" Type="String" />
                                <asp:Parameter Name="Original_faculty_code" Type="String" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <dx:ASPxLoadingPanel ID="lp_grads" runat="server" ClientInstanceName="lp_grads" Modal="True">
                        </dx:ASPxLoadingPanel>
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
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <uc1:ResultsProblems ID="ResultsProblems1" runat="server" />
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_set_gradinfo" runat="server" HeaderText="Graduation Info Settings" Modal="True" PopupElementID="cmdAddDates" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                            <ContentStyle>
                                <Paddings Padding="30px" />
                            </ContentStyle>
                            <HeaderStyle HorizontalAlign="Center">
                            <Paddings Padding="10px" />
                            </HeaderStyle>
                            <ModalBackgroundStyle BackColor="Black">
                            </ModalBackgroundStyle>
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
                                            <td>Completion Date:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxDateEdit ID="txtCompDate" runat="server" Date="07/27/2017 16:15:53" DisplayFormatString="dd MMMM, yyyy" Height="35px" Width="100%">
                                                </dx:ASPxDateEdit>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Graduation Date:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxDateEdit ID="txtGradDate" runat="server" Date="07/27/2017 16:15:53" DisplayFormatString="dd MMMM, yyyy" Height="35px" Width="100%">
                                                </dx:ASPxDateEdit>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Convocation Title:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxTextBox ID="txtConvocation" runat="server" Height="35px" NullText="eg MRU 17th Congregation" Width="100%">
                                                </dx:ASPxTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="cmdSetGraduationInfo" runat="server" Height="35px" OnClick="cmdSetGraduationInfo_Click" Text="Set Graduation Info" Width="100%">
                                                    <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Update Graduation Info?');
if(e.processOnServer)
{
	lp_loadingsettings.Show();
}
}" />
                                                    <Image IconID="content_checkbox_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <br />
                                                <dx:ASPxLoadingPanel ID="lp_loadingsettings" runat="server" ClientInstanceName="lp_loadingsettings" Modal="True" Text="Processing&amp;hellip;">
                                                </dx:ASPxLoadingPanel>
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
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="cmdExportExcel" />
        </Triggers>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>