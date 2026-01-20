<%@ Control Language="C#" AutoEventWireup="true" CodeFile="AnnualLeavel.ascx.cs" Inherits="UserControls_HumanResource_AnnualLeavel" %>
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

img
{
	border-width: 0;
}


    .auto-style1 {
        height: 30px;
    }
    .auto-style2 {
        height: 30px;
        width: 60px;
    }
    .auto-style3 {
        height: 30px;
        width: 186px;
    }
    .auto-style4 {
        height: 30px;
        width: 92px;
    }
    .auto-style5 {
        height: 30px;
        width: 81px;
    }


</style>
    <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    ShowCollapseButton="true" ShowHeader="False" Width="100%">
        <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server">
    <table width="100%">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_leave_info.png">
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
                </table>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp;</td>
        </tr>
        <tr>
            <td>
                <table cellpadding="1" cellspacing="1" width="100%">
                    <tr>
                        <td class="auto-style2">
                            Year:</td>
                        <td class="auto-style3">
                            <dx:ASPxComboBox ID="txtYear" runat="server" AutoPostBack="True" Height="35px">
                            </dx:ASPxComboBox>
                        </td>
                        <td class="auto-style5">Leave Days:</td>
                        <td class="auto-style4">
                            <dx:ASPxTextBox ID="txtLeaveDays" runat="server" Height="35px" Text="30" Width="100px">
                            </dx:ASPxTextBox>
                        </td>
                        <td class="auto-style1">
                            <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" Text="Refresh List" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td align="right" class="auto-style1">
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvContracts" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsContractInfo" KeyFieldName="ID" Width="100%" ClientInstanceName="gvContracts" OnHtmlDataCellPrepared="gvContracts_HtmlDataCellPrepared">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="0" Visible="False">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Emp. Code" FieldName="empID" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Width="60px">
                            <EditFormSettings Visible="False" />
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn FieldName="leave_year" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Leave Days" FieldName="default_days" ShowInCustomizationForm="True" VisibleIndex="5" Width="80px">
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Employee Name" FieldName="emp_name" ShowInCustomizationForm="True" VisibleIndex="3">
                            <EditFormSettings Visible="False" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="1" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn Caption="Balance" FieldName="balance" ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Days Taken" FieldName="taken" ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Track Leave" ShowInCustomizationForm="True" VisibleIndex="8" Width="30px">
                            <EditFormSettings Visible="False" />
                            <DataItemTemplate>
                                <asp:ImageButton ID="cmdTrack" runat="server" ImageUrl="~/COOPERP/images/clipboard-list.png" OnClick="cmdTrack_Click" />
                            </DataItemTemplate>
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <SettingsEditing Mode="Batch">
                    </SettingsEditing>
                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                    <SettingsSearchPanel Visible="True" />
                    <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |" 
                        CommandEdit="| Edit |" CommandUpdate="| Save Changes |" 
                        ConfirmDelete="Delete Contract?" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsContractInfo" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetLeaveByYear" 
                    TypeName="HRMDataTableAdapters.hrm_annual_leaveTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="empID" Type="UInt32" />
                        <asp:Parameter Name="leave_year" Type="UInt32" />
                        <asp:Parameter Name="default_days" Type="UInt32" />
                    </InsertParameters>
                    <SelectParameters>
                        <asp:ControlParameter ControlID="txtYear" Name="yr" PropertyName="Value" Type="Int32" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="empID" Type="UInt32" />
                        <asp:Parameter Name="leave_year" Type="UInt32" />
                        <asp:Parameter Name="default_days" Type="UInt32" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsScales" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="HRMDataTableAdapters.hrm_payscalesTableAdapter">
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsDepartment" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="HRMDataTableAdapters.hrm_departmentsTableAdapter">
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsEmployees" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="HRMDataTableAdapters.hrm_employeeTableAdapter">
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsJobs" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="HRMDataTableAdapters.hrm_jobsTableAdapter"></asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" Modal="True" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" CloseAction="CloseButton" Width="300px">
                    <ClientSideEvents CloseUp="function(s, e) {
gvContracts.Refresh();	
}" />
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
                                    <td style="text-align: center">
                                        <dx:ASPxLabel ID="lbl_msg" runat="server" Font-Bold="True" ForeColor="Blue">
                                        </dx:ASPxLabel>
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
</dx:ASPxRoundPanel>
