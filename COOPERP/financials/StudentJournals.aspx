<%@ Page Title="" Language="VB" MasterPageFile="~/COOPERP/financials/MasterPage.master" AutoEventWireup="false" CodeFile="StudentJournals.aspx.vb" Inherits="UserControls_financials_StudentJournals" %>

<%@ Register src="../../UserControls/Accounts/JournalCentre.ascx" tagname="JournalCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:JournalCentre ID="JournalCentre1" runat="server" />
</asp:Content>

