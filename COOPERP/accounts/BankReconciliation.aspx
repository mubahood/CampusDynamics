<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="BankReconciliation.aspx.cs" Inherits="COOPERP_accounts_BankReconciliation" %>

<%@ Register src="../../UserControls/Accounts/BankReconciliation.ascx" tagname="BankReconciliation" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:BankReconciliation ID="BankReconciliation1" runat="server" />
</asp:Content>

