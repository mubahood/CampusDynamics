<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="FeesTracking.aspx.cs" Inherits="COOPERP_accounts_FeesTracking" %>

<%@ Register src="../../UserControls/schools/TermlyClasses.ascx" tagname="TermlyClasses" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:TermlyClasses ID="TermlyClasses1" runat="server" />
</asp:Content>

