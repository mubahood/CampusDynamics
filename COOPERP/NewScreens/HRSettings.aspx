<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="HRSettings.aspx.cs" Inherits="COOPERP_NewScreens_HRSettings" Title="HR Settings - Campus Dynamics" %>

<%@ Register Assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ========== HR SETTINGS STYLES ========== */
.cd-card { background:#fff; border:1px solid #e0e0e0; border-radius:0; margin-bottom:12px; }
.cd-card__header { display:flex; align-items:center; justify-content:space-between; padding:10px 14px; border-bottom:1px solid #e0e0e0; }
.cd-card__title { font-size:14px; font-weight:700; color:#1a1a1a; display:flex; align-items:center; gap:8px; }

/* Tabs override */
.dxpLite_Glass { border:none !important; }
.dxpLite_Glass .dxtc-stripContainer { background:#fff !important; border-bottom:2px solid #e0e0e0 !important; padding:0 10px !important; }
.dxpLite_Glass .dxtc-activeTab { border-bottom:2px solid #174DA4 !important; }
.dxpLite_Glass .dxtc-tab { padding:8px 16px !important; font-size:12px !important; font-weight:600 !important; }
.dxpLite_Glass .dxtc-content { padding:0 !important; }

/* Grid overrides */
.dxgvControl_Glass { border:none !important; }
.dxgvHeader_Glass { font-size:10px !important; text-transform:uppercase !important; letter-spacing:.3px !important; }
.dxgvDataRow_Glass td { font-size:11px !important; padding:5px 10px !important; }

/* Badge */
.hr-badge { display:inline-block; padding:2px 8px; font-size:10px; font-weight:600; border-radius:0; text-transform:uppercase; letter-spacing:.3px; }
.hr-badge--allow { background:#d4edda; color:#155724; }
.hr-badge--deduct { background:#f8d7da; color:#721c24; }
.hr-badge--pct { background:#cce5ff; color:#004085; }
.hr-badge--fixed { background:#e2e3e5; color:#383d41; }

/* Info box */
.hr-info-box { background:#e8f0fe; border-left:3px solid #174DA4; padding:10px 14px; margin:10px; font-size:12px; color:#174DA4; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="cd-card">
    <div class="cd-card__header">
        <div class="cd-card__title">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#174DA4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
            HR Configuration Settings
        </div>
    </div>
    
    <dx:ASPxPageControl ID="tabSettings" runat="server" Theme="Glass" Width="100%" EnableTabScrolling="True">
        <TabPages>
            <dx:TabPage Text="Departments">
                <ContentCollection>
                    <dx:ContentControl>
                        <div class="hr-info-box">Manage organizational departments. The Department Head is referenced by employee ID.</div>
                        <dx:ASPxGridView ID="gvDepartments" runat="server" Width="100%" ClientInstanceName="gvDepartments"
                            KeyFieldName="ID" EnableCallBacks="false" Theme="Glass"
                            OnRowInserting="gvDepartments_RowInserting" OnRowUpdating="gvDepartments_RowUpdating" OnRowDeleting="gvDepartments_RowDeleting">
                            <SettingsPager PageSize="20" />
                            <Settings ShowFilterRow="True" />
                            <SettingsBehavior ConfirmDelete="True" />
                            <SettingsEditing Mode="Inline" />
                            <Columns>
                                <dx:GridViewCommandColumn ShowNewButton="True" ShowEditButton="True" ShowDeleteButton="True" Width="80" />
                                <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" Width="50" EditFormSettings-Visible="False" ReadOnly="true" />
                                <dx:GridViewDataTextColumn FieldName="dept_name" Caption="Department Name" Width="300" />
                                <dx:GridViewDataTextColumn FieldName="dept_headID" Caption="Head (Emp ID)" Width="120" />
                                <dx:GridViewDataTextColumn FieldName="head_name" Caption="Department Head" Width="200" ReadOnly="true" />
                            </Columns>
                        </dx:ASPxGridView>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            
            <dx:TabPage Text="Positions">
                <ContentCollection>
                    <dx:ContentControl>
                        <div class="hr-info-box">Define job positions/titles and their minimum qualification requirements.</div>
                        <dx:ASPxGridView ID="gvJobs" runat="server" Width="100%" ClientInstanceName="gvJobs"
                            KeyFieldName="ID" EnableCallBacks="false" Theme="Glass"
                            OnRowInserting="gvJobs_RowInserting" OnRowUpdating="gvJobs_RowUpdating" OnRowDeleting="gvJobs_RowDeleting">
                            <SettingsPager PageSize="20" />
                            <Settings ShowFilterRow="True" />
                            <SettingsBehavior ConfirmDelete="True" />
                            <SettingsEditing Mode="Inline" />
                            <Columns>
                                <dx:GridViewCommandColumn ShowNewButton="True" ShowEditButton="True" ShowDeleteButton="True" Width="80" />
                                <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" Width="50" ReadOnly="true" />
                                <dx:GridViewDataTextColumn FieldName="jobname" Caption="Position / Job Title" Width="300" />
                                <dx:GridViewDataTextColumn FieldName="min_qualifications" Caption="Minimum Qualifications" Width="300" />
                            </Columns>
                        </dx:ASPxGridView>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            
            <dx:TabPage Text="Stations">
                <ContentCollection>
                    <dx:ContentControl>
                        <div class="hr-info-box">Work stations or campus locations where employees can be assigned.</div>
                        <dx:ASPxGridView ID="gvStations" runat="server" Width="100%" ClientInstanceName="gvStations"
                            KeyFieldName="ID" EnableCallBacks="false" Theme="Glass"
                            OnRowInserting="gvStations_RowInserting" OnRowUpdating="gvStations_RowUpdating" OnRowDeleting="gvStations_RowDeleting">
                            <SettingsPager PageSize="20" />
                            <Settings ShowFilterRow="True" />
                            <SettingsBehavior ConfirmDelete="True" />
                            <SettingsEditing Mode="Inline" />
                            <Columns>
                                <dx:GridViewCommandColumn ShowNewButton="True" ShowEditButton="True" ShowDeleteButton="True" Width="80" />
                                <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" Width="50" ReadOnly="true" />
                                <dx:GridViewDataTextColumn FieldName="station_name" Caption="Station Name" Width="400" />
                            </Columns>
                        </dx:ASPxGridView>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            
            <dx:TabPage Text="Pay Scales">
                <ContentCollection>
                    <dx:ContentControl>
                        <div class="hr-info-box">Salary scales with base pay. Employees on a scale inherit its basic pay in payroll calculations.</div>
                        <dx:ASPxGridView ID="gvPayScales" runat="server" Width="100%" ClientInstanceName="gvPayScales"
                            KeyFieldName="ID" EnableCallBacks="false" Theme="Glass"
                            OnRowInserting="gvPayScales_RowInserting" OnRowUpdating="gvPayScales_RowUpdating" OnRowDeleting="gvPayScales_RowDeleting">
                            <SettingsPager PageSize="20" />
                            <Settings ShowFilterRow="True" />
                            <SettingsBehavior ConfirmDelete="True" />
                            <SettingsEditing Mode="Inline" />
                            <Columns>
                                <dx:GridViewCommandColumn ShowNewButton="True" ShowEditButton="True" ShowDeleteButton="True" Width="80" />
                                <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" Width="50" ReadOnly="true" />
                                <dx:GridViewDataTextColumn FieldName="scale_name" Caption="Scale Name" Width="250" />
                                <dx:GridViewDataSpinEditColumn FieldName="basicpay" Caption="Basic Pay (UGX)" Width="200">
                                    <PropertiesSpinEdit DisplayFormatString="N0" NumberType="Float" />
                                </dx:GridViewDataSpinEditColumn>
                            </Columns>
                        </dx:ASPxGridView>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            
            <dx:TabPage Text="Banks">
                <ContentCollection>
                    <dx:ContentControl>
                        <div class="hr-info-box">Banking institutions for employee salary disbursement.</div>
                        <dx:ASPxGridView ID="gvBanks" runat="server" Width="100%" ClientInstanceName="gvBanks"
                            KeyFieldName="bank_id" EnableCallBacks="false" Theme="Glass"
                            OnRowInserting="gvBanks_RowInserting" OnRowUpdating="gvBanks_RowUpdating" OnRowDeleting="gvBanks_RowDeleting">
                            <SettingsPager PageSize="20" />
                            <Settings ShowFilterRow="True" />
                            <SettingsBehavior ConfirmDelete="True" />
                            <SettingsEditing Mode="Inline" />
                            <Columns>
                                <dx:GridViewCommandColumn ShowNewButton="True" ShowEditButton="True" ShowDeleteButton="True" Width="80" />
                                <dx:GridViewDataTextColumn FieldName="bank_id" Caption="ID" Width="50" ReadOnly="true" />
                                <dx:GridViewDataTextColumn FieldName="bank_name" Caption="Bank Name" Width="400" />
                            </Columns>
                        </dx:ASPxGridView>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
            
            <dx:TabPage Text="Allowances &amp; Deductions">
                <ContentCollection>
                    <dx:ContentControl>
                        <div class="hr-info-box">Configure payroll allowances and deductions. Set computation as FIXED amount or PERCENTAGE of basic pay.</div>
                        <dx:ASPxGridView ID="gvAllowDed" runat="server" Width="100%" ClientInstanceName="gvAllowDed"
                            KeyFieldName="ID" EnableCallBacks="false" Theme="Glass"
                            OnRowInserting="gvAllowDed_RowInserting" OnRowUpdating="gvAllowDed_RowUpdating" OnRowDeleting="gvAllowDed_RowDeleting">
                            <SettingsPager PageSize="20" />
                            <Settings ShowFilterRow="True" />
                            <SettingsBehavior ConfirmDelete="True" />
                            <SettingsEditing Mode="Inline" />
                            <Settings ShowGroupPanel="True" />
                            <Columns>
                                <dx:GridViewCommandColumn ShowNewButton="True" ShowEditButton="True" ShowDeleteButton="True" Width="80" />
                                <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" Width="45" ReadOnly="true" />
                                <dx:GridViewDataTextColumn FieldName="dedall_name" Caption="Name" Width="220" />
                                
                                <dx:GridViewDataComboBoxColumn FieldName="ded_allowance" Caption="Type" Width="120">
                                    <PropertiesComboBox>
                                        <Items>
                                            <dx:ListEditItem Text="ALLOWANCE" Value="ALLOWANCE" />
                                            <dx:ListEditItem Text="DEDUCTION" Value="DEDUCTION" />
                                        </Items>
                                    </PropertiesComboBox>
                                    <DataItemTemplate>
                                        <span class='hr-badge <%# Eval("ded_allowance").ToString().Contains("ALL") ? "hr-badge--allow" : "hr-badge--deduct" %>'><%# Eval("ded_allowance") %></span>
                                    </DataItemTemplate>
                                </dx:GridViewDataComboBoxColumn>
                                
                                <dx:GridViewDataSpinEditColumn FieldName="dedall_amount" Caption="Amount / Rate" Width="130">
                                    <PropertiesSpinEdit DisplayFormatString="N2" NumberType="Float" />
                                </dx:GridViewDataSpinEditColumn>
                                
                                <dx:GridViewDataComboBoxColumn FieldName="computation_by" Caption="Computation" Width="120">
                                    <PropertiesComboBox>
                                        <Items>
                                            <dx:ListEditItem Text="FIXED" Value="FIXED" />
                                            <dx:ListEditItem Text="PERCENTAGE" Value="PERCENTAGE" />
                                        </Items>
                                    </PropertiesComboBox>
                                    <DataItemTemplate>
                                        <span class='hr-badge <%# Eval("computation_by").ToString().Contains("PER") ? "hr-badge--pct" : "hr-badge--fixed" %>'><%# Eval("computation_by") %></span>
                                    </DataItemTemplate>
                                </dx:GridViewDataComboBoxColumn>
                                
                                <dx:GridViewDataTextColumn FieldName="dedall_type" Caption="Sub-Type" Width="120" />
                            </Columns>
                        </dx:ASPxGridView>
                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>
        </TabPages>
    </dx:ASPxPageControl>
</div>
</asp:Content>
