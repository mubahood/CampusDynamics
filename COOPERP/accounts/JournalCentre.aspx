<%@ Page Title="Journals Centre" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="JournalCentre.aspx.cs" Inherits="COOPERP_accounts_JournalCentre" %>

<%@ Register src="../../UserControls/Accounts/JournalCentre.ascx" tagname="JournalCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:JournalCentre ID="JournalCentre1" runat="server" />
</asp:Content>

