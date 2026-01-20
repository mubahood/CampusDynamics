<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ResultsDocCentre.ascx.cs" Inherits="UserControls_Results_ResultsDocCentre" %>
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
    .auto-style11 {
        width: 89px;
        height: 25px;
    }
    .auto-style12 {
        width: 89px;
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
                                ImageUrl="~/COOPERP/images/header_marksheet_info.png">
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
                                    <td class="auto-style11">Programme:</td>
                                    <td class="auto-style8">
                                        <dx:ASPxComboBox ID="txtProgramme" runat="server" DataSourceID="dsProgrammes" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" IncrementalFilteringMode="Contains" Width="350px" Height="30px">
                                            <Columns>
                                                <dx:ListBoxColumn Caption="Code" FieldName="progcode" />
                                                <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                                <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" />
                                            </Columns>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style9">Academic Year:</td>
                                    <td class="auto-style10">
                                        <dx:ASPxComboBox ID="txtAcadYear" runat="server" Height="30px">
                                        </dx:ASPxComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style11">Study Year:</td>
                                    <td class="auto-style8">
                                        <dx:ASPxComboBox ID="txtYear" runat="server" SelectedIndex="0" Width="350px" Height="30px">
                                            <Items>
                                                <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                <dx:ListEditItem Text="2" Value="2" />
                                                <dx:ListEditItem Text="3" Value="3" />
                                                <dx:ListEditItem Text="4" Value="4" />
                                            </Items>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style9">Semester:</td>
                                    <td class="auto-style10">
                                        <dx:ASPxComboBox ID="txtSemester" runat="server" SelectedIndex="0" Height="30px" >
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
                                    <td class="auto-style11">Study Session:</td>
                                    <td class="auto-style8">
                                        <dx:ASPxComboBox ID="txtSession" runat="server" AutoPostBack="True" DataSourceID="dsstudysessions" Height="30px" SelectedIndex="0" TextField="Session" TextFormatString="{0}" ValueField="Session" Width="350px">
                                            <Columns>
                                                <dx:ListBoxColumn FieldName="Session" />
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
                                    <td class="auto-style12">Document:</td>
                                    <td class="auto-style6">
                                        <dx:ASPxComboBox ID="txtDocument" runat="server" SelectedIndex="0" Width="350px" Height="30px">
                                            <Items>
                                                <dx:ListEditItem Selected="True" Text="Marksheet" Value="Marksheet" />
                                                <dx:ListEditItem Text="Graduation List" Value="GraduationLists" />
                                               <%-- <dx:ListEditItem Text="Provisional Marksheet" Value="Provisional Marksheet" />--%>
                                                <dx:ListEditItem Text="Redo Marksheet" Value="Redo Marksheet" />
                                                <dx:ListEditItem Text="Results Summary" Value="Results Summary" />
                                                 <dx:ListEditItem Text="Redo Results Summary" Value="Redo Results Summary" />
                                            </Items>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td class="auto-style3">Intake:</td>
                                    <td>
                                        <dx:ASPxComboBox ID="txtIntake" runat="server" SelectedIndex="0" Height="30px">
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
                                    <td class="auto-style12">&nbsp;</td>
                                    <td class="auto-style6">
                                        <dx:ASPxButton ID="cmdPrint" runat="server" Height="30px" OnClick="cmdPrint_Click" Text="Print Document" Width="350px">
                                            <ClientSideEvents Click="function(s, e) {
	lp_grads.Show();
}" />
                                            <Image Url="~/COOPERP/images/printer.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
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
                &nbsp;</td>
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
                <dx:ASPxLoadingPanel ID="lp_grads" runat="server" ClientInstanceName="lp_grads" Modal="True">
                </dx:ASPxLoadingPanel>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton">
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
                &nbsp;</td>
        </tr>
    </table>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>