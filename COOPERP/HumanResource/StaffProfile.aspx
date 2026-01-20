<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StaffProfile.aspx.cs" Inherits="COOPERP_HumanResource_StaffProfile" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .style2
        {
            width: 130px;
            font-weight: 700;
        }
        .style4
        {
            width: 173px;
        }
        .style5
        {
            width: 104px;
            font-weight: 700;
        }
        

*
{ 
    /*padding: 0;*/
    margin-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    
}


        .style8
        {
            width: 73px;
        }
        .style6
        {
            width: 148px;
        }
        </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <dx:ASPxPageControl ID="ASPxPageControl1" runat="server" ActiveTabIndex="0" 
            Width="100%">
            <TabPages>
                <dx:TabPage Text="Bio Data">
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <table width="100%">
                                <tr>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="gvStaffProfile" runat="server" AutoGenerateColumns="False" 
                                            DataSourceID="dsStaffDetails" KeyFieldName="empID" Width="100%">
                                            <Columns>
                                                <dx:GridViewDataTextColumn FieldName="empID" ReadOnly="True" 
                                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="0">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="emp_name" ShowInCustomizationForm="True" 
                                                    Visible="False" VisibleIndex="1">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn FieldName="emp_birthdate" 
                                                    ShowInCustomizationForm="True" VisibleIndex="2">
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn FieldName="emp_phone" ShowInCustomizationForm="True" 
                                                    VisibleIndex="3">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="emp_email" ShowInCustomizationForm="True" 
                                                    VisibleIndex="4">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="emp_qualifications" 
                                                    ShowInCustomizationForm="True" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="emp_nationality" 
                                                    ShowInCustomizationForm="True" VisibleIndex="6">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="bankID" ShowInCustomizationForm="True" 
                                                    VisibleIndex="7">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="EmpType" ShowInCustomizationForm="True" 
                                                    VisibleIndex="10">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="usernames" ShowInCustomizationForm="True" 
                                                    VisibleIndex="28">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="EMP_CODE" ShowInCustomizationForm="True" 
                                                    VisibleIndex="29">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Entry_Year" 
                                                    ShowInCustomizationForm="True" VisibleIndex="30">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="Entry_Satation" 
                                                    ShowInCustomizationForm="True" VisibleIndex="31">
                                                </dx:GridViewDataTextColumn>
                                            </Columns>
                                            <Settings ShowColumnHeaders="False" />
                                            <Templates>
                                                <DataRow>
                                                    <table width="100%">
                                                        <tr>
                                                            <td align="center" colspan="4">
                                                                <dx:ASPxLabel ID="ASPxLabel1" runat="server" Font-Bold="True" Font-Size="Small" 
                                                                    ForeColor="Red" Text='<%# Eval("emp_name", "{0}") %>'>
                                                                </dx:ASPxLabel>
                                                                &nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td align="center" colspan="4">
                                                                <dx:ASPxImage ID="ASPxImage1" runat="server" Height="1px" 
                                                                    ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="true" Width="100%">
                                                                </dx:ASPxImage>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="center" colspan="4">
                                                                <dx:ASPxImage ID="ASPxImage2" runat="server" EnableViewState="False" 
                                                                    Height="150px" 
                                                                    ImageUrl='<%#GenerateImageUrl() %>' 
                                                                    ShowLoadingImage="True">
                                                                </dx:ASPxImage>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="center" colspan="4">
                                                                <dx:ASPxImage ID="ASPxImage3" runat="server" Height="1px" 
                                                                    ImageUrl="~/COOPERP/images/hor_line.png" ShowLoadingImage="true" Width="100%">
                                                                </dx:ASPxImage>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">
                                                                Staff No:</td>
                                                            <td class="style4">
                                                                <dx:ASPxLabel ID="ASPxLabel2" runat="server" Text='<%# Eval("EMP_CODE") %>'>
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="style2">
                                                                Staff Phone:</td>
                                                            <td>
                                                                <dx:ASPxLabel ID="ASPxLabel3" runat="server" Text='<%# Eval("emp_phone") %>'>
                                                                </dx:ASPxLabel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">
                                                                Qualifications:</td>
                                                            <td class="style4">
                                                                <dx:ASPxLabel ID="ASPxLabel5" runat="server" 
                                                                    Text='<%# Eval("emp_qualifications") %>'>
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="style2">
                                                                Email:</td>
                                                            <td>
                                                                <dx:ASPxLabel ID="ASPxLabel4" runat="server" Text='<%# Eval("emp_email") %>'>
                                                                </dx:ASPxLabel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">
                                                                Entry Year:</td>
                                                            <td class="style4">
                                                                <dx:ASPxLabel ID="ASPxLabel6" runat="server" Text='<%# Eval("Entry_Year") %>'>
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="style2">
                                                                Station:</td>
                                                            <td>
                                                                <dx:ASPxLabel ID="ASPxLabel7" runat="server" 
                                                                    Text='<%# Eval("Entry_Satation") %>'>
                                                                </dx:ASPxLabel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">
                                                                Marital Status:</td>
                                                            <td class="style4">
                                                                <dx:ASPxLabel ID="ASPxLabel8" runat="server" 
                                                                    Text='<%# Eval("marital_status") %>'>
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="style2">
                                                                Address:</td>
                                                            <td>
                                                                <dx:ASPxLabel ID="ASPxLabel9" runat="server" Text='<%# Eval("address") %>'>
                                                                </dx:ASPxLabel>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="style5">
                                                                Nationality:</td>
                                                            <td class="style4">
                                                                <dx:ASPxLabel ID="ASPxLabel10" runat="server" 
                                                                    Text='<%# Eval("emp_nationality") %>'>
                                                                </dx:ASPxLabel>
                                                            </td>
                                                            <td class="style2">
                                                                &nbsp;</td>
                                                            <td>
                                                                &nbsp;</td>
                                                        </tr>
                                                    </table>
                                                </DataRow>
                                            </Templates>
                                        </dx:ASPxGridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:ObjectDataSource ID="dsStaffDetails" runat="server" DeleteMethod="Delete" 
                                            InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                                            SelectMethod="GetSingleStaff" 
                                            TypeName="HRMDataTableAdapters.hrm_employeeTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_empID" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="emp_name" Type="String" />
                                                <asp:Parameter Name="emp_birthdate" Type="DateTime" />
                                                <asp:Parameter Name="emp_phone" Type="String" />
                                                <asp:Parameter Name="emp_email" Type="String" />
                                                <asp:Parameter Name="emp_qualifications" Type="String" />
                                                <asp:Parameter Name="emp_nationality" Type="String" />
                                                <asp:Parameter Name="bankID" Type="UInt32" />
                                                <asp:Parameter Name="bankAccount" Type="String" />
                                                <asp:Parameter Name="nssf_no" Type="String" />
                                                <asp:Parameter Name="EmpType" Type="String" />
                                                <asp:Parameter Name="marital_status" Type="String" />
                                                <asp:Parameter Name="address" Type="String" />
                                                <asp:Parameter Name="religion" Type="String" />
                                                <asp:Parameter Name="tribe" Type="String" />
                                                <asp:Parameter Name="spouse_name" Type="String" />
                                                <asp:Parameter Name="no_children" Type="UInt32" />
                                                <asp:Parameter Name="contact_person" Type="String" />
                                                <asp:Parameter Name="relation" Type="String" />
                                                <asp:Parameter Name="phone_contacts" Type="String" />
                                                <asp:Parameter Name="current_residence" Type="String" />
                                                <asp:Parameter Name="father_name" Type="String" />
                                                <asp:Parameter Name="mother_name" Type="String" />
                                                <asp:Parameter Name="referee_1" Type="String" />
                                                <asp:Parameter Name="referee_2" Type="String" />
                                                <asp:Parameter Name="medical_background" Type="String" />
                                                <asp:Parameter Name="schooling_info" Type="String" />
                                                <asp:Parameter Name="employment_info" Type="String" />
                                                <asp:Parameter Name="EMP_CODE" Type="String" />
                                                <asp:Parameter Name="Entry_Year" Type="UInt32" />
                                                <asp:Parameter Name="Entry_Satation" Type="String" />
                                                <asp:Parameter Name="usernames" Type="String" />
                                            </InsertParameters>
                                            <SelectParameters>
                                                <asp:SessionParameter DefaultValue="0" Name="ID" SessionField="empID" 
                                                    Type="Int32" />
                                            </SelectParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="emp_name" Type="String" />
                                                <asp:Parameter Name="emp_birthdate" Type="DateTime" />
                                                <asp:Parameter Name="emp_phone" Type="String" />
                                                <asp:Parameter Name="emp_email" Type="String" />
                                                <asp:Parameter Name="emp_qualifications" Type="String" />
                                                <asp:Parameter Name="emp_nationality" Type="String" />
                                                <asp:Parameter Name="bankID" Type="UInt32" />
                                                <asp:Parameter Name="bankAccount" Type="String" />
                                                <asp:Parameter Name="nssf_no" Type="String" />
                                                <asp:Parameter Name="EmpType" Type="String" />
                                                <asp:Parameter Name="marital_status" Type="String" />
                                                <asp:Parameter Name="address" Type="String" />
                                                <asp:Parameter Name="religion" Type="String" />
                                                <asp:Parameter Name="tribe" Type="String" />
                                                <asp:Parameter Name="spouse_name" Type="String" />
                                                <asp:Parameter Name="no_children" Type="UInt32" />
                                                <asp:Parameter Name="contact_person" Type="String" />
                                                <asp:Parameter Name="relation" Type="String" />
                                                <asp:Parameter Name="phone_contacts" Type="String" />
                                                <asp:Parameter Name="current_residence" Type="String" />
                                                <asp:Parameter Name="father_name" Type="String" />
                                                <asp:Parameter Name="mother_name" Type="String" />
                                                <asp:Parameter Name="referee_1" Type="String" />
                                                <asp:Parameter Name="referee_2" Type="String" />
                                                <asp:Parameter Name="medical_background" Type="String" />
                                                <asp:Parameter Name="schooling_info" Type="String" />
                                                <asp:Parameter Name="employment_info" Type="String" />
                                                <asp:Parameter Name="EMP_CODE" Type="String" />
                                                <asp:Parameter Name="Entry_Year" Type="UInt32" />
                                                <asp:Parameter Name="Entry_Satation" Type="String" />
                                                <asp:Parameter Name="usernames" Type="String" />
                                                <asp:Parameter Name="Original_empID" Type="UInt32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                    </td>
                                </tr>
                            </table>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text="Salary Profile">
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <table width="100%">
                                <tr>
                                    <td>
                                        &nbsp;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="gvSalaryInfo" runat="server" AutoGenerateColumns="False" 
                                            DataSourceID="dsSinglePayroll" Width="100%" KeyFieldName="payrollid">
                                            <Columns>
                                                <dx:GridViewDataTextColumn FieldName="payrollid" ShowInCustomizationForm="True" 
                                                    Visible="False" VisibleIndex="1">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="payroll_title" 
                                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="2">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Month" FieldName="payroll_month" 
                                                    ShowInCustomizationForm="True" VisibleIndex="3">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Year" FieldName="payroll_year" 
                                                    ShowInCustomizationForm="True" VisibleIndex="4" Width="80px">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn FieldName="empID" ShowInCustomizationForm="True" 
                                                    Visible="False" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Basic Salary" FieldName="basic_pay" 
                                                    ShowInCustomizationForm="True" VisibleIndex="6" Width="80px">
                                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                    </PropertiesTextEdit>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="PAYE" FieldName="paye" 
                                                    ShowInCustomizationForm="True" VisibleIndex="9" Width="80px">
                                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                    </PropertiesTextEdit>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="NSSF" FieldName="nssf" 
                                                    ShowInCustomizationForm="True" VisibleIndex="10" Width="80px">
                                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                    </PropertiesTextEdit>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Total Allowances" 
                                                    FieldName="total_allowances" ShowInCustomizationForm="True" VisibleIndex="7" 
                                                    Width="80px">
                                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                    </PropertiesTextEdit>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Total Deductions" 
                                                    FieldName="total_deductions" ShowInCustomizationForm="True" VisibleIndex="11" 
                                                    Width="80px">
                                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                    </PropertiesTextEdit>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Gross" FieldName="gross_pay" 
                                                    ShowInCustomizationForm="True" VisibleIndex="8" Width="80px">
                                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                    </PropertiesTextEdit>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Net Pay" FieldName="net_pay" 
                                                    ShowInCustomizationForm="True" VisibleIndex="12" Width="80px">
                                                    <PropertiesTextEdit DisplayFormatString="{0:0,0}">
                                                    </PropertiesTextEdit>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" 
                                                    ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                </dx:GridViewCommandColumn>
                                            </Columns>
                                            <SettingsBehavior AllowFocusedRow="True" />
                                            <Settings ShowFilterRow="True" />
                                        </dx:ASPxGridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:ObjectDataSource ID="dsSinglePayroll" runat="server" 
                                            OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                                            TypeName="HRMDataTableAdapters.hrm_SinglestaffPayrollTableAdapter">
                                            <SelectParameters>
                                                <asp:SessionParameter Name="eid" SessionField="empID" Type="Int32" />
                                            </SelectParameters>
                                        </asp:ObjectDataSource>
                                    </td>
                                </tr>
                            </table>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
                <dx:TabPage Text="Photo">
                    <ContentCollection>
                        <dx:ContentControl runat="server">
                            <table width="100%">
                                <tr>
                                    <td class="style8">
                                        Image File:</td>
                                    <td class="style6">
                                        <dx:ASPxUploadControl ID="txtFilePath" runat="server">
                                        </dx:ASPxUploadControl>
                                    </td>
                                    <td>
                                        <dx:ASPxButton ID="cmdAttach" runat="server" OnClick="cmdAttach_Click" 
                                            Text="Attach Photo" Width="170px">
                                            <ClientSideEvents Click="function(s, e) {
	 e.processOnServer = confirm('Attach Photo?');
}" />
                                            <Image Url="~/COOPERP/images/clipboard--plus.png">
                                            </Image>
                                        </dx:ASPxButton>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="style8">
                                        &nbsp;</td>
                                    <td class="style5" colspan="2">
                                        <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red">
                                        </dx:ASPxLabel>
                                    </td>
                                </tr>
                            </table>
                        </dx:ContentControl>
                    </ContentCollection>
                </dx:TabPage>
            </TabPages>
        </dx:ASPxPageControl>
    
    </div>
    </form>
</body>
</html>
