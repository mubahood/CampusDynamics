<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ClearanceCentre.ascx.cs" Inherits="UserControls_financials_ClearanceCentre" %>
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


    
    .style2
    {
        height: 38px;
    }
    .style3
    {
        height: 42px;
    }

    .style4
    {
        height: 23px;
    }
    .auto-style7 {
        width: 104px;
    }
    .auto-style10 {
        width: 197px;
    }
    .auto-style12 {
        width: 329px;
    }
    .auto-style13 {
        width: 90px;
    }
    </style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" HeaderText="" 
    ShowHeader="False" Width="100%">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table id="table3" class="style1">
                <tr>
                    <td>
                        <table id="table4" cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_clearancecentre.png">
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
                        <table id="table5" class="style1">
                            <tr>
                                <td class="auto-style7">Academic Year:</td>
                                <td class="auto-style12">
                                    <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Height="35px" Width="300px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	}" />
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style13">Intake:</td>
                                <td class="auto-style10">
                                    <dx:ASPxComboBox ID="txtIntake" runat="server" Height="35px" SelectedIndex="9" Width="170px" AutoPostBack="True">
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
                                            <dx:ListEditItem Text="AUGUST" Value="AUGUST" />
                                            <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" Selected="True" />
                                            <dx:ListEditItem Text="OCTOBER" Value="OCTOBER" />
                                            <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                            <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                        </Items>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td>
                                    <dx:ASPxButton ID="cmdClear" runat="server" Height="35px" OnClick="cmdClear_Click" Text="Auto Clear Students" Width="170px" Enabled="False">
                                        <ClientSideEvents Click="function(s, e) {

e.processOnServer = confirm('Auto-Clear All Students?');
if(e.processOnServer==true)
{
panel_billling.Show();
}

	
}" />
                                        <Image Url="~/COOPERP/images/tick-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style7">Semester:</td>
                                <td class="auto-style12">
                                    <dx:ASPxComboBox ID="txtSemester" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="300px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                            <dx:ListEditItem Text="2" Value="2" />
                                            <dx:ListEditItem Text="3" Value="3" />
                                            <dx:ListEditItem Text="4" Value="4" />
                                        </Items>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style13">Status:</td>
                                <td class="auto-style10">
                                    <dx:ASPxComboBox ID="txtStatus" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="1">
                                        <Items>
                                            <dx:ListEditItem Text="Cleared" Value="Cleared" />
                                            <dx:ListEditItem Selected="True" Text="Pending" Value="Pending" />
                                            <dx:ListEditItem Text="Printed" Value="Printed" />
                                        </Items>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td>
                                    <dx:ASPxButton ID="cmdManualClearance" runat="server" Height="35px" OnClick="cmdManualClearance_Click" Text="Manually Clear" Width="170px">
                                        <ClientSideEvents Click="function(s, e) {

e.processOnServer = confirm('Manually Clear Students?');
if(e.processOnServer==true)
{
panel_billling.Show();
}

	
}" />
                                        <Image Url="~/COOPERP/images/tick-shield.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style7">Programme:</td>
                                <td class="auto-style12">
                                    <dx:ASPxComboBox ID="txtProgramme" runat="server" AutoPostBack="True" DataSourceID="dsProgrammes" Height="35px" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="300px">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="80px" />
                                            <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                        </Columns>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style13">Card Type:</td>
                                <td class="auto-style10">
                                    <dx:ASPxComboBox ID="txtCardType" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="EXAM PERMIT" Value="EXAMINATION" />
                                            <dx:ListEditItem Text="TEST PERMIT" Value="TEST" />
                                        </Items>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td style="text-align: left">
                                    <dx:ASPxButton ID="cmdRevoke" runat="server" Height="35px" OnClick="cmdRevoke_Click" Text="Revoke Clearance" Width="170px">
                                        <ClientSideEvents Click="function(s, e) {

e.processOnServer = confirm('Revoke Clearances?');
if(e.processOnServer==true)
{
panel_billling.Show();
}

	
}" />
                                        <Image Url="~/COOPERP/images/minus-button.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style7">Clearance Type:</td>
                                <td class="auto-style12">
                                    <dx:ASPxComboBox ID="txtClearanceType" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="300px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="Examination Clearance" Value="Examination" />
                                            <dx:ListEditItem Text="Registration Clearance" Value="Registration" />
                                        </Items>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style13">&nbsp;</td>
                                <td class="auto-style10">
                                    <dx:ASPxButton ID="cmdPrintCards" runat="server" Height="35px" OnClick="cmdPrintCards_Click" Text="Print Cards" Width="170px">
                                        <Image IconID="print_printer_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td style="text-align: left">
                                    <dx:ASPxButton ID="cmdIndicatePrinted" runat="server" Height="35px" OnClick="cmdIndicatePrinted_Click" Text="Indicate Printed" Width="170px">
                                        <ClientSideEvents Click="function(s, e) {

e.processOnServer = confirm('Indicate Printed Card?');
if(e.processOnServer==true)
{
panel_billling.Show();
}

	
}" />
                                        <Image IconID="print_defaultprinter_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                            <tr>
                                <td class="auto-style7">Fees Status:</td>
                                <td class="auto-style12">
                                    <dx:ASPxComboBox ID="txtFeesStatus" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="300px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="All" Value="All" />
                                            <dx:ListEditItem Text="Cleared" Value="Cleared" />
                                            <dx:ListEditItem Text="Pending" Value="Pending" />
                                        </Items>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td class="auto-style13">&nbsp;</td>
                                <td class="auto-style10">
                                    <dx:ASPxButton ID="cmdSecureImage" runat="server" Height="35px" Text="Secure Image" Width="170px">
                                        <ClientSideEvents Click="function(s, e) {	
}" />
                                        <Image IconID="content_image_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td style="text-align: left">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" Width="100%">
                            <TabPages>
                                <dx:TabPage Text=" Batch Clearance">
                                    <TabImage IconID="chart_chartsshowlegend_16x16">
                                    </TabImage>
                                    <ContentCollection>
                                        <dx:ContentControl ID="ContentControl1" runat="server">
                                            <table id="table1" class="style1">
                                                <tr>
                                                    <td>&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <dx:ASPxGridView ID="gvLedger" runat="server" AutoGenerateColumns="False" DataSourceID="dsClearanceLists" Width="100%" KeyFieldName="ID">
                                                            <SettingsPager PageSize="20">
                                                            </SettingsPager>
                                                            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                                            <SettingsBehavior AllowFocusedRow="True" />
                                                            <SettingsSearchPanel Visible="True" />
                                                            <Columns>
                                                                <dx:GridViewDataTextColumn Caption="Name" FieldName="stud_names" ShowInCustomizationForm="True" VisibleIndex="4">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn FieldName="ID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="5">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Registration No" FieldName="regno" ShowInCustomizationForm="True" VisibleIndex="2">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Registration Status" FieldName="regstatus" ShowInCustomizationForm="True" VisibleIndex="6">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Study Year" FieldName="studyyear" ShowInCustomizationForm="True" VisibleIndex="7">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="ID Card Status" FieldName="id_cardStatus" ShowInCustomizationForm="True" VisibleIndex="8">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Residence" FieldName="residence_status" ShowInCustomizationForm="True" VisibleIndex="9">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Reg Card Stat" FieldName="reg_CardStatus" ShowInCustomizationForm="True" VisibleIndex="10">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Exam Clearance" FieldName="examClearance" ShowInCustomizationForm="True" VisibleIndex="11">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataDateColumn Caption="Date Cleared" FieldName="examClearanceDate" ShowInCustomizationForm="True" VisibleIndex="12">
                                                                </dx:GridViewDataDateColumn>
                                                                <dx:GridViewDataTextColumn Caption="Cleared By" FieldName="clearedBy" ShowInCustomizationForm="True" VisibleIndex="13">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataTextColumn Caption="Registered By" FieldName="registeredBy" ShowInCustomizationForm="True" VisibleIndex="14" Visible="False">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px" SelectAllCheckboxMode="AllPages" ShowClearFilterButton="True">
                                                                </dx:GridViewCommandColumn>
                                                                <dx:GridViewDataTextColumn Caption="Stud No" FieldName="entryno" ShowInCustomizationForm="True" VisibleIndex="3" Visible="False">
                                                                </dx:GridViewDataTextColumn>
                                                                <dx:GridViewDataImageColumn Caption="Photo" FieldName="photofile" ShowInCustomizationForm="True" VisibleIndex="1" Width="60px">
                                                                    <PropertiesImage ImageUrlFormatString="~/COOPERP/StudentInfo/photos/{0}" ImageWidth="60px">
                                                                    </PropertiesImage>
                                                                </dx:GridViewDataImageColumn>
                                                                <dx:GridViewDataTextColumn Caption="Balance" FieldName="cur_balance" ShowInCustomizationForm="True" VisibleIndex="15">
                                                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                                    </PropertiesTextEdit>
                                                                </dx:GridViewDataTextColumn>
                                                            </Columns>
                                                        </dx:ASPxGridView>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:ObjectDataSource ID="dsClearanceLists" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentAccountingDataTableAdapters.fin_GetClearanceListsTableAdapter">
                                                            <SelectParameters>
                                                                <asp:ControlParameter ControlID="txtAcadYear" Name="acad" PropertyName="Value" Type="String" />
                                                                <asp:ControlParameter ControlID="txtSemester" Name="sem" PropertyName="Value" Type="Int32" />
                                                                <asp:ControlParameter ControlID="txtClearanceType" Name="clearance_type" PropertyName="Value" Type="String" />
                                                                <asp:ControlParameter ControlID="txtStatus" Name="stat" PropertyName="Value" Type="String" />
                                                                <asp:ControlParameter ControlID="txtIntake" Name="intk" PropertyName="Value" Type="String" />
                                                                <asp:ControlParameter ControlID="txtProgramme" Name="prog" PropertyName="Value" Type="String" />
                                                                <asp:ControlParameter ControlID="txtFeesStatus" Name="f_stat" PropertyName="Value" Type="String" />
                                                            </SelectParameters>
                                                        </asp:ObjectDataSource>
                                                    </td>
                                                </tr>
                                            </table>
                                        </dx:ContentControl>
                                    </ContentCollection>
                                </dx:TabPage>
                                <dx:TabPage Text=" Clearance Analysis">
                                    <TabImage IconID="chart_stackedbar_16x16">
                                    </TabImage>
                                    <ContentCollection>
                                        <dx:ContentControl ID="ContentControl2" runat="server">
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
                <tr>
                    <td>
                        <dx:ASPxLoadingPanel ID="panel_billling" runat="server" ClientInstanceName="panel_billling" Modal="True" Text="Processing...Please wait&amp;hellip;">
                        </dx:ASPxLoadingPanel>
                        <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter"></asp:ObjectDataSource>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_msgbox" runat="server" HeaderText="Campus Dynamics ERP" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px" Height="150px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <br />
                                                <br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" ForeColor="Red" style="font-weight: 700;">
                                                </dx:ASPxLabel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="style3"></td>
                                        </tr>
                                    </table>
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_securephoto" runat="server" ContentUrl="~/COOPERP/financials/secure_photo.aspx" HeaderText="Secure Image" Modal="True" PopupElementID="cmdSecureImage" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                            <HeaderImage IconID="content_image_16x16">
                            </HeaderImage>
                            <HeaderStyle>
                            <Paddings Padding="15px" />
                            </HeaderStyle>
                            <ModalBackgroundStyle BackColor="Black">
                            </ModalBackgroundStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
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
