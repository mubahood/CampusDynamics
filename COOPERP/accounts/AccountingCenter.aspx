<%@ Page  Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="AccountingCenter.aspx.cs" Inherits="COOPERP_accounts_AccountingCenter" %>

<%@ Register src="../../UserControls/Accounts/ChartAccounts.ascx" tagname="ChartAccounts" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <dx:ASPxPanel ID="rp_accounting" runat="server" Width="100%">
    </dx:ASPxPanel>
</asp:Content>

