<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FinanceAuditTrail.aspx.cs" Inherits="COOPERP_NewScreens_FinanceAuditTrail" Title="Finance Audit Trail - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .at-filter-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .at-filter-group { display: flex; flex-direction: column; gap: 4px; }
        .at-filter-group label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .at-filter-group input, .at-filter-group select {
            padding: 5px 8px; border: 1px solid #ccc; font-size: 12px;
        }
        .at-btn {
            padding: 6px 16px; background: #1976d2; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .at-btn:hover { background: #1565c0; }

        .at-tabs {
            display: flex; gap: 0; margin-bottom: 0;
        }
        .at-tab {
            padding: 8px 20px; background: #f5f5f5; border: 1px solid #e0e0e0;
            border-bottom: none; cursor: pointer; font-size: 13px; font-weight: 600; color: #666;
        }
        .at-tab:hover { background: #e3f2fd; }
        .at-tab.at-tab-active { background: #fff; color: #1976d2; border-bottom: 2px solid #1976d2; }

        .at-tab-panel { border: 1px solid #e0e0e0; border-top: none; padding: 0; }

        .at-summary {
            background: #e3f2fd; border: 1px solid #90caf9; padding: 8px 16px; margin-top: 12px;
            font-size: 12px; color: #333;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <!-- Filter Bar -->
    <div class="at-filter-bar">
        <div class="at-filter-group">
            <label>Start Date</label>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" />
        </div>
        <div class="at-filter-group">
            <label>End Date</label>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" />
        </div>
        <div class="at-filter-group">
            <label>Log Type</label>
            <asp:DropDownList ID="ddlLogType" runat="server">
                <asp:ListItem Value="activity">Activity Log</asp:ListItem>
                <asp:ListItem Value="repair">Repair Log</asp:ListItem>
                <asp:ListItem Value="both">Both</asp:ListItem>
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnFilter" runat="server" Text="Search" CssClass="at-btn" OnClick="btnFilter_Click" />
    </div>

    <!-- Activity Log Grid -->
    <asp:Panel ID="pnlActivity" runat="server">
        <h4 style="margin:0 0 4px 0; font-size:13px; color:#1976d2;">Activity Log</h4>
        <dx:ASPxGridView ID="gridActivity" runat="server" Width="100%" KeyFieldName="id"
            ClientInstanceName="gridActivity"
            Settings-ShowGroupPanel="false" Settings-ShowFilterRow="true"
            SettingsPager-PageSize="30"
            SettingsBehavior-AllowFocusedRow="true">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="id" Caption="ID" Width="60" />
                <dx:GridViewDataTextColumn FieldName="username" Caption="User" Width="120" />
                <dx:GridViewDataTextColumn FieldName="activity" Caption="Activity" Width="300" />
                <dx:GridViewDataTextColumn FieldName="module" Caption="Module" Width="120" />
                <dx:GridViewDataDateColumn FieldName="activity_date" Caption="Date/Time" Width="150">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy HH:mm" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn FieldName="ip_address" Caption="IP Address" Width="120" />
            </Columns>
            <SettingsText EmptyDataRow="No activity log entries found." />
        </dx:ASPxGridView>
    </asp:Panel>

    <!-- Repair Log Grid -->
    <asp:Panel ID="pnlRepair" runat="server">
        <h4 style="margin:16px 0 4px 0; font-size:13px; color:#e65100;">Repair Log</h4>
        <dx:ASPxGridView ID="gridRepair" runat="server" Width="100%" KeyFieldName="id"
            ClientInstanceName="gridRepair"
            Settings-ShowGroupPanel="false" Settings-ShowFilterRow="true"
            SettingsPager-PageSize="30"
            SettingsBehavior-AllowFocusedRow="true">
            <Columns>
                <dx:GridViewDataTextColumn FieldName="id" Caption="ID" Width="60" />
                <dx:GridViewDataTextColumn FieldName="repair_type" Caption="Repair Type" Width="150" />
                <dx:GridViewDataTextColumn FieldName="description" Caption="Description" Width="300" />
                <dx:GridViewDataTextColumn FieldName="performed_by" Caption="Performed By" Width="120" />
                <dx:GridViewDataDateColumn FieldName="repair_date" Caption="Date/Time" Width="150">
                    <PropertiesDateEdit DisplayFormatString="dd MMM yyyy HH:mm" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn FieldName="status" Caption="Status" Width="100" />
            </Columns>
            <SettingsText EmptyDataRow="No repair log entries found." />
        </dx:ASPxGridView>
    </asp:Panel>

    <!-- Summary -->
    <div class="at-summary">
        <strong>Records shown:</strong>
        Activity: <asp:Literal ID="litActivityCount" runat="server" Text="0" /> |
        Repair: <asp:Literal ID="litRepairCount" runat="server" Text="0" />
    </div>
</asp:Content>
