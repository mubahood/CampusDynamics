<%@ Control Language="C#" AutoEventWireup="true" CodeFile="TranscriptFormatCentre.ascx.cs" Inherits="UserControls_Registry_TranscriptFormatCentre" %>
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
    .auto-style2 {
        width: 89px;
        height: 39px;
    }
    .auto-style3 {
        height: 39px;
    }
    .auto-style4 {
        width: 89px;
    }
    .auto-style5 {
        width: 89px;
        height: 18px;
    }
    .auto-style6 {
        height: 18px;
    }
    .auto-style7 {
        height: 42px;
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
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_transcript_settings.png" >
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
                                    <dx:ASPxButton ID="cmdAddNew" runat="server" Height="35px" OnClick="cmdAddNew_Click" Text="Add New" Width="200px">
                                        <Image IconID="actions_add_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td style="text-align: right" valign="bottom" width="170px">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheetInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheetInfo" DataSourceID="dsTransacriptFormats" KeyFieldName="ID" Width="100%" OnHtmlDataCellPrepared="gvMarksheetInfo_HtmlDataCellPrepared">
                            <SettingsContextMenu Enabled="True">
                            </SettingsContextMenu>
                            <SettingsEditing Mode="PopupEditForm">
                            </SettingsEditing>
                            <SettingsBehavior AllowFocusedRow="True" AllowSelectSingleRowOnly="True" ConfirmDelete="True" />
                            <SettingsCommandButton RenderMode="Button">
                            </SettingsCommandButton>
                            <SettingsPopup>
                                <EditForm HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter" />
                            </SettingsPopup>
                            <SettingsSearchPanel Visible="True" />
                            <SettingsText CommandCancel="Cancel Changes" CommandUpdate="Save Changes" PopupEditFormCaption="Transcript Format Info" />
                            <EditFormLayoutProperties ColCount="2">
                                <Items>
                                    <dx:EmptyLayoutItem>
                                    </dx:EmptyLayoutItem>
                                    <dx:GridViewColumnLayoutItem ClientVisible="False" ColumnName="ID">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="Programme">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="format_title">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="year_created">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="details">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="Study System">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right">
                                    </dx:EditModeCommandLayoutItem>
                                    <dx:EmptyLayoutItem>
                                    </dx:EmptyLayoutItem>
                                </Items>
                            </EditFormLayoutProperties>
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" VisibleIndex="1" Caption="SNo" Width="30px">
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="format_title" VisibleIndex="3" Caption="Title">
                                    <PropertiesTextEdit Height="35px">
                                    </PropertiesTextEdit>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Year Created" FieldName="year_created" VisibleIndex="4">
                                    <PropertiesTextEdit Height="35px">
                                    </PropertiesTextEdit>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="details" VisibleIndex="5" Caption="Details">
                                    <PropertiesTextEdit Height="35px">
                                    </PropertiesTextEdit>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn VisibleIndex="7" Caption="Details" Width="25px">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdDetails" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="cmdDetails_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Programme" FieldName="prog_id" VisibleIndex="2">
                                    <PropertiesComboBox DataSourceID="dsProgrammes" Height="35px" TextField="progname" TextFormatString="{1}" ValueField="progcode">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="40px" />
                                            <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                        </Columns>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Study System" FieldName="study_system" VisibleIndex="6">
                                    <PropertiesComboBox Height="35px">
                                        <Items>
                                            <dx:ListEditItem Text="Semester" Value="Semester" />
                                            <dx:ListEditItem Text="Quarter" Value="Quarter" />
                                            <dx:ListEditItem Text="Term" Value="Term" />
                                        </Items>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter"></asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td class="auto-style7">
                        <asp:ObjectDataSource ID="dsTransacriptFormats" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetTranscriptsFormats" TypeName="TranscriptSetupDataTableAdapters.acad_transcript_formatTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="prog_id" Type="String" />
                                <asp:Parameter Name="format_title" Type="String" />
                                <asp:Parameter Name="year_created" Type="String" />
                                <asp:Parameter Name="details" Type="String" />
                                <asp:Parameter Name="study_system" Type="String" />
                            </InsertParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="prog_id" Type="String" />
                                <asp:Parameter Name="format_title" Type="String" />
                                <asp:Parameter Name="year_created" Type="String" />
                                <asp:Parameter Name="details" Type="String" />
                                <asp:Parameter Name="study_system" Type="String" />
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
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton" Modal="True">
                            <ClientSideEvents CloseUp="function(s, e) {
gvMarksheetInfo.Refresh();	
}" />
                            <HeaderStyle Font-Bold="True" ForeColor="Red" HorizontalAlign="Center" />
                            <ModalBackgroundStyle BackColor="Black">
                            </ModalBackgroundStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_new_formats" runat="server" CloseAction="CloseButton" HeaderText="New Transacript Settings" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="450px">
                            <ClientSideEvents CloseUp="function(s, e) {
gvMarksheetInfo.Refresh();	
}" />
                            <HeaderStyle Font-Bold="True" ForeColor="Blue" HorizontalAlign="Center">
                            <Paddings Padding="10px" />
                            </HeaderStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td class="auto-style4">&nbsp;</td>
                                            <td>
                                                <br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style2">Programme:</td>
                                            <td class="auto-style3">
                                                <dx:ASPxComboBox ID="txtProg" runat="server" DataSourceID="dsProgrammes" Height="35px" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="100%">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="35px" />
                                                        <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style4">&nbsp;</td>
                                            <td>
                                                <dx:ASPxCheckBox ID="txt_all_progs" runat="server" CheckState="Unchecked" Height="35px" Text="Add all programmes">
                                                </dx:ASPxCheckBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5">Study System:</td>
                                            <td class="auto-style6">
                                                <dx:ASPxComboBox ID="txtStudySystem" runat="server" Height="35px" SelectedIndex="0" Width="100%">
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="Semester" Value="Semester" />
                                                        <dx:ListEditItem Text="Quarter" Value="Quarter" />
                                                        <dx:ListEditItem Text="Term" Value="Term" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style4">&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdAddNewSettings" runat="server" Height="35px" OnClick="cmdAddNewSettings_Click" Text="Add Settings" Width="100%">
                                                    <Image IconID="content_checkbox_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5"></td>
                                            <td class="auto-style6">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5">&nbsp;</td>
                                            <td class="auto-style6">
                                                <dx:ASPxLabel ID="lbl_comments" runat="server" Font-Bold="True" ForeColor="Blue">
                                                </dx:ASPxLabel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style4">&nbsp;</td>
                                            <td>
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
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>