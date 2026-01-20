<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/accounts/MasterPage.master" AutoEventWireup="true" CodeFile="GLDrillDown.aspx.cs" Inherits="COOPERP_accounts_GLDrillDown" %>

<%@ Register src="../../UserControls/Accounts/GLDrillDown.ascx" tagname="GLDrillDown" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:GLDrillDown ID="GLDrillDown1" runat="server" />
</asp:Content>

