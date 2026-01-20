<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Admissions/MasterPage.master" AutoEventWireup="true" CodeFile="Documents.aspx.cs" Inherits="COOPERP_Admissions_Documents" %>

<%@ Register src="../../UserControls/Admissions/documents.ascx" tagname="documents" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:documents ID="documents1" runat="server" />
</asp:Content>

