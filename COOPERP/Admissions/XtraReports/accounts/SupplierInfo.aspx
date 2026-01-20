<%@ Page Title="Cooperative ERP: Supplier Information" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="SupplierInfo.aspx.cs" Inherits="COOPERP_accounts_SupplierInfo" %>

<%@ Register src="../../UserControls/Accounts/SupplierManager.ascx" tagname="SupplierManager" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:SupplierManager ID="SupplierManager1" runat="server" />
</asp:Content>

