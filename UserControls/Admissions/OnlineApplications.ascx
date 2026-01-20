<%@ Control Language="C#" AutoEventWireup="true" CodeFile="OnlineApplications.ascx.cs" Inherits="UserControls_Admissions_applications" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>


<%@ Register assembly="DevExpress.Web.ASPxHtmlEditor.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web.ASPxHtmlEditor" tagprefix="dx" %>
<%@ Register assembly="DevExpress.Web.ASPxSpellChecker.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web.ASPxSpellChecker" tagprefix="dx" %>


<style type="text/css">
    .style1
    {
        width: 100%;
    }
    .style2
    {
        width: 75px;
    }
    .style3
    {
        width: 352px;
    }
    .style4
    {
        width: 65px;
    }

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


    .auto-style1 {
        height: 70px;
    }


    .auto-style2 {
        height: 39px;
    }


    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <%--<asp:UpdatePanel ID="UpdatePanel1" runat="server">--%>
       <%-- <ContentTemplate>--%>
            
                        <table class="style1">
                            <tr>
                                <td colspan="2">
                                    <table cellpadding="0" cellspacing="0" class="style1">
                                        
                                        <tr>
                                            <td style="text-align: center">
                                                <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_applicant_info.png">
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
                                <td colspan="2">&nbsp;</td>
                            </tr>
                            <tr>
                                <td>
                                    <table class="style1">
                                        <tr>
                                            <td class="auto-style2">
                                                <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Entry Year">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td class="auto-style2">
                                                <dx:ASPxComboBox ID="txtEntryYear" runat="server" Width="250px" Height="35px" AutoPostBack="True">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                    <Paddings PaddingLeft="5px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style2">
                                                <dx:ASPxLabel ID="ASPxLabel5" runat="server" Text="Current Intake">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td class="auto-style2">
                                                <dx:ASPxComboBox ID="txtIntake" runat="server" SelectedIndex="7" Width="250px" Height="35px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                                        <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                                        <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                                        <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                                        <dx:ListEditItem Text="MAY" Value="MAY" />
                                                        <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                                        <dx:ListEditItem Text="JULY" Value="JULY" />
                                                        <dx:ListEditItem Text="AUGUST" Value="AUGUST" Selected="True" />
                                                        <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                                        <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                                        <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                                        <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                                    </Items>
                                                    <Paddings PaddingLeft="5px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text="Status">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtStatus" runat="server" SelectedIndex="0" Width="250px" Height="35px" AutoPostBack="True">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="Submitted" Value="Submitted" Selected="True" />
                                                        <dx:ListEditItem Text="Accepted" Value="Accepted" />
                                                        <dx:ListEditItem Text="Rejected" Value="Rejected" />
                                                    </Items>
                                                    <Paddings PaddingLeft="5px" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td>
                                                <dx:ASPxLabel ID="ASPxLabel6" runat="server" Text="Faculty|School">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                               <%-- <dx:ASPxButton ID="cmdReject" runat="server" AutoPostBack="False" Height="35px" OnClick="cmdReject_Click" Text="Reject Application" Width="250px" Visible="False">
                                                    <ClientSideEvents Click="function(s, e) {
	callback_applications.PerformCallback(&quot;AddApplicant&quot;);
}" />
                                                    <Image IconID="actions_cancel_16x16">
                                                    </Image>
                                                </dx:ASPxButton>--%>
                                                <dx:ASPxComboBox ID="txtFaculty" runat="server" DataSourceID="dsFaculty" DropDownWidth="600px" Height="35px" SelectedIndex="2" TextField="faculty_name" TextFormatString="{1}" ValueField="fax_code" Width="250px" AutoPostBack="True">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="fax_code" Width="100px" />
                                                        <dx:ListBoxColumn Caption="Faculty|School" FieldName="faculty_name" Width="500px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                            <td>
                                                <dx:ASPxButton ID="cmdNew" runat="server" AutoPostBack="False" Height="35px" Text="Accept Application" Width="250px" OnClick="cmdNew_Click">
                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('You are about to Accept and Capture an application. Are you Sure?');
if(e.processOnServer)
{
lp_loading.Show();
}
}" />
                                                    <Image IconID="content_checkbox_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td></td>
                                            <td>
                                                <dx:ASPxButton ID="cmdExport" runat="server" Height="35px" OnClick="cmdExport_Click" Text="Export List" Width="250px">
                                                    <Image IconID="export_exporttoxls_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="ASPxButton1" runat="server" Height="35px" OnClick="ASPxButton1_Click" Text="Reject Application" Width="250px">
                                                    <Image IconID="actions_close_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmd_email_sender" runat="server" AutoPostBack="False" Height="35px" OnClick="cmd_email_sender_Click" Text="Send Feedback Email" Width="250px">
                                                    <ClientSideEvents Click="function(s, e) {
	}" />
                                                    <Image IconID="mail_mail_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td align="right" valign="top">
                                    <dx:ASPxRoundPanel ID="panel_sms" runat="server" HeaderText="SMS &amp; E-Mail Centre" Width="250px">
                                        <HeaderStyle HorizontalAlign="Center" />
                                        <PanelCollection>
                                            <dx:PanelContent runat="server">
                                                <table cellpadding="0" cellspacing="0" class="style1">
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxButton ID="btn_Email" runat="server" Text="Add E-Mail" Width="100px" Height="35px" OnClick="btn_Email_Click">
                                                                <Image Url="~/COOPERP/images/arrow-retweet.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td align="right" style="width: 248px">
                                                            <dx:ASPxButton ID="cmdUpdateList" runat="server" OnClick="cmdUpdateList_Click" Text="Add Phone" Width="105px" Height="35px">
                                                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td align="right" style="width: 248px">
                                                            <dx:ASPxButton ID="cmdSMS" runat="server" OnClick="cmdSMS_Click" Text="Send" Width="100px" Height="35px">
                                                                <Image Url="~/COOPERP/images/arrow-000-medium.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td align="right" style="width: 248px">
                                                            <dx:ASPxButton ID="cmdClearList" runat="server" OnClick="cmdClearList_Click" Text="Clear" Width="100px" Height="35px">
                                                                <Image Url="~/COOPERP/images/cross-shield.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td align="right">&nbsp;</td>
                                                    </tr>
                                                </table>
                                                <dx:ASPxPopupControl ID="pop_sms" runat="server" ContentUrl="~/SMSSender.aspx" HeaderText="" PopupElementID="cmdSMS" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="Middle">
                                                    <ContentCollection>
                                                        <dx:PopupControlContentControl runat="server">
                                                        </dx:PopupControlContentControl>
                                                    </ContentCollection>
                                                </dx:ASPxPopupControl>
                                            </dx:PanelContent>
                                        </PanelCollection>
                                    </dx:ASPxRoundPanel>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" HorizontalAlign="Center" Modal="True" Text="Processing..." Theme="MetropolisBlue">
                                                    <LoadingDivStyle BackColor="Black">
                                                    </LoadingDivStyle>
                                                </dx:ASPxLoadingPanel>
                                            </td>
                                            <td style="text-align: right">
                                                &nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <dx:ASPxGridView ID="gv_ApplicantInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvapplicants" DataSourceID="ds_ApplicantInfo" KeyFieldName="form_no" OnCustomErrorText="gv_ApplicantInfo_CustomErrorText" OnInitNewRow="gv_ApplicantInfo_InitNewRow" Width="100%" OnHtmlDataCellPrepared="gv_ApplicantInfo_HtmlDataCellPrepared" OnRowInserting="gv_ApplicantInfo_RowInserting">
                                        <SettingsPopup>
                                            <EditForm Height="600px" HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter" Width="1000px" />
                                        </SettingsPopup>
                                        <SettingsSearchPanel Visible="True" />
                                        <SettingsText PopupEditFormCaption="Applicant Info" />
                                        <EditFormLayoutProperties ColCount="2">
                                            <Items>
                                                <dx:GridViewLayoutGroup Caption="Basic Info" ColCount="2" ColSpan="2">
                                                    <Items>
                                                        <dx:EmptyLayoutItem ColSpan="2">
                                                        </dx:EmptyLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_entry_no">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_entry_year">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="title">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_name">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_sex">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_birthdate">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_phone">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_email">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_campus">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_nationality">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_entry_method">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_intake">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_sponsor">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="sponsor_contact">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:EmptyLayoutItem ColSpan="2">
                                                        </dx:EmptyLayoutItem>
                                                    </Items>
                                                </dx:GridViewLayoutGroup>
                                                <dx:EditModeCommandLayoutItem ColSpan="2">
                                                </dx:EditModeCommandLayoutItem>
                                                <dx:EmptyLayoutItem ColSpan="2">
                                                </dx:EmptyLayoutItem>
                                                <dx:GridViewLayoutGroup Caption="Bio Data Details" ColCount="2" ColSpan="2">
                                                    <Items>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_mar_stat">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_religion">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="spouse_name">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="spouseOccupation">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="spouse_contacts">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="physicalDisability">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_phy_address">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="post_box">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="residence_country">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="home_district">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="stud_occupation">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="next_kin">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="kin_relationship">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="kin_contacts">
                                                        </dx:GridViewColumnLayoutItem>
                                                    </Items>
                                                </dx:GridViewLayoutGroup>
                                                <dx:GridViewLayoutGroup Caption="Education" ColCount="2" ColSpan="2">
                                                    <Items>
                                                        <dx:GridViewColumnLayoutItem ColumnName="olevel_school">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="olevel_index">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="alevel_school">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="alevel_index">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="alevel_year">
                                                        </dx:GridViewColumnLayoutItem>
                                                    </Items>
                                                </dx:GridViewLayoutGroup>
                                                <dx:GridViewLayoutGroup Caption="Referees &amp; Letters" ColCount="2" ColSpan="2">
                                                    <Items>
                                                        <dx:GridViewColumnLayoutItem ColumnName="referee_name">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="referee_contacts">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="referee_comments">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="health_comments">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="hall">
                                                        </dx:GridViewColumnLayoutItem>
                                                        <dx:GridViewColumnLayoutItem ColumnName="letter_campus">
                                                        </dx:GridViewColumnLayoutItem>
                                                    </Items>
                                                </dx:GridViewLayoutGroup>
                                                <dx:EditModeCommandLayoutItem>
                                                </dx:EditModeCommandLayoutItem>
                                            </Items>
                                        </EditFormLayoutProperties>
                                        <Columns>
                                            <dx:GridViewDataTextColumn Caption="Entry No" FieldName="form_no" ShowInCustomizationForm="True" VisibleIndex="1" Width="100px" ReadOnly="True">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <CellStyle HorizontalAlign="Left">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Name" FieldName="applic_name" ShowInCustomizationForm="True" VisibleIndex="2">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Nationality" FieldName="nationality" ShowInCustomizationForm="True" VisibleIndex="16">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Phone No" FieldName="applic_phone" ShowInCustomizationForm="True" VisibleIndex="3" Width="150px">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Sponsor" FieldName="sponsor" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="E-mail" FieldName="applic_email" ShowInCustomizationForm="True" VisibleIndex="15" Width="200px">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="O level Index No" FieldName="olevel_index" ShowInCustomizationForm="True" VisibleIndex="27" Visible="False">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="A level Index No" FieldName="alevel_index" ShowInCustomizationForm="True" VisibleIndex="29" Visible="False">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Sponsor Contacts" FieldName="sponsor_contact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Status" FieldName="form_status" ShowInCustomizationForm="True" VisibleIndex="49">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="20px" SelectAllCheckboxMode="Page">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewCommandColumn ButtonType="Image" ShowClearFilterButton="True" ShowDeleteButton="True" ShowInCustomizationForm="True" VisibleIndex="57" Width="50px" ButtonRenderMode="Image">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataTextColumn Caption="Details" ShowInCustomizationForm="True" VisibleIndex="56" Width="40px">
                                                <EditFormSettings Visible="False" />
                                                <DataItemTemplate>
                                                    <asp:ImageButton ID="btnDetails" runat="server" ImageUrl="~/COOPERP/images/clipboard--plus.png" OnClick="btnDetails_Click" ToolTip="Click to Capture Applicant Choices &amp; Scores " />
                                                </DataItemTemplate>
                                                <CellStyle HorizontalAlign="Center">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Gender" FieldName="applic_sex" ShowInCustomizationForm="True" VisibleIndex="17">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Study Campus" FieldName="campus" VisibleIndex="50">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataDateColumn Caption="Date Applied" FieldName="applic_date" ShowInCustomizationForm="True" VisibleIndex="51">
                                                <PropertiesDateEdit DisplayFormatString="dd MMM, yyyy hh:mm">
                                                </PropertiesDateEdit>
                                            </dx:GridViewDataDateColumn>
                                            <dx:GridViewDataDateColumn Caption="Date Processed" FieldName="proc_date" ShowInCustomizationForm="True" VisibleIndex="53">
                                                <PropertiesDateEdit DisplayFormatString="dd MMM, yyyy hh:mm">
                                                </PropertiesDateEdit>
                                            </dx:GridViewDataDateColumn>
                                        </Columns>
                                        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" ConfirmDelete="True" />
                                        <SettingsPager AlwaysShowPager="True" PageSize="30" Position="TopAndBottom">
                                            <Summary Text="Page {0} of {1} [{2} Applicant(s)]" />
                                        </SettingsPager>
                                        <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                                        </SettingsEditing>
                                        <Settings ShowFilterRowMenu="True" />
                                         <SettingsCommandButton RenderMode="Button"><UpdateButton RenderMode="Button"></UpdateButton><CancelButton RenderMode="Button"></CancelButton><UpdateButton RenderMode="Button"></UpdateButton><CancelButton RenderMode="Button"></CancelButton>
                                            <UpdateButton Text="Save Changes">
                                            </UpdateButton>
                                            <CancelButton Text="Cancel Changes">
                                            </CancelButton>
                                            <EditButton>
                                                <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                </Image>
                                            </EditButton>
                                            <DeleteButton>
                                                <Image Url="~/COOPERP/images/minus-button.png">
                                                </Image>
                                            </DeleteButton>
                                        </SettingsCommandButton>
                                    </dx:ASPxGridView>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:ObjectDataSource ID="ds_ApplicantInfo" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAnnualFormsByFaculty" TypeName="admission_dataTableAdapters.applic_formTableAdapter" UpdateMethod="Update" InsertMethod="Insert">
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
                                            <asp:ControlParameter ControlID="txtEntryYear" Name="yr" PropertyName="Value" Type="String" />
                                            <asp:ControlParameter ControlID="txtStatus" Name="stat" PropertyName="Value" Type="String" />
                                            <asp:ControlParameter ControlID="txtFaculty" DefaultValue="-" Name="prog" PropertyName="Value" Type="String" />
                                        </SelectParameters>
                                        <UpdateParameters>
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
                                            <asp:Parameter Name="Original_form_no" Type="String" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                    <asp:ObjectDataSource ID="dsFaculty" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetUserFaculties" TypeName="SecurityTableAdapters.my_aspnet_user_facultiesTableAdapter">
                                        <SelectParameters>
                                            <asp:SessionParameter DefaultValue="-" Name="unm" SessionField="username" Type="String" />
                                        </SelectParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <dx:ASPxGridViewExporter ID="GVE_Applicants" runat="server" GridViewID="gv_ApplicantInfo" ExportedRowType="All">
                                    </dx:ASPxGridViewExporter></td>
                            </tr>
                            <tr>
                                <td colspan="2" class="auto-style1">
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <dx:ASPxPopupControl ID="pop_response" runat="server" HeaderText="Campus Dynamics" Height="100px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td align="center">
                                                            <br />
                                                            <br />
                                                            <br />
                                                            <dx:ASPxLabel ID="lbl_comments" runat="server" Font-Bold="False" ForeColor="Red">
                                                            </dx:ASPxLabel>
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
                                <td colspan="2">
                                    <dx:ASPxPopupControl ID="popup_applicants" runat="server" AllowDragging="True" ClientInstanceName="popupdetails" CloseAction="CloseButton" HeaderText="Campus Dynamics" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" ShowPageScrollbarWhenModal="True" Width="300px">
                                        <ClientSideEvents CloseUp="function(s, e) {
	gvapplicants.Refresh();
}" />
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
                                            </dx:PopupControlContentControl>
                                        </ContentCollection>
                                    </dx:ASPxPopupControl>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <dx:ASPxPopupControl ID="popup_email_chat" runat="server" AllowDragging="True" ClientInstanceName="popupdetails" CloseAction="CloseButton" HeaderText="Campus Dynamics" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" ShowPageScrollbarWhenModal="True" Width="500px">
                                        <ClientSideEvents CloseUp="function(s, e) {
	gvapplicants.Refresh();
}" />
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxLabel ID="ASPxLabel7" runat="server" Font-Bold="True" Text="Applicant Name:">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxLabel ID="lbl_applicant_name" runat="server">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxLabel ID="ASPxLabel8" runat="server" Font-Bold="True" Text="Applicant Email:">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxLabel ID="lbl_email" runat="server">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxLabel ID="ASPxLabel9" runat="server" Font-Bold="True" Text="Subject">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxTextBox ID="txt_subject" runat="server" Height="35px" Width="100%">
                                                            </dx:ASPxTextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxLabel ID="ASPxLabel10" runat="server" Font-Bold="True" Text="Message:">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxHtmlEditor ID="txt_email" runat="server" Height="300px" Width="500px">
                                                            </dx:ASPxHtmlEditor>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            &nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdSendEmail" runat="server" Height="35px" OnClick="cmdSendEmail_Click" Text="Send Email" Width="100%">
                                                                <ClientSideEvents Click="function(s, e) {
	
e.processOnServer = confirm('Send Email?');
if(e.processOnServer)
{
lp_loading.Show();
}

}" />
                                                                <Image IconID="mail_mail_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
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

