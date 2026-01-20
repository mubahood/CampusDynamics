<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ElectronicSheets.ascx.cs" Inherits="UserControls_Results_ElectronicSheets" %>
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
        width: 110px;
        height: 38px;
    }
    .auto-style17 {
        width: 317px;
        height: 38px;
    }
    .auto-style18 {
        width: 84px;
        height: 38px;
    }
    .auto-style19 {
        height: 38px;
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
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_marksheet_info.png" >
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
                                <td>
                                    <table class="style1">
                                        <tr>
                                            <td class="auto-style12">Faculty:</td>
                                            <td class="auto-style13">
                                                <dx:ASPxComboBox ID="txtFaculty" runat="server" AutoPostBack="True" DataSourceID="dsFaculties" SelectedIndex="0" TextField="faculty_name" TextFormatString="{0} - {1}" ValueField="fax_code" Width="300px" Height="30px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="fax_code" Width="50px" />
                                                        <dx:ListBoxColumn Caption="Faculty" FieldName="faculty_name" Width="300px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style14">Sheet Status:</td>
                                            <td class="auto-style15">
                                                <dx:ASPxComboBox ID="txtStatus" runat="server" AutoPostBack="True" SelectedIndex="1" Height="30px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="PENDING" Value="NEW" />
                                                        <dx:ListEditItem Selected="True" Text="SUBMITTED" Value="SUBMITTED" />
                                                        <dx:ListEditItem Text="APPROVED" Value="APPROVED" />
                                                        <dx:ListEditItem Text="CAPTURED" Value="CAPTURED" />
                                                        <%--<dx:ListEditItem Text="REJECTED" Value="REJECTED" />--%>
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style16">Academic Year:</td>
                                            <td class="auto-style17">
                                                <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Width="300px" Height="30px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style18"></td>
                                            <td class="auto-style19">
                                                <%--<dx:ASPxButton ID="cmdApprove" runat="server" OnClick="cmdApprove_Click" Text="Approvals" Width="170px" Height="30px">
                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                    </Image>
                                                </dx:ASPxButton>--%>
                                                 <dx:ASPxButton ID="cmdExportExcel" runat="server" OnClick="cmdExportExcel_Click" Text="Export Excel" Width="170px" Height="30px">
                                                    <Image Url="~/COOPERP/images/export_excel.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8">Semester:</td>
                                            <td class="auto-style10">
                                                <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" SelectedIndex="0" Width="300px" Height="30px">
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style11">&nbsp;</td>
                                            <td>
                                               
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8">Campus:</td>
                                            <td class="auto-style10">
                                                <dx:ASPxComboBox ID="txtCampus" runat="server" AutoPostBack="True" DataSourceID="dsCampus" TextField="campus_name" TextFormatString="{0} :: {1}" ValueField="ID" ValueType="System.Int32" Width="300px" SelectedIndex="0" Height="30px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="50px" />
                                                        <dx:ListBoxColumn Caption="Campus Name" FieldName="campus_name" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style11">&nbsp;</td>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="text-align: right" valign="bottom" width="170px">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheetInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheetInfo" DataSourceID="dsMarksheetInfo" KeyFieldName="ID" Width="100%">
                            <SettingsPager AlwaysShowPager="True" Position="TopAndBottom">
                            </SettingsPager>
                            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowFilterRowMenuLikeItem="True" />
                            <SettingsBehavior AllowFocusedRow="True" AllowSelectSingleRowOnly="True" ConfirmDelete="True" />
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="empCode" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Code" FieldName="courseID" ShowInCustomizationForm="True" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="acad_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="semester" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="prog_id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Study Year" FieldName="cyear" ShowInCustomizationForm="True" VisibleIndex="5" Width="50px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Session" FieldName="stud_session" ShowInCustomizationForm="True" VisibleIndex="13">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q1" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q2" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q3" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q4" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q5" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q6" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q7" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q8" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q9" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="max_Q10" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Sheet Status" FieldName="sheet_status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="24">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Course Name" FieldName="course_name" ShowInCustomizationForm="True" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Staff Name" FieldName="emp_name" ShowInCustomizationForm="True" VisibleIndex="25">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Class" FieldName="classname" ShowInCustomizationForm="True" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Created" FieldName="dateCreated" ShowInCustomizationForm="True" VisibleIndex="26" Width="100px">
                                    <PropertiesDateEdit DisplayFormatString="dd-MMM-yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataDateColumn Caption="Submitted" FieldName="dateSubmitted" ShowInCustomizationForm="True" VisibleIndex="27" Width="100px">
                                    <PropertiesDateEdit DisplayFormatString="dd-MMM-yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Intake" FieldName="intake" ShowInCustomizationForm="True" VisibleIndex="8">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Stream" FieldName="stream" ShowInCustomizationForm="True" VisibleIndex="6">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="Details" ShowInCustomizationForm="True" VisibleIndex="29" Width="40px">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdDetails" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="cmdDetails_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="EntryYear" VisibleIndex="7">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="CampusId" Visible="False" VisibleIndex="30">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="practical_percent" Visible="False" VisibleIndex="31">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="ExamFormat" Visible="False" VisibleIndex="32">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="CW No." FieldName="courseworkentries" VisibleIndex="28" Width="50px">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridViewExporter ID="GVE_Marksheets" runat="server" ExportedRowType="All" GridViewID="gvMarksheetInfo">
                        </dx:ASPxGridViewExporter>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsMarksheetInfo" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSheetsByFaculty" TypeName="ResultsDataTableAdapters.acad_examsettingsTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="empCode" Type="String" />
                                <asp:Parameter Name="courseID" Type="String" />
                                <asp:Parameter Name="acad_year" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="prog_id" Type="String" />
                                <asp:Parameter Name="cyear" Type="UInt32" />
                                <asp:Parameter Name="EntryYear" Type="Int32" />
                                <asp:Parameter Name="stud_session" Type="String" />
                                <asp:Parameter Name="max_Q1" Type="Double" />
                                <asp:Parameter Name="max_Q2" Type="Double" />
                                <asp:Parameter Name="max_Q3" Type="Double" />
                                <asp:Parameter Name="max_Q4" Type="Double" />
                                <asp:Parameter Name="max_Q5" Type="Double" />
                                <asp:Parameter Name="max_Q6" Type="Double" />
                                <asp:Parameter Name="max_Q7" Type="Double" />
                                <asp:Parameter Name="max_Q8" Type="Double" />
                                <asp:Parameter Name="max_Q9" Type="Double" />
                                <asp:Parameter Name="max_Q10" Type="Double" />
                                <asp:Parameter Name="sheet_status" Type="String" />
                                <asp:Parameter Name="dateCreated" Type="DateTime" />
                                <asp:Parameter Name="dateSubmitted" Type="DateTime" />
                                <asp:Parameter Name="intake" Type="String" />
                                <asp:Parameter Name="stream" Type="String" />
                                <asp:Parameter Name="exam_percent" Type="Double" />
                                <asp:Parameter Name="cw_percent" Type="Double" />
                                <asp:Parameter Name="final_total" Type="UInt32" />
                                <asp:Parameter Name="CampusId" Type="UInt32" />
                                <asp:Parameter Name="practical_percent" Type="Double" />
                                <asp:Parameter Name="ExamFormat" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtFaculty" Name="fax" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="Int32" />
                                <asp:Parameter DefaultValue="-" Name="txt" Type="String" />
                                <asp:ControlParameter ControlID="txtStatus" Name="stat" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtCampus" DefaultValue="" Name="campusno" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="empCode" Type="String" />
                                <asp:Parameter Name="courseID" Type="String" />
                                <asp:Parameter Name="acad_year" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="prog_id" Type="String" />
                                <asp:Parameter Name="cyear" Type="UInt32" />
                                <asp:Parameter Name="EntryYear" Type="Int32" />
                                <asp:Parameter Name="stud_session" Type="String" />
                                <asp:Parameter Name="max_Q1" Type="Double" />
                                <asp:Parameter Name="max_Q2" Type="Double" />
                                <asp:Parameter Name="max_Q3" Type="Double" />
                                <asp:Parameter Name="max_Q4" Type="Double" />
                                <asp:Parameter Name="max_Q5" Type="Double" />
                                <asp:Parameter Name="max_Q6" Type="Double" />
                                <asp:Parameter Name="max_Q7" Type="Double" />
                                <asp:Parameter Name="max_Q8" Type="Double" />
                                <asp:Parameter Name="max_Q9" Type="Double" />
                                <asp:Parameter Name="max_Q10" Type="Double" />
                                <asp:Parameter Name="sheet_status" Type="String" />
                                <asp:Parameter Name="dateCreated" Type="DateTime" />
                                <asp:Parameter Name="dateSubmitted" Type="DateTime" />
                                <asp:Parameter Name="intake" Type="String" />
                                <asp:Parameter Name="stream" Type="String" />
                                <asp:Parameter Name="exam_percent" Type="Double" />
                                <asp:Parameter Name="cw_percent" Type="Double" />
                                <asp:Parameter Name="final_total" Type="UInt32" />
                                <asp:Parameter Name="CampusId" Type="UInt32" />
                                <asp:Parameter Name="practical_percent" Type="Double" />
                                <asp:Parameter Name="ExamFormat" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsFaculties" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetUserFaculties" TypeName="SecurityTableAdapters.my_aspnet_user_facultiesTableAdapter">
                            <SelectParameters>
                                <asp:SessionParameter Name="unm" SessionField="username" Type="String" />
                            </SelectParameters>
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
                        &nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton">
                            <ClientSideEvents CloseUp="function(s, e) {
gvMarksheetInfo.Refresh();	
}" />
                            <HeaderStyle Font-Bold="True" ForeColor="Red" HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
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