<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewSpecialisations.aspx.cs" Inherits="COOPERP_NewScreens_NewSpecialisations" Title="Specialisations - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .manage-courses-btn { cursor: pointer; color: #422774; font-size: 11px; text-decoration: underline; }
        .manage-courses-btn:hover { color: #5a3a9a; }
        .course-count-badge { display: inline-block; padding: 2px 6px; background: #e8e0f3; color: #422774; border-radius: 3px; font-size: 11px; font-weight: 500; }
        .batch-input { font-family: Consolas, monospace; font-size: 12px; }
        .year-sem-table { width: 100%; border-collapse: collapse; font-size: 11px; }
        .year-sem-table th, .year-sem-table td { border: 1px solid #ddd; padding: 6px 8px; text-align: left; }
        .year-sem-table th { background: #f5f5f5; font-weight: 600; }
        .year-sem-header { background: #422774 !important; color: #fff !important; }
        .course-item { padding: 3px 6px; margin: 2px 0; background: #f8f9fa; border-radius: 2px; display: flex; justify-content: space-between; align-items: center; }
        .course-item:hover { background: #e8e0f3; }
        .remove-course { color: #dc3545; cursor: pointer; font-size: 14px; }
        .tab-content { padding: 15px 0; }
        .form-row { display: flex; gap: 10px; margin-bottom: 10px; align-items: flex-end; }
        .form-group { flex: 1; }
        .form-group label { display: block; font-size: 11px; font-weight: 500; color: #666; margin-bottom: 3px; }
        .validation-msg { font-size: 11px; margin-top: 5px; }
        .validation-success { color: #28a745; }
        .validation-error { color: #dc3545; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="cd-card">
        <div class="cd-card__header">
            <h3 class="cd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"></line><circle cx="18" cy="6" r="3"></circle><circle cx="6" cy="18" r="3"></circle><path d="M18 9a9 9 0 0 1-9 9"></path></svg>
                Programme Specialisations
            </h3>
            <div class="cd-card__actions">
                <asp:LinkButton ID="cmdAddNew" runat="server" CssClass="cd-btn cd-btn--primary cd-btn--sm" OnClick="cmdAddNew_Click">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                    Add New
                </asp:LinkButton>
            </div>
        </div>
        
        <!-- Filter Panel -->
        <div class="cd-card__filter" style="padding: 8px 12px; background: #f8f9fa; border-bottom: 1px solid #dee2e6;">
            <div style="display: flex; align-items: center; gap: 10px;">
                <label style="font-size: 11px; font-weight: 500; color: #666;">Filter by Programme:</label>
                <dx:ASPxComboBox ID="cmbProgramme" runat="server" 
                    DataSourceID="dsProgrammes" 
                    TextField="progname" 
                    ValueField="progcode"
                    Width="350px"
                    IncrementalFilteringMode="Contains"
                    EnableTheming="True" Theme="Glass"
                    AutoPostBack="True"
                    OnSelectedIndexChanged="cmbProgramme_SelectedIndexChanged"
                    NullText="-- All Programmes --">
                    <ClearButton DisplayMode="Always" />
                </dx:ASPxComboBox>
            </div>
        </div>
        
        <div class="cd-card__body cd-p-0">
            <dx:ASPxGridView ID="gvMain" runat="server" AutoGenerateColumns="False" DataSourceID="dsMain" 
                KeyFieldName="spec_id" Width="100%" 
                EnableTheming="True" Theme="Glass"
                ClientInstanceName="gvMain"
                OnRowInserting="gvMain_RowInserting"
                OnRowUpdating="gvMain_RowUpdating"
                OnRowDeleting="gvMain_RowDeleting"
                OnCustomErrorText="gvMain_CustomErrorText"
                EnableCallBacks="true">
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowGroupPanel="False" />
                <SettingsBehavior AllowSort="True" AllowGroup="True" AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsEditing Mode="Inline" />
                <SettingsDataSecurity AllowDelete="True" />
                <SettingsPager PageSize="20" Mode="ShowPager" />
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
                    <dx:GridViewDataTextColumn FieldName="spec_id" VisibleIndex="1" Caption="ID" Width="50px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="prog_id" VisibleIndex="2" Caption="Programme" Width="250px">
                        <PropertiesComboBox DataSourceID="dsProgrammes" 
                            TextField="progname" 
                            ValueField="progcode"
                            IncrementalFilteringMode="Contains">
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Programme is required" />
                            </ValidationSettings>
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataTextColumn FieldName="spec" VisibleIndex="3" Caption="Specialisation Name">
                        <PropertiesTextEdit>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Specialisation Name is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="abbrev" VisibleIndex="4" Caption="Abbrev" Width="80px">
                        <PropertiesTextEdit MaxLength="20">
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Abbreviation is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="course_count" VisibleIndex="5" Caption="Courses" Width="60px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                        <DataItemTemplate>
                            <span class="course-count-badge"><%# Eval("course_count") %></span>
                        </DataItemTemplate>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn VisibleIndex="6" Caption="Actions" Width="100px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                        <DataItemTemplate>
                            <asp:LinkButton ID="btnManageCourses" runat="server" CssClass="manage-courses-btn" 
                                CommandArgument='<%# Eval("spec_id") + "|" + Eval("spec") + "|" + Eval("prog_id") %>'
                                OnClick="btnManageCourses_Click">
                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle;"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                                Manage
                            </asp:LinkButton>
                        </DataItemTemplate>
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
    
    <!-- Summary Panel -->
    <div class="cd-card cd-mt-3">
        <div class="cd-card__body" style="padding: 10px 15px;">
            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: #666;">
                <div>
                    <strong>Total Specialisations:</strong> 
                    <asp:Label ID="lblTotalCount" runat="server" Text="0" CssClass="cd-badge cd-badge--primary"></asp:Label>
                </div>
                <div>
                    <asp:Label ID="lblFilterInfo" runat="server" Text="" ForeColor="#888"></asp:Label>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Manage Courses Popup -->
    <dx:ASPxPopupControl ID="popManageCourses" runat="server" 
        HeaderText="Manage Specialisation Courses" 
        Width="900px" Height="600px"
        Modal="True" 
        CloseAction="CloseButton"
        PopupHorizontalAlign="WindowCenter" 
        PopupVerticalAlign="WindowCenter"
        ClientInstanceName="popManageCourses"
        EnableTheming="True" Theme="Glass">
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <asp:HiddenField ID="hdnSpecId" runat="server" />
                <asp:HiddenField ID="hdnProgCode" runat="server" />
                
                <div style="padding: 5px;">
                    <div style="background: #f8f9fa; padding: 8px 12px; margin-bottom: 10px; border-radius: 3px;">
                        <strong>Specialisation:</strong> <asp:Label ID="lblSpecName" runat="server" ForeColor="#422774"></asp:Label>
                        &nbsp;&nbsp;|&nbsp;&nbsp;
                        <strong>Programme:</strong> <asp:Label ID="lblProgName" runat="server" ForeColor="#422774"></asp:Label>
                    </div>
                    
                    <dx:ASPxPageControl ID="tabCourses" runat="server" ActiveTabIndex="0" Width="100%" EnableTheming="True" Theme="Glass">
                        <TabPages>
                            <dx:TabPage Text="Batch Add Courses">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content">
                                            <div style="margin-bottom: 15px;">
                                                <label style="font-size: 11px; font-weight: 500; color: #666; display: block; margin-bottom: 5px;">
                                                    Enter course codes separated by comma (e.g., BBA101, BBA102, BBA103):
                                                </label>
                                                <dx:ASPxMemo ID="txtBatchCourses" runat="server" Width="100%" Height="80px" 
                                                    NullText="Enter course codes here..." CssClass="batch-input">
                                                </dx:ASPxMemo>
                                            </div>
                                            
                                            <div class="form-row">
                                                <div class="form-group">
                                                    <label>Curriculum</label>
                                                    <dx:ASPxComboBox ID="cmbBatchCurriculum" runat="server" 
                                                        DataSourceID="dsCurriculums" 
                                                        TextField="Tittle" 
                                                        ValueField="ID"
                                                        Width="100%"
                                                        IncrementalFilteringMode="Contains"
                                                        EnableTheming="True" Theme="Glass">
                                                    </dx:ASPxComboBox>
                                                </div>
                                                <div class="form-group" style="max-width: 100px;">
                                                    <label>Year</label>
                                                    <dx:ASPxComboBox ID="cmbBatchYear" runat="server" Width="100%" EnableTheming="True" Theme="Glass">
                                                        <Items>
                                                            <dx:ListEditItem Text="1" Value="1" Selected="True" />
                                                            <dx:ListEditItem Text="2" Value="2" />
                                                            <dx:ListEditItem Text="3" Value="3" />
                                                            <dx:ListEditItem Text="4" Value="4" />
                                                            <dx:ListEditItem Text="5" Value="5" />
                                                        </Items>
                                                    </dx:ASPxComboBox>
                                                </div>
                                                <div class="form-group" style="max-width: 100px;">
                                                    <label>Semester</label>
                                                    <dx:ASPxComboBox ID="cmbBatchSemester" runat="server" Width="100%" EnableTheming="True" Theme="Glass">
                                                        <Items>
                                                            <dx:ListEditItem Text="1" Value="1" Selected="True" />
                                                            <dx:ListEditItem Text="2" Value="2" />
                                                        </Items>
                                                    </dx:ASPxComboBox>
                                                </div>
                                                <div class="form-group" style="max-width: 150px;">
                                                    <label>&nbsp;</label>
                                                    <dx:ASPxButton ID="cmdValidateBatch" runat="server" Text="Validate" 
                                                        OnClick="cmdValidateBatch_Click" Width="100%">
                                                    </dx:ASPxButton>
                                                </div>
                                            </div>
                                            
                                            <asp:Panel ID="pnlValidationResult" runat="server" Visible="false">
                                                <div style="margin: 10px 0; padding: 10px; background: #f8f9fa; border-radius: 3px;">
                                                    <asp:Label ID="lblValidationResult" runat="server"></asp:Label>
                                                </div>
                                            </asp:Panel>
                                            
                                            <div style="margin-top: 15px; text-align: right;">
                                                <dx:ASPxButton ID="cmdAddBatch" runat="server" Text="Add Courses" 
                                                    OnClick="cmdAddBatch_Click" CssClass="cd-btn cd-btn--primary">
                                                </dx:ASPxButton>
                                            </div>
                                            
                                            <asp:Panel ID="pnlBatchResult" runat="server" Visible="false">
                                                <div style="margin-top: 10px; padding: 10px; border-radius: 3px;">
                                                    <asp:Label ID="lblBatchResult" runat="server"></asp:Label>
                                                </div>
                                            </asp:Panel>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="Course Structure">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content">
                                            <div style="margin-bottom: 10px; text-align: right;">
                                                <dx:ASPxButton ID="cmdRefreshStructure" runat="server" Text="Refresh" 
                                                    OnClick="cmdRefreshStructure_Click">
                                                </dx:ASPxButton>
                                                <dx:ASPxButton ID="cmdPrintStructure" runat="server" Text="Print PDF" 
                                                    OnClick="cmdPrintStructure_Click" CssClass="cd-btn cd-btn--primary">
                                                </dx:ASPxButton>
                                            </div>
                                            <asp:Literal ID="litCourseStructure" runat="server"></asp:Literal>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                            <dx:TabPage Text="All Courses">
                                <ContentCollection>
                                    <dx:ContentControl runat="server">
                                        <div class="tab-content">
                                            <dx:ASPxGridView ID="gvSpecCourses" runat="server" AutoGenerateColumns="False" 
                                                KeyFieldName="ID" Width="100%" 
                                                EnableTheming="True" Theme="Glass"
                                                ClientInstanceName="gvSpecCourses"
                                                OnRowUpdating="gvSpecCourses_RowUpdating"
                                                OnRowDeleting="gvSpecCourses_RowDeleting">
                                                <Settings ShowFilterRow="True" />
                                                <SettingsBehavior AllowSort="True" ConfirmDelete="True" />
                                                <SettingsEditing Mode="Inline" />
                                                <SettingsPager PageSize="15" />
                                                <Columns>
                                                    <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="True" VisibleIndex="0" Width="70px">
                                                        <CellStyle HorizontalAlign="Center" />
                                                    </dx:GridViewCommandColumn>
                                                    <dx:GridViewDataTextColumn FieldName="course_code" Caption="Code" Width="100px" ReadOnly="True">
                                                        <EditFormSettings Visible="False" />
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataTextColumn FieldName="courseName" Caption="Course Name" ReadOnly="True">
                                                        <EditFormSettings Visible="False" />
                                                    </dx:GridViewDataTextColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="study_year" Caption="Year" Width="60px">
                                                        <PropertiesComboBox ValueType="System.Int32">
                                                            <Items>
                                                                <dx:ListEditItem Text="1" Value="1" />
                                                                <dx:ListEditItem Text="2" Value="2" />
                                                                <dx:ListEditItem Text="3" Value="3" />
                                                                <dx:ListEditItem Text="4" Value="4" />
                                                                <dx:ListEditItem Text="5" Value="5" />
                                                            </Items>
                                                        </PropertiesComboBox>
                                                        <CellStyle HorizontalAlign="Center" />
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataComboBoxColumn FieldName="semester" Caption="Sem" Width="55px">
                                                        <PropertiesComboBox ValueType="System.Int32">
                                                            <Items>
                                                                <dx:ListEditItem Text="1" Value="1" />
                                                                <dx:ListEditItem Text="2" Value="2" />
                                                            </Items>
                                                        </PropertiesComboBox>
                                                        <CellStyle HorizontalAlign="Center" />
                                                    </dx:GridViewDataComboBoxColumn>
                                                    <dx:GridViewDataTextColumn FieldName="CreditUnit" Caption="Credits" Width="55px" ReadOnly="True">
                                                        <CellStyle HorizontalAlign="Center" />
                                                    </dx:GridViewDataTextColumn>
                                                </Columns>
                                                <Styles>
                                                    <Header Font-Size="11px" />
                                                    <Cell Font-Size="11px" Paddings-Padding="3px" />
                                                </Styles>
                                            </dx:ASPxGridView>
                                        </div>
                                    </dx:ContentControl>
                                </ContentCollection>
                            </dx:TabPage>
                        </TabPages>
                    </dx:ASPxPageControl>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Data Sources -->
    <asp:SqlDataSource ID="dsMain" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT s.spec_id, s.prog_id, s.spec, s.abbrev, p.progname, COALESCE(c.course_count, 0) as course_count FROM acad_specialisation s LEFT JOIN acad_programme p ON s.prog_id = p.progcode LEFT JOIN (SELECT specialisation_id, COUNT(*) as course_count FROM acad_programmecourses GROUP BY specialisation_id) c ON s.spec_id = c.specialisation_id ORDER BY p.progname, s.spec"
        InsertCommand="INSERT INTO acad_specialisation (prog_id, spec, abbrev) VALUES (@prog_id, @spec, @abbrev)"
        UpdateCommand="UPDATE acad_specialisation SET prog_id=@prog_id, spec=@spec, abbrev=@abbrev WHERE spec_id=@spec_id"
        DeleteCommand="DELETE FROM acad_specialisation WHERE spec_id=@spec_id">
        <InsertParameters>
            <asp:Parameter Name="prog_id" Type="String" />
            <asp:Parameter Name="spec" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="prog_id" Type="String" />
            <asp:Parameter Name="spec" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
            <asp:Parameter Name="spec_id" Type="Int32" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="spec_id" Type="Int32" />
        </DeleteParameters>
    </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="dsProgrammes" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT progcode, progname FROM acad_programme ORDER BY progname">
    </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="dsCurriculums" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT ID, Tittle FROM acad_curriculum ORDER BY Tittle">
    </asp:SqlDataSource>
</asp:Content>
