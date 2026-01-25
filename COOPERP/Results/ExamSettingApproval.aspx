<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="ExamSettingApproval.aspx.cs" Inherits="COOPERP_Timetables_ExamSettingApproval" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
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
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_exams_setting.png" >
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
                                            <td class="auto-style12" style="width: 95px">Faculty:</td>
                                            <td class="auto-style13" style="width: 402px">
                                                <dx:ASPxComboBox ID="txtFaculty" runat="server" AutoPostBack="True" DataSourceID="dsFaculties" SelectedIndex="0" TextField="faculty_name" TextFormatString="{0} - {1}" ValueField="fax_code" Width="300px" Height="30px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="fax_code" Width="50px" />
                                                        <dx:ListBoxColumn Caption="Faculty" FieldName="faculty_name" Width="300px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="sidebar_item" style="width: 81px">Exam Status:</td>
                                            <td class="auto-style15">
                                                <dx:ASPxComboBox ID="txtStatus" runat="server" AutoPostBack="True" SelectedIndex="1" Height="30px" OnSelectedIndexChanged="txtStatus_SelectedIndexChanged">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="CREATED" Value="CREATED" />
                                                        <dx:ListEditItem Selected="True" Text="SUBMITTED" Value="SUBMITTED" />
                                                         <dx:ListEditItem Text="FOR REVIEW" Value="FOR REVIEW" />
                                                        <dx:ListEditItem Text="APPROVED" Value="APPROVED" />
                                                        <dx:ListEditItem Text="PRINTED" Value="PRINTED" />
                                                        <%--<dx:ListEditItem Text="REJECTED" Value="REJECTED" />--%>
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style12" style="width: 95px">Programme:</td>
                                            <td class="auto-style13" style="width: 402px">
                                                <dx:ASPxComboBox ID="txtProgramme" runat="server" AutoPostBack="True" DataSourceID="dsProgrammes" Height="30px" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="300px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="80px" />
                                                        <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="sidebar_item" style="width: 81px">&nbsp;</td>
                                            <td class="auto-style15">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style16" style="width: 95px">Academic Year:</td>
                                            <td class="auto-style17" style="width: 402px">
                                                <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Width="300px" Height="30px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="sidebar_item" style="width: 81px"></td>
                                            <td class="auto-style19">
                                                <%--<dx:ASPxButton ID="cmdApprove" runat="server" OnClick="cmdApprove_Click" Text="Approvals" Width="170px" Height="30px">
                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                    </Image>
                                                </dx:ASPxButton>--%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8" style="width: 95px">Semester:</td>
                                            <td class="auto-style10" style="width: 402px">
                                                <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" SelectedIndex="0" Width="300px" Height="30px">
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="sidebar_item" style="width: 81px">&nbsp;</td>
                                            <td>
                                               
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8" style="width: 95px">Campus:</td>
                                            <td class="auto-style10" style="width: 402px">
                                                <dx:ASPxComboBox ID="txtCampus" runat="server" AutoPostBack="True" DataSourceID="dsCampus" TextField="campus_name" TextFormatString="{0} :: {1}" ValueField="ID" ValueType="System.Int32" Width="300px" SelectedIndex="0" Height="30px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="50px" />
                                                        <dx:ListBoxColumn Caption="Campus Name" FieldName="campus_name" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="sidebar_item" style="width: 81px">&nbsp;</td>
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
                            <SettingsBehavior AllowFocusedRow="True" AllowSelectSingleRowOnly="True" ConfirmDelete="True" />
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="empCode" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Code" FieldName="courseID" ShowInCustomizationForm="True" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="acad_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="semester" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="prog_id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Study Year" FieldName="cyear" ShowInCustomizationForm="True" VisibleIndex="4" Width="50px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Session" FieldName="stud_session" ShowInCustomizationForm="True" VisibleIndex="11">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="sheet_status" Visible="False" VisibleIndex="21" Caption="Sheet Status">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="Course_Name" VisibleIndex="3" Caption="Course Name">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="emp_name" ShowInCustomizationForm="True" VisibleIndex="22" Caption="Staff Name">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Created" FieldName="dateCreated" ShowInCustomizationForm="True" VisibleIndex="24" Width="100px">
                                    <PropertiesDateEdit DisplayFormatString="dd-MMM-yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataDateColumn Caption="Submitted" FieldName="dateSubmitted" ShowInCustomizationForm="True" VisibleIndex="25" Width="100px">
                                    <PropertiesDateEdit DisplayFormatString="dd-MMM-yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn FieldName="intake" ShowInCustomizationForm="True" VisibleIndex="6" Caption="Intake">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="Details" ShowInCustomizationForm="True" VisibleIndex="27" Width="40px" Name="Detail">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdDetails" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="cmdDetails_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="EntryYear" VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="CampusId" Visible="False" VisibleIndex="29">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="approved_by" VisibleIndex="26" Caption="Approved By" Width="100px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="exam_candidates" VisibleIndex="23" Caption="Candidates" Width="50px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Print Exam" Name="Print" VisibleIndex="28" Width="30px" Visible="False">
                                    <EditFormSettings Visible="False" />
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="btn_print" runat="server" ImageUrl="~/COOPERP/images/printer.png" OnClick="btn_print_Click" />
                                    </DataItemTemplate>
                                    <HeaderStyle HorizontalAlign="Center" />
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
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
                        <asp:ObjectDataSource ID="dsMarksheetInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ExamSettingTableAdapters.acad_GetFacultyExaminationPapersTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtProgramme" Name="prog" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acadyr" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtCampus" DefaultValue="" Name="campusno" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtStatus" Name="stat" PropertyName="Value" Type="String" DefaultValue="SUBMITTED" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsFaculties" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetUserFaculties" TypeName="SecurityTableAdapters.my_aspnet_user_facultiesTableAdapter">
                            <SelectParameters>
                                <asp:SessionParameter Name="unm" SessionField="username" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.myaspnet_GetMyProgrammesTableAdapter">
                            <SelectParameters>
                                <asp:SessionParameter DefaultValue="-" Name="usr" SessionField="username" Type="String" />
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
                        <dx:ASPxPopupControl ID="pop_print" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton">
                            <ClientSideEvents CloseUp="function(s, e) {
gvMarksheetInfo.Refresh();	
}" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
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
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton">
                            <ClientSideEvents CloseUp="function(s, e) {
gvMarksheetInfo.Refresh();	
}" />
                            <HeaderStyle Font-Bold="True" ForeColor="Red" HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
        
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
</asp:Content>

