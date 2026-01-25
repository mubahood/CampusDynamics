<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TranscriptFormatDetails.aspx.cs" Inherits="COOPERP_Registry_TranscriptFormatDetails" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">


*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    .style1
    {
        width: 100%;
    }

        .auto-style6 {
            height: 18px;
        }
        .auto-style7 {
            width: 74px;
        }
        .auto-style8 {
            width: 74px;
            height: 18px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <dx:ASPxRoundPanel ID="panel_setting_details" runat="server" HeaderText=" Transcript Format Details" Width="100%">
                    <HeaderImage IconID="filterelements_listbox_16x16">
                    </HeaderImage>
                    <HeaderStyle Font-Bold="True" ForeColor="Blue" HorizontalAlign="Center">
                    <Paddings Padding="10px" />
                    </HeaderStyle>
                    <PanelCollection>
                        <dx:PanelContent runat="server">
                            <table class="dx-justification">
                                <tr>
                                    <td>
                                        <dx:ASPxButton ID="addCUnits" runat="server" Height="35px" OnClick="addCUnits_Click" Text="Add Course Units" Width="200px">
                                            <Image IconID="actions_insert_16x16">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="gvTranscriptDetails" runat="server" AutoGenerateColumns="False" DataSourceID="dsTransDetails" KeyFieldName="ID" OnHtmlDataCellPrepared="gvTranscriptDetails_HtmlDataCellPrepared" Width="100%">
                                            <SettingsEditing Mode="Batch">
                                                <BatchEditSettings StartEditAction="Click" />
                                            </SettingsEditing>
                                            <SettingsBehavior AllowFocusedRow="True" />
                                            <SettingsSearchPanel Visible="True" />
                                            <Columns>
                                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Format ID" FieldName="format_id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Code" FieldName="course_id" ShowInCustomizationForm="True" VisibleIndex="2" Width="100px">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Semester" FieldName="semester" ShowInCustomizationForm="True" VisibleIndex="6" Width="50px">
                                                    <CellStyle HorizontalAlign="Center">
                                                    </CellStyle>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Year" FieldName="study_year" ShowInCustomizationForm="True" VisibleIndex="5" Width="45px">
                                                    <CellStyle HorizontalAlign="Center">
                                                    </CellStyle>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Course Name" FieldName="course_name" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="1" Width="25px">
                                                </dx:GridViewCommandColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:ObjectDataSource ID="dsTransDetails" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetTranscriptFormatDetails" TypeName="TranscriptSetupDataTableAdapters.acad_transcript_format_detailTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="format_id" Type="UInt32" />
                                                <asp:Parameter Name="course_id" Type="String" />
                                                <asp:Parameter Name="semester" Type="UInt32" />
                                                <asp:Parameter Name="study_year" Type="UInt32" />
                                            </InsertParameters>
                                            <SelectParameters>
                                                <asp:QueryStringParameter DefaultValue="0" Name="formatid" QueryStringField="formatid" Type="Int32" />
                                            </SelectParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="format_id" Type="UInt32" />
                                                <asp:Parameter Name="course_id" Type="String" />
                                                <asp:Parameter Name="semester" Type="UInt32" />
                                                <asp:Parameter Name="study_year" Type="UInt32" />
                                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Modal="True" Text="Processing&amp;hellip;">
                                        </dx:ASPxLoadingPanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxPopupControl ID="pop_new_formats" runat="server" CloseAction="CloseButton" HeaderText="New Course Units" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="450px">
                                            <ClientSideEvents CloseUp="function(s, e) {
gvMarksheetInfo.Refresh();	
}" />
                                            <HeaderStyle Font-Bold="True" ForeColor="Blue" HorizontalAlign="Center">
                                            <Paddings Padding="10px" />
                                            </HeaderStyle>
                                            <ModalBackgroundStyle BackColor="Black">
                                            </ModalBackgroundStyle>
                                            <ContentCollection>
                                                <dx:PopupControlContentControl runat="server">
                                                    <table class="style1">
                                                        <tr>
                                                            <td class="auto-style7">&nbsp;</td>
                                                            <td>
                                        <br />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="auto-style7">&nbsp;</td>
                                                            <td>
                                                                <dx:ASPxCheckBox ID="txt_batch_cu" runat="server" AutoPostBack="True" CheckState="Unchecked" Height="35px" OnCheckedChanged="txt_batch_cu_CheckedChanged" Text="Batch Course Units">
                                                                </dx:ASPxCheckBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="auto-style8">Course Unit:</td>
                                                            <td class="auto-style6">
                                                                <dx:ASPxComboBox ID="txtCourseUnit" runat="server" DataSourceID="dsCourseUnits" Height="35px" SelectedIndex="0" TextField="course_name" TextFormatString="{0} - {1}" ValueField="courseid" Width="100%">
                                                                    <Columns>
                                                                        <dx:ListBoxColumn Caption="Code" FieldName="courseid" Width="50px" />
                                                                        <dx:ListBoxColumn Caption="Course Name" FieldName="course_name" Width="250px" />
                                                                    </Columns>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="auto-style7">Semester:</td>
                                                            <td>
                                                                <dx:ASPxComboBox ID="txtSemester" runat="server" Height="35px" SelectedIndex="0" TextField="course_name" TextFormatString="{0} - {1}" ValueField="courseid" Width="100%">
                                                                    <Items>
                                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                                        <dx:ListEditItem Text="2" Value="2" />
                                                                        <dx:ListEditItem Text="3" Value="3" />
                                                                    </Items>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="auto-style8">Year:</td>
                                                            <td class="auto-style6">
                                                                <dx:ASPxComboBox ID="txtYear" runat="server" Height="35px" SelectedIndex="0" TextField="course_name" TextFormatString="{0} - {1}" ValueField="courseid" Width="100%">
                                                                    <Items>
                                                                        <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                                        <dx:ListEditItem Text="2" Value="2" />
                                                                        <dx:ListEditItem Text="3" Value="3" />
                                                                    </Items>
                                                                </dx:ASPxComboBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="auto-style7">&nbsp;</td>
                                                            <td>
                                                                <dx:ASPxButton ID="cmdAddNewSettings" runat="server" Height="35px" OnClick="cmdAddNewSettings_Click" Text="Add Course Units" Width="100%">
                                                                    <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Add New Courses?');
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
                                                            <td class="auto-style8"></td>
                                                            <td class="auto-style6">
                                                                <asp:ObjectDataSource ID="dsCourseUnits" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="TranscriptSetupDataTableAdapters.acad_resultsTableAdapter">
                                                                    <SelectParameters>
                                                                        <asp:QueryStringParameter DefaultValue="-" Name="prog" QueryStringField="progid" Type="String" />
                                                                    </SelectParameters>
                                                                </asp:ObjectDataSource>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="auto-style8">&nbsp;</td>
                                                            <td class="auto-style6">
                                                                <dx:ASPxLabel ID="lbl_comments" runat="server" Font-Bold="True" ForeColor="Blue">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="auto-style7">&nbsp;</td>
                                                            <td>
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
            </ContentTemplate>
        </asp:UpdatePanel>
    
    </div>
    </form>
</body>
</html>
