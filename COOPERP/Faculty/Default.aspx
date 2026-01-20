<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Faculty/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="COOPERP_Faculty_Default" %>

<%@ Register src="../../UserControls/Faculty/FacultyInfo.ascx" tagname="FacultyInfo" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:FacultyInfo ID="FacultyInfo1" runat="server" />
</asp:Content>

