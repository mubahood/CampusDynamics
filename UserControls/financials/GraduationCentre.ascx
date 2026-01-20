<%@ Control Language="C#" AutoEventWireup="true" CodeFile="GraduationCentre.ascx.cs" Inherits="UserControls_Results_GraduationCentre" %>
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
    .auto-style5 {
        width: 78px;
    }
    .auto-style6 {
        width: 360px;
    }
    .auto-style7 {
        width: 165px;
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
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_graduation.png">
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
                                            <td class="auto-style5">Programme:</td>
                                            <td class="auto-style6">
                                                <dx:ASPxComboBox ID="txtProgramme" runat="server" DataSourceID="dsProgrammes" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="350px" AutoPostBack="True" OnSelectedIndexChanged="txtProgramme_SelectedIndexChanged" Height="35px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
lp_grads.Show();
	}" />
                                                    <Columns>
                                                        <dx:ListBoxColumn Caption="Code" FieldName="progcode" />
                                                        <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                                        <dx:ListBoxColumn Caption="Abbreviation" FieldName="abbrev" />
                                                    </Columns>
                                                </dx:ASPxComboBox>
                                            </td>
                                            <td class="auto-style3">Academic Year:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtAcadYear" runat="server" AutoPostBack="True" Height="35px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
lp_grads.Show();

	}" />
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5">&nbsp;</td>
                                            <td class="auto-style6">
                                                <table cellspacing="0" class="style1">
                                                    <tr>
                                                        <td class="auto-style7">
                                                            <dx:ASPxButton ID="cmdClear" runat="server" Height="35px" OnClick="cmdClear_Click" Text="Clear Student" Width="175px">
                                                                <Image IconID="content_checkbox_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdCancel" runat="server" Height="35px" OnClick="cmdCancel_Click" Text="Cancel Clearance" Width="173px">
                                                                <Image IconID="actions_cancel_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td class="auto-style3">Study Year:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtYear" runat="server" SelectedIndex="2" AutoPostBack="True" Height="35px">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	lp_grads.Show();

}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="1" Value="1" />
                                                        <dx:ListEditItem Text="2" Value="2" />
                                                        <dx:ListEditItem Selected="True" Text="3" Value="3" />
                                                        <dx:ListEditItem Text="4" Value="4" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style5">&nbsp;</td>
                                            <td class="auto-style6">
                                                <table cellspacing="0" class="style1">
                                                    <tr>
                                                        <td class="auto-style7">
                                                            <dx:ASPxButton ID="cmdExportExcel" runat="server" OnClick="cmdExportExcel_Click" Text="Export Excel" Width="175px" Height="35px">
                                                                <Image Url="~/COOPERP/images/export_excel.png">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                        <td>
                                                            <dx:ASPxButton ID="cmdRefresh" runat="server" OnClick="cmdRefresh_Click" Text="Refresh List" Width="173px" Height="35px">
                                                                <ClientSideEvents Click="function(s, e) {
lp_grads.Show();	
}" />
                                                                <Image IconID="scheduling_recurrence_16x16">
                                                                </Image>
                                                            </dx:ASPxButton>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td class="auto-style3">List Status:</td>
                                            <td>
                                                <dx:ASPxComboBox ID="txtStatus" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0">
                                                    <ClientSideEvents TextChanged="function(s, e) {
	lp_grads.Show();

}" />
                                                    <Items>
                                                        <dx:ListEditItem Text="GRADUANDS" Value="GRAD" Selected="True" />
                                                    </Items>
                                                </dx:ASPxComboBox>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="text-align: right" valign="bottom" width="170px">
                                    <dx:ASPxTextBox ID="txtSearch" runat="server" AutoCompleteType="Search" Height="27px" NullText="Enter Search Text" Width="170px">
                                        <ClientSideEvents TextChanged="function(s, e) {
	gvMarksheetInfo.Refresh();
}" />
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxTextBox>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvMarksheetInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvMarksheetInfo" DataSourceID="dsMarksheetInfo" KeyFieldName="ID" Width="100%">
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="ID" VisibleIndex="1" ReadOnly="True" Caption="SNo" Width="40px">
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Reg No" FieldName="stud_reg_no" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Graduation Year" FieldName="comp_year" VisibleIndex="4" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Current Balance" FieldName="cur_balance" VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Clearance Status" FieldName="clear_status" VisibleIndex="6">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Cleared By" FieldName="cleared_by" VisibleIndex="7">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Date Cleared" FieldName="date_cleared" VisibleIndex="8">
                                    <PropertiesDateEdit DisplayFormatString="dd MMM, yyyy h:mm tt">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn FieldName="stud_name" VisibleIndex="3" Caption="Student Name">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Programme" VisibleIndex="9" FieldName="progid" Visible="False">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="AllPages" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="Legder" VisibleIndex="10" Width="35px">
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdLedger" runat="server" ImageUrl="~/COOPERP/images/clipboard-invoice.png" OnClick="cmdProfile_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <SettingsPager PageSize="50" AlwaysShowPager="True" Position="TopAndBottom">
                            </SettingsPager>
                            <Settings ShowFilterRowMenu="True" />
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
                        <asp:ObjectDataSource ID="dsMarksheetInfo" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAnnualGradList" TypeName="GraduationFinanceTableAdapters.acad_graduation_clearanceTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_ID" Type="Int32" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="ID" Type="Int32" />
                                <asp:Parameter Name="stud_reg_no" Type="String" />
                                <asp:Parameter Name="comp_year" Type="String" />
                                <asp:Parameter Name="cur_balance" Type="String" />
                                <asp:Parameter Name="clear_status" Type="String" />
                                <asp:Parameter Name="cleared_by" Type="String" />
                                <asp:Parameter Name="date_cleared" Type="DateTime" />
                                <asp:Parameter Name="stud_name" Type="String" />
                                <asp:Parameter Name="progid" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtProgramme" Name="prog" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtAcadYear" Name="compyr" PropertyName="Value" Type="String" DefaultValue="-" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="stud_reg_no" Type="String" />
                                <asp:Parameter Name="comp_year" Type="String" />
                                <asp:Parameter Name="cur_balance" Type="String" />
                                <asp:Parameter Name="clear_status" Type="String" />
                                <asp:Parameter Name="cleared_by" Type="String" />
                                <asp:Parameter Name="date_cleared" Type="DateTime" />
                                <asp:Parameter Name="stud_name" Type="String" />
                                <asp:Parameter Name="progid" Type="String" />
                                <asp:Parameter Name="Original_ID" Type="Int32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
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
                        <dx:ASPxLoadingPanel ID="lp_grads" runat="server" ClientInstanceName="lp_grads" Modal="True">
                        </dx:ASPxLoadingPanel>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_msgBox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table align="center" class="style1">
                                        <tr>
                                            <td align="center">
                                                <br />
                                                <br />
                                                <dx:ASPxLabel ID="lbl_msg" runat="server" ForeColor="Red" style="font-weight: 700">
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
                <tr>
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
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="cmdExportExcel" />
        </Triggers>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>