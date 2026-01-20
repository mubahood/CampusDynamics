<%@ Control Language="C#" AutoEventWireup="true" CodeFile="api_fees_structure.ascx.cs" Inherits="UserControls_financials_api_fees_structure" %>
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
        width: 97px;
        height: 16px;
    }
    .auto-style6 {
        width: 227px;
        height: 16px;
    }
    .auto-style7 {
        width: 96px;
        height: 16px;
    }
    .auto-style8 {
        width: 185px;
        height: 16px;
    }
    .auto-style9 {
        width: 76px;
        height: 16px;
    }
    .auto-style10 {
        width: 207px;
        height: 16px;
    }
    .auto-style11 {
        height: 16px;
    }
    .auto-style12 {
        width: 227px;
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
                                        <tr><td><table cellpadding="0" cellspacing="0" class="dx-justification">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_billimgsys.png">
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
                                                                    <td class="auto-style5">
                                                                        </td>
                                                                    <td class="auto-style6">
                                                                        </td>
                                                                    <td class="auto-style7">
                                                                        </td>
                                                                    <td class="auto-style8">
                                                                        </td>
                                                                    <td class="auto-style9">
                                                                        </td>
                                                                    <td class="auto-style10">
                                                                        </td>
                                                                    <td class="auto-style11">
                                                                        </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">Year of Study:</td>
                                                                    <td class="auto-style12">
                                                                        <dx:ASPxComboBox ID="txtYear" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="200px">
                                                                            <Items>
                                                                                <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                                                <dx:ListEditItem Text="2" Value="2" />
                                                                                <dx:ListEditItem Text="3" Value="3" />
                                                                                <dx:ListEditItem Text="4" Value="4" />
                                                                            </Items>
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                    <td class="style11">Current Year:</td>
                                                                    <td class="style13">
                                                                        <dx:ASPxComboBox ID="txtAcademicYear" runat="server" AutoPostBack="True" Width="200px" Height="35px">
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                    <td class="auto-style2">&nbsp;</td>
                                                                    <td class="style16">
                                                                        &nbsp;</td>
                                                                    <td>
                                                                        &nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">
                                                                        Semester:</td>
                                                                    <td class="auto-style12">
                                                                        <dx:ASPxComboBox ID="txtTerm" runat="server" AutoPostBack="True" Height="35px" SelectedIndex="0" Width="200px">
                                                                            <Items>
                                                                                <dx:ListEditItem Selected="True" Text="1" Value="1" />
                                                                                <dx:ListEditItem Text="2" Value="2" />
                                                                                <dx:ListEditItem Text="3" Value="3" />
                                                                                <dx:ListEditItem Text="4" Value="4" />
                                                                            </Items>
                                                                            <Paddings PaddingLeft="5px" />
                                                                        </dx:ASPxComboBox>
                                                                    </td>
                                                                    <td class="style11">
                                                                        &nbsp;</td>
                                                                    <td class="style13">
                                                                        <dx:ASPxButton ID="btn_payschedule" runat="server" Height="35px" OnClick="btn_payschedule_Click" Text="Fees Schedule" ToolTip="Edit Bill Items" Width="200px">
                                                                            <Image IconID="conditionalformatting_adateoccurring_16x16">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                    <td class="auto-style2">
                                                                        &nbsp;</td>
                                                                    <td class="style16">
                                                                        &nbsp;</td>
                                                                    <td>
                                                                        <dx:ASPxButton ID="cmdPrintStructure" runat="server" Height="35px" Text="Print Structure" ToolTip="Bill Selected Students" Visible="False" Width="170px">
                                                                            <ClientSideEvents Click="function(s, e) {
	
  }" />
                                                                            <Image IconID="print_print_16x16">
                                                                            </Image>
                                                                        </dx:ASPxButton>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">
                                                                        &nbsp;</td>
                                                                    <td class="auto-style12">
                                                                        &nbsp;</td>
                                                                    <td class="style11">
                                                                        &nbsp;</td>
                                                                    <td class="style13">
                                                                        &nbsp;</td>
                                                                    <td class="auto-style2">
                                                                        &nbsp;</td>
                                                                    <td class="style16">
                                                                        &nbsp;</td>
                                                                    <td>
                                                                        &nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="style14">
                                                                        &nbsp;</td>
                                                                    <td class="auto-style12">
                                                                        &nbsp;</td>
                                                                    <td class="style11">
                                                                        &nbsp;</td>
                                                                    <td class="style13">
                                                                        &nbsp;</td>
                                                                    <td class="auto-style2">
                                                                        &nbsp;</td>
                                                                    <td class="style16">
                                                                        &nbsp;</td>
                                                                    <td style="text-align: right">
                                                                        &nbsp;</td>
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
                                                    KeyFieldName="ID" OnDataBound="gvClass_DataBound" OnHtmlDataCellPrepared="gvClass_HtmlDataCellPrepared">
                                                    <TotalSummary>
                                                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="amount" 
                                                            ShowInColumn="Amount" ShowInGroupFooterColumn="Amount" 
                                                            SummaryType="Sum" ValueDisplayFormat="{0:0,0}" />
                                                    </TotalSummary>
                                                    <SettingsDataSecurity AllowInsert="False" />
                                                    <SettingsSearchPanel Visible="True" />
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ID" 
                                                                VisibleIndex="1" ReadOnly="True" Visible="False">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ItemCode" VisibleIndex="2" Width="150px" Visible="False">
                                                            <EditFormSettings Visible="False" />
                                                            <CellStyle HorizontalAlign="Left">
                                                            </CellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="progid" 
                                                                VisibleIndex="3" Caption="Programme" Visible="False">
                                                        </dx:GridViewDataTextColumn>
<dx:GridViewDataTextColumn FieldName="studsession" VisibleIndex="4" Caption="Session" Visible="False">
</dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Amount" FieldName="amount" VisibleIndex="9" Width="100px">
                                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                            </PropertiesTextEdit>
                                                            <FooterCellStyle Font-Bold="True" ForeColor="#FF3300">
                                                            </FooterCellStyle>
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Current Year" FieldName="curr_year" VisibleIndex="6" Visible="False">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="semester" 
                                                            VisibleIndex="7" Caption="Semester" Visible="False">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="study_year" VisibleIndex="8" 
                                                            Caption="Year of Study" Visible="False">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn FieldName="ItemName" VisibleIndex="5">
                                                            <EditFormSettings Visible="False" />
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                        </dx:GridViewCommandColumn>
                                                    </Columns>
                                                    <SettingsBehavior ConfirmDelete="True" AllowFocusedRow="True" />
                                                    <SettingsContextMenu Enabled="True" EnableGroupPanelMenu="False">
                                                    </SettingsContextMenu>
                                                    <SettingsPager PageSize="50">
                                                    </SettingsPager>
                                                    <SettingsEditing Mode="EditForm">
                                                        <BatchEditSettings StartEditAction="Click" />
                                                    </SettingsEditing>
                                                    <Settings ShowFilterRowMenu="True" ShowFooter="True" />
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ObjectDataSource ID="dsClass" runat="server" OldValuesParameterFormatString="original_{0}" 
                                                    SelectMethod="GetStudentFeesStructure" 
                                                    
                                                    
                                                    
                                                    TypeName="StudentAccountingDataTableAdapters.fin_fees_structureTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </DeleteParameters>
                                                    <InsertParameters>
                                                        <asp:Parameter Name="ItemCode" Type="UInt32" />
                                                        <asp:Parameter Name="progid" Type="String" />
                                                        <asp:Parameter Name="studsession" Type="String" />
                                                        <asp:Parameter Name="amount" Type="Double" />
                                                        <asp:Parameter Name="curr_year" Type="UInt32" />
                                                        <asp:Parameter Name="semester" Type="UInt32" />
                                                        <asp:Parameter Name="study_year" Type="UInt32" />
                                                    </InsertParameters>
                                                    <SelectParameters>
                                                        <asp:QueryStringParameter DefaultValue="-" Name="reg" QueryStringField="regno" Type="String" />
                                                        <asp:ControlParameter ControlID="txtYear" Name="cyr" PropertyName="Value" 
                                                            Type="Int32" />
                                                        <asp:ControlParameter ControlID="txtTerm" Name="sem" PropertyName="Value" Type="Int32" />
                                                        <asp:ControlParameter ControlID="txtAcademicYear" Name="yr" 
                                                            PropertyName="Value" Type="Int32" />
                                                    </SelectParameters>
                                                    <UpdateParameters>
                                                        <asp:Parameter Name="ItemCode" Type="UInt32" />
                                                        <asp:Parameter Name="progid" Type="String" />
                                                        <asp:Parameter Name="studsession" Type="String" />
                                                        <asp:Parameter Name="amount" Type="Double" />
                                                        <asp:Parameter Name="curr_year" Type="UInt32" />
                                                        <asp:Parameter Name="semester" Type="UInt32" />
                                                        <asp:Parameter Name="study_year" Type="UInt32" />
                                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                                    </UpdateParameters>
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
                                                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetBillItems" 
                                                    TypeName="StudentACCBLL"></asp:ObjectDataSource>
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
                                                        <dx:PopupControlContentControl ID="PopupControlContentControl1" runat="server" SupportsDisabledAttribute="True">
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
                                                    <ModalBackgroundStyle BackColor="#CCCCCC">
                                                    </ModalBackgroundStyle>
                                                    <ContentCollection>
                                                        <dx:PopupControlContentControl ID="PopupControlContentControl2" runat="server">
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
                        </td>
                    </tr>
                </table>
            </dx:PanelContent>
        </PanelCollection>
    </dx:ASPxRoundPanel>