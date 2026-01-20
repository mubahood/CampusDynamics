<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentLockCentre.ascx.cs" Inherits="UserControls_financials_StudentLockCentre" %>
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
    margin-top: 0;
    margin-bottom: 0;
        
    }


    .ledger_style2
    {
        width: 52px;
    }
    .style4
    {
        width: 174px;
    }
    .auto-style5 {
        height: 170px;
    }
    .auto-style6 {
        width: 71px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="Student Legder Centre" Width="100%" ShowHeader="False">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <table class="style1">
                <tr>
                    <td>
                        <table id="table1" cellpadding="0" cellspacing="0" class="style1">
                            <tr>
                                <td style="text-align: center">
                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_stud_access.png">
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
                    <td>
                        <table class="style1">
                            <tr>
                                <td class="auto-style6">&nbsp;</td>
                                <td class="style4">&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style6">Campus:</td>
                                <td class="style4">
                                    <dx:ASPxComboBox ID="txtCampus" runat="server" AutoPostBack="True" DataSourceID="dsCampus" Height="35px" TextField="campus_name" TextFormatString="{0} :: {1}" ValueField="ID" ValueType="System.Int32" Width="250px">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="50px" />
                                            <dx:ListBoxColumn Caption="Campus Name" FieldName="campus_name" />
                                        </Columns>
                                    </dx:ASPxComboBox>
                                </td>
                                <td>
                                    <dx:ASPxButton ID="cmdRefresh" runat="server" Height="35px" OnClick="cmdRefresh_Click" Text="Refresh Students" Width="200px">
                                        <ClientSideEvents Click="function(s, e) {
	var app = e.processOnServer = confirm('Refresh Student List?');
  	 if(app){
lp_processing.Show()
}
}" />
                                        <Image IconID="actions_refresh2_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style6">Entry Year:</td>
                                <td class="style4">
                                    <dx:ASPxComboBox ID="txt_entry_year" runat="server" AutoPostBack="True" Height="35px" Width="250px">
                                    </dx:ASPxComboBox>
                                </td>
                                <td>
                                    <dx:ASPxButton ID="cmdChangeStatus" runat="server" Height="35px" Text="Change Access" Width="200px">
                                        <ClientSideEvents Click="function(s, e) {
}" />
                                        <Image IconID="actions_apply_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style6">Intake:</td>
                                <td class="style4">
                                    <dx:ASPxComboBox ID="txtintake" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="250px">
                                        <Items>
                                            <dx:ListEditItem Selected="True" Text="-" Value="-" />
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
                                    </dx:ASPxComboBox>
                                </td>
                                <td>
                                    <dx:ASPxButton ID="cmdExportData" runat="server" Height="35px" OnClick="cmdExportData_Click" Text="Export to Excel" Width="200px">
                                        <ClientSideEvents Click="function(s, e) {
	}" />
                                        <Image IconID="export_exporttoxlsx_16x16">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style6">Programme:</td>
                                <td class="style4">
                                    <dx:ASPxComboBox ID="txtProgramme" runat="server" AutoPostBack="True" DataSourceID="dsProgrammes" Height="35px" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="250px">
                                        <Columns>
                                            <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="50px" />
                                            <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                        </Columns>
                                        <Paddings PaddingLeft="5px" />
                                    </dx:ASPxComboBox>
                                </td>
                                <td>
                                    &nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="auto-style6">&nbsp;</td>
                                <td class="style4">&nbsp;</td>
                                <td>
                                    &nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvSchoolPayList" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvSchoolPayList" DataSourceID="dsStudAccounts" KeyFieldName="regno" OnHtmlDataCellPrepared="gvStudentList_HtmlDataCellPrepared" Width="100%">
                            <Settings ShowFooter="True" />
                            <SettingsBehavior AllowFocusedRow="True" />
                            <SettingsSearchPanel Visible="True" />
                            <Columns>
                                <dx:GridViewDataTextColumn Caption="Student No" FieldName="regno" ReadOnly="True" VisibleIndex="1">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Lock Reason" FieldName="lock_reason" VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Lock Date" FieldName="lock_date" VisibleIndex="6">
                                    <PropertiesDateEdit DisplayFormatString="dd MMM, yyyy h:mm tt">
                                    </PropertiesDateEdit>
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Locked By" FieldName="locked_by" VisibleIndex="7">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Student Name" FieldName="stud_name" VisibleIndex="3">
                                    <EditFormSettings Visible="False" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="progid" Visible="False" VisibleIndex="8">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Lock Status" FieldName="lock_status" VisibleIndex="4">
                                    <PropertiesComboBox>
                                        <Items>
                                            <dx:ListEditItem Text="Locked" Value="Locked" />
                                            <dx:ListEditItem Text="Open" Value="Open" />
                                        </Items>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataTextColumn Caption="Registration No" FieldName="entryno" VisibleIndex="2">
                                </dx:GridViewDataTextColumn>
                            </Columns>
                            <TotalSummary>
                                <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="amount_paid" ShowInColumn="Amount" ShowInGroupFooterColumn="Amount" SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                            </TotalSummary>
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ObjectDataSource ID="dsStudAccounts" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetStudentsByProgramme" TypeName="PortalSecurityTableAdapters.fin_studentlocksTableAdapter" UpdateMethod="Update">
                            <DeleteParameters>
                                <asp:Parameter Name="Original_regno" Type="String" />
                            </DeleteParameters>
                            <InsertParameters>
                                <asp:Parameter Name="regno" Type="String" />
                                <asp:Parameter Name="lock_status" Type="String" />
                                <asp:Parameter Name="lock_reason" Type="String" />
                                <asp:Parameter Name="lock_date" Type="DateTime" />
                                <asp:Parameter Name="locked_by" Type="String" />
                                <asp:Parameter Name="stud_name" Type="String" />
                                <asp:Parameter Name="progid" Type="String" />
                            </InsertParameters>
                            <SelectParameters>
                                <asp:ControlParameter ControlID="txtProgramme" DefaultValue="-" Name="progid" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtCampus" DefaultValue="0" Name="campus" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txt_entry_year" DefaultValue="0" Name="entryyr" PropertyName="Value" Type="String" />
                                <asp:ControlParameter ControlID="txtintake" DefaultValue="-" Name="intak" PropertyName="Value" Type="String" />
                            </SelectParameters>
                            <UpdateParameters>
                                <asp:Parameter Name="lock_status" Type="String" />
                                <asp:Parameter Name="lock_reason" Type="String" />
                                <asp:Parameter Name="lock_date" Type="DateTime" />
                                <asp:Parameter Name="locked_by" Type="String" />
                                <asp:Parameter Name="stud_name" Type="String" />
                                <asp:Parameter Name="progid" Type="String" />
                                <asp:Parameter Name="Original_regno" Type="String" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter"></asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsCampus" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_Campus" TypeName="CampusDataTableAdapters.acad_campusesTableAdapter" UpdateMethod="Update">
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
                        <dx:ASPxGridViewExporter ID="GVE_SchoolPay" runat="server" ExportedRowType="All" GridViewID="gvSchoolPayList">
                        </dx:ASPxGridViewExporter>
                        <dx:ASPxLoadingPanel ID="lp_processing" runat="server" ClientInstanceName="lp_processing" Modal="True" Text="Processing...">
                            <LoadingDivStyle BackColor="Black">
                            </LoadingDivStyle>
                        </dx:ASPxLoadingPanel>
                    </td>
                </tr>
                <tr>
                    <td class="auto-style5">
                        <dx:ASPxPopupControl ID="pop_details" runat="server" CloseAction="CloseButton" ContentUrl="~/COOPERP/financials/billitems.aspx" HeaderText="" Modal="True" PopupElementID="btn_billitems" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                        <dx:ASPxPopupControl ID="pop_msgbox" runat="server" HeaderText="Campus Dynamics ERP" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                            <HeaderStyle HorizontalAlign="Center" />
                            <ModalBackgroundStyle BackColor="Black">
                            </ModalBackgroundStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <br />
                                                <br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center">&nbsp;<dx:ASPxLabel ID="lbl_msgbox" runat="server" ForeColor="#0033CC" style="font-weight: 700;">
                                                </dx:ASPxLabel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="style3">
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
                        <dx:ASPxPopupControl ID="pop_lock_status" runat="server" CloseAction="CloseButton" HeaderText="Lock Status Update" Modal="True" PopupElementID="cmdChangeStatus" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                            <HeaderImage IconID="dashboards_locknavigation_16x16">
                            </HeaderImage>
                            <HeaderStyle HorizontalAlign="Center">
                            <Paddings Padding="15px" />
                            </HeaderStyle>
                            <ModalBackgroundStyle BackColor="Black">
                            </ModalBackgroundStyle>
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>
                                                <br />
                                                Reason for Lock Change<br /> </td>
                                        </tr>
                                        <tr>
                                            <td align="center" style="text-align: left">
                                                <dx:ASPxMemo ID="txt_reason" runat="server" Height="71px" Width="100%">
                                                </dx:ASPxMemo>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center" style="text-align: left">
                                                <dx:ASPxButton ID="cmdUpdateStatus" runat="server" Height="35px" OnClick="cmdUpdateStatus_Click" Text="Change Access" Width="100%">
                                                    <ClientSideEvents Click="function(s, e) {
	var app=e.processOnServer = confirm('Change Access Status?');
 if(app){
lp_processing.Show()
}

}" />
                                                    <Image IconID="actions_apply_16x16">
                                                    </Image>
                                                </dx:ASPxButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="style3">
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
        </ContentTemplate>
    </asp:UpdatePanel>
        </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>