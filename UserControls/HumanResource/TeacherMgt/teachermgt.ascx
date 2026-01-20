<%@ Control Language="C#" AutoEventWireup="true" CodeFile="teachermgt.ascx.cs" Inherits="UserControls_HumanResource_TeacherMgt_teachermgt" %>
<script language="javascript" type="text/javascript">
    // <![CDATA[
    function ShowDetailsWindow() {

        StaffDetails.Show();
    }
    </script>
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
                        <td>
                            <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" 
                                ImageUrl="~/COOPERP/images/header_employeeinfo.png">
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
                <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click" 
                    Text="Add New" Width="170px">
                    <Image Url="~/COOPERP/images/clipboard--plus.png">
                    </Image>
                </dx:ASPxButton>
            </td>
        </tr>
        <tr>
            <td>
                <dx:ASPxGridView ID="gvEmployees" runat="server" AutoGenerateColumns="False" 
                    DataSourceID="dsEmployees" KeyFieldName="empID" 
                    OnRowInserting="gvEmployees_RowInserting" Width="100%" 
                    OnInitNewRow="gvEmployees_InitNewRow">
                    <Columns>
                        <dx:GridViewCommandColumn SelectAllCheckboxMode="Page" 
                            ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" 
                            Width="25px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataTextColumn Caption="SNo" FieldName="empID" ReadOnly="True" 
                            ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                            <EditFormSettings Visible="False" />
                            <CellStyle HorizontalAlign="Left">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Employee Name" FieldName="emp_name" 
                            ShowInCustomizationForm="True" VisibleIndex="4">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataDateColumn Caption="Birth Date" FieldName="emp_birthdate" 
                            ShowInCustomizationForm="True" VisibleIndex="5">
                            <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                            </PropertiesDateEdit>
                        </dx:GridViewDataDateColumn>
                        <dx:GridViewDataTextColumn Caption="Phone Contact" FieldName="emp_phone" 
                            ShowInCustomizationForm="True" VisibleIndex="6">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Email" FieldName="emp_email" 
                            ShowInCustomizationForm="True" VisibleIndex="7">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True" 
                            ShowInCustomizationForm="True" VisibleIndex="22" Width="100px">
                        </dx:GridViewCommandColumn>
                        <dx:GridViewDataMemoColumn Caption="Qualifications" 
                            FieldName="emp_qualifications" ShowInCustomizationForm="True" Visible="False" 
                            VisibleIndex="9">
                            <EditFormSettings ColumnSpan="2" Visible="True" />
                        </dx:GridViewDataMemoColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Nationality" 
                            FieldName="emp_nationality" ShowInCustomizationForm="True" VisibleIndex="11">
                            <PropertiesComboBox IncrementalFilteringMode="Contains">
                                <Items>
                                    <dx:ListEditItem Text="UGANDAN" Value="UGANDAN" />
                                    <dx:ListEditItem Text="KENYAN" Value="KENYAN" />
                                    <dx:ListEditItem Text="TANZANIAN" Value="TANZANIAN" />
                                    <dx:ListEditItem Text="RWANDAN" Value="RWANDAN" />
                                    <dx:ListEditItem Text="SOUTH SUDANESE" Value="SOUTH SUDANESE" />
                                </Items>
                            </PropertiesComboBox>
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Account No" FieldName="bankAccount" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="14">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="NSSF No" FieldName="nssf_no" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Bank" FieldName="bankID" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                            <PropertiesComboBox DataSourceID="dsBanks" TextField="bank_name" 
                                TextFormatString="{1}" ValueField="bank_id">
                                <Columns>
                                    <dx:ListBoxColumn Caption="Code" FieldName="bank_id" Width="40px" />
                                    <dx:ListBoxColumn Caption="Bank Name" FieldName="bank_name" Width="200px" />
                                </Columns>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Category" FieldName="EmpType" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="17">
                            <PropertiesComboBox>
                                <Items>
                                    <dx:ListEditItem Text="Academic" Value="Academic" />
                                    <dx:ListEditItem Text="Administrative" Value="Administrative" />
                                    <dx:ListEditItem Text="Support" Value="Support" />
                                </Items>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataTextColumn Caption="Address" FieldName="address" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="25">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Religion" FieldName="religion" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="26">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Tribe" FieldName="tribe" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="27">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Spouse Name" FieldName="spouse_name" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="28">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="No. Children" FieldName="no_children" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="29">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Contact Person" FieldName="contact_person" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="30">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Relation" FieldName="relation" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="31">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Phone Contacts" FieldName="phone_contacts" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="32">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Current Residence" 
                            FieldName="current_residence" ShowInCustomizationForm="True" Visible="False" 
                            VisibleIndex="33">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Father Name" FieldName="father_name" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="34">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Mother Name" FieldName="mother_name" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="35">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Referee 1" FieldName="referee_1" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="36">
                            <EditFormSettings ColumnSpan="2" Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Referee 2" FieldName="referee_2" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="37">
                            <EditFormSettings ColumnSpan="2" Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataComboBoxColumn Caption="Marital Status" 
                            FieldName="marital_status" ShowInCustomizationForm="True" Visible="False" 
                            VisibleIndex="24">
                            <PropertiesComboBox IncrementalFilteringMode="StartsWith">
                                <Items>
                                    <dx:ListEditItem Text="SINGLE" Value="SINGLE" />
                                    <dx:ListEditItem Text="MARRIED" Value="MARRIED" />
                                    <dx:ListEditItem Text="DIVORCED" Value="DIVORCED" />
                                </Items>
                            </PropertiesComboBox>
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataComboBoxColumn>
                        <dx:GridViewDataMemoColumn Caption="Medical Info" 
                            FieldName="medical_background" ShowInCustomizationForm="True" Visible="False" 
                            VisibleIndex="38">
                            <EditFormSettings ColumnSpan="2" Visible="True" />
                        </dx:GridViewDataMemoColumn>
                        <dx:GridViewDataMemoColumn Caption="Employment" FieldName="employment_info" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="41">
                            <EditFormSettings ColumnSpan="2" Visible="True" />
                        </dx:GridViewDataMemoColumn>
                        <dx:GridViewDataMemoColumn Caption="Academic | Prof. Training" 
                            FieldName="schooling_info" ShowInCustomizationForm="True" Visible="False" 
                            VisibleIndex="40">
                            <EditFormSettings ColumnSpan="2" Visible="True" />
                        </dx:GridViewDataMemoColumn>
                        <dx:GridViewDataTextColumn Caption="User Name" FieldName="usernames" 
                            ShowInCustomizationForm="True" VisibleIndex="20" Width="50px">
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Staff Code" FieldName="EMP_CODE" 
                            ReadOnly="True" ShowInCustomizationForm="True" VisibleIndex="2" Width="100px">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entry Year" FieldName="Entry_Year" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="42">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Entry Station" FieldName="Entry_Satation" 
                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="43">
                            <EditFormSettings Visible="True" />
                        </dx:GridViewDataTextColumn>
                        <dx:GridViewDataTextColumn Caption="Staff Profile" 
                            ShowInCustomizationForm="True" VisibleIndex="21" Width="30px">
                            <DataItemTemplate>
                                <asp:ImageButton ID="cmdProfile" runat="server" 
                                    ImageUrl="~/COOPERP/images/clipboard-invoice.png" onclick="cmdProfile_Click" />
                            </DataItemTemplate>
                            <CellStyle HorizontalAlign="Center">
                            </CellStyle>
                        </dx:GridViewDataTextColumn>
                    </Columns>
                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                    <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                    <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |" 
                        CommandEdit="| Edit |" CommandUpdate="| Save Changes |" 
                        ConfirmDelete="Delete Employee?" />
                </dx:ASPxGridView>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ObjectDataSource ID="dsBanks" runat="server" 
                    OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" 
                    TypeName="HRMDataTableAdapters.banksTableAdapter"></asp:ObjectDataSource>
                <asp:ObjectDataSource ID="dsEmployees" runat="server" DeleteMethod="Delete" 
                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" 
                    SelectMethod="GetData" TypeName="HRMDataTableAdapters.hrm_employeeTableAdapter" 
                    UpdateMethod="Update">
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
                <dx:ASPxPopupControl ID="pop_staffdetails" runat="server" AllowDragging="True" 
                    AutoUpdatePosition="True" ClientInstanceName="StaffDetails" 
                    HeaderText="International School Dynamics Version 1.0" Modal="True" 
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

