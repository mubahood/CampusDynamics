<%@ Control Language="C#" AutoEventWireup="true" CodeFile="applications.ascx.cs" Inherits="UserControls_Admissions_applications" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>


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


    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <dx:ASPxCallbackPanel ID="cbk_applications" runat="server" ClientInstanceName="callback_applications" OnCallback="cbk_applications_Callback" Width="100%">
                <PanelCollection>
                    <dx:PanelContent runat="server">
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
                                            <td>
                                                <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Entry Year">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtEntryYear" runat="server" Width="250px" Height="35px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	callback_applications.PerformCallback(&quot;EntryYearChange&quot;);
}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td>
                                                <dx:ASPxLabel ID="ASPxLabel5" runat="server" Text="Intake">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtIntake" runat="server" SelectedIndex="1" Width="250px" Height="35px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	callback_applications.PerformCallback(&quot;EntryYearChange&quot;);
}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="ALL" Value="ALL" />
                                                        <dx:ListEditItem Text="JANUARY" Value="JANUARY" Selected="True" />
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
                                            <td>
                                                <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text="Status">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtStatus" runat="server" SelectedIndex="0" Width="250px" Height="35px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	callback_applications.PerformCallback(&quot;EntryYearChange&quot;);
}" />
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="Pending" Value="0" />
                                                        <dx:ListEditItem Text="Admitted" Value="1" />
                                                        <dx:ListEditItem Text="Assigned Letter" Value="2" />
                                                        <dx:ListEditItem Text="Rejected" Value="8" />
                                                        <dx:ListEditItem Text="In Waiting" Value="9" />
                                                        <dx:ListEditItem Text="Under Investigation" Value="10" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td>
                                                <dx:ASPxLabel ID="ASPxLabel7" runat="server" Text="Processing">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtNewStatus" runat="server" SelectedIndex="0" Width="250px" Height="35px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	callback_applications.PerformCallback(&quot;EntryYearChange&quot;);
}" />
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="Revoke Admission" Value="0" />
                                                        <dx:ListEditItem Text="Admit Students" Value="1" />
                                                        <dx:ListEditItem Text="Assign Letters" Value="2" />
                                                        <dx:ListEditItem Text="Reject Candidates" Value="8" />
                                                        <dx:ListEditItem Text="Place in Waiting" Value="9" />
                                                        <dx:ListEditItem Text="Under Investigation" Value="10" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxLabel ID="ASPxLabel8" runat="server" Text="Faculty|School">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtFaculty" runat="server" DataSourceID="dsFaculty" DropDownWidth="600px" Height="35px" TextField="faculty_name" TextFormatString="{0}-{1}" ValueField="faculty_code" Width="250px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	callback_applications.PerformCallback(&quot;EntryYearChange&quot;);
}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="faculty_code" Width="100px" />
                                                        <dx:ListBoxColumn Caption="Faculty|School" FieldName="faculty_name" Width="500px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td>Letter Template:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txt_letter" runat="server" DataSourceID="ds_lettertemplates" TextField="letter_ref" TextFormatString="{0}" ValueField="letter_ref" Width="250px" Height="35px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Template" FieldName="letter_ref" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxLabel ID="ASPxLabel3" runat="server" Text="Programme">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtProg" runat="server" DataSourceID="dsProgrammes" DropDownWidth="600px" Height="35px" TextField="progname" TextFormatString="{0}-{1}" ValueField="progcode" Width="250px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	callback_applications.PerformCallback(&quot;EntryYearChange&quot;);
}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="100px" />
                                                        <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="500px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdUpdate" runat="server" AutoPostBack="False" Enabled="False" Text="Update Status" Width="250px" Height="35px">
                                                    <ClientSideEvents Click="function(s, e) {
	callback_applications.PerformCallback(&quot;UpdateStatus&quot;);
}" />
                                                    <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdNew" runat="server" AutoPostBack="False" Height="35px" Text="New Applicant" Width="250px">
                                                    <ClientSideEvents Click="function(s, e) {
	callback_applications.PerformCallback(&quot;AddApplicant&quot;);
}" />
                                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdPrintLetters" runat="server" AutoPostBack="False" Height="35px" OnClick="cmdPrintLetters_Click" Text="Print Admission Letter" Width="250px">
                                                    <ClientSideEvents Click="function(s, e) {
	callback_applications.PerformCallback(&quot;AddApplicant&quot;);
}" />
                                                    <Image Url="~/COOPERP/images/printer.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdChangeCourse" runat="server" AutoPostBack="False" Height="35px" OnClick="cmdChangeCourse_Click" Text="Change Course" Width="250px">
                                                   <%-- <ClientSideEvents Click="function(s, e) {
	callback_applications.PerformCallback(&quot;AddApplicant&quot;);
}" />--%>
                                                    <Image IconID="actions_convert_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdAssignHall" runat="server" Height="35px"  Text="Assign Hall" Width="250px" AutoPostBack="False">
                                                    <ClientSideEvents Click="function(s, e) {
	callback_applications.PerformCallback(&quot;AssignHall&quot;);
}" />
                                                    <Image IconID="navigation_home_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdSendELetter" runat="server" AutoPostBack="False" Height="35px" OnClick="cmdSendELetter_Click" Text="Send Email Letter" Width="250px">
                                                    <ClientSideEvents Click="function(s, e) {
	callback_applications.PerformCallback(&quot;AddApplicant&quot;);
}" />
                                                    <Image IconID="mail_attach_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                            <td>&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdBillingUpdate" runat="server" Height="35px" OnClick="cmdBillingUpdate_Click" Text="Change Billing System" ToolTip="Click to change the Billing system of Selected Applicants" Width="250px">
                                                    <Image IconID="edit_edit_16x16">
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
                                                            <dx:ASPxButton ID="btn_Email" runat="server" Text="Add E-Mail" Width="100px" Height="35px">
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
                                            <td align="Right" valign="Bottom">
                                                <dx:ASPxButton ID="btn_ocupations" runat="server" Height="30px" Text="Add Occupations" Width="200px">
                                                    <Image IconID="dashboards_initialstate_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <dx:ASPxGridView ID="gv_ApplicantInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvapplicants" DataSourceID="ds_ApplicantInfo" KeyFieldName="stud_entry_no" OnCustomErrorText="gv_ApplicantInfo_CustomErrorText" OnInitNewRow="gv_ApplicantInfo_InitNewRow" Width="100%" OnHtmlDataCellPrepared="gv_ApplicantInfo_HtmlDataCellPrepared" OnRowInserting="gv_ApplicantInfo_RowInserting">
                                        <SettingsDataSecurity AllowDelete="False" />
                                        <SettingsPopup>
                                            <EditForm Height="600px" HorizontalAlign="WindowCenter" Modal="True" VerticalAlign="WindowCenter" Width="1000px" />
                                        </SettingsPopup>
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
                                            <dx:GridViewDataTextColumn Caption="Entry No" FieldName="stud_entry_no" ShowInCustomizationForm="True" VisibleIndex="1" Width="100px" ReadOnly="True">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Name" FieldName="stud_name" ShowInCustomizationForm="True" VisibleIndex="6">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Sponsor" FieldName="stud_sponsor" ShowInCustomizationForm="True" Visible="False" VisibleIndex="37">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Sponsor Contact" FieldName="sponsor_contact" ShowInCustomizationForm="True" Visible="False" VisibleIndex="38">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Entry Year" FieldName="stud_entry_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataDateColumn Caption="Birth Date" FieldName="stud_birthdate" ShowInCustomizationForm="True" Visible="False" VisibleIndex="8">
                                                <PropertiesDateEdit DisplayFormatInEditMode="True" DisplayFormatString="{0:dd-MMM-yyyy}" Height="35px">
                                                </PropertiesDateEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataDateColumn>
                                            <dx:GridViewDataTextColumn Caption="Phone No" FieldName="stud_phone" ShowInCustomizationForm="True" VisibleIndex="25" Width="150px">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Next Of Kin" FieldName="next_kin" ShowInCustomizationForm="True" Visible="False" VisibleIndex="29">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Physical Address" FieldName="stud_phy_address" ShowInCustomizationForm="True" Visible="False" VisibleIndex="21">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="E-mail" FieldName="stud_email" ShowInCustomizationForm="True" VisibleIndex="26" Width="200px">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Spouse Name" FieldName="spouse_name" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="O level School" FieldName="olevel_school" ShowInCustomizationForm="True" Visible="False" VisibleIndex="32">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="A  level School" FieldName="alevel_school" ShowInCustomizationForm="True" Visible="False" VisibleIndex="34">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Referee Name" FieldName="referee_name" ShowInCustomizationForm="True" Visible="False" VisibleIndex="41">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Referee Contacts" FieldName="referee_contacts" ShowInCustomizationForm="True" Visible="False" VisibleIndex="42">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Referee Comments" FieldName="referee_comments" ShowInCustomizationForm="True" Visible="False" VisibleIndex="43">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Health Comments" FieldName="health_comments" ShowInCustomizationForm="True" Visible="False" VisibleIndex="44">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="O level Index No" FieldName="olevel_index" ShowInCustomizationForm="True" Visible="False" VisibleIndex="33">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="A level Index No" FieldName="alevel_index" ShowInCustomizationForm="True" Visible="False" VisibleIndex="35">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Spouse Contacts" FieldName="spouse_contacts" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Post Box" FieldName="post_box" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Home District" FieldName="home_district" ShowInCustomizationForm="True" Visible="False" VisibleIndex="24">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Kin Contacts" FieldName="kin_contacts" ShowInCustomizationForm="True" Visible="False" VisibleIndex="31">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Kin Relationship" FieldName="kin_relationship" ShowInCustomizationForm="True" Visible="False" VisibleIndex="30">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="A  level Year" FieldName="alevel_year" ShowInCustomizationForm="True" Visible="False" VisibleIndex="36">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Hall" FieldName="hall" ShowInCustomizationForm="True" Visible="False" VisibleIndex="45">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Disabilities" FieldName="physicalDisability" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                <PropertiesTextEdit Height="35px">
                                                </PropertiesTextEdit>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Registration No" FieldName="stud_reg_no" ShowInCustomizationForm="True" VisibleIndex="5" Width="150px">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="progname" ShowInCustomizationForm="True" Visible="False" VisibleIndex="52">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Session" FieldName="stud_session" ShowInCustomizationForm="True" VisibleIndex="53" Width="150px">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Status" FieldName="statusName" ShowInCustomizationForm="True" Visible="False" VisibleIndex="54">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn FieldName="fac_name" ShowInCustomizationForm="True" Visible="False" VisibleIndex="55">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="20px" SelectAllCheckboxMode="Page">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Study Campus" FieldName="stud_campus" ShowInCustomizationForm="True" Visible="False" VisibleIndex="3">
                                                <PropertiesComboBox DataSourceID="ds_campuses" TextField="campus_name" TextFormatString="{0}" ValueField="campus_code" Height="35px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Campus" FieldName="campus_name" />
                                                    </Columns>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Gender" FieldName="stud_sex" ShowInCustomizationForm="True" VisibleIndex="7" Width="100px">
                                                <PropertiesComboBox Height="35px">
                                                    <Items>
                                                        <dx:ListEditItem Text="FEMALE" Value="F" />
                                                        <dx:ListEditItem Text="MALE" Value="M" />
                                                        <dx:ListEditItem Text="OTHER" Value="OTHER" />
                                                    </Items>
                                                </PropertiesComboBox>
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataCheckColumn FieldName="IsAccountTransfered" ShowInCustomizationForm="True" Visible="False" VisibleIndex="40">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataCheckColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Marital Status" FieldName="stud_mar_stat" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                <PropertiesComboBox Height="35px">
                                                    <Items>
                                                        <dx:ListEditItem Text="SINGLE" Value="SINGLE" />
                                                        <dx:ListEditItem Text="MARRIED" Value="MARRIED" />
                                                        <dx:ListEditItem Text="DIVORCED" Value="DIVORCED" />
                                                    </Items>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Nationality" FieldName="stud_nationality" ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                                <PropertiesComboBox DataSourceID="ds_nationality" IncrementalFilteringMode="Contains" TextField="country_name" TextFormatString="{0}" ValueField="country_name" Height="35px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Country" FieldName="country_name" />
                                                    </Columns>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Religion" FieldName="stud_religion" ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                                                <PropertiesComboBox Height="35px">
                                                    <Items>
                                                        <dx:ListEditItem Text="MUSLIM" Value="MUSLIM" />
                                                        <dx:ListEditItem Text="CHRISTIAN" Value="CHRISTIAN" />
                                                        <dx:ListEditItem Text="ADVENTIST" Value="ADVENTIST" />
                                                        <dx:ListEditItem Text="ANGLICAN" Value="ANGLICAN" />
                                                        <dx:ListEditItem Text="BORN AGAIN" Value="BORN AGAIN" />
                                                        <dx:ListEditItem Text="BAHAI" Value="BAHAI" />
                                                        <dx:ListEditItem Text="CATHOLIC" Value="CATHOLIC" />
                                                        <dx:ListEditItem Text="JEHOVAS WITNESS" Value="JEHOVAS WITNESS" />
                                                        <dx:ListEditItem Text="LUTHERAN" Value="LUTHERAN" />
                                                        <dx:ListEditItem Text="ORTHODOX" Value="ORTHODOX" />
                                                        <dx:ListEditItem Text="PENTACOSTAL" Value="PENTACOSTAL" />
                                                        <dx:ListEditItem Text="PROTESTANT" Value="PROTESTANT" />
                                                        <dx:ListEditItem Text="SDA" Value="SDA" />
                                                        <dx:ListEditItem Text="OTHERS" Value="OTHERS" />
                                                    </Items>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Residence Country" FieldName="residence_country" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                                <PropertiesComboBox DataSourceID="dscountry" IncrementalFilteringMode="Contains" TextField="CountryName" TextFormatString="{1}" ValueField="CountryName" Height="35px">
                                                    <Columns>
                                                        <dx:ListBoxColumn FieldName="Code" Name="100px" />
                                                        <dx:ListBoxColumn FieldName="CountryName" />
                                                    </Columns>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Intake" FieldName="stud_intake" ShowInCustomizationForm="True" Visible="False" VisibleIndex="47">
                                                <PropertiesComboBox IncrementalFilteringMode="Contains" Height="35px">
                                                    <Items>
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
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Entry Method" FieldName="stud_entry_method" ShowInCustomizationForm="True" Visible="False" VisibleIndex="49">
                                                <PropertiesComboBox Height="35px">
                                                    <Items>
                                                        <dx:ListEditItem Text="ACCESS" Value="ACCESS" />
                                                        <dx:ListEditItem Text="CERTIFICATE" Value="CERTIFICATE" />
                                                        <dx:ListEditItem Text="DIRECT" Value="DIRECT" />
                                                        <dx:ListEditItem Text="DIPLOMA" Value="DIPLOMA" />
                                                        <dx:ListEditItem Text="MATURE AGE" Value="MATURE AGE" />
                                                        <dx:ListEditItem Text="BACHELORS DEGREE" Value="BACHELORS DEGREE" />
                                                        <dx:ListEditItem Text="SKILLING" Value="SKILLING" />
                                                        <dx:ListEditItem Text="HIGHER EDUCATION CERTIFICATE(HEC)" Value="HIGHER EDUCATION CERTIFICATE(HEC)" />
                                                        <dx:ListEditItem Text="O LEVEL" Value="O LEVEL" />
                                                        <dx:ListEditItem Text="A LEVEL" Value="A LEVEL" />
                                                    </Items>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Letter Pick Point" FieldName="letter_campus" ShowInCustomizationForm="True" Visible="False" VisibleIndex="51">
                                                <PropertiesComboBox DataSourceID="ds_campuses" TextField="campus_name" TextFormatString="{0}" ValueField="campus_name" Height="35px">
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Campus" FieldName="campus_name" />
                                                    </Columns>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewCommandColumn ButtonType="Image" ShowClearFilterButton="True" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="57" Width="50px" ButtonRenderMode="Image">
                                            </dx:GridViewCommandColumn>
                                            <dx:GridViewDataTextColumn Caption="Details" ShowInCustomizationForm="True" VisibleIndex="56" Width="40px">
                                                <EditFormSettings Visible="False" />
                                                <DataItemTemplate>
                                                    <asp:ImageButton ID="btnDetails" runat="server" ImageUrl="~/COOPERP/images/clipboard--plus.png" OnClick="btnDetails_Click" ToolTip="Click to Capture Applicant Choices &amp; Scores " />
                                                </DataItemTemplate>
                                                <CellStyle HorizontalAlign="Center">
                                                </CellStyle>
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Title" FieldName="title" ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                                                <PropertiesComboBox Height="35px">
                                                    <Items>
                                                        <dx:ListEditItem Text="MR." Value="MR." />
                                                        <dx:ListEditItem Text="MS." Value="MS." />
                                                        <dx:ListEditItem Text="MRS." Value="MRS." />
                                                    </Items>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Occupation" FieldName="stud_occupation" ShowInCustomizationForm="True" Visible="False" VisibleIndex="28">
                                                <PropertiesComboBox DataSourceID="dsOccupations" Height="35px" TextField="Occupation" TextFormatString="{0}" ValueField="Occupation">
                                                    <Columns>
                                                        <dx:ListBoxColumn FieldName="Occupation" />
                                                    </Columns>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                            <dx:GridViewDataComboBoxColumn Caption="Spouse Occupation" FieldName="spouseOccupation" ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                                                <PropertiesComboBox DataSourceID="dsOccupations" Height="35px" TextField="Occupation" TextFormatString="{0}" ValueField="Occupation">
                                                    <Columns>
                                                        <dx:ListBoxColumn FieldName="Occupation" />
                                                    </Columns>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                        </Columns>
                                        <SettingsBehavior AllowFocusedRow="True" AllowSelectByRowClick="True" ConfirmDelete="True" />
                                        <SettingsPager AlwaysShowPager="True" PageSize="30" Position="TopAndBottom">
                                            <Summary Text="Page {0} of {1} [{2} Applicant(s)]" />
                                        </SettingsPager>
                                        <SettingsEditing EditFormColumnCount="1" Mode="PopupEditForm">
                                        </SettingsEditing>
                                        <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
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
                                    <asp:ObjectDataSource ID="ds_ApplicantInfo" runat="server" DeleteMethod="DeleteApplicant" InsertMethod="AddApplicant" OldValuesParameterFormatString="original_{0}" SelectMethod="GetApplicants" TypeName="ApplicationsBLL" UpdateMethod="EditApplicantData">
                                        <DeleteParameters>
                                            <asp:Parameter Name="original_stud_entry_no" Type="String" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="stud_entry_no" Type="String" />
                                            <asp:Parameter Name="stud_name" Type="String" />
                                            <asp:Parameter Name="stud_sex" Type="String" />
                                            <asp:Parameter Name="stud_nationality" Type="String" />
                                            <asp:Parameter Name="stud_religion" Type="String" />
                                            <asp:Parameter Name="stud_entry_method" Type="String" />
                                            <asp:Parameter Name="stud_sponsor" Type="String" />
                                            <asp:Parameter Name="sponsor_contact" Type="String" />
                                            <asp:Parameter Name="stud_entry_year" Type="String" />
                                            <asp:Parameter Name="stud_birthdate" Type="DateTime" />
                                            <asp:Parameter Name="stud_phone" Type="String" />
                                            <asp:Parameter Name="next_kin" Type="String" />
                                            <asp:Parameter Name="stud_phy_address" Type="String" />
                                            <asp:Parameter Name="stud_email" Type="String" />
                                            <asp:Parameter Name="stud_mar_stat" Type="String" />
                                            <asp:Parameter Name="stud_campus" Type="String" />
                                            <asp:Parameter Name="IsAccountTransfered" Type="UInt16" />
                                            <asp:Parameter Name="spouse_name" Type="String" />
                                            <asp:Parameter Name="residence_country" Type="String" />
                                            <asp:Parameter Name="olevel_school" Type="String" />
                                            <asp:Parameter Name="alevel_school" Type="String" />
                                            <asp:Parameter Name="referee_name" Type="String" />
                                            <asp:Parameter Name="referee_contacts" Type="String" />
                                            <asp:Parameter Name="referee_comments" Type="String" />
                                            <asp:Parameter Name="letter_campus" Type="String" />
                                            <asp:Parameter Name="health_comments" Type="String" />
                                            <asp:Parameter Name="olevel_index" Type="String" />
                                            <asp:Parameter Name="alevel_index" Type="String" />
                                            <asp:Parameter Name="spouse_contacts" Type="String" />
                                            <asp:Parameter Name="post_box" Type="String" />
                                            <asp:Parameter Name="home_district" Type="String" />
                                            <asp:Parameter Name="stud_occupation" Type="String" />
                                            <asp:Parameter Name="kin_contacts" Type="String" />
                                            <asp:Parameter Name="kin_relationship" Type="String" />
                                            <asp:Parameter Name="alevel_year" Type="UInt32" />
                                            <asp:Parameter Name="stud_intake" Type="String" />
                                            <asp:Parameter Name="spouseOccupation" Type="String" />
                                            <asp:Parameter Name="title" Type="String" />
                                            <asp:Parameter Name="physicalDisability" Type="String" />
                                            <asp:Parameter Name="prog" Type="String" />
                                        </InsertParameters>
                                        <SelectParameters>
                                            <asp:ControlParameter ControlID="txtEntryYear" Name="entryyr" PropertyName="Value" Type="Int32" />
                                            <asp:ControlParameter ControlID="txtStatus" Name="stat" PropertyName="Value" Type="Int32" />
                                            <asp:ControlParameter ControlID="txtProg" Name="progID" PropertyName="Value" Type="String" />
                                            <asp:ControlParameter ControlID="txtIntake" Name="intake" PropertyName="Value" Type="String" />
                                        </SelectParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="original_stud_entry_no" Type="String" />
                                            <asp:Parameter Name="stud_name" Type="String" />
                                            <asp:Parameter Name="stud_sex" Type="String" />
                                            <asp:Parameter Name="stud_nationality" Type="String" />
                                            <asp:Parameter Name="stud_religion" Type="String" />
                                            <asp:Parameter Name="stud_entry_method" Type="String" />
                                            <asp:Parameter Name="stud_sponsor" Type="String" />
                                            <asp:Parameter Name="sponsor_contact" Type="String" />
                                            <asp:Parameter Name="stud_entry_year" Type="String" />
                                            <asp:Parameter Name="stud_birthdate" Type="DateTime" />
                                            <asp:Parameter Name="stud_phone" Type="String" />
                                            <asp:Parameter Name="next_kin" Type="String" />
                                            <asp:Parameter Name="stud_phy_address" Type="String" />
                                            <asp:Parameter Name="stud_email" Type="String" />
                                            <asp:Parameter Name="stud_mar_stat" Type="String" />
                                            <asp:Parameter Name="stud_campus" Type="String" />
                                            <asp:Parameter Name="IsAccountTransfered" Type="UInt16" />
                                            <asp:Parameter Name="spouse_name" Type="String" />
                                            <asp:Parameter Name="residence_country" Type="String" />
                                            <asp:Parameter Name="olevel_school" Type="String" />
                                            <asp:Parameter Name="alevel_school" Type="String" />
                                            <asp:Parameter Name="referee_name" Type="String" />
                                            <asp:Parameter Name="referee_contacts" Type="String" />
                                            <asp:Parameter Name="referee_comments" Type="String" />
                                            <asp:Parameter Name="letter_campus" Type="String" />
                                            <asp:Parameter Name="health_comments" Type="String" />
                                            <asp:Parameter Name="olevel_index" Type="String" />
                                            <asp:Parameter Name="alevel_index" Type="String" />
                                            <asp:Parameter Name="spouse_contacts" Type="String" />
                                            <asp:Parameter Name="post_box" Type="String" />
                                            <asp:Parameter Name="home_district" Type="String" />
                                            <asp:Parameter Name="stud_occupation" Type="String" />
                                            <asp:Parameter Name="kin_contacts" Type="String" />
                                            <asp:Parameter Name="kin_relationship" Type="String" />
                                            <asp:Parameter Name="alevel_year" Type="UInt32" />
                                            <asp:Parameter Name="stud_intake" Type="String" />
                                            <asp:Parameter Name="spouseOccupation" Type="String" />
                                            <asp:Parameter Name="title" Type="String" />
                                            <asp:Parameter Name="physicalDisability" Type="String" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                    <asp:ObjectDataSource ID="dsFaculty" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="FacultyDataTableAdapters.acad_facultyTableAdapter"></asp:ObjectDataSource>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:ObjectDataSource ID="ds_campuses" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_campusesTableAdapter" UpdateMethod="Update">
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
                                <td colspan="2" class="auto-style1">
                                    <asp:ObjectDataSource ID="dscountry" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.countryTableAdapter">
                                        <InsertParameters>
                                            <asp:Parameter Name="Code" Type="String" />
                                            <asp:Parameter Name="CountryName" Type="String" />
                                        </InsertParameters>
                                    </asp:ObjectDataSource>
                                    <asp:ObjectDataSource ID="ds_lettertemplates" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="Getadmissionletters" TypeName="admission_dataTableAdapters.acad_admissionlettersTableAdapter">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_letter_ref" Type="String" />
                                        </DeleteParameters>
                                        <SelectParameters>
                                            <asp:ControlParameter ControlID="txtEntryYear" Name="acad" PropertyName="Value" Type="String" />
                                            <asp:ControlParameter ControlID="txtIntake" Name="intak" PropertyName="Value" Type="String" />
                                        </SelectParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:ObjectDataSource ID="ds_nationality" runat="server" DeleteMethod="Delete" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.nationalitiesTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                        </DeleteParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
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
                                    <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetProgrammesByFaculty" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter">
                                        <SelectParameters>
                                            <asp:ControlParameter ControlID="txtFaculty" Name="faculty_code" PropertyName="Value" Type="String" />
                                        </SelectParameters>
                                    </asp:ObjectDataSource>
                                    <asp:ObjectDataSource ID="dsOccupations" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_applicant_occupationsTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="Occupation" Type="String" />
                                        </InsertParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="Occupation" Type="String" />
                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                    <asp:ObjectDataSource ID="dsBillingSystem" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentAccountingDataTableAdapters.fin_billing_systemsTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="bs_name" Type="String" />
                                            <asp:Parameter Name="bs_description" Type="String" />
                                            <asp:Parameter Name="bs_currency" Type="String" />
                                        </InsertParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="bs_name" Type="String" />
                                            <asp:Parameter Name="bs_description" Type="String" />
                                            <asp:Parameter Name="bs_currency" Type="String" />
                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                    <dx:ASPxPopupControl ID="pop_billing" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Billing System Editor" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
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
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td>New Billing System</td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <dx:ASPxComboBox ID="txtBillingSystem" runat="server" DataSourceID="dsBillingSystem" Height="35px" SelectedIndex="0" TextField="bs_name" TextFormatString="{1}" ValueField="ID" Width="100%">
                                                                            <Columns>
                                                                                <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="30px" />
                                                                                <dx:ListBoxColumn Caption="Billing System" FieldName="bs_name" Width="250px" />
                                                                            </Columns>
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <dx:ASPxButton ID="cmdApplyBilling" runat="server" Height="35px" OnClick="cmdApplyBilling_Click" Text="Apply New System" Width="100%">
                                                                            <Image IconID="edit_edit_16x16">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <br />
                                                            <dx:ASPxLabel ID="lbl_bill_comment" runat="server" ForeColor="Red" style="font-weight: 700">
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
                                    <asp:ObjectDataSource ID="ds_specialisation" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_specialisationTableAdapter" UpdateMethod="Update">
                                        <DeleteParameters>
                                            <asp:Parameter Name="Original_spec_id" Type="UInt32" />
                                        </DeleteParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="prog_id" Type="String" />
                                            <asp:Parameter Name="spec" Type="String" />
                                            <asp:Parameter Name="abbrev" Type="String" />
                                        </InsertParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="prog_id" Type="String" />
                                            <asp:Parameter Name="spec" Type="String" />
                                            <asp:Parameter Name="abbrev" Type="String" />
                                            <asp:Parameter Name="Original_spec_id" Type="UInt32" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                    <dx:ASPxPopupControl ID="pop_occupations" runat="server" CloseAction="CloseButton" HeaderText="OCCUPATIONS" Height="400px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="600px" PopupElementID="btn_ocupations">
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxGridView ID="gv_occupations" runat="server" AutoGenerateColumns="False" DataSourceID="dsOccupations" KeyFieldName="ID" Width="100%">
                                                                <Columns>
                                                                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewDataTextColumn FieldName="Occupation" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                    </dx:GridViewDataTextColumn>
                                                                    <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="3" Width="50px">
                                                                    </dx:GridViewCommandColumn>
                                                                    <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowNewButtonInHeader="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="50px">
                                                                    </dx:GridViewCommandColumn>
                                                                </Columns>
                                                            </dx:ASPxGridView>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </dx:PopupControlContentControl>
                                        </ContentCollection>
                                    </dx:ASPxPopupControl>
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
                                    <dx:ASPxPopupControl ID="popup_changeCourse" runat="server" AllowDragging="True" ClientInstanceName="popupdetails" CloseAction="CloseButton" HeaderText="Campus Dynamics" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" ShowPageScrollbarWhenModal="True" Width="400px">
                                        <ClientSideEvents CloseUp="function(s, e) {
	gvapplicants.Refresh();
}" />
                                        <ContentStyle>
                                            <Paddings Padding="20px" />
                                        </ContentStyle>
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td>
                                                            <br />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>New Programme</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxComboBox ID="txtNewProg" runat="server" DataSourceID="dsProgrammes" DropDownWidth="600px" Height="35px" TextField="progname" TextFormatString="{0}-{1}" ValueField="progcode" Width="100%">
                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	
}" />
                                                                <Columns>
                                                                    <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="100px" />
                                                                    <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="500px" />
                                                                </Columns>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>New Session:</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxComboBox ID="txtSession" runat="server" Height="35px" SelectedIndex="0" Width="100%" DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                                <Columns>
                                                                    <dx:ListBoxColumn FieldName="Session" />
                                                                </Columns>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>New Specialisation:</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxComboBox ID="txtNewSpec" runat="server" DataSourceID="ds_specialisation" DropDownWidth="600px" Height="35px" TextField="abbrev" TextFormatString="{1}" ValueField="spec_id" ValueType="System.Int32" Width="100%">
                                                                <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                                <Columns>
                                                                    <dx:ListBoxColumn Caption="Code" FieldName="spec_id" Width="100px" />
                                                                    <dx:ListBoxColumn Caption="Programme" FieldName="abbrev" Width="500px" />
                                                                </Columns>
                                                            </dx:ASPxComboBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdChangeProgramme" runat="server" Height="35px" Text="Change Course for Selected" Width="100%" OnClick="cmdChangeProgramme_Click">
                                                                <Image IconID="content_checkbox_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                    <tr>
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
            </dx:ASPxCallbackPanel>
        </ContentTemplate>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

