<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="AccountLedger.aspx.cs" Inherits="COOPERP_accounts_AccountLedger" %>

<%@ Register src="../../UserControls/Accounts/JournalCentre.ascx" tagname="JournalCentre" tagprefix="uc1" %>
<%@ Register src="../../UserControls/Accounts/LedgersCentre.ascx" tagname="LedgersCentre" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc2:LedgersCentre ID="LedgersCentre1" runat="server" />
</asp:Content>

