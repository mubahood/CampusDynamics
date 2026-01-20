<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Payroll.ascx.cs" Inherits="UserControls_HumanResource_Payroll" %>
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
                                ImageUrl="~/COOPERP/images/header_payrollInfo.png">
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
                        </td>
                        <td align="right">
                            <dx:ASPxButton ID="cmdPayrollDetails" runat="server" 
                                OnClick="cmdPayrollDetails_Click" Text="Payroll Details" Width="170px" Height="35px">
                                <Image Url="~/COOPERP/images/clipboard-list.png">
                                </Image>
                            </dx:ASPxButton>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvPayroll" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsPayroll" KeyFieldName="ID" Width="100%" 
                    ClientInstanceName="gvPayroll" OnHtmlRowPrepared="gvPayroll_HtmlRowPrepared">
                    <Columns>
                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Payroll Title" FieldName="payroll_title" 
                            ShowInCustomizationForm="True" VisibleIndex="2" Width="250px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Month" FieldName="payroll_month" 
                            ShowInCustomizationForm="True" VisibleIndex="3">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Year" FieldName="payroll_year" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Comments" FieldName="payroll_comments" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Total Amount" FieldName="total_amount" 
                            ShowInCustomizationForm="True" VisibleIndex="10">

                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                            </PropertiesTextEdit>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataCheckColumn Caption="Lock Status" FieldName="lockStatus" 
                            ShowInCustomizationForm="True" VisibleIndex="13" Width="80px">
                        </dx:GridViewDataCheckColumn>
                        <dx:GridViewDataDateColumn Caption="Payroll Date" FieldName="payroll_date" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                            ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" 
                            ShowInCustomizationForm="True" VisibleIndex="15" Width="100px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Prepared By" FieldName="prepared_by" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                            <PropertiesComboBox DataSourceID="dsEmployees" 
                                IncrementalFilteringMode="Contains" TextField="emp_name" TextFormatString="{1}" 
                                ValueField="empID">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="empID" Width="30px" />
                                    <dx:ListBoxColumn Caption="Staff Name" FieldName="emp_name" Width="150px" />
                                </Columns>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Checked By" FieldName="checked_by" 
                            ShowInCustomizationForm="True" VisibleIndex="7" Visible="False">
                            <PropertiesComboBox DataSourceID="dsEmployees" TextField="emp_name" 
                                TextFormatString="{1}" ValueField="empID" 
                                IncrementalFilteringMode="Contains">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="empID" Width="30px" />
                                    <dx:ListBoxColumn Caption="Staff Name" FieldName="emp_name" Width="150px" />
                                </Columns>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Approved By" FieldName="approved_by" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="9">
                            <PropertiesComboBox DataSourceID="dsEmployees" 
                                IncrementalFilteringMode="Contains" TextField="emp_name" TextFormatString="{1}" 
                                ValueField="empID">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="empID" Width="30px" />
                                    <dx:ListBoxColumn Caption="Staff Name" FieldName="emp_name" Width="150px" />
                                </Columns>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Work Days" FieldName="expected_days" ShowInCustomizationForm="True" VisibleIndex="11" Width="80px">
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <Settings ShowFilterRowMenu="True" />
                    <SettingsSearchPanel Visible="True" />
                    <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |" 
                        CommandEdit="| Edit |" CommandUpdate="| Save Changes |" 
                        ConfirmDelete="Delete Payroll?" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsPayroll" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" TypeName="HRMDataTableAdapters.hrm_payrollTableAdapter" 
                    UpdateMethod="Update">
                    <DeleteParameters>
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </DeleteParameters>
                    <InsertParameters>
                        <asp:Parameter Name="payroll_title" Type="String" />
                        <asp:Parameter Name="payroll_month" Type="String" />
                        <asp:Parameter Name="payroll_year" Type="UInt32" />
                        <asp:Parameter Name="payroll_comments" Type="String" />
                        <asp:Parameter Name="prepared_by" Type="UInt32" />
                        <asp:Parameter Name="checked_by" Type="UInt32" />
                        <asp:Parameter Name="approved_by" Type="UInt32" />
                        <asp:Parameter Name="total_amount" Type="Double" />
                        <asp:Parameter Name="lockStatus" Type="Byte" />
                        <asp:Parameter Name="payroll_date" Type="DateTime" />
                        <asp:Parameter Name="expected_days" Type="Int32" />
                    </InsertParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="payroll_title" Type="String" />
                        <asp:Parameter Name="payroll_month" Type="String" />
                        <asp:Parameter Name="payroll_year" Type="UInt32" />
                        <asp:Parameter Name="payroll_comments" Type="String" />
                        <asp:Parameter Name="prepared_by" Type="UInt32" />
                        <asp:Parameter Name="checked_by" Type="UInt32" />
                        <asp:Parameter Name="approved_by" Type="UInt32" />
                        <asp:Parameter Name="total_amount" Type="Double" />
                        <asp:Parameter Name="lockStatus" Type="Byte" />
                        <asp:Parameter Name="payroll_date" Type="DateTime" />
                        <asp:Parameter Name="expected_days" Type="Int32" />
                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsEmployees" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="HRMDataTableAdapters.hrm_employeeTableAdapter">
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" Modal="True" 
                    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                    <ClientSideEvents CloseUp="function(s, e) {
	gvPayroll.Refresh();
}" />
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

