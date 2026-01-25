<%@ Page Title="Coop ERP: Ledger Center" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="LedgeerCenter.aspx.cs" Inherits="COOPERP_accounts_LedgeerCenter" %>

<%@ Register src="../../UserControls/Accounts/LedgersCentre.ascx" tagname="LedgersCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:LedgersCentre ID="LedgersCentre1" runat="server" />
</asp:Content>

