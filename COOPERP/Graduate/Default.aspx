<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Graduate/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="COOPERP_Graduate_Default" %>

<%@ Register src="../../UserControls/Graduate/GraduateStudent.ascx" tagname="GraduateStudent" tagprefix="uc1" %>

<%@ Register src="../../UserControls/Graduate/StudentEditor.ascx" tagname="StudentEditor" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:GraduateStudent ID="GraduateStudent1" runat="server" />
</asp:Content>

