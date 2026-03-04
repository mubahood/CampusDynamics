<%@ Control Language="C#" AutoEventWireup="true" CodeFile="TranscriptDocumentCentre.ascx.cs" Inherits="UserControls_Registry_TranscriptDocumentCentre" %>
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
    .auto-style6 {
        width: 360px;
    }
    .auto-style7 {
        width: 165px;
    }
    .auto-style9 {
        width: 106px;
    }
    .auto-style10 {
        width: 164px;
    }
    .auto-style11 {
        height: 121px;
    }
    .auto-style12 {
        height: 18px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <%--<asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>--%>
            <table class="style1">
                <tr>
                    <td>
                        <table cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_transcripts.png">
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
                                            <td class="auto-style9">Programme:</td>
                                            <td class="auto-style6">
                                                <dx:ASPxComboBox ID="txtProgramme" runat="server" DataSourceID="dsProgrammes" IncrementalFilteringMode="Contains" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="350px" AutoPostBack="True" Height="35px" OnSelectedIndexChanged="txtProgramme_SelectedIndexChanged">
                                                    <ClientSideEvents TextChanged="function(s, e) {
           lp_processing.Show();
}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="progcode" />
                                                        <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                                        <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style3">Academic Year:</td>
                                            <td class="auto-style10">
                                                <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" OnSelectedIndexChanged="txtAcadYear_SelectedIndexChanged" Height="35px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	 lp_processing.Show();
}" />
                                                    <Paddings PaddingLeft="5px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style9">&nbsp;</td>
                                            <td class="auto-style6">
                                                <dx:ASPxButton ID="cmdGradDate" runat="server" Height="35px" OnClick="cmdGradDate_Click" Text="Set Graduation Info" Width="350px">
                                                    <ClientSideEvents Click="function(s, e) {
	}" />
                                                    <Image Url="~/COOPERP/images/graduation-hat.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td class="auto-style3">Document Name:</td>
                                            <td class="auto-style10">
                                                <dx:ASPxComboBox ID="txtDocument" runat="server" AutoPostBack="True" SelectedIndex="0" OnSelectedIndexChanged="txtDocument_SelectedIndexChanged" Height="35px">
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="Single Transcript" Value="Single Transcript" />
                                                        <dx:ListEditItem Text="Single Certificate" Value="Single Certificate" />
                                                        <dx:ListEditItem Text="Batch Transcripts" Value="Batch Transcripts" />
                                                        <dx:ListEditItem Text="Batch Certificates" Value="Batch Certificates" />
                                                        <dx:ListEditItem Text="Basic Completion Letter" Value="Basic Completion Letter" />
                                                        <dx:ListEditItem Text="Single Completion Letter" Value="Single Completion Letter" />
                                                        <dx:ListEditItem Text="Batch Completion Letters" Value="Batch Completion Letters" />
                                                        <dx:ListEditItem Text="Masters Letter of Award" Value="Masters Letter of Award" />
                                                    </Items>
                                                    <Paddings PaddingLeft="5px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style9">&nbsp;</td>
                                            <td class="auto-style6">
                                                <table cellspacing="0" class="style1">
                                                    <tr>
                                                        <td class="auto-style7">
                                                            <dx:ASPxButton ID="cmdReverseStatus" runat="server" Height="35px" OnClick="cmdReverseStatus_Click" Text="Reverse Status" Width="174px">
                                                                <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Do you want to continue?');
if(e.processOnServer==true)
{
lp_processing.Show();
}

}" />
                                                                <Image Url="~/COOPERP/images/arrow-retweet.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdUpdateStatus" runat="server" Height="35px" OnClick="cmdUpdateStatus_Click" Text="Update Status" Width="174px">
                                                                <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Do you want to continue?');
if(e.processOnServer==true)
{
lp_processing.Show();
}

}" />
                                                                <Image Url="~/COOPERP/images/tick-button.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="auto-style7">
                                                            <dx:ASPxButton ID="cmdSetEntryType" runat="server" Height="35px" OnClick="cmdSetEntryType_Click" Text="Set Entry Type" Width="174px">
                                                                <ClientSideEvents Click="function(s, e) {
	}" />
                                                                <Image IconID="edit_edit_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td valign="top">
                                                            <dx:ASPxButton ID="cmdResultsSync" runat="server" Height="35px" Text="Results Sync" Width="174px" OnClick="cmdResultsSync_Click">
                                                                <Image IconID="scheduling_switchtimescalesto_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td class="auto-style3">&nbsp;</td>
                                            <td class="auto-style10" valign="top">
                                                <table cellspacing="1" class="style1">
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdPrint" runat="server" Height="35px" OnClick="cmdPrint_Click"  Text="Print Documents" Width="170px">
                                                                <Image Url="~/COOPERP/images/printer.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdTranscriptConfig" runat="server" Height="35px" OnClick="cmdTranscriptConfig_Click" Text="Create Transcripts" Width="170px">
                                                                <Image IconID="actions_insert_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style9">&nbsp;</td>
                                            <td class="auto-style6">&nbsp;</td>
                                            <td class="auto-style3">&nbsp;</td>
                                            <td class="auto-style10" valign="top">
                                                <dx:ASPxDateEdit ID="txtPrintGradDate" runat="server" DisplayFormatString="dd MMMM, yyyy" Height="35px" Visible="False" Width="170px">
                                                </dx:ASPxDateEdit>
                                            </td>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="text-align: right" valign="bottom" width="170px">
                                    &nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheetInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheetInfo" DataSourceID="dsMarksheetInfo" KeyFieldName="regno" Width="100%" OnHtmlDataCellPrepared="gvMarksheetInfo_HtmlDataCellPrepared">
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="Stud No" FieldName="regno" VisibleIndex="1" Width="80px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Student" FieldName="stud_name" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Completion Status" FieldName="comp" VisibleIndex="4" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Total Credits" FieldName="credits" VisibleIndex="5" Width="50px">
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="CGPA" FieldName="cgpa" VisibleIndex="6" Width="50px">
                                    <PropertiesTextEdit DisplayFormatString="{0:0.00}">
                                    </PropertiesTextEdit>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn FieldName="trans_status" VisibleIndex="7" Caption="Transcript Status" Width="60px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Printed By" FieldName="trans_printer" VisibleIndex="8" Width="60px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Print Date" FieldName="trans_date" VisibleIndex="9">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Certificate Status" FieldName="cert_status" VisibleIndex="10" Width="60px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Printed By" FieldName="cert_printer" VisibleIndex="11" Width="60px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Print Date" FieldName="cert_date" VisibleIndex="12">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Grad. Date" FieldName="grad_date" ShowInCustomizationForm="True" VisibleIndex="14" Width="80px">
                                    <PropertiesDateEdit DisplayFormatString="dd MMM, yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataDateColumn Caption="Comp. Date" FieldName="comp_date" ShowInCustomizationForm="True" VisibleIndex="13" Width="80px">
                                    <PropertiesDateEdit DisplayFormatString="dd MMM, yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Reg. Number" FieldName="entryno" ShowInCustomizationForm="True" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsPager Mode="ShowAllRecords" PageSize="50">
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
                        <asp:ObjectDataSource ID="dsMarksheetInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="ResultsDataTableAdapters.acad_Get_GraduationCompletionDataTableAdapter">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtProgramme" Name="prog" PropertyName="Value" Type="String" />
                                <asp:Parameter DefaultValue="0" Name="yr" Type="Int32" />
                                <asp:Parameter DefaultValue="GRAD" Name="cat" Type="String" />
                                <asp:ControlParameter ControlID="txtPrintGradDate" Name="gdt" PropertyName="Value" Type="DateTime" />
                                <asp:Parameter DefaultValue="1" Name="sems" Type="String" />
                                <asp:Parameter DefaultValue="-" Name="intk" Type="String" />
                            </SelectParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_ProgrammesOnly" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
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
                        <dx:ASPxLoadingPanel ID="lp_processing" runat="server" ClientInstanceName="lp_processing" Modal="True" Text="Processing&amp;hellip;">
                        </dx:ASPxLoadingPanel>
                    </td>
                </tr>
                <tr>
                    <td class="auto-style11">
                        <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <br />
                                                <br />
                                                <dx:ASPxLabel ID="lbl_msg" runat="server" ForeColor="Red" style="font-weight: 700">
                                                </dx:ASPxLabel>
                                                <br />
                                                <br />
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
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_create_transcripts" runat="server" HeaderText="Transcript Creator" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
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
                                            <td>Transcript Format:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxComboBox ID="txtTranscriptFormat" runat="server" DataSourceID="dsTransacriptFormats" Height="35px" SelectedIndex="0" TextField="format_title" TextFormatString="{0} - {1}" ValueField="ID" ValueType="System.Int32" Width="100%">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="50px" />
                                                        <dx:ListBoxColumn Caption="Course Name" FieldName="format_title" Width="250px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxRadioButtonList ID="rb_type" runat="server" AutoPostBack="True" Height="35px" OnSelectedIndexChanged="rb_type_SelectedIndexChanged" RepeatDirection="Horizontal" SelectedIndex="1" Width="100%">
                                                    <Items>
                                                        <dx:ListEditItem Text="Custom" Value="Custom" />
                                                        <dx:ListEditItem Selected="True" Text="Normal" Value="Normal" />
                                                    </Items>
                                                </dx:ASPxRadioButtonList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="cmdRefreshTranscript" runat="server" Height="35px" OnClick="cmdRefreshTranscript_Click" Text="Create Transcripts" Width="100%">
                                                    <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Create Selected Transcrips?');
if(e.processOnServer)
{
	lp_loading.Show();
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
                                                <asp:ObjectDataSource ID="dsTransacriptFormats" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetFormatsByProgramme" TypeName="TranscriptSetupDataTableAdapters.acad_transcript_formatTableAdapter">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="txtProgramme" DefaultValue="-" Name="prog" PropertyName="Value" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Modal="True" Text="Processing&amp;hellip;">
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
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_set_gradinfo" runat="server" HeaderText="Graduation Info Settings" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
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
                                            <td>Completioin Date:</td>
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
                                                <dx:ASPxTextBox ID="txtConvocation" runat="server" Height="35px" NullText="eg CIU 10th Congregation" Width="100%">
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
	lp_loading.Show();
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
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_set_entry_type" runat="server" HeaderText="Entry Type Update" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
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
                                            <td>Entry Type:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxComboBox ID="txtEntryMethod" runat="server" Height="35px" SelectedIndex="0" Width="100%">
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="A'LEVEL" Value="A'LEVEL" />
                                                        <dx:ListEditItem Text="BACHELORS DEGREE" Value="BACHELORS DEGREE" />
                                                        <dx:ListEditItem Text="CERTIFICATE" Value="CERTIFICATE" />
                                                        <dx:ListEditItem Text="DIPLOMA" Value="DIPLOMA" />
                                                        <dx:ListEditItem Text="HIGHER EDUC. CERT. (HEC)" Value="HIGHER EDUC. CERT. (HEC)" />
                                                        <dx:ListEditItem Text="MATURE" Value="MATURE" />
                                                        <dx:ListEditItem Text="O’LEVEL" Value="O’LEVEL" />
                                                        <dx:ListEditItem Text="SKILLING" Value="SKILLING" />
                                                    </Items>
                                                    <Paddings PaddingLeft="5px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style12"></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="cmdUpdateEntryMethod" runat="server" Height="35px" OnClick="cmdUpdateEntryMethod_Click" Text="Update Entry Type" Width="100%">
                                                    <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Set entry type for selected students?');
if(e.processOnServer)
{
	lp_loading_entry.Show();
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
                                                <dx:ASPxLoadingPanel ID="lp_loading_entry" runat="server" ClientInstanceName="lp_loading_entry" Modal="True" Text="Processing&amp;hellip;">
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
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_masters_letter" runat="server" HeaderText="Masters Letter of Award" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="460px">
                            <ContentStyle>
                                <Paddings Padding="28px" />
                            </ContentStyle>
                            <HeaderStyle HorizontalAlign="Center">
                                <Paddings Padding="10px" />
                            </HeaderStyle>
                            <ModalBackgroundStyle BackColor="Black" Opacity="60">
                            </ModalBackgroundStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <p style="margin:0 0 16px 0; color:#002365; font-weight:600; font-size:13px;">
                                                    Enter the date of the Senate meeting at which the degree was approved.
                                                    The reference number and letter date are generated automatically.
                                                </p>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-bottom:6px; font-weight:600;">Senate Meeting Date:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxDateEdit ID="txtMastersSenatDate" runat="server" DisplayFormatString="dd MMMM, yyyy" EditFormatString="dd MMMM, yyyy" Height="35px" Width="100%">
                                                    <ClientSideEvents Init="function(s,e){ s.GetInputElement().setAttribute('autocomplete','off'); }" />
                                                </dx:ASPxDateEdit>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-top:20px;">
                                                <dx:ASPxButton ID="cmdGenerateMastersLetter" runat="server" Height="38px" OnClick="cmdGenerateMastersLetter_Click" Text="Generate Letter of Award" Width="100%">
                                                    <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Generate Masters Letter of Award for the selected student?');
if(e.processOnServer) lp_processing.Show();
}" />
                                                    <Image IconID="content_checkbox_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><br /></td>
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