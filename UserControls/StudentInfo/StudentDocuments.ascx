<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentDocuments.ascx.cs" Inherits="UserControls_StudentInfo_StudentDocuments" %>
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
    .auto-style4 {
        width: 194px;
    }
    .auto-style5 {
        width: 95px;
    }
    .auto-style6 {
        width: 353px;
    }
    .auto-style7 {
        width: 65px;
    }
    .auto-style8 {
        width: 29px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <table class="style1">
        <tr>
            <td colspan="7">
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_studentdocs.png">
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
            <td colspan="7">
                &nbsp;</td>
        </tr>
        <tr>
            <td colspan="7">
                <table class="style1">
                    <tr>
                        <td>
                            <table class="style1">
                                <tr>
                                    <td class="auto-style5">Faculty:</td>
                                    <td class="auto-style6">
                                        <dx:ASPxComboBox ID="txtFaculty" runat="server" DataSourceID="dsFaculties" SelectedIndex="0" TextField="faculty_name" TextFormatString="{1} - {0}" ValueField="faculty_code" AutoPostBack="True" Width="300px" Height="30px">
                                            <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Code" FieldName="faculty_code" />
                                                <dx:ListBoxColumn Caption="Faculty" FieldName="faculty_name" Width="250px" />
                                                <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style3">Academic Year:</td>
                                    <td class="auto-style4">
                                        <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Height="30px">
                                            <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style5">Programme:</td>
                                    <td class="auto-style6">
                                        <dx:ASPxComboBox ID="txtProgramme" runat="server" AutoPostBack="True" DataSourceID="dsProgramme" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="300px" Height="30px">
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="50px" />
                                                <dx:ListBoxColumn Caption="Programme Name" FieldName="progname" Width="200px" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style3">Semester:</td>
                                    <td class="auto-style4">
                                        <dx:ASPxComboBox ID="txtSemester" runat="server" SelectedIndex="0" AutoPostBack="True" Height="30px">
                                            <Items>
                                                <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                <dx:ListEditItem Text="2" Value="2" />
                                                <dx:ListEditItem Text="3" Value="3" />
                                                <dx:ListEditItem Text="4" Value="4" />
                                            </Items>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style5">Session:</td>
                                    <td class="auto-style6">
                                        <dx:ASPxComboBox ID="txtSession" runat="server" AutoPostBack="True" SelectedIndex="0" Width="300px" Height="30px" DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                            <Columns>
                                                <dx:ListBoxColumn FieldName="Session" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style3">Nationality:</td>
                                    <td class="auto-style4">
                                        <dx:ASPxComboBox ID="txtNationality" runat="server" AutoPostBack="True" DataSourceID="ds_nationality" SelectedIndex="0" TextField="country_name" TextFormatString="{0}" ValueField="country_name" Height="30px">
                                            <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Nationality" FieldName="country_name" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style5">Campus:</td>
                                    <td class="auto-style6">
                                        <dx:ASPxComboBox ID="txtCampus" runat="server" AutoPostBack="True" DataSourceID="dsCampus" Height="30px" TextField="campus_name" TextFormatString="{0} :: {1}" ValueField="ID" ValueType="System.Int32" Width="300px">
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="50px" />
                                                <dx:ListBoxColumn Caption="Campus Name" FieldName="campus_name" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style3">Intake:</td>
                                    <td class="auto-style4">
                                        <dx:ASPxComboBox ID="txtIntake" runat="server" SelectedIndex="8" Width="170px" Height="30px">
                                            <ClientSideEvents SelectedIndexChanged="function(s, e) {
	callback_applications.PerformCallback(&quot;EntryYearChange&quot;);
}" />
                                            <Items>
                                                <dx:ListEditItem Text="-" Value="-" />
                                                <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                                <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                                <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                                <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                                <dx:ListEditItem Text="MAY" Value="MAY" />
                                                <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                                <dx:ListEditItem Text="JULY" Value="JULY" />
                                                <dx:ListEditItem Selected="True" Text="AUGUST" Value="AUGUST" />
                                                <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                                <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                                <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                                <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                            </Items>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style5">List Type:</td>
                                    <td class="auto-style6">
                                        <dx:ASPxComboBox ID="txt_Doctype" runat="server" AutoPostBack="True" Height="30px" SelectedIndex="0" Width="300px">
                                            <Items>
                                                <dx:ListEditItem Selected="True" Text="Lecture Attendance List" Value="REGISTERED" />
                                                <dx:ListEditItem Text="General List" Value="GENERAL" />
                                            </Items>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style3">Entry Year:</td>
                                    <td class="auto-style4">
                                        <dx:ASPxComboBox ID="txt_entry_year" runat="server" AutoPostBack="True" Height="30px" Width="170px">
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style5">&nbsp;</td>
                                    <td class="auto-style6">
                                        <dx:ASPxButton ID="cmdPrintList" runat="server" OnClick="cmdPrintList_Click" Text="Print List" Width="300px">
                                            <Image Url="~/COOPERP/images/printer.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                    <td class="auto-style3">&nbsp;</td>
                                    <td class="auto-style4">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                            </table>
                        </td>
                       
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="auto-style8">
                &nbsp;</td>
            <td class="auto-style7">&nbsp;</td>
            <td class="auto-style7">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td colspan="7">
                &nbsp;</td>
        </tr>
        <tr>
            <td colspan="7">
                <asp:ObjectDataSource ID="dsFaculties" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_facultyTableAdapter"></asp:ObjectDataSource>
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
                <asp:ObjectDataSource ID="dsProgramme" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="SecurityTableAdapters.myaspnet_GetMyProgrammesTableAdapter">
                    <SelectParameters>
                        <asp:SessionParameter DefaultValue="-" Name="usr" SessionField="username" Type="String" />
                    </SelectParameters>
                </asp:ObjectDataSource>
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
                <asp:ObjectDataSource ID="ds_nationality" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.nationalitiesTableAdapter" UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td colspan="7">
                &nbsp;</td>
        </tr>
        <tr>
            <td colspan="7">
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <ContentCollection>
                        <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>