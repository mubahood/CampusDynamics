<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewFacultyProgrammes.aspx.cs" Inherits="COOPERP_NewScreens_NewFacultyProgrammes" Title="Programmes - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="cd-card">
        <div class="cd-card__header">
            <h3 class="cd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                Academic Programmes
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
                KeyFieldName="progcode" Width="100%" 
                EnableTheming="True" Theme="Glass"
                ClientInstanceName="gvMain"
                OnRowCommand="gvMain_RowCommand"
                OnCellEditorInitialize="gvMain_CellEditorInitialize"
                OnRowUpdating="gvMain_RowUpdating"
                EnableCallBacks="true">
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowGroupPanel="False" />
                <SettingsBehavior AllowSort="True" AllowGroup="True" AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsEditing Mode="Inline" />
                <SettingsDataSecurity AllowDelete="False" />
                <SettingsPager PageSize="20" Mode="ShowPager" />
                <SettingsPopup>
                    <EditForm Width="550px" Height="450px" Modal="True" HorizontalAlign="Center" VerticalAlign="Middle" />
                </SettingsPopup>
                <SettingsCommandButton>
                    <UpdateButton Text="Save Changes" />
                    <CancelButton Text="Cancel" />
                    <EditButton Text="Edit" />
                </SettingsCommandButton>
                <Columns>
                    <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="False" VisibleIndex="0" Width="50px">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="progcode" VisibleIndex="1" Caption="Code" Width="80px">
                        <PropertiesTextEdit>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Programme Code is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="progname" VisibleIndex="2" Caption="Programme Name">
                        <PropertiesTextEdit>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Programme Name is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="couselength" VisibleIndex="3" Caption="Duration" Width="80px">
                        <PropertiesComboBox ValueType="System.Int32">
                            <Items>
                                <dx:ListEditItem Text="1 Year" Value="1" />
                                <dx:ListEditItem Text="2 Years" Value="2" />
                                <dx:ListEditItem Text="3 Years" Value="3" />
                                <dx:ListEditItem Text="4 Years" Value="4" />
                                <dx:ListEditItem Text="5 Years" Value="5" />
                            </Items>
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="faculty_code" VisibleIndex="4" Caption="Faculty">
                        <PropertiesComboBox DataSourceID="dsFaculties" IncrementalFilteringMode="Contains" 
                            TextField="faculty_name" ValueField="faculty_code">
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="levelCode" VisibleIndex="5" Caption="Level" Width="120px">
                        <PropertiesComboBox IncrementalFilteringMode="Contains">
                            <Items>
                                <dx:ListEditItem Text="Elementary" Value="0" />
                                <dx:ListEditItem Text="Certificate" Value="1" />
                                <dx:ListEditItem Text="Diploma" Value="2" />
                                <dx:ListEditItem Text="Bachelors Degree" Value="3" />
                                <dx:ListEditItem Text="Post Grad. Diploma" Value="4" />
                                <dx:ListEditItem Text="Masters Degree" Value="5" />
                                <dx:ListEditItem Text="Doctorate" Value="6" />
                            </Items>
                        </PropertiesComboBox>
                    </dx:GridViewDataComboBoxColumn>
                    <dx:GridViewDataTextColumn VisibleIndex="6" Caption="Structure" Width="70px" UnboundType="String">
                        <EditFormSettings Visible="False" />
                        <DataItemTemplate>
                            <asp:LinkButton ID="cmdStructure" runat="server" CssClass="cd-btn cd-btn--outline cd-btn--xs" 
                                OnClick="cmdStructure_Click" ToolTip="View Programme Structure & Specialisations">
                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
                            </asp:LinkButton>
                        </DataItemTemplate>
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="spec_count" VisibleIndex="7" Caption="Specs" Width="50px" ReadOnly="True">
                        <EditFormSettings Visible="False" />
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataComboBoxColumn FieldName="is_fully_set" VisibleIndex="8" Caption="Fully Set" Width="70px">
                        <PropertiesComboBox ValueType="System.String">
                            <Items>
                                <dx:ListEditItem Text="Yes" Value="Yes" />
                                <dx:ListEditItem Text="No" Value="No" />
                            </Items>
                        </PropertiesComboBox>
                        <CellStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" />
                    </dx:GridViewDataComboBoxColumn>
                </Columns>
                <Styles>
                    <Header Font-Size="11px" />
                    <Cell Font-Size="12px" Paddings-Padding="4px" />
                    <FilterRow Font-Size="11px" />
                </Styles>
            </dx:ASPxGridView>
        </div>
    </div>
    
    <!-- Programme Structure Popup -->
    <dx:ASPxPopupControl ID="popStructure" runat="server" 
        HeaderText="Programme Structure" 
        PopupHorizontalAlign="WindowCenter" 
        PopupVerticalAlign="WindowCenter"
        Width="900px" Height="550px"
        Modal="True" 
        CloseAction="CloseButton"
        EnableTheming="True" Theme="Glass"
        ClientInstanceName="popStructure">
        <HeaderStyle Font-Bold="True" />
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
    
    <!-- Data Sources -->
    <asp:SqlDataSource ID="dsMain" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT p.progcode, p.progname, p.abbrev, p.mincredit, p.couselength, p.maxduration, p.faculty_code, p.levelCode, p.study_system, IFNULL(p.is_fully_set, 'No') AS is_fully_set, IFNULL(s.spec_count, 0) AS spec_count FROM acad_programme p LEFT JOIN (SELECT prog_id, COUNT(*) AS spec_count FROM acad_specialisation GROUP BY prog_id) s ON p.progcode = s.prog_id ORDER BY p.progname"
        InsertCommand="INSERT INTO acad_programme (progcode, progname, abbrev, mincredit, couselength, maxduration, faculty_code, levelCode, study_system) VALUES (@progcode, @progname, @abbrev, @mincredit, @couselength, @maxduration, @faculty_code, @levelCode, @study_system)"
        UpdateCommand="UPDATE acad_programme SET progname=@progname, abbrev=@abbrev, mincredit=@mincredit, couselength=@couselength, maxduration=@maxduration, faculty_code=@faculty_code, levelCode=@levelCode, study_system=@study_system, is_fully_set=@is_fully_set WHERE progcode=@Original_progcode">
        <InsertParameters>
            <asp:Parameter Name="progcode" Type="String" />
            <asp:Parameter Name="progname" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
            <asp:Parameter Name="mincredit" Type="Double" />
            <asp:Parameter Name="couselength" Type="Int32" />
            <asp:Parameter Name="maxduration" Type="Int32" />
            <asp:Parameter Name="faculty_code" Type="String" />
            <asp:Parameter Name="levelCode" Type="Int32" />
            <asp:Parameter Name="study_system" Type="String" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="progname" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
            <asp:Parameter Name="mincredit" Type="Double" />
            <asp:Parameter Name="couselength" Type="Int32" />
            <asp:Parameter Name="maxduration" Type="Int32" />
            <asp:Parameter Name="faculty_code" Type="String" />
            <asp:Parameter Name="levelCode" Type="Int32" />
            <asp:Parameter Name="study_system" Type="String" />
            <asp:Parameter Name="is_fully_set" Type="String" />
            <asp:Parameter Name="Original_progcode" Type="String" />
        </UpdateParameters>
    </asp:SqlDataSource>
    
    <asp:SqlDataSource ID="dsFaculties" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name">
    </asp:SqlDataSource>
</asp:Content>
