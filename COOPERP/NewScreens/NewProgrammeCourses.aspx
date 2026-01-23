<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewProgrammeCourses.aspx.cs" Inherits="COOPERP_NewScreens_NewProgrammeCourses" Title="Programme Courses - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="cd-card">
        <div class="cd-card__header">
            <h3 class="cd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                Programme Courses
            </h3>
            <div class="cd-card__actions">
                <asp:LinkButton ID="cmdAddNew" runat="server" CssClass="cd-btn cd-btn--primary cd-btn--sm" OnClick="cmdAddNew_Click">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    Add New
                </asp:LinkButton>
            </div>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvMain" runat="server" AutoGenerateColumns="False" DataSourceID="dsMain"
                KeyFieldName="ID" Width="100%" 
                EnableTheming="True" Theme="Glass"
                ClientInstanceName="gvMain"
                OnRowInserting="gvMain_RowInserting"
                OnRowUpdating="gvMain_RowUpdating"
                OnRowDeleting="gvMain_RowDeleting"
                OnInitNewRow="gvMain_InitNewRow"
                OnCustomErrorText="gvMain_CustomErrorText"
                EnableCallBacks="true">
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowGroupPanel="False" />
                <SettingsBehavior AllowSort="True" AllowGroup="True" AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsEditing Mode="Inline" />
                <SettingsDataSecurity AllowDelete="True" />
                <SettingsPager PageSize="25" Mode="ShowPager" />
                <SettingsCommandButton>
                    <UpdateButton Text="Save" />
                    <CancelButton Text="Cancel" />
                    <EditButton Text="Edit" />
                    <DeleteButton Text="Delete" />
                    <NewButton Text="New" />
                </SettingsCommandButton>
                <Columns>
                    <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="True" ShowNewButtonInHeader="False" VisibleIndex="0" Width="80px">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="ID" VisibleIndex="1" Caption="ID" Width="50px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="progcode" VisibleIndex="2" Caption="Programme" Width="200px">
                        <PropertiesComboBox DataSourceID="dsProgrammes" 
                            TextField="progname" 
                            ValueField="progcode"
                            IncrementalFilteringMode="Contains">
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Programme is required" />
                            </ValidationSettings>
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="specialisation_id" VisibleIndex="3" Caption="Specialisation" Width="160px">
                        <PropertiesComboBox DataSourceID="dsSpecialisations" 
                            TextField="spec" 
                            ValueField="spec_id"
                            IncrementalFilteringMode="Contains">
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Specialisation is required" />
                            </ValidationSettings>
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="course_code" VisibleIndex="4" Caption="Course" Width="250px">
                        <PropertiesComboBox DataSourceID="dsCourses" 
                            TextField="display_name" 
                            ValueField="courseID"
                            IncrementalFilteringMode="Contains">
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Course is required" />
                            </ValidationSettings>
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="study_year" VisibleIndex="5" Caption="Year" Width="55px">
                        <PropertiesComboBox ValueType="System.Int32">
                            <Items>
                                <dx:ListEditItem Text="1" Value="1" />
                                <dx:ListEditItem Text="2" Value="2" />
                                <dx:ListEditItem Text="3" Value="3" />
                                <dx:ListEditItem Text="4" Value="4" />
                                <dx:ListEditItem Text="5" Value="5" />
                            </Items>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Year is required" />
                            </ValidationSettings>
                        </PropertiesComboBox>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="semester" VisibleIndex="6" Caption="Sem" Width="50px">
                        <PropertiesComboBox ValueType="System.Int32">
                            <Items>
                                <dx:ListEditItem Text="1" Value="1" />
                                <dx:ListEditItem Text="2" Value="2" />
                            </Items>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Semester is required" />
                            </ValidationSettings>
                        </PropertiesComboBox>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="course_type" VisibleIndex="7" Caption="Type" Width="80px">
                        <PropertiesComboBox>
                            <Items>
                                <dx:ListEditItem Text="Core" Value="CORE" />
                                <dx:ListEditItem Text="Elective" Value="ELECTIVE" />
                            </Items>
                        </PropertiesComboBox>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataTextColumn FieldName="CreditUnit" VisibleIndex="8" Caption="CU" Width="45px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                </Columns>
                <Styles>
                    <Header Font-Size="11px" />
                    <Cell Font-Size="12px" Paddings-Padding="4px" />
                    <FilterRow Font-Size="11px" />
                </Styles>
            </dx:ASPxGridView>
        </div>
    </div>
    
    <!-- Data Sources -->
    <asp:SqlDataSource ID="dsMain" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT pc.ID, pc.progcode, pc.course_code, pc.study_year, pc.semester, pc.specialisation_id, pc.course_type, c.courseName, c.CreditUnit FROM acad_programmecourses pc LEFT JOIN acad_course c ON pc.course_code = c.courseID ORDER BY pc.progcode, pc.study_year, pc.semester"
        InsertCommand="INSERT INTO acad_programmecourses (progcode, course_code, study_year, semester, CurriculumID, specialisation_id, course_type) VALUES (@progcode, @course_code, @study_year, @semester, 0, @specialisation_id, @course_type)"
        UpdateCommand="UPDATE acad_programmecourses SET progcode=@progcode, course_code=@course_code, study_year=@study_year, semester=@semester, specialisation_id=@specialisation_id, course_type=@course_type WHERE ID=@ID"
        DeleteCommand="DELETE FROM acad_programmecourses WHERE ID=@ID">
        <InsertParameters>
            <asp:Parameter Name="progcode" Type="String" />
            <asp:Parameter Name="course_code" Type="String" />
            <asp:Parameter Name="study_year" Type="Int32" />
            <asp:Parameter Name="semester" Type="Int32" />
            <asp:Parameter Name="specialisation_id" Type="Int32" />
            <asp:Parameter Name="course_type" Type="String" DefaultValue="CORE" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="progcode" Type="String" />
            <asp:Parameter Name="course_code" Type="String" />
            <asp:Parameter Name="study_year" Type="Int32" />
            <asp:Parameter Name="semester" Type="Int32" />
            <asp:Parameter Name="specialisation_id" Type="Int32" />
            <asp:Parameter Name="course_type" Type="String" />
            <asp:Parameter Name="ID" Type="Int32" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="ID" Type="Int32" />
        </DeleteParameters>
    </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="dsProgrammes" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT progcode, progname FROM acad_programme ORDER BY progname">
    </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="dsCourses" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT courseID, CONCAT(courseID, ' - ', courseName) as display_name FROM acad_course ORDER BY courseID">
    </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="dsSpecialisations" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT spec_id, spec FROM acad_specialisation ORDER BY spec">
    </asp:SqlDataSource>
</asp:Content>
