<%@ Page Language="C#" AutoEventWireup="true" CodeFile="OnlineApplicantDetails.aspx.cs" Inherits="COOPERP_Admissions_ApplicantDetails" %>
<%@ Register src="../../UserControls/Admissions/ApplicantChoices.ascx" tagname="ApplicantChoices" tagprefix="uc4" %>
<%@ Register src="../../UserControls/Admissions/ApplicantResults.ascx" tagname="ApplicantResults" tagprefix="uc5" %>
<%@ Register src="../../UserControls/Admissions/ApplicantQualifications.ascx" tagname="ApplicantQualifications" tagprefix="uc6" %>
<%@ Register src="../../UserControls/Admissions/OnlineApplicantResults.ascx" tagname="OnlineApplicantResults" tagprefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" HeaderText="" 
                                            ShowHeader="False" Width="100%">
                                            <PanelCollection>
                                                <dx:PanelContent ID="PanelContent1" runat="server">
                                                    <table width="100%">
                                                        <tr>
                                                            <td align="center">
                                                                <dx:ASPxLabel ID="lblheader" runat="server" Font-Size="17px" ForeColor="Red">
                                                                </dx:ASPxLabel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">
                                                                <asp:Image ID="Image3" runat="server" Height="1px" 
                                                                    ImageUrl="~/COOPERP/images/hor_line.png" Width="100%" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" 
                                                                    Width="100%">
                                                                    <TabPages>
                                                                        <dx:TabPage Text=" Applicant Choices">
                                                                            <TabImage IconID="actions_apply_16x16">
                                                                            </TabImage>
                                                                            <ContentCollection>
                                                                                <dx:ContentControl runat="server">
                                                                                    <dx:ASPxRoundPanel ID="ASPxRoundPanel3" runat="server" ShowCollapseButton="True" ShowHeader="False" Width="100%">
                                                                                        <PanelCollection>
                                                                                            <dx:PanelContent runat="server">
                                                                                                <table class="dxeBinImgCPnlSys">
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <dx:ASPxGridView ID="gv_Choices" runat="server" AutoGenerateColumns="False" DataSourceID="ds_choicces" KeyFieldName="form_no" Width="100%" OnHtmlRowPrepared="gv_Choices_HtmlRowPrepared" OnCustomErrorText="gv_Choices_CustomErrorText">
                                                                                                                <SettingsBehavior AllowFocusedRow="True" />
                                                                                                                <Columns>
                                                                                                                    <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="0" Width="2px">
                                                                                                                    </dx:GridViewCommandColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="form_no" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="applic_name" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="applic_sex" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataDateColumn FieldName="applic_dob" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                                                                                    </dx:GridViewDataDateColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="home_dist" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="nationality" ShowInCustomizationForm="True" Visible="False" VisibleIndex="6">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="sponsor" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="sponsor_contact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="info_source" ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="olevel_index" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="olevel_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="alevel_index" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="alevel_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="entry_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="applic_no" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="applic_phone" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="applic_email" ShowInCustomizationForm="True" Visible="False" VisibleIndex="22">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="form_status" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataComboBoxColumn Caption="Choice of Programme" FieldName="first_choiceprog" ShowInCustomizationForm="True" VisibleIndex="14">
                                                                                                                        <PropertiesComboBox DataSourceID="dsProgrammes" TextField="progname" TextFormatString="{1}" ValueField="progcode">
                                                                                                                            <Columns>
                                                                                                                                <dx:ListBoxColumn FieldName="progcode" />
                                                                                                                                <dx:ListBoxColumn FieldName="progname" />
                                                                                                                            </Columns>
                                                                                                                        </PropertiesComboBox>
                                                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                                                    <dx:GridViewDataComboBoxColumn Caption="Second Choice Programme" FieldName="second_choiceprog" ShowInCustomizationForm="True" VisibleIndex="16" Visible="False">
                                                                                                                        <PropertiesComboBox DataSourceID="dsProgrammes" TextField="progname" TextFormatString="{1}" ValueField="progcode">
                                                                                                                            <Columns>
                                                                                                                                <dx:ListBoxColumn FieldName="progcode" />
                                                                                                                                <dx:ListBoxColumn FieldName="progname" />
                                                                                                                            </Columns>
                                                                                                                        </PropertiesComboBox>
                                                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                                                    <dx:GridViewDataComboBoxColumn Caption="Session" FieldName="first_choice_session" ShowInCustomizationForm="True" VisibleIndex="15">
                                                                                                                        <PropertiesComboBox DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                                                                                                            <Columns>
                                                                                                                                <dx:ListBoxColumn FieldName="Session" />
                                                                                                                            </Columns>
                                                                                                                        </PropertiesComboBox>
                                                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                                                    <dx:GridViewDataComboBoxColumn Caption="Campus" FieldName="campus" ShowInCustomizationForm="True" VisibleIndex="18">
                                                                                                                        <PropertiesComboBox DataSourceID="dscampuses" TextField="campus_name" TextFormatString="{1}" ValueField="campus_name">
                                                                                                                            <Columns>
                                                                                                                                <dx:ListBoxColumn Caption="SNo" FieldName="ID" />
                                                                                                                                <dx:ListBoxColumn Caption="Campus" FieldName="campus_name" />
                                                                                                                            </Columns>
                                                                                                                        </PropertiesComboBox>
                                                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                                                    <dx:GridViewDataComboBoxColumn Caption="Session" FieldName="secondchoice_session" ShowInCustomizationForm="True" VisibleIndex="17" Visible="False">
                                                                                                                        <PropertiesComboBox DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                                                                                                            <Columns>
                                                                                                                                <dx:ListBoxColumn FieldName="Session" />
                                                                                                                            </Columns>
                                                                                                                        </PropertiesComboBox>
                                                                                                                    </dx:GridViewDataComboBoxColumn>
                                                                                                                </Columns>
                                                                                                            </dx:ASPxGridView>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:ObjectDataSource ID="ds_choicces" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="Get_ApplicantDetails" TypeName="admission_dataTableAdapters.applic_formTableAdapter" UpdateMethod="UpdateApplicantChoices">
                                                                                                                <DeleteParameters>
                                                                                                                    <asp:Parameter Name="Original_form_no" Type="String" />
                                                                                                                </DeleteParameters>
                                                                                                                <InsertParameters>
                                                                                                                    <asp:Parameter Name="form_no" Type="String" />
                                                                                                                    <asp:Parameter Name="applic_name" Type="String" />
                                                                                                                    <asp:Parameter Name="applic_sex" Type="String" />
                                                                                                                    <asp:Parameter Name="applic_dob" Type="DateTime" />
                                                                                                                    <asp:Parameter Name="home_dist" Type="String" />
                                                                                                                    <asp:Parameter Name="nationality" Type="String" />
                                                                                                                    <asp:Parameter Name="sponsor" Type="String" />
                                                                                                                    <asp:Parameter Name="sponsor_contact" Type="String" />
                                                                                                                    <asp:Parameter Name="info_source" Type="String" />
                                                                                                                    <asp:Parameter Name="olevel_index" Type="String" />
                                                                                                                    <asp:Parameter Name="olevel_year" Type="UInt32" />
                                                                                                                    <asp:Parameter Name="alevel_index" Type="String" />
                                                                                                                    <asp:Parameter Name="alevel_year" Type="UInt32" />
                                                                                                                    <asp:Parameter Name="first_choiceprog" Type="String" />
                                                                                                                    <asp:Parameter Name="first_choice_session" Type="String" />
                                                                                                                    <asp:Parameter Name="second_choiceprog" Type="String" />
                                                                                                                    <asp:Parameter Name="secondchoice_session" Type="String" />
                                                                                                                    <asp:Parameter Name="campus" Type="String" />
                                                                                                                    <asp:Parameter Name="entry_year" Type="String" />
                                                                                                                    <asp:Parameter Name="applic_no" Type="String" />
                                                                                                                    <asp:Parameter Name="applic_phone" Type="String" />
                                                                                                                    <asp:Parameter Name="applic_email" Type="String" />
                                                                                                                    <asp:Parameter Name="form_status" Type="String" />
                                                                                                                    <asp:Parameter Name="recruiterID" Type="UInt32" />
                                                                                                                    <asp:Parameter Name="residence" Type="String" />
                                                                                                                    <asp:Parameter Name="applic_date" Type="DateTime" />
                                                                                                                    <asp:Parameter Name="proc_date" Type="DateTime" />
                                                                                                                </InsertParameters>
                                                                                                                <SelectParameters>
                                                                                                                    <asp:SessionParameter Name="form_no" SessionField="formNo" Type="String" />
                                                                                                                </SelectParameters>
                                                                                                                <UpdateParameters>
                                                                                                                    <asp:Parameter Name="first_choiceprog" Type="String" />
                                                                                                                    <asp:Parameter Name="first_choice_session" Type="String" />
                                                                                                                    <asp:Parameter Name="second_choiceprog" Type="String" />
                                                                                                                    <asp:Parameter Name="secondchoice_session" Type="String" />
                                                                                                                    <asp:Parameter Name="campus" Type="String" />
                                                                                                                    <asp:Parameter Name="Original_form_no" Type="String" />
                                                                                                                </UpdateParameters>
                                                                                                            </asp:ObjectDataSource>
                                                                                                            <asp:ObjectDataSource ID="dsProgrammes" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_programmeTableAdapter">
                                                                                                                <DeleteParameters>
                                                                                                                    <asp:Parameter Name="Original_progcode" Type="String" />
                                                                                                                </DeleteParameters>
                                                                                                            </asp:ObjectDataSource>
                                                                                                            <asp:ObjectDataSource ID="dscampuses" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataByCampuses" TypeName="admission_dataTableAdapters.acad_campusesTableAdapter" UpdateMethod="Update">
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
                                                                                                            <asp:ObjectDataSource ID="dsstudysessions" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update">
                                                                                                                <InsertParameters>
                                                                                                                    <asp:Parameter Name="Session" Type="String" />
                                                                                                                </InsertParameters>
                                                                                                                <UpdateParameters>
                                                                                                                    <asp:Parameter Name="Original_Session" Type="String" />
                                                                                                                </UpdateParameters>
                                                                                                            </asp:ObjectDataSource>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </dx:PanelContent>
                                                                                        </PanelCollection>
                                                                                    </dx:ASPxRoundPanel>
                                                                                </dx:ContentControl>
                                                                            </ContentCollection>
                                                                        </dx:TabPage>
                                                                        <dx:TabPage Text=" Education Background">
                                                                            <TabImage IconID="actions_loadfrom_16x16">
                                                                            </TabImage>
                                                                            <ContentCollection>
                                                                                <dx:ContentControl runat="server">
                                                                                    <dx:ASPxRoundPanel ID="ASPxRoundPanel5" runat="server" ShowCollapseButton="True" ShowHeader="False" Width="100%">
                                                                                        <PanelCollection>
                                                                                            <dx:PanelContent runat="server">
                                                                                                <table class="dxeBinImgCPnlSys">
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <dx:ASPxGridView ID="gv_education" runat="server" AutoGenerateColumns="False" DataSourceID="ds_education" KeyFieldName="ID" Width="100%">
                                                                                                                <Columns>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="form_no" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn Caption="Institution Name" FieldName="school_name" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn Caption="Education Level" FieldName="educ_level" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn Caption="Completion Year" FieldName="grad_year" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn Caption="Achievement" FieldName="results" ShowInCustomizationForm="True" VisibleIndex="5">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                </Columns>
                                                                                                            </dx:ASPxGridView>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:ObjectDataSource ID="ds_education" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="Get_Education" TypeName="admission_dataTableAdapters.educ_backgroundTableAdapter" UpdateMethod="Update">
                                                                                                                <DeleteParameters>
                                                                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                                                                </DeleteParameters>
                                                                                                                <InsertParameters>
                                                                                                                    <asp:Parameter Name="form_no" Type="String" />
                                                                                                                    <asp:Parameter Name="school_name" Type="String" />
                                                                                                                    <asp:Parameter Name="educ_level" Type="String" />
                                                                                                                    <asp:Parameter Name="grad_year" Type="String" />
                                                                                                                    <asp:Parameter Name="results" Type="String" />
                                                                                                                </InsertParameters>
                                                                                                                <SelectParameters>
                                                                                                                    <asp:SessionParameter Name="form_no" SessionField="formNo" Type="String" />
                                                                                                                </SelectParameters>
                                                                                                                <UpdateParameters>
                                                                                                                    <asp:Parameter Name="form_no" Type="String" />
                                                                                                                    <asp:Parameter Name="school_name" Type="String" />
                                                                                                                    <asp:Parameter Name="educ_level" Type="String" />
                                                                                                                    <asp:Parameter Name="grad_year" Type="String" />
                                                                                                                    <asp:Parameter Name="results" Type="String" />
                                                                                                                    <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                                                                                </UpdateParameters>
                                                                                                            </asp:ObjectDataSource>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </dx:PanelContent>
                                                                                        </PanelCollection>
                                                                                    </dx:ASPxRoundPanel>
                                                                                </dx:ContentControl>
                                                                            </ContentCollection>
                                                                        </dx:TabPage>
                                                                        <dx:TabPage Text=" Applicant Documents">
                                                                            <TabImage IconID="chart_chartsshowlegend_16x16">
                                                                            </TabImage>
                                                                            <ContentCollection>
                                                                                <dx:ContentControl ID="ContentControl2" runat="server">
                                                                                    <dx:ASPxRoundPanel ID="ASPxRoundPanel4" runat="server" ShowCollapseButton="True" ShowHeader="False" Width="100%">
                                                                                        <PanelCollection>
                                                                                            <dx:PanelContent runat="server">
                                                                                                <table class="dxeBinImgCPnlSys">
                                                                                                    <tr>
                                                                                                        <td> <dx:ASPxGridView ID="gvDocuments" runat="server" AutoGenerateColumns="False" DataSourceID="dsDocuments" EnableTheming="True" KeyFieldName="DocID" Theme="Default" Width="100%"  ClientInstanceName="gvDocuments">
                           
                                                                                                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                           
                            <SettingsText CommandCancel="Cancel Changes" CommandDelete="Delete" CommandUpdate="Save Changes" PopupEditFormCaption="New Applicant Results" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="DocID" ReadOnly="True" VisibleIndex="1" Caption="DocNo" Width="50px" Visible="False">
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="applic_no" VisibleIndex="2" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Document Name" FieldName="doc_name" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewCommandColumn ButtonRenderMode="Button" ButtonType="Button" ShowDeleteButton="True" VisibleIndex="5" Width="40px" Visible="False">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="View" FieldName="doc_path" ShowInCustomizationForm="True" VisibleIndex="4" Width="60px">
                                    <PropertiesTextEdit DisplayFormatString="{0}">
                                    </PropertiesTextEdit>
                                    <DataItemTemplate>
                                        <dx:ASPxButton ID="cmdView" runat="server" Height="35px" OnClick="cmdView_Click" Text="View">
                                        </dx:ASPxButton>
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                            </Columns>
                        </dx:ASPxGridView>
                        
                       </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td><asp:ObjectDataSource ID="dsDocuments" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetApplicantDocs" TypeName="admission_dataTableAdapters.doc_uploadsTableAdapter" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_DocID" Type="UInt32" />
                            </DeleteParameters>
                                                                                                            <InsertParameters>
                                                                                                                <asp:Parameter Name="applic_no" Type="String" />
                                                                                                                <asp:Parameter Name="doc_name" Type="String" />
                                                                                                                <asp:Parameter Name="doc_path" Type="String" />
                                                                                                            </InsertParameters>
                            <SelectParameters>
                                <asp:SessionParameter Name="applicno" SessionField="formNo" Type="String" />
                            </SelectParameters>
                                                                                                            <UpdateParameters>
                                                                                                                <asp:Parameter Name="applic_no" Type="String" />
                                                                                                                <asp:Parameter Name="doc_name" Type="String" />
                                                                                                                <asp:Parameter Name="doc_path" Type="String" />
                                                                                                                <asp:Parameter Name="Original_DocID" Type="UInt32" />
                                                                                                            </UpdateParameters>
                        </asp:ObjectDataSource>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <dx:ASPxPopupControl ID="pop_doc_viewer" runat="server" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                                                                                                                <ModalBackgroundStyle BackColor="Black">
                                                                                                                </ModalBackgroundStyle>
                                                                                                                <ContentCollection>
                                                                                                                    <dx:PopupControlContentControl runat="server">
                                                                                                                    </dx:PopupControlContentControl>
                                                                                                                </ContentCollection>
                                                                                                            </dx:ASPxPopupControl>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </dx:PanelContent>
                                                                                        </PanelCollection>
                                                                                    </dx:ASPxRoundPanel>
                                                                                </dx:ContentControl>
                                                                            </ContentCollection>
                                                                        </dx:TabPage>
                                                                        <dx:TabPage Text=" Payments">
                                                                            <TabImage IconID="functionlibrary_financial_16x16">
                                                                            </TabImage>
                                                                            <ContentCollection>
                                                                                <dx:ContentControl ID="ContentControl1" runat="server">
                                                                                    
                                                                                    <dx:ASPxRoundPanel ID="ASPxRoundPanel6" runat="server" ShowCollapseButton="True" ShowHeader="False" Width="100%">
                                                                                        <PanelCollection>
                                                                                            <dx:PanelContent runat="server">
                                                                                                <table class="dxeBinImgCPnlSys">
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <dx:ASPxGridView ID="gv_payments" runat="server" AutoGenerateColumns="False" DataSourceID="ds_Payments" KeyFieldName="receiptNo" Width="100%">
                                                                                                                <Columns>
                                                                                                                    <dx:GridViewDataTextColumn Caption="Receipt No" FieldName="receiptNo" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="0" Width="200px">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataDateColumn Caption="Payment Date" FieldName="date_paid" ShowInCustomizationForm="True" VisibleIndex="1">
                                                                                                                        <PropertiesDateEdit DisplayFormatString="dd-MMMM-yyyy">
                                                                                                                        </PropertiesDateEdit>
                                                                                                                    </dx:GridViewDataDateColumn>
                                                                                                                    <dx:GridViewDataTextColumn Caption="Channel Used" FieldName="channel_paid" ShowInCustomizationForm="True" VisibleIndex="3">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn Caption="Amount" FieldName="amount_paid" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                    <dx:GridViewDataTextColumn FieldName="formNo" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                                                                                    </dx:GridViewDataTextColumn>
                                                                                                                </Columns>
                                                                                                            </dx:ASPxGridView>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:ObjectDataSource ID="ds_Payments" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetPaymentsByForm" TypeName="admission_dataTableAdapters.applic_paymentsTableAdapter" UpdateMethod="Update">
                                                                                                                <DeleteParameters>
                                                                                                                    <asp:Parameter Name="Original_receiptNo" Type="UInt32" />
                                                                                                                </DeleteParameters>
                                                                                                                <InsertParameters>
                                                                                                                    <asp:Parameter Name="receiptNo" Type="UInt32" />
                                                                                                                    <asp:Parameter Name="date_paid" Type="DateTime" />
                                                                                                                    <asp:Parameter Name="channel_paid" Type="String" />
                                                                                                                    <asp:Parameter Name="amount_paid" Type="Double" />
                                                                                                                    <asp:Parameter Name="formNo" Type="String" />
                                                                                                                </InsertParameters>
                                                                                                                <SelectParameters>
                                                                                                                    <asp:SessionParameter Name="formNo" SessionField="formNo" Type="String" />
                                                                                                                </SelectParameters>
                                                                                                                <UpdateParameters>
                                                                                                                    <asp:Parameter Name="date_paid" Type="DateTime" />
                                                                                                                    <asp:Parameter Name="channel_paid" Type="String" />
                                                                                                                    <asp:Parameter Name="amount_paid" Type="Double" />
                                                                                                                    <asp:Parameter Name="formNo" Type="String" />
                                                                                                                    <asp:Parameter Name="Original_receiptNo" Type="UInt32" />
                                                                                                                </UpdateParameters>
                                                                                                            </asp:ObjectDataSource>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </dx:PanelContent>
                                                                                        </PanelCollection>
                                                                                    </dx:ASPxRoundPanel>
                                                                                    
                                                                                </dx:ContentControl>
                                                                            </ContentCollection>
                                                                        </dx:TabPage>
                                                                    </TabPages>
                                                                    <TabStyle>
                                                                        <Paddings Padding="10px" />
                                                                    </TabStyle>
                                                                </dx:ASPxPageControl>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </dx:PanelContent>
                                            </PanelCollection>
                                        </dx:ASPxRoundPanel>
    </div>
    </form>
</body>
</html>
