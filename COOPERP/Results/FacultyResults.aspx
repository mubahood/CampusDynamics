<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="FacultyResults.aspx.cs" Inherits="COOPERP_Results_FacultyResults" %>

<%@ Register src="../../UserControls/Results/FacultyExamResults.ascx" tagname="FacultyExamResults" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc1:FacultyExamResults ID="FacultyExamResults1" runat="server" />
</asp:Content>

