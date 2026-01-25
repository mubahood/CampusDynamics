<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="DocumentCentre.aspx.cs" Inherits="COOPERP_accounts_DocumentCentre" %>

<%@ Register src="../../UserControls/Accounts/DocumentCentre.ascx" tagname="DocumentCentre" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:DocumentCentre ID="DocumentCentre1" runat="server" />
</asp:Content>

