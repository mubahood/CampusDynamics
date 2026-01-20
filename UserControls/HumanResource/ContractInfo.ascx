<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ContractInfo.ascx.cs" Inherits="UserControls_HumanResource_ContractInfo" %>
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


</style>
    <dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    ShowCollapseButton="true" ShowHeader="False" Width="100%">
        <PanelCollection>
<dx:PanelContent runat="server">
    <table width="100%">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" class="style1">
                    <tr>
                        <td style="text-align: center">
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_contractInfo.png">
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
                        <td>
                            <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" 
                                Text="Add New" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/clipboard--plus.png">
                                </Image>
                            </dx:ASPxButton>
                            <dx:ASPxButton ID="cmdPrintID" runat="server" Height="35px" OnClick="cmdPrintID_Click" Text="Print ID" Width="170px">
                                <Image Url="~/COOPERP/images/printer.png">
                                </Image>
                            </dx:ASPxButton>
                            <dx:ASPxButton ID="cmdJobsDepts" runat="server" OnClick="cmdJobsDepts_Click" Text="Settings" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/clipboard-list.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                        <td align="right">
                            <dx:ASPxRoundPanel ID="panel_sms" runat="server" HeaderText="SMS Centre" Width="250px">
                                <HeaderStyle HorizontalAlign="Center" />
                                <PanelCollection>
                                    <dx:PanelContent runat="server">
                                        <table cellpadding="0" cellspacing="0" class="style1">
                                            <tr>
                                                <td align="right" style="width: 248px">
                                                    <dx:ASPxButton ID="cmdUpdateList" runat="server" OnClick="cmdUpdateList_Click" Text="Add" Width="100px">
                                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td align="right" style="width: 248px">
                                                    <dx:ASPxButton ID="cmdSMS" runat="server" Text="Send" Width="100px">
                                                        <Image Url="~/COOPERP/images/arrow-000-medium.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td align="right" style="width: 248px">
                                                    <dx:ASPxButton ID="cmdClearList" runat="server" OnClick="cmdClearList_Click" Text="Clear" Width="100px">
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
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvContracts" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsContractInfo" KeyFieldName="ID" Width="100%" OnHtmlDataCellPrepared="gvContracts_HtmlDataCellPrepared">
                    <Columns>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" 
                            ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" 
                            Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="50px">
                            <EditFormSettings Visible="False" />
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Start Date" FieldName="contractStart" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                            <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataDateColumn Caption="Contract Expiry" FieldName="contractEnd" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                            <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Comments" FieldName="comments" 
                            ShowInCustomizationForm="True" VisibleIndex="12">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" 
                            ShowInCustomizationForm="True" VisibleIndex="15" Width="100px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Employee" FieldName="empID" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                            <PropertiesComboBox DataSourceID="dsEmployees" 
                                IncrementalFilteringMode="Contains" TextField="emp_name" TextFormatString="{1}" 
                                ValueField="empID">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="empID" Width="30px" />
                                    <dx:ListBoxColumn Caption="Employee" FieldName="emp_name" Width="200px" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Job" FieldName="jobID" 
                            ShowInCustomizationForm="True" VisibleIndex="7">
                            <PropertiesComboBox DataSourceID="dsJobs" TextField="jobname" 
                                TextFormatString="{1}" ValueField="ID">
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Department" FieldName="departmentID" 
                            ShowInCustomizationForm="True" VisibleIndex="9">
                            <PropertiesComboBox DataSourceID="dsDepartment" TextField="dept_name" 
                                TextFormatString="{1}" ValueField="ID">
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Status" FieldName="contractStatus" 
                            ShowInCustomizationForm="True" VisibleIndex="11">
                            <PropertiesComboBox IncrementalFilteringMode="StartsWith">
                                <Items>
                                    <dx:ListEditItem Text="VALID" Value="VALID" />
                                    <dx:ListEditItem Text="EXPIRED" Value="EXPIRED" />
                                    <dx:ListEditItem Text="TERMINATED" Value="TERMINATED" />
                                    <dx:ListEditItem Text="RESIGNED" Value="RESIGNED" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Fixed Amount" FieldName="fixedamount" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Pay Scale" FieldName="payscale" 
                            ShowInCustomizationForm="True" VisibleIndex="13">
                            <PropertiesComboBox DataSourceID="dsScales" TextField="scale_name" 
                                TextFormatString="{1}" ValueField="ID">
                                <Columns>
                                    <dx:ListBoxColumn FieldName="ID" />
                                    <dx:ListBoxColumn Caption="Scale Code" FieldName="scale_name" />
                                    <dx:ListBoxColumn Caption="Basic Pay" FieldName="basicpay" />
                                </Columns>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
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
                    SelectMethod="GetData" 
                    TypeName="HRMDataTableAdapters.hrm_emp_contractsTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="empID" Type="UInt32" />
                        <asp:Parameter Name="contractStart" Type="DateTime" />
                        <asp:Parameter Name="contractEnd" Type="DateTime" />
                        <asp:Parameter Name="jobID" Type="UInt32" />
                        <asp:Parameter Name="departmentID" Type="UInt32" />
                        <asp:Parameter Name="comments" Type="String" />
                        <asp:Parameter Name="contractStatus" Type="String" />
                        <asp:Parameter Name="payscale" Type="UInt32" />
                        <asp:Parameter Name="fixedamount" Type="Double" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="empID" Type="UInt32" />
                        <asp:Parameter Name="contractStart" Type="DateTime" />
                        <asp:Parameter Name="contractEnd" Type="DateTime" />
                        <asp:Parameter Name="jobID" Type="UInt32" />
                        <asp:Parameter Name="departmentID" Type="UInt32" />
                        <asp:Parameter Name="comments" Type="String" />
                        <asp:Parameter Name="contractStatus" Type="String" />
                        <asp:Parameter Name="payscale" Type="UInt32" />
                        <asp:Parameter Name="fixedamount" Type="Double" />
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
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <ContentCollection>
                        <dx:PopupControlContentControl runat="server">
                        </dx:PopupControlContentControl>
                    </ContentCollection>
                </dx:ASPxPopupControl>
            </td>
        </tr>
    </table>
            </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>

        
