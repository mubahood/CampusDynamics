<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="CashBook.aspx.cs" Inherits="COOPERP_accounts_CashBook" %>

<%@ Register src="../../UserControls/Accounts/CashBook.ascx" tagname="CashBook" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:CashBook ID="CashBook1" runat="server" />
</asp:Content>

