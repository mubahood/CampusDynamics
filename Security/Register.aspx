<%@ Page Title="" Language="C#" MasterPageFile="MasterPage.master" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="Security_Register" %>

<%@ Register src="../UserControls/Security/UserRegister.ascx" tagname="UserRegister" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:UserRegister ID="UserRegister1" runat="server" />
</asp:Content>

