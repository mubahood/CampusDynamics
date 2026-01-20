<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StudentProfile.aspx.cs" Inherits="COOPERP_StudentInfo_StudentProfile" %>

<%@ Register src="../../UserControls/StudentInfo/BioData.ascx" tagname="BioData" tagprefix="uc1" %>

<%@ Register src="../../UserControls/Results/StudentResults.ascx" tagname="StudentResults" tagprefix="uc2" %>

<%@ Register src="../../UserControls/StudentInfo/RegistrationHistory.ascx" tagname="RegistrationHistory" tagprefix="uc3" %>

<%@ Register src="../../UserControls/StudentInfo/api_stud_ledger.ascx" tagname="api_stud_ledger" tagprefix="uc4" %>

<%@ Register src="../../UserControls/StudentInfo/Course_Registrations.ascx" tagname="Course_Registrations" tagprefix="uc5" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">



        .style1
        {
            width: 100%;
        }
        .style1_Profile {
            width: 239px;
        }
        .auto-style2 {
            width: 96px;
        }
        .auto-style4 {
            width: 172px;
        }
        .auto-style5 {
            width: 73px;
        }
        .auto-style8 {
            width: 75px;
        }

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


        .auto-style11 {
            width: 134px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%" EnableTabScrolling="True">
            <TabPages>
                <dx:TabPage Text=" Bio Data">
                    <TabImage IconID="mail_contact_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <uc1:BioData ID="BioData1" runat="server" />
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text=" Results">
                    <TabImage IconID="filterelements_listbox_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <uc2:StudentResults ID="StudentResults1" runat="server" />
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text=" Faculty Registration">
                    <TabImage IconID="mail_editcontact_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <uc3:RegistrationHistory ID="RegistrationHistory1" runat="server" />
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text="Course Registration">
                    <TabImage IconID="support_issue_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <uc5:Course_Registrations ID="Course_Registrations1" runat="server" />
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text=" Fees Ledger">
                    <TabImage IconID="arrange_withtextwrapping_bottomright_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <uc4:api_stud_ledger ID="api_stud_ledger1" runat="server" />
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text=" Documents">
                    <TabImage IconID="export_exporttodocx_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td class="auto-style5">&nbsp;</td>
                                    <td class="auto-style4">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style5">Document:</td>
                                    <td class="auto-style4">
                                        <dx:ASPxComboBox ID="txtDoc" runat="server" SelectedIndex="0">
                                            <Items>
                                                <dx:ListEditItem Selected="True" Text="Statement of Results" Value="ResultStatement" />
                                                <dx:ListEditItem Text="Draft Transcript" Value="Draft Transcript" />
                                                <dx:ListEditItem Text="Partial Transcript" Value="Partial Transcript" />
                                            </Items>
                                        </dx:ASPxComboBox>
                                    </td>
                                    <td>
                                        <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" Text="Print" Width="170px">
                                            <Image Url="~/COOPERP/images/printer.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style5">&nbsp;</td>
                                    <td class="auto-style4">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style5">&nbsp;</td>
                                    <td class="auto-style4">&nbsp;</td>
                                    <td>
                                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                                            <ContentCollection>
                                                <dx:PopupControlContentControl runat="server">
                                                </dx:PopupControlContentControl>
                                            </ContentCollection>
                                        </dx:ASPxPopupControl>
                                    </td>
                                </tr>
                            </table>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text=" Photo Updates">
                    <TabImage IconID="content_image_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td class="auto-style2">&nbsp;</td>
                                    <td class="style1_Profile">
                                        &nbsp;</td>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style2">Image File:</td>
                                    <td class="style1_Profile">
                                        <dx:ASPxUploadControl ID="txtFilePath" runat="server">
                                        </dx:ASPxUploadControl>
                                    </td>
                                    <td>
                                        <dx:ASPxButton ID="cmdAttach" runat="server" OnClick="cmdAttach_Click" Text="Attach Photo" Width="170px">
                                            <ClientSideEvents Click="function(s, e) {
	 e.processOnServer = confirm('Attach Photo?');
}" />
                                            <Image Url="~/COOPERP/images/tick-button.png">
                                            </Image>
                                        </dx:ASPxButton>
                                        <dx:ASPxButton ID="cmdAttachSign" runat="server" OnClick="cmdAttachSign_Click" Text="Attach Signature" Width="170px">
                                            <ClientSideEvents Click="function(s, e) {
	 e.processOnServer = confirm('Attach Signature?');
}" />
                                            <Image Url="~/COOPERP/images/tick-button.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style2">&nbsp;</td>
                                    <td class="style1_Profile">
                                        <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                            </table>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text=" Change Reg. No">
                    <TabImage IconID="actions_refresh2_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td class="auto-style8">&nbsp;</td>
                                    <td class="auto-style11">&nbsp;</td>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td class="auto-style8">&nbsp;</td>
                                    <td class="auto-style11">New Registration No:</td>
                                    <td>
                                        <dx:ASPxTextBox ID="txtNewRegNo" runat="server" NullText="Enter New Reg Number" Width="200px">
                                        </dx:ASPxTextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style8">&nbsp;</td>
                                    <td class="auto-style11">&nbsp;</td>
                                    <td>
                                        <dx:ASPxButton ID="ASPxButton1" runat="server" OnClick="ASPxButton1_Click" Text="Change Number" Width="200px">
                                            <Image Url="~/COOPERP/images/tick-button.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="auto-style8">&nbsp;</td>
                                    <td class="auto-style11">&nbsp;</td>
                                    <td>
                                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                            <HeaderStyle HorizontalAlign="Center" />
                                            <ContentCollection>
                                                <dx:PopupControlContentControl runat="server">
                                                    <table align="center" class="style1">
                                                        <tr>
                                                            <td align="center">
                                                                <br />
                                                                <br />
                                                                <dx:ASPxLabel ID="lbl_comments" runat="server" ForeColor="Red" style="font-weight: 700">
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
                            </table>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                 <dx:TabPage Text="Sponsor Details">
                    <TabImage IconID="arrange_withtextwrapping_topleft_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl ID="ContentControl1" runat="server">
                            <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowHeader="False" Width="100%">
                                <PanelCollection>
                                    <dx:PanelContent ID="PanelContent1" runat="server">
                                        <table class="style1">
                                            <tr>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxGridView ID="SponsorGridView1" runat="server" AutoGenerateColumns="False" DataSourceID="ds_sponsors" KeyFieldName="ID" Width="100%" OnInitNewRow="SponsorGridView1_InitNewRow">
                                                        <SettingsBehavior AllowFocusedRow="True" />
                                                        <EditFormLayoutProperties ColCount="2">
                                                            <Items>
                                                                <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="reg_no">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="SponsorName">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="Contact">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right">
                                                                </dx:EditModeCommandLayoutItem>
                                                            </Items>
                                                        </EditFormLayoutProperties>
                                                        <Columns>
                                                            <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="5px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="5px">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="reg_no" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                <EditFormSettings Visible="True" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="SponsorName" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Contact" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            </dx:GridViewDataTextColumn>
                                                        </Columns>
                                                    </dx:ASPxGridView>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:ObjectDataSource ID="ds_sponsors" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBystudentNo" TypeName="otherDetailsTableAdapters.acad_studetsponsorsTableAdapter" UpdateMethod="Update">
                                                        <DeleteParameters>
                                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                        </DeleteParameters>
                                                        <InsertParameters>
                                                            <asp:Parameter Name="reg_no" Type="String" />
                                                            <asp:Parameter Name="SponsorName" Type="String" />
                                                            <asp:Parameter Name="Contact" Type="String" />
                                                        </InsertParameters>
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="reg" SessionField="regno" Type="String" />
                                                        </SelectParameters>
                                                        <UpdateParameters>
                                                            <asp:Parameter Name="reg_no" Type="String" />
                                                            <asp:Parameter Name="SponsorName" Type="String" />
                                                            <asp:Parameter Name="Contact" Type="String" />
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
                <dx:TabPage Text="Kin Info">
                    <TabImage IconID="businessobjects_bodetails_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl ID="ContentControl2" runat="server">
                            <dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" ShowHeader="False" Width="100%">
                                <PanelCollection>
                                    <dx:PanelContent ID="PanelContent2" runat="server">
                                        <table class="style1">
                                            <tr>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxGridView ID="NextofKinGridView1" runat="server" AutoGenerateColumns="False" DataSourceID="ds_kinIfo" KeyFieldName="ID" Width="100%" OnInitNewRow="NextofKinGridView1_InitNewRow">
                                                        <SettingsBehavior AllowFocusedRow="True" />
                                                        <EditFormLayoutProperties ColCount="2">
                                                            <Items>
                                                                <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="reg_no">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="NextKin">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="Relationship">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="Contact">
                                                                </dx:GridViewColumnLayoutItem>
                                                                <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right">
                                                                </dx:EditModeCommandLayoutItem>
                                                            </Items>
                                                        </EditFormLayoutProperties>
                                                        <Columns>
                                                            <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="5px">
                                                            </dx:GridViewCommandColumn>
                                                            <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="1" Width="5px">
                                                                <EditFormSettings Visible="False" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="reg_no" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                                <EditFormSettings Visible="True" />
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn Caption="Next of Kin" FieldName="NextKin" ShowInCustomizationForm="True" VisibleIndex="3">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Contact" ShowInCustomizationForm="True" VisibleIndex="4">
                                                            </dx:GridViewDataTextColumn>
                                                            <dx:GridViewDataTextColumn FieldName="Relationship" ShowInCustomizationForm="True" VisibleIndex="5">
                                                            </dx:GridViewDataTextColumn>
                                                        </Columns>
                                                    </dx:ASPxGridView>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:ObjectDataSource ID="ds_kinIfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataByStudent" TypeName="otherDetailsTableAdapters.nextofkinTableAdapter" UpdateMethod="Update">
                                                        <DeleteParameters>
                                                            <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                        </DeleteParameters>
                                                        <InsertParameters>
                                                            <asp:Parameter Name="reg_no" Type="String" />
                                                            <asp:Parameter Name="NextKin" Type="String" />
                                                            <asp:Parameter Name="Contact" Type="String" />
                                                            <asp:Parameter Name="Relationship" Type="String" />
                                                        </InsertParameters>
                                                        <SelectParameters>
                                                            <asp:SessionParameter Name="reg" SessionField="regno" Type="String" />
                                                        </SelectParameters>
                                                        <UpdateParameters>
                                                            <asp:Parameter Name="reg_no" Type="String" />
                                                            <asp:Parameter Name="NextKin" Type="String" />
                                                            <asp:Parameter Name="Contact" Type="String" />
                                                            <asp:Parameter Name="Relationship" Type="String" />
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
                <dx:TabPage Text="Other information">
                    <TabImage IconID="actions_insert_16x16">
                    </TabImage>
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <table class="style1">
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="OtherGridView1" runat="server" AutoGenerateColumns="False" DataSourceID="others_ODS" KeyFieldName="IDz" OnInitNewRow="OtherGridView1_InitNewRow" Width="100%">
                                            <Columns>
                                                <dx:GridViewCommandColumn ShowEditButton="True" ShowInCustomizationForm="True" ShowNewButtonInHeader="True" VisibleIndex="0" Width="5px">
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataTextColumn FieldName="IDz" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Registration N" FieldName="reg_no" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Alternative Email " FieldName="Alt_email" ShowInCustomizationForm="True" VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Residence" FieldName="CResidence" ShowInCustomizationForm="True" VisibleIndex="6">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Graduation Yr" FieldName="expYrGraduation" ShowInCustomizationForm="True" VisibleIndex="8">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Disability" ShowInCustomizationForm="True" VisibleIndex="9">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="paymentOptions" ShowInCustomizationForm="True" VisibleIndex="10">
                                                    <PropertiesComboBox>
                                                        <Items>
                                                            <dx:ListEditItem Text="One off" Value="One off" />
                                                            <dx:ListEditItem Text="Per Module  " Value="Per Module  " />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataTextColumn Caption="Alternative Phone" FieldName="Phone2" ShowInCustomizationForm="True" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Faculty" FieldName="Facultyx" ShowInCustomizationForm="True" VisibleIndex="3">
                                                    <PropertiesComboBox DataSourceID="faclty_ods" TextField="faculty_name" TextFormatString="{0}" ValueField="faculty_name">
                                                        <Columns>
                                                            <dx:ListBoxColumn FieldName="faculty_name" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn FieldName="MaritalStatus" ShowInCustomizationForm="True" VisibleIndex="7">
                                                    <PropertiesComboBox>
                                                        <Items>
                                                            <dx:ListEditItem Text="Married" Value="Married" />
                                                            <dx:ListEditItem Text="Single" Value="Single" />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                            </Columns>
                                        </dx:ASPxGridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:ObjectDataSource ID="others_ODS" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataByotherDetails" TypeName="otherDetailsTableAdapters.otherstudent_infoTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_IDz" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="reg_no" Type="String" />
                                                <asp:Parameter Name="Alt_email" Type="String" />
                                                <asp:Parameter Name="CResidence" Type="String" />
                                                <asp:Parameter Name="expYrGraduation" Type="String" />
                                                <asp:Parameter Name="Disability" Type="String" />
                                                <asp:Parameter Name="paymentOptions" Type="String" />
                                                <asp:Parameter Name="Facultyx" Type="String" />
                                                <asp:Parameter Name="MaritalStatus" Type="String" />
                                                <asp:Parameter Name="Phone2" Type="String" />
                                            </InsertParameters>
                                            <SelectParameters>
                                                <asp:SessionParameter Name="reg" SessionField="regno" Type="String" />
                                            </SelectParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="reg_no" Type="String" />
                                                <asp:Parameter Name="Alt_email" Type="String" />
                                                <asp:Parameter Name="CResidence" Type="String" />
                                                <asp:Parameter Name="expYrGraduation" Type="String" />
                                                <asp:Parameter Name="Disability" Type="String" />
                                                <asp:Parameter Name="paymentOptions" Type="String" />
                                                <asp:Parameter Name="Facultyx" Type="String" />
                                                <asp:Parameter Name="MaritalStatus" Type="String" />
                                                <asp:Parameter Name="Phone2" Type="String" />
                                                <asp:Parameter Name="Original_IDz" Type="UInt32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="faclty_ods" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="otherDetailsTableAdapters.acad_facultyTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_faculty_code" Type="String" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="faculty_name" Type="String" />
                                                <asp:Parameter Name="faculty_code" Type="String" />
                                                <asp:Parameter Name="faculty_dean" Type="String" />
                                                <asp:Parameter Name="faculty_contacts" Type="String" />
                                                <asp:Parameter Name="abbrev" Type="String" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="faculty_name" Type="String" />
                                                <asp:Parameter Name="faculty_dean" Type="String" />
                                                <asp:Parameter Name="faculty_contacts" Type="String" />
                                                <asp:Parameter Name="abbrev" Type="String" />
                                                <asp:Parameter Name="Original_faculty_code" Type="String" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                    </td>
                                </tr>
                            </table>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
            </TabPages>
           
            <TabStyle Height="30px">
                <Paddings Padding="10px" />
            </TabStyle>
           
        </dx:ASPxPageControl>
    
    </div>
    </form>
</body>
</html>
