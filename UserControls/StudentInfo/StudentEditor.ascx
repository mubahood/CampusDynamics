<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StudentEditor.ascx.cs" Inherits="COOPERP_StudentInfo_StudentEditor" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
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


    .style2_apps
    {
        width: 80px;
    }
    .style3
    {
        width: 218px;
    }
    .style4
    {
        width:40px;
    }
    .style5
    {
        width: 1052px;
    }
    .auto-style1 {
        width: 167px;
    }
</style>

<dx:ASPxRoundPanel ID="ASPxRoundPanel1" runat="server" 
    HeaderText="System Applications" ShowHeader="False" Width="100%" DefaultButton="txtSearch">
    <PanelCollection>
<dx:PanelContent ID="PanelContent1" runat="server" SupportsDisabledAttribute="True">

                <dx:ASPxCallbackPanel ID="CBP_Students" runat="server" ClientInstanceName="CBP_Students" OnCallback="CBP_Students_Callback" Width="100%">
                    <ClientSideEvents EndCallback="function(s, e) {
	pop_messagebox.Show();
}" />
                    <PanelCollection>
                        <dx:PanelContent runat="server">
                            <table class="style1">
                                <tr>
                                    <td>
                                        <table cellpadding="0" cellspacing="0" class="style1">
                                            <tr>
                                                <td style="text-align: center">
                                                    <dx:ASPxImage ID="ASPxImage1" runat="server" ImageAlign="AbsBottom" ImageUrl="~/COOPERP/images/header_student_info.png">
                                                    </dx:ASPxImage>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <dx:ASPxImage ID="ASPxImage2" runat="server" Height="1px" ImageUrl="~/COOPERP/images/hor_line.png" Width="100%">
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
                                                <td class="auto-style1">
                                                    <%--<dx:ASPxButton ID="cmdAddNew" runat="server" OnClick="cmdAddNew_Click1" Text="Add New" Width="170px" Height="40px">
                                                        <Image Url="~/COOPERP/images/clipboard--plus.png">
                                                        </Image>
                                                    </dx:ASPxButton>--%>
                                                    <dx:ASPxButton ID="cmdBillingUpdate" runat="server" Height="35px" OnClick="cmdBillingUpdate_Click" Text="Change Billing System" ToolTip="Click to change the Billing system of Selected Students" Width="170px">
                                                        <Image IconID="edit_edit_16x16">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td>
                                                    <dx:ASPxButton ID="cmdSpecs" runat="server" Height="35px" OnClick="cmdSpecs_Click" Text="Specialisations" Visible="False" Width="170px">
                                                        <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                    <dx:ASPxButton ID="AddStudentButton1" runat="server" Height="35px" OnClick="AddStudentButton1_Click" Visible="False" Text="Add Student" Width="170px">
                                                        <Image IconID="actions_insert_16x16">
                                                        </Image>
                                                    </dx:ASPxButton>
                                                </td>
                                                <td>
                                                    &nbsp;</td>
                                                <td style="text-align: right" width="170px">
                                                    <dx:ASPxTextBox ID="txtSearch" runat="server" AutoCompleteType="Search" Height="35px" NullText="Enter Search Text" Width="170px">
                                                        <ClientSideEvents TextChanged="function(s, e) {
	gvStudentInfo.Refresh();
}" />
                                                        <Paddings PaddingLeft="5px" />
                                                    </dx:ASPxTextBox>
                                                </td>
                                                <td style="text-align: right" width="20px">
                                                    <dx:ASPxCallbackPanel ID="CPB_Export" runat="server" ClientInstanceName="CPB_Export" OnCallback="CPB_Export_Callback">
                                                        <PanelCollection>
                                                            <dx:PanelContent runat="server">
                                                                <dx:ASPxButton ID="cmdExport" runat="server" OnClick="cmdExport_Click" Height="35px" Text="Export" ToolTip="Click to Export the displayed list of students data" Width="200px">
                                                                    <Image Url="~/COOPERP/images/export_excel.png">
                                                                    </Image>
                                                                </dx:ASPxButton>
                                                            </dx:PanelContent>
                                                        </PanelCollection>
                                                    </dx:ASPxCallbackPanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridView ID="gvStudentInfo" runat="server" AutoGenerateColumns="False" ClientInstanceName="gvStudentInfo" DataSourceID="dsStudentInfo" KeyFieldName="regno" Width="100%" OnHtmlDataCellPrepared="gvStudentInfo_HtmlDataCellPrepared" OnCustomErrorText="gvStudentInfo_CustomErrorText" OnRowUpdated="gvStudentInfo_RowUpdated">
                                           <SettingsCommandButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton><UpdateButton RenderMode="Link"></UpdateButton><CancelButton RenderMode="Link"></CancelButton>
                                                <EditButton>
                                                    <Image Url="~/COOPERP/images/clipboard--pencil.png">
                                                    </Image>
                                                </EditButton>
                                                <DeleteButton>
                                                    <Image Url="~/COOPERP/images/minus-button.png">
                                                    </Image>
                                                </DeleteButton>
                                            </SettingsCommandButton>
                                            <SettingsDataSecurity AllowDelete="False" />
                                            <SettingsPopup>
                                                <EditForm HorizontalAlign="WindowCenter" VerticalAlign="WindowCenter" Height="500px" Width="700px" />
                                                <CustomizationWindow HorizontalAlign="WindowCenter" />
                                            </SettingsPopup>
                                            <EditFormLayoutProperties ColCount="2">
                                                <Items>
                                                    <dx:GridViewLayoutGroup Caption="Students' Details " ColCount="2" ColSpan="2">
                                                        <Items>
                                                            <dx:GridViewColumnLayoutItem ColumnName="entryno">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="regno">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="firstname">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="othername">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="dob">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="gender">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="nationality">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="studPhone">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="email">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="religion">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="home_dist">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="photofile">
                                                            </dx:GridViewColumnLayoutItem>
                                                        </Items>
                                                    </dx:GridViewLayoutGroup>
                                                    <dx:GridViewLayoutGroup Caption="Programme Details" ColCount="2" ColSpan="2" RowSpan="2">
                                                        <Items>
                                                            <dx:GridViewColumnLayoutItem ColumnName="entryyear">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="intake">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="progid">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="studsesion">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="studCampus">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="gradSystemID">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="specialisation" ClientVisible="False">
                                                            </dx:GridViewColumnLayoutItem>
                                                            <dx:GridViewColumnLayoutItem ColumnName="duration" ClientVisible="False">
                                                            </dx:GridViewColumnLayoutItem>
                                                        </Items>
                                                    </dx:GridViewLayoutGroup>
                                                    <dx:EditModeCommandLayoutItem ColSpan="2" HorizontalAlign="Right">
                                                    </dx:EditModeCommandLayoutItem>
                                                </Items>
                                            </EditFormLayoutProperties>
                                            <Columns>
                                                <dx:GridViewDataTextColumn Caption="Registration No" FieldName="entryno" ShowInCustomizationForm="True" VisibleIndex="4" Width="200px">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Entry No" FieldName="regno" ShowInCustomizationForm="True" VisibleIndex="3" ReadOnly="True">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="First Name" FieldName="firstname" ShowInCustomizationForm="True" VisibleIndex="5">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataDateColumn Caption="Birth Date" FieldName="dob" ShowInCustomizationForm="True" Visible="False" VisibleIndex="7">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataDateColumn>
                                                <dx:GridViewDataTextColumn Caption="Nationality" FieldName="nationality" ShowInCustomizationForm="True" VisibleIndex="9">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Religion" FieldName="religion" ShowInCustomizationForm="True" Visible="False" VisibleIndex="15">
                                                <PropertiesComboBox>
                                                    <Items>
                                                        <dx:ListEditItem Text="MUSLIM" Value="MUSLIM" />
                                                        <dx:ListEditItem Text="CHRISTIAN" Value="CHRISTIAN" />
                                                        <dx:ListEditItem Text="ADVENTIST" Value="ADVENTIST" />
                                                        <dx:ListEditItem Text="ANGLICAN" Value="ANGLICAN" />
                                                        <dx:ListEditItem Text="BORN AGAIN" Value="BORN AGAIN" />
                                                        <dx:ListEditItem Text="BAHAI" Value="BAHAI" />
                                                        <dx:ListEditItem Text="CATHOLIC" Value="CATHOLIC" />
                                                        <dx:ListEditItem Text="JEHOVAS WITNESS" Value="JEHOVAS WITNESS" />
                                                        <dx:ListEditItem Text="LUTHERAN" Value="LUTHERAN" />
                                                        <dx:ListEditItem Text="ORTHODOX" Value="ORTHODOX" />
                                                        <dx:ListEditItem Text="PENTACOSTAL" Value="PENTACOSTAL" />
                                                        <dx:ListEditItem Text="PROTESTANT" Value="PROTESTANT" />
                                                        <dx:ListEditItem Text="SDA" Value="SDA" />
                                                        <dx:ListEditItem Text="OTHERS" Value="OTHERS" />
                                                    </Items>
                                                </PropertiesComboBox>
                                                <EditFormSettings Visible="True" />
                                            </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataTextColumn Caption="Entry Method" FieldName="entrymethod" ShowInCustomizationForm="True" Visible="False" VisibleIndex="10">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Student Phone" FieldName="studPhone" ShowInCustomizationForm="True" VisibleIndex="12">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Email" FieldName="email" ShowInCustomizationForm="True" VisibleIndex="13">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Entry Year" FieldName="entryyear" ShowInCustomizationForm="True" VisibleIndex="2" Width="50px">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Home District" FieldName="home_dist" ShowInCustomizationForm="True" Visible="False" VisibleIndex="16">
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Other Name" FieldName="othername" ShowInCustomizationForm="True" VisibleIndex="6">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Duration" FieldName="duration" ShowInCustomizationForm="True" Visible="False" VisibleIndex="19">
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataTextColumn Caption="Photo File" FieldName="photofile" ShowInCustomizationForm="True" Visible="False" VisibleIndex="20" ReadOnly="True">
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewCommandColumn ShowInCustomizationForm="True" ShowSelectCheckbox="True" VisibleIndex="0" Width="25px">
                                                </dx:GridViewCommandColumn>
                                                
                                                <dx:GridViewDataTextColumn Caption="Profile" ShowInCustomizationForm="True" VisibleIndex="21" Width="50px">
                                                    <EditFormSettings Visible="False" />
                                                    <DataItemTemplate>
                                                        <asp:ImageButton ID="cmdDetails" runat="server" ImageUrl="~/COOPERP/images/card-address.png" OnClick="cmdDetails_Click" />
                                                    </DataItemTemplate>
                                                    <CellStyle HorizontalAlign="Center">
                                                    </CellStyle>
                                                </dx:GridViewDataTextColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Programme" FieldName="progid" ShowInCustomizationForm="True" Visible="False" VisibleIndex="11" ReadOnly="True">
                                                    <PropertiesComboBox DataSourceID="dsProgrammeInfo" IncrementalFilteringMode="Contains" TextField="progname" TextFormatString="{1}" ValueField="progcode">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="Code" FieldName="progcode" />
                                                            <dx:ListBoxColumn Caption="Programme" FieldName="progname" Width="350px" />
                                                            <dx:ListBoxColumn Caption="Abbrev" FieldName="abbrev" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Intake" FieldName="intake" ShowInCustomizationForm="True" VisibleIndex="17">
                                                    <PropertiesComboBox>
                                                        <Items>
                                                            <dx:ListEditItem Text="JANUARY" Value="JANUARY" />
                                                            <dx:ListEditItem Text="FEBRUARY" Value="FEBRUARY" />
                                                            <dx:ListEditItem Text="MARCH" Value="MARCH" />
                                                            <dx:ListEditItem Text="APRIL" Value="APRIL" />
                                                            <dx:ListEditItem Text="MAY" Value="MAY" />
                                                            <dx:ListEditItem Text="JUNE" Value="JUNE" />
                                                            <dx:ListEditItem Text="JULY" Value="JULY" />
                                                            <dx:ListEditItem Text="AUGUST" Value="AUGUST" />
                                                            <dx:ListEditItem Text="SEPTEMBER" Value="SEPTEMBER" />
<dx:ListEditItem Text="OCTOBER" Value="OCTOBER"></dx:ListEditItem>
                                                            <dx:ListEditItem Text="NOVEMBER" Value="NOVEMBER" />
                                                            <dx:ListEditItem Text="DECEMBER" Value="DECEMBER" />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Session" FieldName="studsesion" ShowInCustomizationForm="True" VisibleIndex="14" Width="80px">
                                                    <PropertiesComboBox DataSourceID="dsstudysessions" TextField="Session" TextFormatString="{0}" ValueField="Session">
                                                        <Columns>
                                                            <dx:ListBoxColumn FieldName="Session" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Gender" FieldName="gender" ShowInCustomizationForm="True" VisibleIndex="8">
                                                    <PropertiesComboBox IncrementalFilteringMode="StartsWith">
                                                        <Items>
                                                            <dx:ListEditItem Text="MALE" Value="MALE" />
                                                            <dx:ListEditItem Text="FEMALE" Value="FEMALE" />
                                                        </Items>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Grading System" FieldName="gradSystemID" ShowInCustomizationForm="True" Visible="False" VisibleIndex="18">
                                                    <PropertiesComboBox DataSourceID="dsGradingSys" IncrementalFilteringMode="Contains" TextField="gs_name" TextFormatString="{1}" ValueField="ID">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="SNo" FieldName="ID" Width="50px" />
                                                            <dx:ListBoxColumn Caption="Grading System" FieldName="gs_name" Width="250px" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Specialisation" FieldName="specialisation" ShowInCustomizationForm="True" Visible="False" VisibleIndex="23">
                                                    <PropertiesComboBox DataSourceID="dsSpecialisations" IncrementalFilteringMode="Contains" TextField="spec" TextFormatString="{1}" ValueField="spec_id" DropDownWidth="600px" ValueType="System.Int32">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="SNo" FieldName="spec_id" Width="50px" />
                                                            <dx:ListBoxColumn Caption="Specialisation" FieldName="spec" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewCommandColumn ButtonRenderMode="Image" ButtonType="Image" ShowDeleteButton="True" ShowEditButton="True" ShowInCustomizationForm="True" VisibleIndex="27" Width="40px" Name="Edit">
                                                </dx:GridViewCommandColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Campus" FieldName="studCampus" ShowInCustomizationForm="True" Visible="False" VisibleIndex="25">
                                                    <PropertiesComboBox DataSourceID="dsCampus" TextField="campus_name" TextFormatString="{1}" ValueField="campus_code">
                                                        <Columns>
                                                            <dx:ListBoxColumn Caption="Code" FieldName="campus_code" Width="50px" />
                                                            <dx:ListBoxColumn Caption="Name" FieldName="campus_name" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                    <EditFormSettings Visible="True" />
                                                </dx:GridViewDataComboBoxColumn>
                                                <dx:GridViewDataImageColumn Caption="Photo" FieldName="photofile" ShowInCustomizationForm="True" VisibleIndex="1" Width="70px">
                                                    <PropertiesImage ImageAlign="AbsMiddle" ImageHeight="50px" ImageUrlFormatString="~/COOPERP/StudentInfo/photos/{0}" ImageWidth="40px" NullDisplayText="No Image">
                                                    </PropertiesImage>
                                                    <EditFormSettings Visible="False" />
                                                </dx:GridViewDataImageColumn>
                                                <dx:GridViewDataComboBoxColumn Caption="Hall" FieldName="StudentHall" ShowInCustomizationForm="True" Visible="False" VisibleIndex="26">
                                                    <PropertiesComboBox DataSourceID="ds_Halls" TextField="hall_name" TextFormatString="{1}" ValueField="hall_name">
                                                        <Columns>
                                                            <dx:ListBoxColumn FieldName="ID" />
                                                            <dx:ListBoxColumn Caption="Hall Name" FieldName="hall_name" />
                                                        </Columns>
                                                    </PropertiesComboBox>
                                                </dx:GridViewDataComboBoxColumn>
                                            </Columns>
                                            <SettingsPager AlwaysShowPager="True" Position="TopAndBottom">
                                            </SettingsPager>
                                            <SettingsEditing Mode="PopupEditForm">
                                            </SettingsEditing>
                                            <Settings ShowFilterRow="True" ShowFilterRowMenu="True" />
                                            <SettingsBehavior AllowFocusedRow="True" ConfirmDelete="True" />
                                        </dx:ASPxGridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <dx:ASPxGridViewExporter ID="GVE_Students" runat="server" GridViewID="gvStudentInfo">
                                        </dx:ASPxGridViewExporter>
                                        <asp:ObjectDataSource ID="dsSpecialisations" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.acad_specialisationTableAdapter" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_spec_id" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="prog_id" Type="String" />
                                                <asp:Parameter Name="spec" Type="String" />
                                                <asp:Parameter Name="abbrev" Type="String" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="prog_id" Type="String" />
                                                <asp:Parameter Name="spec" Type="String" />
                                                <asp:Parameter Name="abbrev" Type="String" />
                                                <asp:Parameter Name="Original_spec_id" Type="UInt32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:ObjectDataSource ID="dsStudentInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetStudentSearch" TypeName="StudentDataTableAdapters.acad_studentTableAdapter" UpdateMethod="Update">
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
                                            <SelectParameters>
                                                <asp:ControlParameter ControlID="txtSearch" DefaultValue="" Name="txt" PropertyName="Text" Type="String" />
                                            </SelectParameters>
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
                                                <asp:Parameter Name="studCampus" Type="String" />
                                                <asp:Parameter Name="StudentHall" Type="String" />
                                                <asp:Parameter Name="Original_regno" Type="String" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="dsstudysessions" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="admission_dataTableAdapters.acad_studysessionsTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_Session" Type="String" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="Session" Type="String" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="Original_Session" Type="String" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="dsGradingSys" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllGradingSystems" TypeName="ResultsDataTableAdapters.acad_gradingsystemTableAdapter"></asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="dsCampus" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataBy_Campus" TypeName="CampusDataTableAdapters.acad_campusesTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="campus_name" Type="String" />
                                                <asp:Parameter Name="campus_phone" Type="String" />
                                                <asp:Parameter Name="campus_email" Type="String" />
                                                <asp:Parameter Name="campus_short_name" Type="String" />
                                                <asp:Parameter Name="campus_head" Type="String" />
                                                <asp:Parameter Name="campus_code" Type="String" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="campus_name" Type="String" />
                                                <asp:Parameter Name="campus_phone" Type="String" />
                                                <asp:Parameter Name="campus_email" Type="String" />
                                                <asp:Parameter Name="campus_short_name" Type="String" />
                                                <asp:Parameter Name="campus_head" Type="String" />
                                                <asp:Parameter Name="campus_code" Type="String" />
                                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="ds_Halls" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentDataTableAdapters.acad_hall_assignerTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="hall_gender" Type="String" />
                                                <asp:Parameter Name="hall_name" Type="String" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="hall_gender" Type="String" />
                                                <asp:Parameter Name="hall_name" Type="String" />
                                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="dsBillingSystem" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="StudentAccountingDataTableAdapters.fin_billing_systemsTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="bs_name" Type="String" />
                                                <asp:Parameter Name="bs_description" Type="String" />
                                                <asp:Parameter Name="bs_currency" Type="String" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="bs_name" Type="String" />
                                                <asp:Parameter Name="bs_description" Type="String" />
                                                <asp:Parameter Name="bs_currency" Type="String" />
                                                <asp:Parameter Name="Original_ID" Type="UInt32" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <asp:ObjectDataSource ID="dsProgrammeInfo" runat="server" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetAllProgrammes" TypeName="FacultyDataTableAdapters.acad_programmeTableAdapter" UpdateMethod="Update">
                                            <DeleteParameters>
                                                <asp:Parameter Name="Original_progcode" Type="String" />
                                            </DeleteParameters>
                                            <InsertParameters>
                                                <asp:Parameter Name="progcode" Type="String" />
                                                <asp:Parameter Name="progname" Type="String" />
                                                <asp:Parameter Name="mincredit" Type="Double" />
                                                <asp:Parameter Name="abbrev" Type="String" />
                                                <asp:Parameter Name="couselength" Type="Double" />
                                                <asp:Parameter Name="maxduration" Type="Double" />
                                                <asp:Parameter Name="faculty_code" Type="String" />
                                                <asp:Parameter Name="levelCode" Type="UInt32" />
                                            </InsertParameters>
                                            <UpdateParameters>
                                                <asp:Parameter Name="progname" Type="String" />
                                                <asp:Parameter Name="mincredit" Type="Double" />
                                                <asp:Parameter Name="abbrev" Type="String" />
                                                <asp:Parameter Name="couselength" Type="Double" />
                                                <asp:Parameter Name="maxduration" Type="Double" />
                                                <asp:Parameter Name="faculty_code" Type="String" />
                                                <asp:Parameter Name="levelCode" Type="UInt32" />
                                                <asp:Parameter Name="Original_progcode" Type="String" />
                                            </UpdateParameters>
                                        </asp:ObjectDataSource>
                                        <dx:ASPxPopupControl ID="pop_billing" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Billing System Editor" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="400px">
                                            <HeaderStyle HorizontalAlign="Center">
                                            <Paddings Padding="10px" />
                                            </HeaderStyle>
                                            <ContentCollection>
                                                <dx:PopupControlContentControl runat="server">
                                                    <table align="center" class="style1">
                                                        <tr>
                                                            <td align="center">
                                                                <br />
                                                                <table class="style1">
                                                                    <tr>
                                                                        <td>&nbsp;</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>New Billing System</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            <dx:ASPxComboBox ID="txtBillingSystem" runat="server" DataSourceID="dsBillingSystem" Height="35px" SelectedIndex="0" TextField="bs_name" TextFormatString="{1}" ValueField="ID" Width="100%">
                                                                                <Columns>
                                                                                    <dx:ListBoxColumn Caption="Code" FieldName="ID" Width="30px" />
                                                                                    <dx:ListBoxColumn Caption="Billing System" FieldName="bs_name" Width="250px" />
                                                                                </Columns>
                                                                            </dx:ASPxComboBox>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            <dx:ASPxButton ID="cmdApplyBilling" runat="server" Height="35px" OnClick="cmdApplyBilling_Click" Text="Apply New System" Width="100%">
                                                                                <Image IconID="edit_edit_16x16">
                                                                                </Image>
                                                                            </dx:ASPxButton>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                                <br />
                                                                <dx:ASPxLabel ID="lbl_bill_comment" runat="server" ForeColor="Red" style="font-weight: 700">
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
                                <tr>
                                    <td>
                                        <dx:ASPxPopupControl ID="pop_messagebox" runat="server" ClientInstanceName="pop_messagebox" DisappearAfter="10" HeaderText="Campus Dynamics Version 1.0" Height="100px" Modal="True" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter" Width="300px">
                                            <HeaderStyle HorizontalAlign="Center" />
                                            <ContentCollection>
                                                <dx:PopupControlContentControl runat="server">
                                                    <table align="center" class="style1">
                                                        <tr>
                                                            <td align="center">
                                                                <br />
                                                                <br />
                                                                <dx:ASPxLabel ID="lbl_comment" runat="server" ForeColor="Red" style="font-weight: 700">
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
                                <tr>
                                    <td>
                                        <dx:ASPxPopupControl ID="pop_details" runat="server" HeaderText="" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter">
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
                </dx:ASPxCallbackPanel>
            </dx:PanelContent>
</PanelCollection>
</dx:ASPxRoundPanel>