<%@ Page Title="" Language="C#" MasterPageFile="MasterPage.master" AutoEventWireup="true" CodeFile="MyApplications.aspx.cs" Inherits="MyApplications" %>

<%@ Register src="UserControls/Security/SystemApplications.ascx" tagname="SystemApplications" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:SystemApplications ID="SystemApplications1" runat="server" />
</asp:Content>

