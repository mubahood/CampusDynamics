<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/StudentInfo/MasterPage.master" AutoEventWireup="true" CodeFile="StudentDocuments.aspx.cs" Inherits="COOPERP_StudentInfo_StudentDocuments" %>

<%@ Register src="../../UserControls/StudentInfo/StudentDocuments.ascx" tagname="StudentDocuments" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:StudentDocuments ID="StudentDocuments1" runat="server" />
</asp:Content>

