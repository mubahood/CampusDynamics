<%@ Control Language="C#" AutoEventWireup="true" CodeFile="RegistrationNoCentre.ascx.cs" Inherits="UserControls_Admissions_RegistrationNoCentre" %>
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
        width: 286px;
    }
    .auto-style4 {
        width: 95px;
    }
    .auto-style5 {
        width: 69px;
    }


    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" 
    Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>

                        <table class="style1">
                            <tr>
                                <td colspan="2">
                                    <table cellpadding="0" cellspacing="0" class="style1">
                                        
                                        <tr>
                                            <td style="text-align: center">
                                                <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_regno_centre.png">
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
                                            <td class="auto-style4">
                                                <dx:ASPxLabel ID="ASPxLabel1" runat="server" Text="Entry Year">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td class="auto-style1">
                                                <dx:ASPxComboBox ID="txtEntryYear" runat="server" Width="250px" AutoPostBack="True" Height="35px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style5">
                                                <dx:ASPxLabel ID="ASPxLabel5" runat="server" Text="Intake">
                                                </dx:ASPxLabel>
                                                :</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtIntake" runat="server" SelectedIndex="7" Width="200px" AutoPostBack="True" Height="35px">
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
                                                        <dx:ListEditItem Selected="True" Text="AUGUST" Value="AUGUST" />
                                                        <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
                                                        <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                                        <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                                        <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style4">
                                                <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text="Status">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td class="auto-style1">
                                                <dx:ASPxComboBox ID="txtStatus" runat="server" SelectedIndex="0" Width="250px" AutoPostBack="True" Height="35px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                    <Items>
                                                        <dx:ListEditItem Selected="True" Text="Admitted" Value="1" />
                                                        <dx:ListEditItem Text="Assigned Letter" Value="2" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style5">
                                                Session:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtSession" runat="server" AutoPostBack="True" SelectedIndex="0" Width="200px" Height="35px" DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn FieldName="Session" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style4">
                                                <dx:ASPxLabel ID="ASPxLabel3" runat="server" Text="Programme">
                                                </dx:ASPxLabel>
                                            </td>
                                            <td class="auto-style1">
                                                <dx:ASPxComboBox ID="txtProg" runat="server" DataSourceID="dsProgrammes" DropDownWidth="600px" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="250px" AutoPostBack="True" SelectedIndex="0" Height="35px">
                                                    <ClientSideEvents SelectedIndexChanged="function(s, e) {
	}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="100px" />
                                                        <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="500px" />
                                                        <dx:ListBoxColumn Caption="Abbrev" FieldName="abbrev" Width="80px" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style5">&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdUpdate" runat="server" Text="Accept Applicant" Width="200px" OnClick="cmdUpdate_Click" Height="35px">
                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('You are about to Accept the Selected Applicant(s), Are you Sure?');
   if(e.processOnServer==true)
   {
	lp_loading.Show();
   }

}" />
                                                    <Image Url="~/COOPERP/images/tick-button.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style4">&nbsp;</td>
                                            <td class="auto-style1">&nbsp;</td>
                                            <td class="auto-style5">&nbsp;</td>
                                            <td>
                                                <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" Text="Print List" Width="200px" Height="35px">
                                                    <ClientSideEvents Click="function(s, e) {
	}" />
                                                    <Image Url="~/COOPERP/images/printer.png">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td align="right" valign="top">
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <dx:ASPxGridView ID="gv_ApplicantInfo" runat="server" AutoGenerateColumns="False" DataSourceID="dsApplicants" KeyFieldName="stud_entry_no" Width="100%" OnHtmlDataCellPrepared="gv_ApplicantInfo_HtmlDataCellPrepared">
                                        <SettingsPager PageSize="100" AlwaysShowPager="True" Position="TopAndBottom">
                                        </SettingsPager>
                                        <SettingsEditing Mode="EditForm">
                                        </SettingsEditing>
                                        <Settings ShowFilterRow="True" />
                                        <SettingsBehavior AllowFocusedRow="True" />
                                        <SettingsDataSecurity AllowEdit="False" />
                                        <SettingsSearchPanel Visible="True" />
                                        <Columns>
                                            <dx:GridViewDataTextColumn Caption="Entry No" FieldName="stud_entry_no" ReadOnly="True" VisibleIndex="1" Width="120px">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Student Name" FieldName="stud_name" VisibleIndex="3">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Gender" FieldName="stud_sex" VisibleIndex="4">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Nationality" FieldName="stud_nationality" VisibleIndex="5">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Registration No" FieldName="stud_reg_no" VisibleIndex="2" Width="200px">
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewDataTextColumn Caption="Session" FieldName="adm_session" VisibleIndex="6">
                                                <EditFormSettings Visible="False" />
                                            </dx:GridViewDataTextColumn>
                                            <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowClearFilterButton="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                            </dx:GridViewCommandColumn>
                                        </Columns>
                                    </dx:ASPxGridView>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:ObjectDataSource ID="dsApplicants" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_GetBasicApplicantListTableAdapter" UpdateMethod="UpdateRegNo">
                                        <SelectParameters>
                                            <asp:ControlParameter ControlID="txtEntryYear" Name="acad" PropertyName="Value" Type="String" />
                                            <asp:ControlParameter ControlID="txtIntake" Name="intk" PropertyName="Value" Type="String" />
                                            <asp:ControlParameter ControlID="txtProg" Name="prog" PropertyName="Value" Type="String" />
                                            <asp:ControlParameter ControlID="txtSession" DefaultValue="-" Name="sess" PropertyName="Value" Type="String" />
                                        </SelectParameters>
                                        <UpdateParameters>
                                            <asp:Parameter Name="stud_reg_no" Type="String" />
                                            <asp:Parameter Name="Original_stud_entry_no" Type="String" />
                                        </UpdateParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:ObjectDataSource ID="dsstudysessions" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update" DeleteMethod="Delete">
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
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter">
                                    </asp:ObjectDataSource>
                                    <dx:ASPxPopupControl ID="pop_response" runat="server" HeaderText="Campus Dynamics" Height="100px" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                        <ContentCollection>
                                            <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                                <table class="style1">
                                                    <tr>
                                                        <td align="center">
                                                            <br />
                                                            <br />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center">
                                                            <dx:ASPxLabel ID="lbl_comments" runat="server" Font-Bold="False" ForeColor="Red">
                                                            </dx:ASPxLabel>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center">
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
                                    <dx:ASPxPopupControl ID="popup_applicants" runat="server" AllowDragging="True" ClientInstanceName="popupdetails" CloseAction="CloseButton" ContentUrl="~/COOPERP/Admissions/ApplicantDetails.aspx" HeaderText="Campus Dynamics" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" ShowPageScrollbarWhenModal="True" Width="300px">
                                        <ClientSideEvents CloseUp="function(s, e) {
	gvapplicants.Refresh();
}" />
                                        <ContentCollection>
                                            <dx:PopupControlContentControl ID="PopupControlContentControl3" runat="server">
                                            </dx:PopupControlContentControl>
                                        </ContentCollection>
                                    </dx:ASPxPopupControl>
                                    <dx:ASPxPopupControl ID="pop_print" runat="server" AllowDragging="True" CloseAction="CloseButton" ContentUrl="~/COOPERP/Admissions/XtraReports/Reports.aspx" HeaderText="Document Printing ..." Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                                        <ContentCollection>
                                            <dx:PopupControlContentControl runat="server">
                                            </dx:PopupControlContentControl>
                                        </ContentCollection>
                                    </dx:ASPxPopupControl>
                                    <dx:ASPxLoadingPanel ID="lp_loading" runat="server" ClientInstanceName="lp_loading" Text="Processing. Please wait&amp;hellip;">
                        </dx:ASPxLoadingPanel>
                                </td>
                            </tr>
                        </table>
                  
        </ContentTemplate>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
