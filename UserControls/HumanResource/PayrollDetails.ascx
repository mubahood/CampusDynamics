<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PayrollDetails.ascx.cs" Inherits="UserControls_HumanResource_PayrollDetails" %>
<%@ Register src="MonthlyDeductionAllowance.ascx" tagname="MonthlyDeductionAllowance" tagprefix="uc1" %>

<%@ Register src="DocumentCentre.ascx" tagname="DocumentCentre" tagprefix="uc2" %>
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


    .auto-style1 {
        width: 178px;
    }


    </style>

<dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" 
    Width="100%">
    <TabPages>
        <dx:TabPage Text=" Payroll List">
            <TabImage IconID="chart_chartsshowlegend_16x16">
            </TabImage>
            <ContentCollection>
                <dx:ContentControl runat="server">
                    <table width="100%">
                        <tr>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <table cellspacing="0" class="style1">
                                    <tr>
                                        <td>
                                            <dx:ASPxComboBox ID="txtSchool" runat="server" AutoPostBack="True" 
                                                DataSourceID="dsSchools" OnDataBound="txtSchool_DataBound" SelectedIndex="0" 
                                                TextField="station_name" TextFormatString="{0}" ValueField="station_name" 
                                                Width="170px" Height="35px">
                                                <Columns>
                                                    <dx:ListBoxColumn Caption="Station" FieldName="station_name" />
                                                </Columns>
                                                <Paddings PaddingLeft="5px" />
                                            </dx:ASPxComboBox>
                                        </td>
                                        <td align="right">
                                            &nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <dx:ASPxButton ID="cmdRefreshPayroll" runat="server" 
                                                OnClick="cmdRefreshPayroll_Click" Text="Refresh" Width="170px" Height="35px">
                                                <Image Url="~/COOPERP/images/arrow-retweet.png">
                                                </Image>
                                            </dx:ASPxButton>
                                        </td>
                                        <td align="right">
                                            <dx:ASPxButton ID="cmdPrint" runat="server" OnClick="cmdPrint_Click" 
                                                Text="Print" Width="170px" Height="35px">
                                                <Image Url="~/COOPERP/images/printer.png">
                                                </Image>
                                            </dx:ASPxButton>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxGridView ID="gvPayrollList" runat="server" AutoGenerateColumns="False" 
                                    DataSourceID="dsPayrollList" KeyFieldName="ID" Width="100%" OnHtmlRowPrepared="gvPayrollList_HtmlRowPrepared">
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Staff No" FieldName="empID" 
                                            ShowInCustomizationForm="True" VisibleIndex="2" Width="50px" Visible="False">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Basic Pay" FieldName="basic_pay" 
                                            ShowInCustomizationForm="True" VisibleIndex="5" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="PAYE" FieldName="paye" 
                                            ShowInCustomizationForm="True" VisibleIndex="8" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="NSSF" FieldName="nssf" 
                                            ShowInCustomizationForm="True" VisibleIndex="9" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Allowances" FieldName="total_allowances" 
                                            ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Other Deductions" 
                                            FieldName="total_deductions" ShowInCustomizationForm="True" VisibleIndex="10" 
                                            Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Gross Pay" FieldName="gross_pay" 
                                            ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Net" FieldName="net_pay" 
                                            ShowInCustomizationForm="True" VisibleIndex="11" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Staff Name" FieldName="emp_name" 
                                            ShowInCustomizationForm="True" VisibleIndex="3">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Attendance" FieldName="days_attended" ShowInCustomizationForm="True" VisibleIndex="4" Width="80px">
                                        </dx:GridViewDataTextColumn>
                                    </Columns>
                                    <SettingsBehavior AllowFocusedRow="True" />
                                    <SettingsEditing Mode="Batch">
                                        <BatchEditSettings StartEditAction="Click" />
                                    </SettingsEditing>
                                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                </dx:ASPxGridView>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ObjectDataSource ID="dsPayrollList" runat="server" DeleteMethod="Delete" 
                                    OldValuesParameterFormatString="original_{0}" 
                                    SelectMethod="GetPayrollDetailsByBranch" 
                                    TypeName="HRMDataTableAdapters.hrm_payroll_detailsTableAdapter" 
                                    InsertMethod="Insert" UpdateMethod="Update">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="payrollID" Type="UInt32" />
                                        <asp:Parameter Name="empID" Type="UInt32" />
                                        <asp:Parameter Name="basic_pay" Type="Double" />
                                        <asp:Parameter Name="paye" Type="Double" />
                                        <asp:Parameter Name="nssf" Type="Double" />
                                        <asp:Parameter Name="total_allowances" Type="Double" />
                                        <asp:Parameter Name="total_deductions" Type="Double" />
                                        <asp:Parameter Name="gross_pay" Type="Double" />
                                        <asp:Parameter Name="net_pay" Type="Double" />
                                        <asp:Parameter Name="days_attended" Type="Int32" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="pid" SessionField="pid" Type="Int32" />
                                        <asp:ControlParameter ControlID="txtSchool" DefaultValue="0" Name="bname" 
                                            PropertyName="Value" Type="String" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="payrollID" Type="UInt32" />
                                        <asp:Parameter Name="empID" Type="UInt32" />
                                        <asp:Parameter Name="basic_pay" Type="Double" />
                                        <asp:Parameter Name="paye" Type="Double" />
                                        <asp:Parameter Name="nssf" Type="Double" />
                                        <asp:Parameter Name="total_allowances" Type="Double" />
                                        <asp:Parameter Name="total_deductions" Type="Double" />
                                        <asp:Parameter Name="gross_pay" Type="Double" />
                                        <asp:Parameter Name="net_pay" Type="Double" />
                                        <asp:Parameter Name="days_attended" Type="Int32" />
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </UpdateParameters>
                                </asp:ObjectDataSource>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ObjectDataSource ID="dsSchools" runat="server" DeleteMethod="Delete" 
                                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                    SelectMethod="GetData" TypeName="HRMDataTableAdapters.hrm_stationsTableAdapter" 
                                    UpdateMethod="Update">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="station_name" Type="String" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="station_name" Type="String" />
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </UpdateParameters>
                                </asp:ObjectDataSource>
                            </td>
                        </tr>
                    </table>
                </dx:ContentControl>
            </ContentCollection>
        </dx:TabPage>
        <dx:TabPage Text=" Deductions &amp; Allowances">
            <TabImage IconID="actions_insert_16x16">
            </TabImage>
            <ContentCollection>
                <dx:ContentControl runat="server">
                    <uc1:MonthlyDeductionAllowance ID="MonthlyDeductionAllowance1" runat="server" />
                </dx:ContentControl>
            </ContentCollection>
        </dx:TabPage>
        <dx:TabPage Text=" Special Payments">
            <TabImage IconID="functionlibrary_financial_16x16">
            </TabImage>
            <ContentCollection>
                <dx:ContentControl runat="server">
                    <table width="100%">
                        <tr>
                            <td>&nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <table cellspacing="0" class="style1">
                                    <tr>
                                        <td class="auto-style1">
                                            <dx:ASPxButton ID="cmdRefreshSpecialPayroll" runat="server" Height="35px" OnClick="cmdRefreshSpecialPayroll_Click" Text="Refresh" Width="170px">
                                                <Image Url="~/COOPERP/images/arrow-retweet.png">
                                                </Image>
                                            </dx:ASPxButton>
                                        </td>
                                        <td>
                                            <dx:ASPxButton ID="cmdDeleteBlanks" runat="server" Height="35px" OnClick="cmdDeleteBlanks_Click" Text="Clean List" Width="170px">
                                                <ClientSideEvents Click="function(s, e) {
e.processOnServer = confirm('Delete 0 pay Staff?');  	
}" />
                                                <Image Url="~/COOPERP/images/delete.png">
                                                </Image>
                                            </dx:ASPxButton>
                                        </td>
                                        <td align="right">
                                            <dx:ASPxButton ID="cmdSpecialPrint" runat="server" Height="35px" OnClick="cmdSpecialPrint_Click" Text="Print" Width="170px">
                                                <Image Url="~/COOPERP/images/printer.png">
                                                </Image>
                                            </dx:ASPxButton>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxGridView ID="gvSpecialPayrollList" runat="server" AutoGenerateColumns="False" DataSourceID="dsSpecialPayrollList" KeyFieldName="ID" OnHtmlRowPrepared="gvPayrollList_HtmlRowPrepared" OnRowUpdating="gvSpecialPayrollList_RowUpdating" Width="100%">
                                    <SettingsEditing Mode="Batch">
                                        <BatchEditSettings StartEditAction="Click" />
                                    </SettingsEditing>
                                    <Settings ShowFilterRowMenu="True" ShowFooter="True" />
                                    <SettingsBehavior AllowFocusedRow="True" />
                                    <SettingsSearchPanel Visible="True" />
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="payroll_id" ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Hours Taught" FieldName="hours" ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Pay Rate" FieldName="pay_rate" ShowInCustomizationForm="True" VisibleIndex="5" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Gross Pay" FieldName="gross_pay" ShowInCustomizationForm="True" VisibleIndex="7" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                            <FooterCellStyle Font-Bold="True" ForeColor="Red">
                                            </FooterCellStyle>
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Deductions" FieldName="deductions" ShowInCustomizationForm="True" VisibleIndex="8" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="True" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Net Pay" FieldName="net_pay" ShowInCustomizationForm="True" VisibleIndex="9" Width="80px">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                            <EditFormSettings Visible="False" />
                                            <FooterCellStyle Font-Bold="True" ForeColor="Red">
                                            </FooterCellStyle>
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn FieldName="staff_code" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Category" FieldName="pay_type" ShowInCustomizationForm="True" VisibleIndex="4">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Staff Name" FieldName="emp_name" ShowInCustomizationForm="True" VisibleIndex="3">
                                            <EditFormSettings Visible="False" />
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" VisibleIndex="0" Width="25px">
                                        </dx:GridViewCommandColumn>
                                    </Columns>
                                    <TotalSummary>
                                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="gross_pay" ShowInColumn="Gross Pay" ShowInGroupFooterColumn="Gross Pay" SummaryType="Sum" />
                                        <dx:ASPxSummaryItem DisplayFormat="{0:0,0}" FieldName="net_pay" ShowInColumn="Net Pay" ShowInGroupFooterColumn="Net Pay" SummaryType="Sum" />
                                    </TotalSummary>
                                </dx:ASPxGridView>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ObjectDataSource ID="dsSpecialPayrollList" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetSpecialPayList" TypeName="HRMDataTableAdapters.hrm_special_paymentsTableAdapter" UpdateMethod="Update">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Original_ID" Type="Int32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="payroll_id" Type="Int32" />
                                        <asp:Parameter Name="hours" Type="Double" />
                                        <asp:Parameter Name="pay_rate" Type="Double" />
                                        <asp:Parameter Name="gross_pay" Type="Double" />
                                        <asp:Parameter Name="deductions" Type="Double" />
                                        <asp:Parameter Name="net_pay" Type="Double" />
                                        <asp:Parameter Name="staff_code" Type="Int32" />
                                        <asp:Parameter Name="pay_type" Type="String" />
                                    </InsertParameters>
                                    <SelectParameters>
                                        <asp:SessionParameter Name="pid" SessionField="pid" Type="Int32" />
                                    </SelectParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="payroll_id" Type="Int32" />
                                        <asp:Parameter Name="hours" Type="Double" />
                                        <asp:Parameter Name="pay_rate" Type="Double" />
                                        <asp:Parameter Name="gross_pay" Type="Double" />
                                        <asp:Parameter Name="deductions" Type="Double" />
                                        <asp:Parameter Name="net_pay" Type="Double" />
                                        <asp:Parameter Name="staff_code" Type="Int32" />
                                        <asp:Parameter Name="pay_type" Type="String" />
                                        <asp:Parameter Name="Original_ID" Type="Int32" />
                                    </UpdateParameters>
                                </asp:ObjectDataSource>
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                        </tr>
                    </table>
                </dx:ContentControl>
            </ContentCollection>
        </dx:TabPage>
        <dx:TabPage Text=" Documents Centre">
            <TabImage IconID="support_knowledgebasearticle_16x16">
            </TabImage>
            <ContentCollection>
                <dx:ContentControl runat="server">
                    <uc2:DocumentCentre ID="DocumentCentre1" runat="server" />
                </dx:ContentControl>
            </ContentCollection>
        </dx:TabPage>
    </TabPages>
    <TabStyle>
        <Paddings Padding="10px" />
    </TabStyle>
</dx:ASPxPageControl>

                <dx:ASPxPopupControl runat="server" 
    PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" 
    Modal="True" HeaderText="" ID="pop_details">
<ClientSideEvents CloseUp="function(s, e) {
	gvPayroll.Refresh();
}"></ClientSideEvents>
<ContentCollection>
<dx:PopupControlContentControl runat="server">
                        </dx:PopupControlContentControl>
</ContentCollection>
</dx:ASPxPopupControl>

            

