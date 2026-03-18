<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="FinancialPeriods.aspx.cs" Inherits="COOPERP_NewScreens_FinancialPeriods" Title="Financial Periods - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .fp-page-intro {
            background: #e3f2fd; border: 1px solid #90caf9; padding: 10px 16px; margin-bottom: 16px;
            font-size: 13px; color: #333;
        }
        .fp-add-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .fp-field { display: flex; flex-direction: column; gap: 4px; }
        .fp-field label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .fp-field input, .fp-field select {
            padding: 5px 8px; border: 1px solid #ccc; font-size: 12px;
        }
        .fp-btn {
            padding: 6px 16px; background: #1976d2; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .fp-btn:hover { background: #1565c0; }
        .fp-btn-danger {
            padding: 4px 10px; background: #c62828; color: #fff; border: none; cursor: pointer;
            font-size: 11px; font-weight: 600;
        }
        .fp-btn-danger:hover { background: #b71c1c; }
        .fp-btn-toggle {
            padding: 4px 10px; background: #388e3c; color: #fff; border: none; cursor: pointer;
            font-size: 11px; font-weight: 600;
        }
        .fp-btn-toggle:hover { background: #2e7d32; }
        .fp-msg {
            padding: 8px 12px; margin-bottom: 12px; font-size: 12px; font-weight: 600;
        }
        .fp-msg-ok { background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; }
        .fp-msg-err { background: #fce4ec; border: 1px solid #ef9a9a; color: #c62828; }

        .fp-status-open {
            display: inline-block; padding: 2px 8px; background: #e8f5e9; color: #2e7d32;
            font-weight: 600; font-size: 11px; border: 1px solid #a5d6a7; border-radius: 3px;
        }
        .fp-status-closed {
            display: inline-block; padding: 2px 8px; background: #fce4ec; color: #c62828;
            font-weight: 600; font-size: 11px; border: 1px solid #ef9a9a; border-radius: 3px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <div class="fp-page-intro">
        <strong>Financial Periods</strong> define the accounting time-frames. Only <em>one period</em> should be open at a time.
        Transactions can only be posted to an open period.
    </div>

    <!-- Message Panel -->
    <asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="fp-msg fp-msg-ok">
        <asp:Literal ID="litMsg" runat="server" />
    </asp:Panel>

    <!-- Add New Period -->
    <div class="fp-add-bar">
        <div class="fp-field">
            <label>Financial Year</label>
            <asp:TextBox ID="txtFinYear" runat="server" placeholder="e.g. 2024/2025" />
        </div>
        <div class="fp-field">
            <label>Start Date</label>
            <asp:TextBox ID="txtPeriodStart" runat="server" TextMode="Date" />
        </div>
        <div class="fp-field">
            <label>End Date</label>
            <asp:TextBox ID="txtPeriodEnd" runat="server" TextMode="Date" />
        </div>
        <div class="fp-field">
            <label>Status</label>
            <asp:DropDownList ID="ddlStatus" runat="server">
                <asp:ListItem Value="Open">Open</asp:ListItem>
                <asp:ListItem Value="Closed">Closed</asp:ListItem>
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnAddPeriod" runat="server" Text="+ Add Period" CssClass="fp-btn" OnClick="btnAddPeriod_Click" />
    </div>

    <!-- Periods Grid -->
    <dx:ASPxGridView ID="gridPeriods" runat="server" Width="100%" KeyFieldName="id"
        ClientInstanceName="gridPeriods"
        Settings-ShowGroupPanel="false"
        SettingsBehavior-AllowFocusedRow="true"
        OnCustomButtonCallback="gridPeriods_CustomButtonCallback">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="id" Caption="ID" Width="60" ReadOnly="true" />
            <dx:GridViewDataTextColumn FieldName="finacial_Year" Caption="Financial Year" Width="150" />
            <dx:GridViewDataDateColumn FieldName="start_date" Caption="Start Date" Width="130">
                <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
            </dx:GridViewDataDateColumn>
            <dx:GridViewDataDateColumn FieldName="end_date" Caption="End Date" Width="130">
                <PropertiesDateEdit DisplayFormatString="dd MMM yyyy" />
            </dx:GridViewDataDateColumn>
            <dx:GridViewDataTextColumn FieldName="status" Caption="Status" Width="100" />
            <dx:GridViewDataTextColumn Caption="Actions" Width="200" UnboundType="String">
                <DataItemTemplate>
                    <dx:ASPxButton ID="btnToggle" runat="server" Text='<%# Eval("status").ToString() == "Open" ? "Close Period" : "Open Period" %>'
                        CssClass='<%# Eval("status").ToString() == "Open" ? "fp-btn-danger" : "fp-btn-toggle" %>'
                        AutoPostBack="true" OnClick="btnToggle_Click"
                        CommandArgument='<%# Eval("id") %>' />
                    &nbsp;
                    <dx:ASPxButton ID="btnDelete" runat="server" Text="Delete"
                        CssClass="fp-btn-danger" AutoPostBack="true" OnClick="btnDelete_Click"
                        CommandArgument='<%# Eval("id") %>' />
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
        </Columns>
        <SettingsText EmptyDataRow="No financial periods defined." />
    </dx:ASPxGridView>
</asp:Content>
