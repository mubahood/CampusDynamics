<%@ Control Language="C#" AutoEventWireup="true" CodeFile="Employee.ascx.cs" Inherits="UserControls_HumanResource_Employee" %>
<style type="text/css">
    .style1 {
        width: 100%;
    }

    * {
        /*padding: 0;*/
        margin-left: 0;
        margin-top: 0;
        margin-bottom: 0;
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
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>
                        <table class="style1">
                            <tr>
                                <td>
                                    <dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click"
                                        Text="Add New" Width="170px" Height="35px">
                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                                <td align="right">
                                    <dx:ASPxButton ID="cmdStations" runat="server" OnClick="cmdStations_Click"
                                        Text="Stations..." Width="170px" Height="35px">
                                        <Image Url="~/COOPERP/images/home.png">
                                        </Image>
                                    </dx:ASPxButton>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxGridView ID="gvEmployees" runat="server" AutoGenerateColumns="False"
                            DataSourceID="dsEmployees" KeyFieldName="empID" Width="100%"
                            OnRowInserting="gvEmployees_RowInserting" OnCustomErrorText="gvEmployees_CustomErrorText" OnHtmlRowPrepared="gvEmployees_HtmlRowPrepared" OnInitNewRow="gvEmployees_InitNewRow">
                            <EditFormLayoutProperties ColCount="2">
                                <Items>
                                    <dx:GridViewColumnLayoutItem ColumnName="EMP_CODE">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="emp_name">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="emp_birthdate">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="emp_phone">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="emp_email">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="emp_qualifications">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="Education Level">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="emp_nationality">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="bankID">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="bankAccount">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="nssf_no">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="TIN">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="EmpType">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="usernames">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="marital_status">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="address">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="religion">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="tribe">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="spouse_name">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="no_children">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="contact_person">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="relation">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="phone_contacts">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="current_residence">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="father_name">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="mother_name">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="referee_1">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="referee_2">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="medical_background">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="schooling_info">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColSpan="2" ColumnName="employment_info">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="Entry_Year">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:GridViewColumnLayoutItem ColumnName="Entry_Satation">
                                    </dx:GridViewColumnLayoutItem>
                                    <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right">
                                    </dx:EditModeCommandLayoutItem>
                                </Items>
                            </EditFormLayoutProperties>
                            <Columns>
                                <dx:GridViewCommandColumn SelectAllCheckboxMode="Page"
                                    ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0"
                                    Width="25px" ShowClearFilterButton="True">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataTextColumn Caption="SNo" FieldName="empID" ReadOnly="True"
                                    ShowInCustomizationForm="True" VisibleIndex="1" Width="40px">
                                    <EditFormSettings Visible="False" />
                                    <CellStyle HorizontalAlign="Left">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Employee Name" FieldName="emp_name"
                                    ShowInCustomizationForm="True" VisibleIndex="3">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataDateColumn Caption="Birth Date" FieldName="emp_birthdate"
                                    ShowInCustomizationForm="True" VisibleIndex="4">
                                    <PropertiesDateEdit DisplayFormatString="dd MMMM, yyyy">
                                    </PropertiesDateEdit>
                                </dx:GridViewDataDateColumn>
                                <dx:GridViewDataTextColumn Caption="Phone Contact" FieldName="emp_phone"
                                    ShowInCustomizationForm="True" VisibleIndex="5">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Email" FieldName="emp_email"
                                    ShowInCustomizationForm="True" VisibleIndex="6">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True"
                                    ShowInCustomizationForm="True" VisibleIndex="21" Width="45px">
                                </dx:GridViewCommandColumn>
                                <dx:GridViewDataMemoColumn Caption="Qualifications"
                                    FieldName="emp_qualifications" ShowInCustomizationForm="True" Visible="False"
                                    VisibleIndex="7">
                                    <EditFormSettings ColumnSpan="2" Visible="True" />
                                </dx:GridViewDataMemoColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Nationality"
                                    FieldName="emp_nationality" ShowInCustomizationForm="True"
                                    VisibleIndex="9">
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
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="12">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="NSSF No" FieldName="nssf_no"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="13">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Bank" FieldName="bankID"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="11">
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
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                    <PropertiesComboBox>
                                        <Items>
                                            <dx:ListEditItem Text="Academic" Value="Academic" />
                                            <dx:ListEditItem Text="Administrative" Value="Administrative" />
                                            <dx:ListEditItem Text="Support" Value="Support" />
                                            <dx:ListEditItem Text="Consultant" Value="Consultant" />
                                            <dx:ListEditItem Text="Adjunct" Value="Adjunct" />
                                            <dx:ListEditItem Text="Parttime" Value="Parttime" />
                                        </Items>
                                    </PropertiesComboBox>
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataTextColumn Caption="Address" FieldName="address"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="24">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Religion" FieldName="religion"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="25">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Tribe" FieldName="tribe"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="26">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Spouse Name" FieldName="spouse_name"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="27">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="No. Children" FieldName="no_children"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="28">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Contact Person" FieldName="contact_person"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="29">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Relation" FieldName="relation"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="30">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Phone Contacts" FieldName="phone_contacts"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="31">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Current Residence"
                                    FieldName="current_residence" ShowInCustomizationForm="True" Visible="False"
                                    VisibleIndex="32">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Father Name" FieldName="father_name"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="33">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Mother Name" FieldName="mother_name"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="34">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Referee 1" FieldName="referee_1"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="35">
                                    <EditFormSettings Visible="True" ColumnSpan="2" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Referee 2" FieldName="referee_2"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="36">
                                    <EditFormSettings Visible="True" ColumnSpan="2" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Marital Status"
                                    FieldName="marital_status" ShowInCustomizationForm="True" Visible="False"
                                    VisibleIndex="23">
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
                                    FieldName="medical_background" ShowInCustomizationForm="True"
                                    VisibleIndex="37" Visible="False">
                                    <EditFormSettings ColumnSpan="2" Visible="True" />
                                </dx:GridViewDataMemoColumn>
                                <dx:GridViewDataMemoColumn Caption="Employment" FieldName="employment_info"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="40">
                                    <EditFormSettings ColumnSpan="2" Visible="True" />
                                </dx:GridViewDataMemoColumn>
                                <dx:GridViewDataMemoColumn Caption="Academic | Prof. Training"
                                    FieldName="schooling_info" ShowInCustomizationForm="True" Visible="False"
                                    VisibleIndex="39">
                                    <EditFormSettings ColumnSpan="2" Visible="True" />
                                </dx:GridViewDataMemoColumn>
                                <dx:GridViewDataTextColumn Caption="User Name" FieldName="usernames"
                                    ShowInCustomizationForm="True" VisibleIndex="19" Width="50px">
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Staff Code" FieldName="EMP_CODE" ShowInCustomizationForm="True" VisibleIndex="2" Width="120px">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Entry Year" FieldName="Entry_Year"
                                    ShowInCustomizationForm="True" Visible="False" VisibleIndex="41">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn Caption="Staff Profile"
                                    ShowInCustomizationForm="True" VisibleIndex="20" Width="30px">
                                    <EditFormSettings Visible="False" />
                                    <DataItemTemplate>
                                        <asp:ImageButton ID="cmdProfile" runat="server" ImageUrl="~/COOPERP/images/clipboard-invoice.png" OnClick="cmdProfile_Click" />
                                    </DataItemTemplate>
                                    <CellStyle HorizontalAlign="Center">
                                    </CellStyle>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Entry Station" FieldName="Entry_Satation" ShowInCustomizationForm="True" Visible="False" VisibleIndex="42">
                                    <PropertiesComboBox DataSourceID="dsStations" TextField="station_name" ValueField="station_name">
                                    </PropertiesComboBox>
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataComboBoxColumn>
                                <dx:GridViewDataTextColumn Caption="TIN" FieldName="tin" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                    <EditFormSettings Visible="True" />
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataComboBoxColumn Caption="Education Level" FieldName="max_education" ShowInCustomizationForm="True" VisibleIndex="8">
                                    <PropertiesComboBox>
                                        <Items>
                                            <dx:ListEditItem Text="Certificate" Value="Certificate" />
                                            <dx:ListEditItem Text="Diploma" Value="Diploma" />
                                            <dx:ListEditItem Text="Bachelors" Value="Bachelors" />
                                            <dx:ListEditItem Text="Masters" Value="Masters" />
                                            <dx:ListEditItem Text="PHD" Value="PHD" />
                                            <dx:ListEditItem Text="Proffessor" Value="Proffessor" />
                                            <dx:ListEditItem Text="NA" Value="NA" />
                                        </Items>
                                    </PropertiesComboBox>
                                </dx:GridViewDataComboBoxColumn>
                            </Columns>
                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                            <Settings ShowFilterRowMenu="True" ShowFilterRow="True" />
                            <SettingsDataSecurity AllowDelete="False" />
                            <SettingsText CommandCancel=" Cancel Changes |" CommandDelete=" Delete |"
                                CommandEdit="Edit" CommandUpdate="| Save Changes |"
                                ConfirmDelete="Delete Employee?" />
                        </dx:ASPxGridView>
                    </td>
                </tr>
                <tr>
                    <td>
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
                                <asp:Parameter Name="usernames" Type="String" />
                                <asp:Parameter Name="EMP_CODE" Type="String" />
                                <asp:Parameter Name="Entry_Year" Type="UInt32" />
                                <asp:Parameter Name="Entry_Satation" Type="String" />
                                <asp:Parameter Name="tin" Type="String" />
                                <asp:Parameter Name="max_education" Type="String" />
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
                                <asp:Parameter Name="usernames" Type="String" />
                                <asp:Parameter Name="EMP_CODE" Type="String" />
                                <asp:Parameter Name="Entry_Year" Type="UInt32" />
                                <asp:Parameter Name="Entry_Satation" Type="String" />
                                <asp:Parameter Name="tin" Type="String" />
                                <asp:Parameter Name="max_education" Type="String" />
                                <asp:Parameter Name="Original_empID" Type="UInt32" />
                            </UpdateParameters>
                        </asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsBanks" runat="server"
                            OldValuesParameterFormatString="original_{0}" SelectMethod="GetData"
                            TypeName="HRMDataTableAdapters.banksTableAdapter"></asp:ObjectDataSource>
                        <asp:ObjectDataSource ID="dsStations" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="HRMDataTableAdapters.hrm_stationsTableAdapter" UpdateMethod="Update">
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
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="Staff Details"
                            PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                </dx:PopupControlContentControl>
                            </ContentCollection>
                        </dx:ASPxPopupControl>
                    </td>
                </tr>
                <tr>
                    <td>
                        <dx:ASPxPopupControl ID="pop_stations" runat="server"
                            HeaderText="Staff Stations" Height="200px" PopupHorizontalAlign="WindowCenter"
                            PopupVerticalAlign="WindowCenter" Width="300px">
                            <ContentCollection>
                                <dx:PopupControlContentControl runat="server">
                                    <table class="style1">
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <dx:ASPxGridView ID="gvStations" runat="server" AutoGenerateColumns="False"
                                                    DataSourceID="dsStations" KeyFieldName="ID" Width="100%">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True"
                                                            ShowInCustomizationForm="True" Visible="False" VisibleIndex="1">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewDataTextColumn Caption="Station" FieldName="station_name"
                                                            ShowInCustomizationForm="True" VisibleIndex="2">
                                                        </dx:GridViewDataTextColumn>
                                                        <dx:GridViewCommandColumn ShowDeleteButton="True" ShowEditButton="True"
                                                            ShowInCustomizationForm="True" VisibleIndex="3" Width="40px">
                                                        </dx:GridViewCommandColumn>
                                                        <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowNewButton="True"
                                                            VisibleIndex="0" Width="20px">
                                                        </dx:GridViewCommandColumn>
                                                    </Columns>
                                                    <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                                </dx:ASPxGridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
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

