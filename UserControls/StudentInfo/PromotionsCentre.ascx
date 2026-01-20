<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PromotionsCentre.ascx.cs" Inherits="UserControls_StudentInfo_PromotionsCentre" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
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
    .auto-style5 {
        width: 110px;
    }
    .auto-style8 {
        width: 442px;
    }
    .auto-style11 {
        width: 110px;
        height: 37px;
    }
    .auto-style12 {
        width: 442px;
        height: 37px;
    }
    .auto-style13 {
        height: 37px;
    }
    .auto-style16 {
        width: 62px;
        height: 37px;
    }
    .auto-style17 {
        width: 220px;
        height: 37px;
    }
    .auto-style18 {
        width: 62px;
    }
    .auto-style19 {
        width: 220px;
    }
    .auto-style20 {
        width: 76px;
        height: 37px;
    }
    .auto-style21 {
        width: 76px;
    }
</style>



                            <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" ShowCollapseButton="true" ShowHeader="False" Width="100%">
                                <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table id="table5" class="style1">
                <tr>
                    <td>
                        <table id="table6" cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_promotions.png">
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
                        <table id="table7" class="style1">
                            <tr>
                                <td class="auto-style20">Entry Year:</td>
                                <td class="auto-style17">
                                    <dx:ASPxComboBox ID="txtentryyear" runat="server" AutoPostBack="True" Height="35px" Width="200px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style11">Academic Year:</td>
                                <td class="auto-style12">
                                    <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Height="35px" Width="200px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style13">&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style20">Intake:</td>
                                <td class="auto-style17">
                                    <dx:ASPxComboBox ID="txtIntake" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="8" Width="200px">
                                        <ClientSideEvents SelectedIndexChanged="function(s, e) {
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
                                <td class="auto-style11">Semester:</td>
                                <td class="auto-style12">
                                    <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="200px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                        </Items>
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style13"></td>
                            </tr>
                            <tr>
                                <td class="auto-style21">&nbsp;</td>
                                <td class="auto-style19">
                                    <dx:ASPxButton ID="cmdSettings" runat="server" Height="35px" Text="Promote Selected" Width="200px" AutoPostBack="False">
                                       <ClientSideEvents Click="function(s, e) {
                                            
	
}" />
                                        <Image IconID="navigation_previous_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="auto-style5">Programme:</td>
                                <td class="auto-style8">
                                    <dx:ASPxComboBox ID="txtProgramme" runat="server" AutoPostBack="True" DataSourceID="dsProgrammes" Height="35px" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="200px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="25px" />
                                            <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style21">&nbsp;</td>
                                <td class="auto-style19">
                                    <dx:ASPxButton ID="cmdDelete" runat="server" AutoPostBack="False" Height="35px" Text="Delete Selected" Width="200px" OnClick="cmdDelete_Click">
                                        <ClientSideEvents Click="function(s, e) {
                                            e.processOnServer = confirm('Are you Sure?');
	
}" />
                                        <Image IconID="actions_cancel_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td class="auto-style5">&nbsp;</td>
                                <td class="auto-style8">
                                    &nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvStudentInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvStudentInfo" DataSourceID="dsStudentInfo" Width="100%" KeyFieldName="ID" OnHtmlDataCellPrepared="gvStudentInfo_HtmlDataCellPrepared">
                            <SettingsCommandButton>
                                <UpdateButton RenderMode="Link">
                                </UpdateButton>
                                <CancelButton RenderMode="Link">
                                </CancelButton>
                                <UpdateButton RenderMode="Link">
                                </UpdateButton>
                                <CancelButton RenderMode="Link">
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
                            <SettingsDataSecurity AllowInsert="False" />
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" Visible="False" VisibleIndex="1" ReadOnly="True">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="regno" VisibleIndex="2" Caption="Student No">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="acad_year" VisibleIndex="6" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="semester" VisibleIndex="7" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Year" FieldName="studyyear" VisibleIndex="9">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="id_cardStatus" VisibleIndex="10" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="reg_CardStatus" VisibleIndex="12" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="examClearance" VisibleIndex="13" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn FieldName="examClearanceDate" VisibleIndex="14" Visible="False">
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn FieldName="clearedBy" Visible="False" VisibleIndex="15">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="registeredBy" VisibleIndex="16" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Stud Name" VisibleIndex="4" FieldName="stud_name">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="AllPages" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px" ShowClearFilterButton="True">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Reg Status" FieldName="regstatus" VisibleIndex="8">
                                    <PropertiesComboBox>
                                        <Items>
                                            <dx:ListEditItem Text="REGISTERED" Value="REGISTERED" />
                                            <dx:ListEditItem Text="UNREGISTERED" Value="UNREGISTERED" />
                                            <dx:ListEditItem Text="HALTED" Value="HALTED" />
                                            <dx:ListEditItem Text="DEAD YEAR" Value="DEAD YEAR" />
                                            <dx:ListEditItem Text="DISCONTINUED" Value="DISCONTINUED" />
                                        </Items>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Residence" FieldName="residence_status" VisibleIndex="11">
                                    <PropertiesComboBox>
                                        <Items>
                                            <dx:ListEditItem Text="RESIDENT" Value="RESIDENT" />
                                            <dx:ListEditItem Text="NON RESIDENT" Value="NON RESIDENT" />
                                        </Items>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataTextColumn Caption="Programme" FieldName="progname" VisibleIndex="5">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Completion Status" FieldName="stat" VisibleIndex="17">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Reg No" FieldName="FullRegNo" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <SettingsContextMenu Enabled="True">
                            </SettingsContextMenu>
                            <SettingsPager AlwaysShowPager="True" Position="TopAndBottom">
                            </SettingsPager>
                            <SettingsEditing Mode="Batch">
                                <BatchEditSettings StartEditAction="Click" />
                            </SettingsEditing>
                            <Settings ShowFilterRow="True" />
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridViewExporter ID="GVE_Students" runat="server" GridViewID="gvStudentInfo">
                        </dx:ASPxGridViewExporter>
                        <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter"></asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsStudentInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSemesterListing" TypeName="PromotionDataTableAdapters.acad_registrationTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="acad_year" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="regstatus" Type="String" />
                                <asp:Parameter Name="studyyear" Type="UInt32" />
                                <asp:Parameter Name="id_cardStatus" Type="String" />
                                <asp:Parameter Name="residence_status" Type="String" />
                                <asp:Parameter Name="reg_CardStatus" Type="String" />
                                <asp:Parameter Name="examClearance" Type="String" />
                                <asp:Parameter Name="examClearanceDate" Type="DateTime" />
                                <asp:Parameter Name="clearedBy" Type="String" />
                                <asp:Parameter Name="registeredBy" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" DefaultValue="-" />
                                <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="Int32" DefaultValue="0" />
                                <asp:ControlParameter ControlID="txtIntake" Name="intk" PropertyName="Value" Type="String" DefaultValue="-" />
                                <asp:ControlParameter ControlID="txtProgramme" DefaultValue="-" Name="prog" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtentryyear" DefaultValue="" Name="entryyear" PropertyName="Value" Type="Int32" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="acad_year" Type="String" />
                                <asp:Parameter Name="semester" Type="UInt32" />
                                <asp:Parameter Name="regstatus" Type="String" />
                                <asp:Parameter Name="studyyear" Type="UInt32" />
                                <asp:Parameter Name="id_cardStatus" Type="String" />
                                <asp:Parameter Name="residence_status" Type="String" />
                                <asp:Parameter Name="reg_CardStatus" Type="String" />
                                <asp:Parameter Name="examClearance" Type="String" />
                                <asp:Parameter Name="examClearanceDate" Type="DateTime" />
                                <asp:Parameter Name="clearedBy" Type="String" />
                                <asp:Parameter Name="registeredBy" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="New Academic Year &amp; Semester" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Modal="True" PopupElementID="cmdSettings" Width="350px">
                            <HeaderImage IconID="miscellaneous_wizard_16x16">
                            </HeaderImage>
                            <ClientSideEvents CloseUp="function(s, e) {
	gvStudentInfo.Refresh();
}" />
                            <ContentStyle>
                                <Paddings Padding="20px" />
                            </ContentStyle>
                            <HeaderStyle>
                            <Paddings Padding="10px" />
                            </HeaderStyle>
                            <ModalBackgroundStyle BackColor="#0066FF">
                            </ModalBackgroundStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>New Academic Year:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxComboBox ID="txtNewAcadYear" runat="server" AutoPostBack="True" Height="35px" Width="100%">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>New Semester:</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxComboBox ID="txtNewSemester" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="100%">
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
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxCheckBox ID="txtChangeYear" runat="server" CheckState="Unchecked" Font-Size="Small" Text="Change Year of Study">
                                                </dx:ASPxCheckBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxButton ID="cmdPromote" runat="server" Height="35px" OnClick="cmdCreateList_Click" Text="Promote Selected" Width="100%">
                                                    <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Are you Sure?');
}" />
                                                    <Image IconID="navigation_previous_16x16">
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
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <br />
                                                <br />
                                                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red" style="font-weight: 700">
                                                </dx:ASPxLabel>
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
                        &nbsp;</td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
                                    </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>
