<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="COOPERP_accounts_Default" %>

<%@ Register src="../../UserControls/Accounts/ChartAccounts.ascx" tagname="ChartAccounts" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:ChartAccounts ID="ChartAccounts1" runat="server" />
</asp:Content>

