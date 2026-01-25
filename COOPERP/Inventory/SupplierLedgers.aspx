<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Inventory/MasterPage.master" AutoEventWireup="true" CodeFile="SupplierLedgers.aspx.cs" Inherits="COOPERP_Inventory_SupplierLedgers" %>

<%@ Register src="../../UserControls/Inventory/SupplierLedgers.ascx" tagname="SupplierLedgers" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:SupplierLedgers ID="SupplierLedgers1" runat="server" />
</asp:Content>

