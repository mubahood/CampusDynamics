<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="AccountingPeriod.aspx.cs" Inherits="COOPERP_accounts_Default2" %>

<%@ Register src="../../UserControls/Accounts/AccountingPeriods.ascx" tagname="AccountingPeriods" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:AccountingPeriods ID="AccountingPeriods1" runat="server" />
</asp:Content>

