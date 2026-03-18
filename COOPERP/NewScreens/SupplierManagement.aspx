<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="SupplierManagement.aspx.cs" Inherits="COOPERP_NewScreens_SupplierManagement" Title="Supplier Management - Campus Dynamics" %>
<%@ Register assembly="DevExpress.Web.v16.1, Version=16.1.4.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" namespace="DevExpress.Web" tagprefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        .sm-page-intro {
            background: #e3f2fd; border: 1px solid #90caf9; padding: 10px 16px; margin-bottom: 16px;
            font-size: 13px; color: #333;
        }
        .sm-add-bar {
            background: #fff; border: 1px solid #e0e0e0; padding: 12px 16px; margin-bottom: 16px;
            display: flex; align-items: flex-end; gap: 12px; flex-wrap: wrap;
        }
        .sm-field { display: flex; flex-direction: column; gap: 4px; }
        .sm-field label { font-size: 10px; font-weight: 600; color: #666; text-transform: uppercase; }
        .sm-field input {
            padding: 5px 8px; border: 1px solid #ccc; font-size: 12px;
        }
        .sm-btn {
            padding: 6px 16px; background: #1976d2; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .sm-btn:hover { background: #1565c0; }
        .sm-btn-cancel {
            padding: 6px 16px; background: #757575; color: #fff; border: none; cursor: pointer;
            font-size: 12px; font-weight: 600; height: 28px;
        }
        .sm-btn-cancel:hover { background: #616161; }
        .sm-btn-danger {
            padding: 4px 10px; background: #c62828; color: #fff; border: none; cursor: pointer;
            font-size: 11px; font-weight: 600;
        }
        .sm-btn-danger:hover { background: #b71c1c; }
        .sm-btn-edit {
            padding: 4px 10px; background: #1976d2; color: #fff; border: none; cursor: pointer;
            font-size: 11px; font-weight: 600;
        }
        .sm-btn-edit:hover { background: #1565c0; }
        .sm-msg {
            padding: 8px 12px; margin-bottom: 12px; font-size: 12px; font-weight: 600;
        }
        .sm-msg-ok { background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; }
        .sm-msg-err { background: #fce4ec; border: 1px solid #ef9a9a; color: #c62828; }

        .sm-summary {
            background: #e3f2fd; border: 1px solid #90caf9; padding: 8px 16px; margin-top: 12px;
            font-size: 12px; color: #333;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <div class="sm-page-intro">
        <strong>Supplier Management</strong> — Maintain a register of all suppliers / vendors used in payment vouchers.
    </div>

    <!-- Message Panel -->
    <asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="sm-msg sm-msg-ok">
        <asp:Literal ID="litMsg" runat="server" />
    </asp:Panel>

    <!-- Add / Edit Bar -->
    <div class="sm-add-bar">
        <asp:HiddenField ID="hdnEditId" runat="server" Value="" />
        <div class="sm-field">
            <label>Supplier Name</label>
            <asp:TextBox ID="txtSupplierName" runat="server" placeholder="Company / Person name" Width="220" />
        </div>
        <div class="sm-field">
            <label>Address</label>
            <asp:TextBox ID="txtSupplierAddress" runat="server" placeholder="Physical / Postal address" Width="250" />
        </div>
        <div class="sm-field">
            <label>Phone</label>
            <asp:TextBox ID="txtSupplierPhone" runat="server" placeholder="Phone / Mobile" Width="150" />
        </div>
        <asp:Button ID="btnSave" runat="server" Text="+ Add Supplier" CssClass="sm-btn" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="sm-btn-cancel" OnClick="btnCancel_Click" Visible="false" />
    </div>

    <!-- Suppliers Grid -->
    <dx:ASPxGridView ID="gridSuppliers" runat="server" Width="100%" KeyFieldName="supplierID"
        ClientInstanceName="gridSuppliers"
        Settings-ShowGroupPanel="false" Settings-ShowFilterRow="true"
        SettingsPager-PageSize="25"
        SettingsBehavior-AllowFocusedRow="true">
        <Columns>
            <dx:GridViewDataTextColumn FieldName="supplierID" Caption="ID" Width="60" />
            <dx:GridViewDataTextColumn FieldName="supplierName" Caption="Supplier Name" Width="250" />
            <dx:GridViewDataTextColumn FieldName="supplierAdress" Caption="Address" Width="250" />
            <dx:GridViewDataTextColumn FieldName="supplierPhone" Caption="Phone" Width="140" />
            <dx:GridViewDataTextColumn Caption="Actions" Width="150" UnboundType="String">
                <DataItemTemplate>
                    <dx:ASPxButton ID="btnEdit" runat="server" Text="Edit"
                        CssClass="sm-btn-edit" AutoPostBack="true" OnClick="btnEdit_Click"
                        CommandArgument='<%# Eval("supplierID") + "|" + Eval("supplierName") + "|" + Eval("supplierAdress") + "|" + Eval("supplierPhone") %>' />
                    &nbsp;
                    <dx:ASPxButton ID="btnDelete" runat="server" Text="Delete"
                        CssClass="sm-btn-danger" AutoPostBack="true" OnClick="btnDelete_Click"
                        CommandArgument='<%# Eval("supplierID") %>' />
                </DataItemTemplate>
            </dx:GridViewDataTextColumn>
        </Columns>
        <SettingsText EmptyDataRow="No suppliers registered." />
    </dx:ASPxGridView>

    <div class="sm-summary">
        <strong>Total Suppliers:</strong> <asp:Literal ID="litSupplierCount" runat="server" Text="0" />
    </div>
</asp:Content>
