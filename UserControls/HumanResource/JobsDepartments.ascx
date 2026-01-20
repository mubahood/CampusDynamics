<%@ Control Language="C#" AutoEventWireup="true" CodeFile="JobsDepartments.ascx.cs" Inherits="UserControls_HumanResource_JobsDepartments" %>
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
        overflow: hidden;
        padding-left: 3px;
        padding-right: 3px;
        padding-top: 2px;
        padding-bottom: 1px;
    }
    .style2
    {
        width: 100%;
        overflow: hidden;
        padding-left: 2px;
        padding-right: 2px;
        padding-top: 1px;
        padding-bottom: 0px;
    }
</style>

<dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" 
    Width="100%">
    <TabPages>
        <dx:TabPage Text="Jobs Info">
            <ContentCollection>
                <dx:ContentControl runat="server">
                    <table class="style1">
                        <tr>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxButton ID="cmdAddNewJob" runat="server" OnClick="cmdAddNew_Click" 
                                    Text=" New Job" Width="170px">
                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxGridView ID="gvJobs" runat="server" AutoGenerateColumns="False" 
                                    DataSourceID="dsJobs" KeyFieldName="ID" Width="100%">
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Job" FieldName="jobname" 
                                            ShowInCustomizationForm="True" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Qualifications" 
                                            FieldName="min_qualifications" ShowInCustomizationForm="True" VisibleIndex="3">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" 
                                            ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" 
                                            Width="25px">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" 
                                            ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                                        </dx:GridViewCommandColumn>
                                    </Columns>
                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                    <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |" 
                                        CommandEdit="| Edit |" CommandUpdate="| Save Changes |" 
                                        ConfirmDelete="Delete Job?" />
                                </dx:ASPxGridView>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ObjectDataSource ID="dsJobs" runat="server" DeleteMethod="Delete" 
                                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                    SelectMethod="GetData" TypeName="HRMDataTableAdapters.hrm_jobsTableAdapter" 
                                    UpdateMethod="Update">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="jobname" Type="String" />
                                        <asp:Parameter Name="min_qualifications" Type="String" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="jobname" Type="String" />
                                        <asp:Parameter Name="min_qualifications" Type="String" />
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </UpdateParameters>
                                </asp:ObjectDataSource>
                            </td>
                        </tr>
                    </table>
                </dx:ContentControl>
            </ContentCollection>
        </dx:TabPage>
        <dx:TabPage Text="Departments">
            <ContentCollection>
                <dx:ContentControl runat="server">
                    <table class="style1">
                        <tr>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxButton ID="cmdAddNewDept" runat="server" OnClick="cmdAddNewDept_Click" 
                                    Text=" New Department" Width="170px">
                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxGridView ID="gvDepartments" runat="server" AutoGenerateColumns="False" 
                                    DataSourceID="dsDepartment" KeyFieldName="ID" Width="100%">
                                    <Columns>
                                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" 
                                            ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" 
                                            Width="25px">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Department" FieldName="dept_name" 
                                            ShowInCustomizationForm="True" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataComboBoxColumn Caption="HOD" FieldName="dept_headID" 
                                            ShowInCustomizationForm="True" VisibleIndex="3">
                                            <PropertiesComboBox DataSourceID="dsEmployees" 
                                                IncrementalFilteringMode="Contains" TextField="emp_name" TextFormatString="{1}" 
                                                ValueField="empID">
                                                <Columns>
                                                    <dx:ListBoxColumn Caption="Code" FieldName="empID" Width="30px" />
                                                    <dx:ListBoxColumn Caption="Employee Name" FieldName="emp_name" Width="200px" />
                                                </Columns>
                                            </PropertiesComboBox>
                                        </dx:GridViewDataComboBoxColumn>
                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" 
                                            ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                                        </dx:GridViewCommandColumn>
                                    </Columns>
                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                    <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |" 
                                        CommandEdit="| Edit |" CommandUpdate="| Save Changes |" 
                                        ConfirmDelete="Delete Department?" />
                                </dx:ASPxGridView>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ObjectDataSource ID="dsDepartment" runat="server" DeleteMethod="Delete" 
                                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                    SelectMethod="GetData" 
                                    TypeName="HRMDataTableAdapters.hrm_departmentsTableAdapter" 
                                    UpdateMethod="Update">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="dept_name" Type="String" />
                                        <asp:Parameter Name="dept_headID" Type="UInt32" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="dept_name" Type="String" />
                                        <asp:Parameter Name="dept_headID" Type="UInt32" />
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </UpdateParameters>
                                </asp:ObjectDataSource>
                                <asp:ObjectDataSource ID="dsEmployees" runat="server" 
                                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                                    TypeName="HRMDataTableAdapters.hrm_employeeTableAdapter">
                                </asp:ObjectDataSource>
                            </td>
                        </tr>
                    </table>
                </dx:ContentControl>
            </ContentCollection>
        </dx:TabPage>
        <dx:TabPage Text="Banks">
            <ContentCollection>
                <dx:ContentControl runat="server">
                    <table class="style1">
                        <tr>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxButton ID="cmdAddNewBank" runat="server" OnClick="cmdAddNewBank_Click" 
                                    Text=" New Bank" Width="170px">
                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxGridView ID="gvBanks" runat="server" AutoGenerateColumns="False" 
                                    DataSourceID="dsBanks" KeyFieldName="bank_id" Width="100%">
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="bank_id" ReadOnly="True" 
                                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Bank" FieldName="bank_name" 
                                            ShowInCustomizationForm="True" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" 
                                            ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" 
                                            Width="25px">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" 
                                            ShowInCustomizationForm="True" VisibleIndex="4" Width="100px">
                                        </dx:GridViewCommandColumn>
                                    </Columns>
                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                    <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |" 
                                        CommandEdit="| Edit |" CommandUpdate="| Save Changes |" 
                                        ConfirmDelete="Delete Bank?" />
                                </dx:ASPxGridView>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ObjectDataSource ID="dsBanks" runat="server" DeleteMethod="Delete" 
                                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                    SelectMethod="GetData" TypeName="HRMDataTableAdapters.banksTableAdapter" 
                                    UpdateMethod="Update">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Original_bank_id" Type="UInt32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="bank_name" Type="String" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="bank_name" Type="String" />
                                        <asp:Parameter Name="Original_bank_id" Type="UInt32" />
                                    </UpdateParameters>
                                </asp:ObjectDataSource>
                            </td>
                        </tr>
                    </table>
                </dx:ContentControl>
            </ContentCollection>
        </dx:TabPage>
        <dx:TabPage Text="Salary Scales">
            <ContentCollection>
                <dx:ContentControl runat="server">
                    <table class="style1">
                        <tr>
                            <td>
                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxButton ID="cmdAddNewScale" runat="server" 
                                    OnClick="cmdAddNewScale_Click" Text=" New Scale" Width="170px">
                                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                                    </Image>
                                </dx:ASPxButton>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <dx:ASPxGridView ID="gvScales" runat="server" AutoGenerateColumns="False" 
                                    DataSourceID="dsScales" KeyFieldName="ID" Width="100%">
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" 
                                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewDataTextColumn Caption="Scale Code" FieldName="scale_name" 
                                            ShowInCustomizationForm="True" VisibleIndex="2">
                                        </dx:GridViewDataTextColumn>
                                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" 
                                            ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" 
                                            Width="25px">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" 
                                            ShowInCustomizationForm="True" VisibleIndex="5" Width="100px">
                                        </dx:GridViewCommandColumn>
                                        <dx:GridViewDataTextColumn Caption="Basic Pay" FieldName="basicpay" 
                                            ShowInCustomizationForm="True" VisibleIndex="3">
                                            <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                            </PropertiesTextEdit>
                                        </dx:GridViewDataTextColumn>
                                    </Columns>
                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                    <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |" 
                                        CommandEdit="| Edit |" CommandUpdate="| Save Changes |" 
                                        ConfirmDelete="Delete Scale?" />
                                </dx:ASPxGridView>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ObjectDataSource ID="dsScales" runat="server" DeleteMethod="Delete" 
                                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                    SelectMethod="GetData" 
                                    TypeName="HRMDataTableAdapters.hrm_payscalesTableAdapter" UpdateMethod="Update">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </DeleteParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="scale_name" Type="String" />
                                        <asp:Parameter Name="basicpay" Type="Double" />
                                    </InsertParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="scale_name" Type="String" />
                                        <asp:Parameter Name="basicpay" Type="Double" />
                                        <asp:Parameter Name="Original_ID" Type="UInt32" />
                                    </UpdateParameters>
                                </asp:ObjectDataSource>
                            </td>
                        </tr>
                    </table>
                </dx:ContentControl>
            </ContentCollection>
        </dx:TabPage>
    </TabPages>
</dx:ASPxPageControl>

