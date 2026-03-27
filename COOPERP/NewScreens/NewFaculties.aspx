<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="NewFaculties.aspx.cs" Inherits="COOPERP_NewScreens_NewFaculties" Title="Faculties - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
<style type="text/css">
.cd-page-header { background:#05275C; padding:14px 0 12px; margin-bottom:16px; border-bottom:3px solid #041d45; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; }
.cd-page-header__left { display:flex; align-items:center; gap:12px; }
.cd-page-header__icon { width:38px; height:38px; background:rgba(255,255,255,.12); display:flex; align-items:center; justify-content:center; border-radius:4px; flex-shrink:0; }
.cd-page-header__title { font-size:16px; font-weight:700; color:#fff; line-height:1.2; margin:0; }
.cd-page-header__sub { font-size:12px; color:rgba(255,255,255,.75); margin-top:2px; }
</style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<!-- ======= PAGE HEADER =========================================== -->
<div class="cd-page-header">
    <div class="cd-page-header__left">
        <div class="cd-page-header__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
        </div>
        <div>
            <div class="cd-page-header__title">Faculties</div>
            <div class="cd-page-header__sub">Manage university faculties and academic departments</div>
        </div>
    </div>
</div>
    <div class="cd-card">
        <div class="cd-card__header">
            <h3 class="cd-card__title">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                Faculties
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
                KeyFieldName="faculty_code" Width="100%" 
                EnableTheming="True" Theme="Glass"
                OnRowCommand="gvMain_RowCommand"
                EnableCallBacks="true">
                <Settings ShowFilterRow="True" ShowFilterRowMenu="True" ShowGroupPanel="False" />
                <SettingsBehavior AllowSort="True" AllowGroup="True" AllowFocusedRow="True" ConfirmDelete="True" />
                <SettingsEditing Mode="PopupEditForm" />
                <SettingsPager PageSize="20" Mode="ShowPager" />
                <SettingsPopup>
                    <EditForm Width="450px" Height="300px" Modal="True" HorizontalAlign="Center" VerticalAlign="Middle" />
                </SettingsPopup>
                <Columns>
                    <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="False" VisibleIndex="0" Width="60px">
                        <HeaderStyle HorizontalAlign="Center" />
                        <CellStyle HorizontalAlign="Center" />
                    </dx:GridViewCommandColumn>
                    <dx:GridViewDataTextColumn FieldName="faculty_code" VisibleIndex="1" Caption="Code" Width="80px">
                        <PropertiesTextEdit>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Faculty Code is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="faculty_name" VisibleIndex="2" Caption="Faculty Name">
                        <PropertiesTextEdit>
                            <ValidationSettings>
                                <RequiredField IsRequired="True" ErrorText="Faculty Name is required" />
                            </ValidationSettings>
                        </PropertiesTextEdit>
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="abbrev" VisibleIndex="3" Caption="Abbreviation" Width="100px">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="faculty_dean" VisibleIndex="4" Caption="Dean">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="faculty_contacts" VisibleIndex="5" Caption="Contacts">
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
    
    <asp:SqlDataSource ID="dsMain" runat="server" 
        ConnectionString="<%$ ConnectionStrings:vacConnectionString %>" 
        ProviderName="MySql.Data.MySqlClient"
        SelectCommand="SELECT faculty_code, faculty_name, abbrev, faculty_dean, faculty_contacts FROM acad_faculty ORDER BY faculty_name"
        InsertCommand="INSERT INTO acad_faculty (faculty_code, faculty_name, abbrev, faculty_dean, faculty_contacts) VALUES (@faculty_code, @faculty_name, @abbrev, @faculty_dean, @faculty_contacts)"
        UpdateCommand="UPDATE acad_faculty SET faculty_name=@faculty_name, abbrev=@abbrev, faculty_dean=@faculty_dean, faculty_contacts=@faculty_contacts WHERE faculty_code=@Original_faculty_code"
        DeleteCommand="DELETE FROM acad_faculty WHERE faculty_code=@Original_faculty_code">
        <InsertParameters>
            <asp:Parameter Name="faculty_code" Type="String" />
            <asp:Parameter Name="faculty_name" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
            <asp:Parameter Name="faculty_dean" Type="String" />
            <asp:Parameter Name="faculty_contacts" Type="String" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="faculty_name" Type="String" />
            <asp:Parameter Name="abbrev" Type="String" />
            <asp:Parameter Name="faculty_dean" Type="String" />
            <asp:Parameter Name="faculty_contacts" Type="String" />
            <asp:Parameter Name="Original_faculty_code" Type="String" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="Original_faculty_code" Type="String" />
        </DeleteParameters>
    </asp:SqlDataSource>
</asp:Content>
