<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Faculty/MasterPage.master" AutoEventWireup="true" CodeFile="CourseInfo.aspx.cs" Inherits="COOPERP_Faculty_CourseInfo" %>

<%@ Register src="../../UserControls/Faculty/Courses.ascx" tagname="Courses" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:Courses ID="Courses1" runat="server" />
</asp:Content>

