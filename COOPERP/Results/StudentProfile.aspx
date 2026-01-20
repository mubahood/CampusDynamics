<%@ Page Title="" Language="C#" MasterPageFile="~/COOPERP/Results/MasterPage.master" AutoEventWireup="true" CodeFile="StudentProfile.aspx.cs" Inherits="COOPERP_Results_StudentProfile" %>

<%@ Register src="../../UserControls/StudentInfo/BioData.ascx" tagname="BioData" tagprefix="uc1" %>
<%@ Register src="../../UserControls/StudentInfo/StudentEditor.ascx" tagname="StudentEditor" tagprefix="uc2" %>

<%@ Register src="../../UserControls/Results/StudentEditor.ascx" tagname="StudentEditor" tagprefix="uc3" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <uc3:StudentEditor ID="StudentEditor1" runat="server" />
</asp:Content>

