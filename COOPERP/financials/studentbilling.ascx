<%@ Control Language="C#" AutoEventWireup="true" CodeFile="studentbilling.ascx.cs" Inherits="UserControls_financials_studentbilling" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
<style type="text/css">
.style1
{
    width:100%;
}
    


    *
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
        
    }


    .style11
    {
        width: 96px;
    }
    .style12
    {
        width: 143px;
    }
    .style13
    {
        width: 185px;
    }
    .style14
    {
        width: 97px;
    }
    .style15
    {
        width: 120px;
    }
    .style16
    {
        width: 207px;
    }
    .style17
    {
        width: 197px;
    }
    .auto-style2 {
        width: 76px;
    }
    .auto-style4 {
        width: 371px;
    }
    .auto-style5 {
        width: 68px;
        text-align: left;
    }
</style>
<dx:ASPxRoundPanel ID="ASPxRoundPanel2" runat="server" 
        HeaderText="Finance: Student Fees Tracking" Width="100%" ShowHeader="False">
        <PanelCollection>
            <dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">
                <table class="style1">
                    <tr>
                        <td>
                            <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                                <ContentTemplate>
                                    <table class="style1">
                                        <tr><td><table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_studentbilling.png">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" 
                                ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
                            </dx:ASPxImage>
                        </td>
                    </tr>
                </table></td></tr>
                                        <tr>
                                            <td>
                                                <table class="style1">
                                                    <tr>
                                                        <td valign="top">
                                                            <table cellpadding="0" class="style1">
                                                                <tr>
                                                                    <td class="style14">&nbsp;</td>
                                                                    <td class="auto-style4">&nbsp;</td>
                                                                    <td class="style11">&nbsp;</td>
                                                                    <td class="style13">&nbsp;</td>
                                                                    <td class="auto-style2">&nbsp;</td>
                                                                    <td class="style16">&nbsp;</td>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">Programme:</td>
                                                                    <td class="auto-style4">
                                                                        <dx:ASPxComboBox ID="txtProg" runat="server" AutoPostBack="True" DataSourceID="dsProgrammes" Height="27px" OnSelectedIndexChanged="txtClass_SelectedIndexChanged" SelectedIndex="0" TextField="progname" TextFormatString="{1}" ValueField="progcode" Width="350px">
                                                                            <Columns>
                                                                                <dx:ListBoxColumn Caption="Code" FieldName="progcode" Width="50px" />
                                                                                <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="250px" />
                                                                            </Columns>
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                    <td class="style11">Academic Year:</td>
                                                                    <td class="style13">
                                                                        <dx:ASPxComboBox ID="txtAcademicYear" runat="server" AutoPostBack="True" Height="27px" OnSelectedIndexChanged="txtClass_SelectedIndexChanged" Width="170px">
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                    <td class="auto-style2">SMS Sender:</td>
                                                                    <td class="style16">
                                                                        <dx:ASPxTextBox ID="txtSMSSender" runat="server" Height="27px" Text="Equator University" Width="200px">
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxTextBox>
                                                                    </td>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">Session:</td>
                                                                    <td class="auto-style4">
                                                                        <dx:ASPxComboBox ID="txtSession" runat="server" AutoPostBack="True" Height="27px" OnSelectedIndexChanged="txtClass_SelectedIndexChanged" SelectedIndex="0" Width="350px">
                                                                            <Items>
                                                                                <dx:ListEditItem Selected="True" Text="DAY" Value="DAY" />
                                                                                <dx:ListEditItem Text="MORNING" Value="MORNING" />
                                                                                <dx:ListEditItem Text="AFTERNOON" Value="AFTERNOON" />
                                                                                <dx:ListEditItem Text="EVENING" Value="EVENING" />
                                                                                <dx:ListEditItem Text="WEEKEND" Value="WEEKEND" />
                                                                                <dx:ListEditItem Text="DISTANCE" Value="DISTANCE" />
                                                                                <dx:ListEditItem Text="IN-SERVICE" Value="IN-SERVICE" />
                                                                            </Items>
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                    <td class="style11">Semester:</td>
                                                                    <td class="style13">
                                                                        <dx:ASPxComboBox ID="txtTerm" runat="server" AutoPostBack="True" Height="27px" SelectedIndex="0" Width="170px">
                                                                            <Items>
                                                                                <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                                                <dx:ListEditItem Text="2" Value="2" />
                                                                                <dx:ListEditItem Text="3" Value="3" />
                                                                                <dx:ListEditItem Text="4" Value="4" />
                                                                            </Items>
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                    <td class="auto-style2">SMS Text:</td>
                                                                    <td class="style16">
                                                                        <dx:ASPxMemo ID="txtSMS" runat="server" Height="28px" Width="200px">
                                                                        </dx:ASPxMemo>
                                                                    </td>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">Year of Study:</td>
                                                                    <td class="auto-style4">
                                                                        <dx:ASPxComboBox ID="txtYear" runat="server" AutoPostBack="True" Height="27px" SelectedIndex="0" Width="350px">
                                                                            <Items>
                                                                                <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                                                <dx:ListEditItem Text="2" Value="2" />
                                                                                <dx:ListEditItem Text="3" Value="3" />
                                                                                <dx:ListEditItem Text="4" Value="4" />
                                                                            </Items>
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                    <td class="style11">Start Date:</td>
                                                                    <td class="style13">
                                                                        <dx:ASPxDateEdit ID="txtStartDate" runat="server" Height="27px" Width="170px">
                                                                        </dx:ASPxDateEdit>
                                                                    </td>
                                                                    <td class="auto-style2">&nbsp;</td>
                                                                    <td class="style16">
                                                                        <dx:ASPxButton ID="cmdSMS" runat="server" Height="27px" OnClick="cmdSMS_Click" Text="Send SMS" Width="200px">
                                                                            <ClientSideEvents Click="function(s, e) {
	panel_billling.Show();
}" />
                                                                            <Image Url="~/COOPERP/images/balloon-box-left.png">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">Pay Status:</td>
                                                                    <td class="auto-style4">
                                                                        <dx:ASPxComboBox ID="txtStat" runat="server" AutoPostBack="True" Height="27px" SelectedIndex="2" Width="350px">
                                                                            <Items>
                                                                                <dx:ListEditItem Text="Pending" Value="Pending" />
                                                                                <dx:ListEditItem Text="Completed" Value="Completed" />
                                                                                <dx:ListEditItem Selected="True" Text="All" Value="All" />
                                                                            </Items>
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                    <td class="style11">End Date:</td>
                                                                    <td class="style13">
                                                                        <dx:ASPxDateEdit ID="txtEndDate" runat="server" Height="27px" Width="170px">
                                                                        </dx:ASPxDateEdit>
                                                                    </td>
                                                                    <td class="auto-style2">&nbsp;</td>
                                                                    <td class="style16">
                                                                        <dx:ASPxButton ID="cmdPrintList" runat="server" Height="27px" OnClick="cmdPrintList_Click" Text="Print List" Width="200px">
                                                                            <Image Url="~/COOPERP/images/printer.png">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">&nbsp;</td>
                                                                    <td class="auto-style4">
                                                                        <dx:ASPxButton ID="cmdNew" runat="server" Height="35px" OnClick="cmdNew_Click" Text="Auto Bill Selected" ToolTip="Bill Selected Students" Width="174px">
                                                                            <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Auto-Bill All Students?');
if(e.processOnServer==true)
{
panel_billling.Show();
}
  }" />
                                                                            <Image IconID="miscellaneous_wizard_16x16">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                        <dx:ASPxButton ID="btn_billitems" runat="server" Height="35px" OnClick="btn_billitems_Click" Text="Billing Items" ToolTip="Edit Bill Items" Width="174px">
                                                                            <Image IconID="filterelements_listbox_16x16">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                    <td class="style11">&nbsp;</td>
                                                                    <td class="style13">
                                                                        <dx:ASPxButton ID="cmdSingleItem" runat="server" Height="35px" Text="Single Item Bill" ToolTip="Bill Selected Students" Width="170px">
                                                                            <ClientSideEvents Click="function(s, e) {
	
  }" />
                                                                            <Image Url="~/COOPERP/images/tick-button.png">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                    <td class="auto-style2">&nbsp;</td>
                                                                    <td class="style16">
                                                                        <dx:ASPxButton ID="cmdBillingCorrection" runat="server" Height="35px" OnClick="cmdBillingCorrection_Click" Text="Billing Corrections" ToolTip="Bill Selected Students" Width="200px">
                                                                            <ClientSideEvents Click="function(s, e) {
	e.processOnServer = confirm('Process Billing Corrections?');
                                                                                if(e.processOnServer==true)
{
panel_billling.Show();
}
  }" />
                                                                            <Image IconID="actions_reset2_16x16">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">&nbsp;</td>
                                                                    <td class="auto-style4">&nbsp;</td>
                                                                    <td class="style11">&nbsp;</td>
                                                                    <td class="style13">&nbsp;</td>
                                                                    <td class="auto-style2">&nbsp;</td>
                                                                    <td class="style16">&nbsp;</td>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxGridView ID="gvClass" runat="server" AutoGenerateColumns="False" 
                                                    DataSourceID="dsClass" Width="100%" ClientInstanceName="gvClass" 
                                                    KeyFieldName="ID" OnHtmlDataCellPrepared="gvClass_HtmlDataCellPrepared" OnDataBound="gvClass_DataBound">
                                                    <TotalSummary>
                                                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="opBal" 
                                                            ShowInColumn="Opening Balance" ShowInGroupFooterColumn="Opening Balance" 
                                                            SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="TotalDR" 
                                                            ShowInColumn="Billings (DR)" ShowInGroupFooterColumn="Billings (DR)" 
                                                            SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="TotalCR" 
                                                            ShowInColumn="Payments (CR)" ShowInGroupFooterColumn="Payments (CR)" 
                                                            SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="CurBal" 
                                                            ShowInColumn="Balance" ShowInGroupFooterColumn="Balance" 
                                                            SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                    </TotalSummary>
                                                    <SettingsSearchPanel Visible="True" />
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ID" 
                                                                VisibleIndex="1" ReadOnly="True" Visible="False">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                            <HeaderTemplate>
                                                                <dx:ASPxCheckBox ID="SelectAllCheckBox" runat="server" CheckState="Unchecked" ClientSideEvents-CheckedChanged="function(s, e) { gvClass.SelectAllRowsOnPage(s.GetChecked()); }" ToolTip="Select/Unselect all rows on the page">
                                                                    <ClientSideEvents CheckedChanged="function(s, e) { 
                                                                    gvClass.SelectAllRowsOnPage(s.GetChecked()); }"/>
                                                                </dx:ASPxCheckBox>
                                                            </HeaderTemplate>
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewDataTextColumn FieldName="regno" VisibleIndex="3" 
                                                            Caption="Student No" Width="150px">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="stud_names" 
                                                                VisibleIndex="4" Caption="Student Name">
                                                        </dx:GridViewDataTextColumn>
<dx:GridViewDataTextColumn FieldName="residence" VisibleIndex="7" Caption="Residence">
</dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Billed Items" FieldName="billItems" VisibleIndex="10">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Opening Balance" FieldName="opBal" VisibleIndex="11" Width="80px">
                                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="False" ForeColor="Black">
                                                            </CellStyle>
                                                            <FooterCellStyle Font-Bold="True" ForeColor="Red">
                                                            </FooterCellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="TotalDR" 
                                                            VisibleIndex="13" Caption="Billings (DR)" Width="80px">
                                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="False" ForeColor="Black">
                                                            </CellStyle>
                                                            <FooterCellStyle Font-Bold="True" ForeColor="Red">
                                                            </FooterCellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="TotalCR" VisibleIndex="14" 
                                                            Caption="Payments (CR)" Width="80px">
                                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="False" Font-Italic="False" ForeColor="Black">
                                                            </CellStyle>
                                                            <FooterCellStyle Font-Bold="True" ForeColor="Red">
                                                            </FooterCellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Balance" FieldName="CurBal" VisibleIndex="15" Width="80px">
                                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                            </PropertiesTextEdit>
                                                            <CellStyle Font-Bold="False" ForeColor="Black">
                                                            </CellStyle>
                                                            <FooterCellStyle Font-Bold="True" ForeColor="Red">
                                                            </FooterCellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Ledgers" 
                                                            VisibleIndex="17" Width="50px">
                                                            <DataItemTemplate>
                                                                <asp:ImageButton ID="cmdLedger" runat="server" 
                                                                    ImageUrl="~/COOPERP/images/clipboard-invoice.png" onclick="cmdLedger_Click" 
                                                                    onclientclick="lp_loading.Show();" />
                                                                <dx:ASPxLoadingPanel ID="lp_loading" runat="server" 
                                                                    ClientInstanceName="lp_loading" Modal="True">
                                                                </dx:ASPxLoadingPanel>
                                                            </DataItemTemplate>
                                                            <HeaderStyle HorizontalAlign="Center" />
                                                            <CellStyle HorizontalAlign="Center">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Reg No" FieldName="entryno" VisibleIndex="2" Width="150px">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Reg Status" FieldName="regstatus" VisibleIndex="9">
                                                        </dx:GridViewDataTextColumn>
                                                    </Columns>
                                                    <SettingsBehavior ConfirmDelete="True" AllowFocusedRow="True" />
                                                    <SettingsPager PageSize="50">
                                                    </SettingsPager>
                                                    <Settings ShowFilterRowMenu="True" ShowFooter="True" />
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="dsClass" runat="server" OldValuesParameterFormatString="original_{0}" 
                                                    SelectMethod="GetData" 
                                                    
                                                    
                                                    
                                                    TypeName="StudentAccountingDataTableAdapters.fin_GetStudentFeesTrackListTableAdapter">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="txtProg" Name="prog" PropertyName="Value" 
                                                            Type="String" />
                                                        <asp:ControlParameter ControlID="txtSession" Name="sess" 
                                                            PropertyName="Value" Type="String" />
                                                        <asp:ControlParameter ControlID="txtAcademicYear" Name="acad" PropertyName="Value" 
                                                            Type="String" />
                                                        <asp:ControlParameter ControlID="txtTerm" Name="sem" PropertyName="Value" Type="Int32" />
                                                        <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Value" 
                                                            Type="Int32" />
                                                        <asp:ControlParameter ControlID="txtStat" DefaultValue="Unpaid" Name="stat" 
                                                            PropertyName="Value" Type="String" />
                                                        <asp:ControlParameter ControlID="txtStartDate" Name="sDate" PropertyName="Value" Type="DateTime" />
                                                        <asp:ControlParameter ControlID="txtEndDate" Name="eDate" PropertyName="Value" Type="DateTime" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="dsProgrammes" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter"></asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="dsClassData" runat="server" 
                                                    OldValuesParameterFormatString="original_{0}" 
                                                    SelectMethod="GetData" 
                                                    TypeName="StudentDataTableAdapters.acad_studentTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_regno" Type="String" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="entryno" Type="String" />
                                                        <asp:Parameter Name="regno" Type="String" />
                                                        <asp:Parameter Name="firstname" Type="String" />
                                                        <asp:Parameter Name="dob" Type="DateTime" />
                                                        <asp:Parameter Name="gender" Type="String" />
                                                        <asp:Parameter Name="nationality" Type="String" />
                                                        <asp:Parameter Name="religion" Type="String" />
                                                        <asp:Parameter Name="entrymethod" Type="String" />
                                                        <asp:Parameter Name="progid" Type="String" />
                                                        <asp:Parameter Name="studPhone" Type="String" />
                                                        <asp:Parameter Name="email" Type="String" />
                                                        <asp:Parameter Name="entryyear" Type="Int32" />
                                                        <asp:Parameter Name="studsesion" Type="String" />
                                                        <asp:Parameter Name="home_dist" Type="String" />
                                                        <asp:Parameter Name="intake" Type="String" />
                                                        <asp:Parameter Name="gradSystemID" Type="Int32" />
                                                        <asp:Parameter Name="othername" Type="String" />
                                                        <asp:Parameter Name="duration" Type="UInt32" />
                                                        <asp:Parameter Name="photofile" Type="String" />
                                                        <asp:Parameter Name="specialisation" Type="String" />
                                                    </InsertParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="entryno" Type="String" />
                                                        <asp:Parameter Name="firstname" Type="String" />
                                                        <asp:Parameter Name="dob" Type="DateTime" />
                                                        <asp:Parameter Name="gender" Type="String" />
                                                        <asp:Parameter Name="nationality" Type="String" />
                                                        <asp:Parameter Name="religion" Type="String" />
                                                        <asp:Parameter Name="entrymethod" Type="String" />
                                                        <asp:Parameter Name="progid" Type="String" />
                                                        <asp:Parameter Name="studPhone" Type="String" />
                                                        <asp:Parameter Name="email" Type="String" />
                                                        <asp:Parameter Name="entryyear" Type="Int32" />
                                                        <asp:Parameter Name="studsesion" Type="String" />
                                                        <asp:Parameter Name="home_dist" Type="String" />
                                                        <asp:Parameter Name="intake" Type="String" />
                                                        <asp:Parameter Name="gradSystemID" Type="Int32" />
                                                        <asp:Parameter Name="othername" Type="String" />
                                                        <asp:Parameter Name="duration" Type="Int32" />
                                                        <asp:Parameter Name="specialisation" Type="String" />
                                                        <asp:Parameter Name="Original_regno" Type="String" />
                                                    </UpdateParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="dsBillItems" runat="server" 
                                                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                                                    TypeName="StudentAccountingDataTableAdapters.academicbillingitemsTableAdapter"></asp:ObjectDataSource>
                                                <dx:ASPxLoadingPanel ID="panel_billling" runat="server" 
                                                    ClientInstanceName="panel_billling" Modal="True" 
                                                    Text="Processing...Please wait&amp;hellip;">
                                                </dx:ASPxLoadingPanel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxPopupControl ID="pop_messagebox" runat="server" 
                                                    HeaderText="Campus Dynamics ERP" Height="150px" 
                                                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
                                                    Width="300px" CloseAction="CloseButton">
                                                    <HeaderStyle HorizontalAlign="Center" />
                                                    <ContentCollection>
                                                        <dx:PopupControlContentControl runat="server" SupportsDisabledAttribute="True">
                                                            <table class="style1">
                                                                <tr>
                                                                    <td height="30">
                                                                        <br />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center">
                                                                        <dx:ASPxImage ID="img_msg" runat="server" ImageAlign="AbsBottom">
                                                                        </dx:ASPxImage>
                                                                        &nbsp;<dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Red">
                                                                        </dx:ASPxLabel>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        &nbsp;</td>
                                                                </tr>
                                                            </table>
                                                        </dx:PopupControlContentControl>
                                                    </ContentCollection>
                                                </dx:ASPxPopupControl>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxPopupControl ID="pop_billitems" runat="server" HeaderText="" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton">
                                                    <ClientSideEvents CloseUp="function(s, e) {
	gvClass.Refresh();
}" />
                                                    <ModalBackgroundStyle BackColor="#CCCCCC">
                                                    </ModalBackgroundStyle>
                                                    <ContentCollection>
                                                        <dx:PopupControlContentControl runat="server">
                                                        </dx:PopupControlContentControl>
                                                    </ContentCollection>
                                                </dx:ASPxPopupControl>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxPopupControl ID="pop_single_bill" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Single Item Billing" Height="100px" Modal="True" PopupElementID="cmdSingleItem" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                                    <HeaderStyle HorizontalAlign="Center">
                                                    <Paddings Padding="10px" />
                                                    </HeaderStyle>
                                                    <ContentCollection>
                                                        <dx:PopupControlContentControl ID="PopupControlContentControl3" runat="server">
                                                            <table align="center" class="style1">
                                                                <tr>
                                                                    <td align="center">
                                                                        <br />
                                                                        <br />
                                                                        <table class="style1">
                                                                            <tr>
                                                                                <td class="auto-style5" style="text-align: left">Residence:</td>
                                                                                <td style="text-align: left">
                                                                                    <dx:ASPxComboBox ID="txtSingleItem" runat="server" DataSourceID="dsBillItems" Height="35px" SelectedIndex="0" TextField="ItemName" TextFormatString="{1}" ValueField="ItemCode" ValueType="System.Int32" Width="100%">
                                                                                        <Columns>
                                                                                            <dx:ListBoxColumn FieldName="ItemCode" Width="25px" Caption="Code" />
                                                                                            <dx:ListBoxColumn Caption="Item Name" FieldName="ItemName" Width="200px" />
                                                                                        </Columns>
                                                                                    </dx:ASPxComboBox>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td class="auto-style5">Amount:</td>
                                                                                <td>
                                                                                    <dx:ASPxTextBox ID="txtAmount" runat="server" Height="35px" Text="0" Width="100%">
                                                                                        <Paddings PaddingLeft="5px" />
                                                                                    </dx:ASPxTextBox>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td class="auto-style5">&nbsp;</td>
                                                                                <td>
                                                                                    <dx:ASPxButton ID="cmdPostBilling" runat="server" Height="35px" OnClick="cmdPostBilling_Click" Text="Post Billing" Width="100%">
                                                                                        <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Post Billing?');
	
}" />
                                                                                        <Image IconID="actions_apply_16x16">
                                                                                        </Image>
                                                                                    </dx:ASPxButton>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                        <br />
                                                                        <dx:ASPxLabel ID="lbl_single_bill_comm" runat="server" ForeColor="Blue" style="font-weight: 700">
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
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </dx:PanelContent>
        </PanelCollection>
    </dx:ASPxRoundPanel>