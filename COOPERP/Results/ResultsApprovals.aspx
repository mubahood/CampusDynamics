<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="ResultsApprovals.aspx.cs" Inherits="COOPERP_Results_ResultsApprovals" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
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
            width: 100%;
        }
        .auto-style17 {
            width: 1102px;
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
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_resultsupdates.png" >
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
                       <%-- <table class="style1">
                            <tr>
                                <td>--%>
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
                                            <td class="auto-style14">&nbsp;</td>
                                            <td class="auto-style15" colspan="2">
                                                &nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style8">Academic Year:</td>
                                            <td class="auto-style10">
                                                <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Width="300px" Height="30px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style11">&nbsp;</td>
                                            <td colspan="2">
                                                &nbsp;</td>
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
                                            <td colspan="2">
                                                &nbsp;</td>
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
                                            <td align="right" class="auto-style17">
                                                <dx:ASPxButton ID="cmdUpdateSessions" runat="server" Height="35px" OnClick="cmdUpdateSessions_Click" Text="Update Study Session" ToolTip="Click to Access Platform to Update Study Session to the Selected Programmes" Width="170px">
                                                    <Image IconID="data_editdatasource_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td align="right">
                                                <dx:ASPxButton ID="cmdApprove" runat="server" Height="35px" OnClick="cmdApprove_Click" Text="Change Release Status" ToolTip="Change the Status for the Selected Programmes" Width="170px">
                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                    </Image>
                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Change Publish Status for Results of the Selected group(s)?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }

}" />
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                    </table>
                               <%-- </td>
                                <td style="text-align: right" valign="bottom" width="170px">
                                    &nbsp;</td>
                            </tr>
                        </table>--%>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheetInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheetInfo" DataSourceID="dsApprovedResultsInfo" KeyFieldName="ID" Width="100%">
                            <SettingsPager Mode="ShowAllRecords">
                                <Summary AllPagesText="Pages: {0} - {1} ({2} Approved Programmes)" EmptyText="No Approved Results" Text="Page {0} of {1} ({2} Approved Programmes)" />
                            </SettingsPager>
                            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                            <SettingsBehavior AllowFocusedRow="True" />
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" Visible="False" VisibleIndex="1">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="acadyr" VisibleIndex="3" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="semester" Visible="False" VisibleIndex="4">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="intake" VisibleIndex="5" Caption="InTake">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="studysession" VisibleIndex="6" Caption="Study Session">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Year of Study" FieldName="studyyear" VisibleIndex="7">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="campus" VisibleIndex="9" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="AllPages" ShowSelectCheckbox="True" VisibleIndex="0" Width="20px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Release Status" FieldName="securitylevel" VisibleIndex="8">
                                    <PropertiesComboBox ValueType="System.Int32">
                                        <Items>
                                            <dx:ListEditItem Text="Not Released" Value="1" />
                                            <dx:ListEditItem Text="Released" Value="2" />
                                        </Items>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Programme" FieldName="progid" VisibleIndex="2">
                                    <PropertiesComboBox DataSourceID="dsProgrammeInfo" TextField="progname" TextFormatString="{1}" ValueField="progcode">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="progcode" />
                                            <dx:ListBoxColumn Caption="Name" FieldName="progname" />
                                        </Columns>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsApprovedResultsInfo" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_ApprovedResults" TypeName="ResultsDataTableAdapters.acad_results_securitylevelTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt64" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="progid" Type="String" />
                                <asp:Parameter Name="acadyr" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="intake" Type="String" />
                                <asp:Parameter Name="studysession" Type="String" />
                                <asp:Parameter Name="studyyear" Type="Int32" />
                                <asp:Parameter Name="campus" Type="Int32" />
                                <asp:Parameter Name="securitylevel" Type="UInt32" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acadyr" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtSemester" Name="semester" PropertyName="Value" Type="Int32" />
                                <asp:ControlParameter ControlID="txtFaculty" Name="faculty_code" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtCampus" Name="campus" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="progid" Type="String" />
                                <asp:Parameter Name="acadyr" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="intake" Type="String" />
                                <asp:Parameter Name="studysession" Type="String" />
                                <asp:Parameter Name="studyyear" Type="Int32" />
                                <asp:Parameter Name="campus" Type="Int32" />
                                <asp:Parameter Name="securitylevel" Type="UInt32" />
                                <asp:Parameter Name="Original_ID" Type="UInt64" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsFaculties" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetUserFaculties" TypeName="SecurityTableAdapters.my_aspnet_user_facultiesTableAdapter">
                            <SelectParameters>
                                <asp:SessionParameter Name="unm" SessionField="username" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsProgrammeInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter" UpdateMethod="Update">
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
                        <asp:ObjectDataSource ID="dsstudysessions" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update">
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
                        <dx:ASPxPopupControl ID="pop_sessionEditor" runat="server" DisappearAfter="10" HeaderText="Programme Study Sessions Editor" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                            <HeaderStyle HorizontalAlign="Center">
                            <Paddings Padding="10px" />
                            </HeaderStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <table class="style1">
                                                    <tr>
                                                        <td class="auto-style1"></td>
                                                    </tr>
                                                    <tr>
                                                        <td>Study Sessions</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxComboBox ID="txtSessions" runat="server" DataSourceID="dsstudysessions" Height="35px" NullText="Select Study Session.." SelectedIndex="0" TextField="Session" TextFormatString="{0}" ValueField="Session" Width="100%">
                                                                <Columns>
                                                                    <dx:ListBoxColumn FieldName="Session" Width="250px" />
                                                                </Columns>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdEditSessions" runat="server" Height="35px" OnClick="cmdEditSessions_Click" Text="Update Session" Width="100%">
                                                                <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('You are about to Update a Study Session to the Selected Programme(s), Are you Sure?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }

}" />
                                                                <Image IconID="edit_edit_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                                <br />
                                                <dx:ASPxLabel ID="lbl_session_comment" runat="server" ForeColor="Blue" style="font-weight: 700">
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
                        <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Text="Processing. Please wait&amp;hellip;">
                        </dx:ASPxLoadingPanel>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton">
                            <HeaderStyle Font-Bold="True" ForeColor="Red" HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                    <table class="auto-style16">
                                        <tr align="center">
                                            <td>
                                                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="#FF3300">
                                                </dx:ASPxLabel>
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
        
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
</asp:Content>

