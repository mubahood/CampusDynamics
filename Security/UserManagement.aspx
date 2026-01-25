<%@ Page Title="" Language="C#" MasterPageFile="MasterPage.master" AutoEventWireup="true" CodeFile="UserManagement.aspx.cs" Inherits="Security_UserManagement" %>

<%@ Register src="../UserControls/UserManagement.ascx" tagname="UserManagement" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:UserManagement ID="UserManagement1" runat="server" />
</asp:Content>

